const express = require('express');
const router = express.Router();
const { getConnection } = require('../config/database');
const { asyncHandler } = require('../middleware/errorHandler');

// GET - جلب جميع حركات المخزون
router.get('/', asyncHandler(async (req, res) => {
  const pool = await getConnection();
  const result = await pool.request().query(`
    SELECT it.*, p.Name as ProductName, w.Name as WarehouseName
    FROM InventoryTransactions it
    JOIN Products p ON it.ProductID = p.ProductID
    LEFT JOIN Warehouses w ON it.WarehouseID = w.WarehouseID
    ORDER BY it.CreatedAt DESC
  `);
  res.json(result.recordset);
}));

// GET - جلب حركات مخزون منتج معين
router.get('/product/:productId', asyncHandler(async (req, res) => {
  const { productId } = req.params;
  const pool = await getConnection();
  const result = await pool.request()
    .input('productId', productId)
    .query(`
      SELECT it.*, w.Name as WarehouseName
      FROM InventoryTransactions it
      LEFT JOIN Warehouses w ON it.WarehouseID = w.WarehouseID
      WHERE it.ProductID = @productId
      ORDER BY it.CreatedAt DESC
    `);
  res.json(result.recordset);
}));

// GET - جلب حركات مستودع معين
router.get('/warehouse/:warehouseId', asyncHandler(async (req, res) => {
  const { warehouseId } = req.params;
  const pool = await getConnection();
  const result = await pool.request()
    .input('warehouseId', warehouseId)
    .query(`
      SELECT it.*, p.Name as ProductName
      FROM InventoryTransactions it
      JOIN Products p ON it.ProductID = p.ProductID
      WHERE it.WarehouseID = @warehouseId
      ORDER BY it.CreatedAt DESC
    `);
  res.json(result.recordset);
}));

// POST - إضافة حركة مخزون جديدة
router.post('/', asyncHandler(async (req, res) => {
  const { WarehouseID, ProductID, TransactionType, Quantity, ReferenceType, ReferenceID, Notes } = req.body;
  const pool = await getConnection();
  
  const transaction = pool.transaction();
  await transaction.begin();
  
  try {
    // إضافة الحركة
    const result = await transaction.request()
      .input('WarehouseID', WarehouseID)
      .input('ProductID', ProductID)
      .input('TransactionType', TransactionType)
      .input('Quantity', Quantity)
      .input('ReferenceType', ReferenceType)
      .input('ReferenceID', ReferenceID)
      .input('Notes', Notes)
      .query(`
        INSERT INTO InventoryTransactions 
        (WarehouseID, ProductID, TransactionType, Quantity, ReferenceType, ReferenceID, Notes)
        OUTPUT INSERTED.*
        VALUES (@WarehouseID, @ProductID, @TransactionType, @Quantity, @ReferenceType, @ReferenceID, @Notes)
      `);
    
    // تحديث مخزون المستودع
    if (WarehouseID) {
      const quantityChange = TransactionType === 'IN' ? Quantity : -Quantity;
      
      await transaction.request()
        .input('WarehouseID', WarehouseID)
        .input('ProductID', ProductID)
        .input('Quantity', quantityChange)
        .query(`
          IF EXISTS (SELECT 1 FROM WarehouseStock WHERE WarehouseID = @WarehouseID AND ProductID = @ProductID)
            UPDATE WarehouseStock 
            SET Quantity = Quantity + @Quantity, LastUpdated = GETDATE()
            WHERE WarehouseID = @WarehouseID AND ProductID = @ProductID
          ELSE
            INSERT INTO WarehouseStock (WarehouseID, ProductID, Quantity)
            VALUES (@WarehouseID, @ProductID, @Quantity)
        `);
    }
    
    await transaction.commit();
    res.status(201).json(result.recordset[0]);
  } catch (error) {
    await transaction.rollback();
    throw error;
  }
}));

module.exports = router;

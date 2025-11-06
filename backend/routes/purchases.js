const express = require('express');
const router = express.Router();
const { getConnection } = require('../config/database');
const { asyncHandler } = require('../middleware/errorHandler');

// GET - جلب جميع المشتريات
router.get('/', asyncHandler(async (req, res) => {
  const pool = await getConnection();
  const result = await pool.request().query(`
    SELECT p.*, s.Name as SupplierName 
    FROM Purchases p
    LEFT JOIN Suppliers s ON p.SupplierID = s.SupplierID
    ORDER BY p.PurchaseDate DESC
  `);
  res.json(result.recordset);
}));

// GET - جلب مشترى واحد مع التفاصيل
router.get('/:id', asyncHandler(async (req, res) => {
  const { id } = req.params;
  const pool = await getConnection();
  
  // جلب بيانات المشترى
  const purchase = await pool.request()
    .input('id', id)
    .query('SELECT * FROM Purchases WHERE PurchaseID = @id');
  
  if (purchase.recordset.length === 0) {
    return res.status(404).json({ error: 'المشترى غير موجود' });
  }
  
  // جلب عناصر المشترى
  const items = await pool.request()
    .input('id', id)
    .query(`
      SELECT pi.*, p.Name as ProductName 
      FROM PurchaseItems pi
      JOIN Products p ON pi.ProductID = p.ProductID
      WHERE pi.PurchaseID = @id
    `);
  
  res.json({
    ...purchase.recordset[0],
    items: items.recordset
  });
}));

// POST - إضافة مشترى جديد
router.post('/', asyncHandler(async (req, res) => {
  const { SupplierID, PurchaseDate, TotalAmount, PaidAmount, Notes, Items } = req.body;
  const pool = await getConnection();
  
  const transaction = pool.transaction();
  await transaction.begin();
  
  try {
    // إضافة المشترى
    const result = await transaction.request()
      .input('SupplierID', SupplierID)
      .input('PurchaseDate', PurchaseDate || new Date())
      .input('TotalAmount', TotalAmount || 0)
      .input('PaidAmount', PaidAmount || 0)
      .input('Notes', Notes)
      .query(`
        INSERT INTO Purchases (SupplierID, PurchaseDate, TotalAmount, PaidAmount, Notes)
        OUTPUT INSERTED.*
        VALUES (@SupplierID, @PurchaseDate, @TotalAmount, @PaidAmount, @Notes)
      `);
    
    const purchaseId = result.recordset[0].PurchaseID;
    
    // إضافة عناصر المشترى
    if (Items && Items.length > 0) {
      for (const item of Items) {
        await transaction.request()
          .input('PurchaseID', purchaseId)
          .input('ProductID', item.ProductID)
          .input('Quantity', item.Quantity)
          .input('UnitPrice', item.UnitPrice)
          .input('TotalPrice', item.Quantity * item.UnitPrice)
          .query(`
            INSERT INTO PurchaseItems (PurchaseID, ProductID, Quantity, UnitPrice, TotalPrice)
            VALUES (@PurchaseID, @ProductID, @Quantity, @UnitPrice, @TotalPrice)
          `);
        
        // تحديث مخزون المنتج
        await transaction.request()
          .input('ProductID', item.ProductID)
          .input('Quantity', item.Quantity)
          .query(`
            UPDATE Products 
            SET Stock = Stock + @Quantity 
            WHERE ProductID = @ProductID
          `);
      }
    }
    
    await transaction.commit();
    res.status(201).json(result.recordset[0]);
  } catch (error) {
    await transaction.rollback();
    throw error;
  }
}));

// PUT - تحديث مشترى
router.put('/:id', asyncHandler(async (req, res) => {
  const { id } = req.params;
  const { SupplierID, TotalAmount, PaidAmount, Notes } = req.body;
  const pool = await getConnection();
  
  const result = await pool.request()
    .input('id', id)
    .input('SupplierID', SupplierID)
    .input('TotalAmount', TotalAmount)
    .input('PaidAmount', PaidAmount)
    .input('Notes', Notes)
    .query(`
      UPDATE Purchases 
      SET SupplierID = @SupplierID,
          TotalAmount = @TotalAmount,
          PaidAmount = @PaidAmount,
          Notes = @Notes
      WHERE PurchaseID = @id
    `);
  
  if (result.rowsAffected[0] === 0) {
    return res.status(404).json({ error: 'المشترى غير موجود' });
  }
  
  res.json({ message: 'تم تحديث المشترى بنجاح' });
}));

// DELETE - حذف مشترى
router.delete('/:id', asyncHandler(async (req, res) => {
  const { id } = req.params;
  const pool = await getConnection();
  
  const result = await pool.request()
    .input('id', id)
    .query('DELETE FROM Purchases WHERE PurchaseID = @id');
  
  if (result.rowsAffected[0] === 0) {
    return res.status(404).json({ error: 'المشترى غير موجود' });
  }
  
  res.json({ message: 'تم حذف المشترى بنجاح' });
}));

module.exports = router;

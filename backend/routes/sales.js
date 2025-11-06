const express = require('express');
const router = express.Router();
const { getConnection, sql } = require('../config/database');

// Get all sales
router.get('/', async (req, res) => {
  try {
    const pool = await getConnection();
    const result = await pool.request().query(`
      SELECT s.*, c.Name as CustomerName 
      FROM Sales s
      LEFT JOIN Customers c ON s.CustomerID = c.CustomerID
      ORDER BY s.SaleID DESC
    `);
    res.json(result.recordset);
  } catch (err) {
    console.error('Error fetching sales:', err);
    res.status(500).json({ error: err.message });
  }
});

// Get sale by ID with items
router.get('/:id', async (req, res) => {
  try {
    const pool = await getConnection();
    
    // Get sale header
    const saleResult = await pool.request()
      .input('id', sql.Int, req.params.id)
      .query(`
        SELECT s.*, c.Name as CustomerName 
        FROM Sales s
        LEFT JOIN Customers c ON s.CustomerID = c.CustomerID
        WHERE s.SaleID = @id
      `);
    
    if (saleResult.recordset.length === 0) {
      return res.status(404).json({ error: 'Sale not found' });
    }
    
    // Get sale items
    const itemsResult = await pool.request()
      .input('id', sql.Int, req.params.id)
      .query(`
        SELECT si.*, p.Name as ProductName, p.Barcode
        FROM SaleItems si
        JOIN Products p ON si.ProductID = p.ProductID
        WHERE si.SaleID = @id
      `);
    
    const sale = saleResult.recordset[0];
    sale.items = itemsResult.recordset;
    
    res.json(sale);
  } catch (err) {
    console.error('Error fetching sale:', err);
    res.status(500).json({ error: err.message });
  }
});

// Create new sale
router.post('/', async (req, res) => {
  const transaction = new sql.Transaction();
  try {
    const { CustomerID, TotalAmount, PaidAmount, Discount, PaymentMethod, Notes, Items } = req.body;
    const pool = await getConnection();
    
    await transaction.begin(pool);
    
    // Insert sale header
    const saleResult = await transaction.request()
      .input('CustomerID', sql.Int, CustomerID || null)
      .input('TotalAmount', sql.Decimal(18, 2), TotalAmount)
      .input('PaidAmount', sql.Decimal(18, 2), PaidAmount || 0)
      .input('Discount', sql.Decimal(18, 2), Discount || 0)
      .input('PaymentMethod', sql.NVarChar(50), PaymentMethod || 'نقدي')
      .input('Notes', sql.NVarChar(sql.MAX), Notes || null)
      .query(`
        INSERT INTO Sales (CustomerID, SaleDate, TotalAmount, PaidAmount, Discount, PaymentMethod, Notes)
        OUTPUT INSERTED.SaleID
        VALUES (@CustomerID, GETDATE(), @TotalAmount, @PaidAmount, @Discount, @PaymentMethod, @Notes)
      `);
    
    const saleId = saleResult.recordset[0].SaleID;
    
    // Insert sale items
    for (const item of Items) {
      await transaction.request()
        .input('SaleID', sql.Int, saleId)
        .input('ProductID', sql.Int, item.ProductID)
        .input('Quantity', sql.Decimal(18, 2), item.Quantity)
        .input('UnitPrice', sql.Decimal(18, 2), item.UnitPrice)
        .input('TotalPrice', sql.Decimal(18, 2), item.TotalPrice)
        .query(`
          INSERT INTO SaleItems (SaleID, ProductID, Quantity, UnitPrice, TotalPrice)
          VALUES (@SaleID, @ProductID, @Quantity, @UnitPrice, @TotalPrice)
        `);
      
      // Update product stock
      await transaction.request()
        .input('ProductID', sql.Int, item.ProductID)
        .input('Quantity', sql.Decimal(18, 2), item.Quantity)
        .query(`
          UPDATE Products 
          SET Stock = Stock - @Quantity, UpdatedAt = GETDATE()
          WHERE ProductID = @ProductID
        `);
    }
    
    await transaction.commit();
    res.status(201).json({ id: saleId, message: 'Sale created successfully' });
    
  } catch (err) {
    await transaction.rollback();
    console.error('Error creating sale:', err);
    res.status(500).json({ error: err.message });
  }
});

// Delete sale
router.delete('/:id', async (req, res) => {
  const transaction = new sql.Transaction();
  try {
    const pool = await getConnection();
    await transaction.begin(pool);
    
    // Get sale items to restore stock
    const itemsResult = await transaction.request()
      .input('id', sql.Int, req.params.id)
      .query('SELECT ProductID, Quantity FROM SaleItems WHERE SaleID = @id');
    
    // Restore product stock
    for (const item of itemsResult.recordset) {
      await transaction.request()
        .input('ProductID', sql.Int, item.ProductID)
        .input('Quantity', sql.Decimal(18, 2), item.Quantity)
        .query(`
          UPDATE Products 
          SET Stock = Stock + @Quantity, UpdatedAt = GETDATE()
          WHERE ProductID = @ProductID
        `);
    }
    
    // Delete sale items
    await transaction.request()
      .input('id', sql.Int, req.params.id)
      .query('DELETE FROM SaleItems WHERE SaleID = @id');
    
    // Delete sale
    await transaction.request()
      .input('id', sql.Int, req.params.id)
      .query('DELETE FROM Sales WHERE SaleID = @id');
    
    await transaction.commit();
    res.json({ message: 'Sale deleted successfully' });
    
  } catch (err) {
    await transaction.rollback();
    console.error('Error deleting sale:', err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

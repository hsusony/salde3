const express = require('express');
const router = express.Router();
const { getConnection, sql } = require('../config/database');

// Get all sales
router.get('/', async (req, res) => {
  try {
    const pool = await getConnection();
    
    // استخدام TOP لتحديد عدد النتائج (تحسين الأداء)
    const limit = req.query.limit ? parseInt(req.query.limit) : 100;
    
    const result = await pool.request().query(`
      SELECT TOP ${limit} 
        s.SaleID, s.InvoiceNumber, s.SaleDate, s.CustomerID,
        s.TotalAmount, s.Discount, s.Tax, s.FinalAmount,
        s.PaymentMethod, s.PaidAmount, s.RemainingAmount,
        s.Status, s.Notes, s.CreatedAt, s.UpdatedAt,
        c.Name as CustomerName 
      FROM Sales s WITH (NOLOCK)
      LEFT JOIN Customers c WITH (NOLOCK) ON s.CustomerID = c.CustomerID
      ORDER BY s.SaleID DESC
    `);
    
    // جلب الأصناف لكل فاتورة
    for (const sale of result.recordset) {
      const itemsResult = await pool.request()
        .input('saleId', sql.Int, sale.SaleID)
        .query(`
          SELECT 
            si.SaleItemID as id,
            si.SaleID as sale_id,
            si.ProductID as product_id,
            si.Quantity as quantity,
            si.UnitPrice as unit_price,
            si.TotalPrice as total_price,
            p.Name as product_name,
            p.Barcode as product_barcode
          FROM SaleItems si WITH (NOLOCK)
          JOIN Products p WITH (NOLOCK) ON si.ProductID = p.ProductID
          WHERE si.SaleID = @saleId
        `);
      sale.items = itemsResult.recordset;
    }
    
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
  let transaction;
  try {
    const { CustomerID, TotalAmount, PaidAmount, Discount, Tax, PaymentMethod, Notes, Items } = req.body;
    const pool = await getConnection();
    
    // حساب المبلغ النهائي
    const discountAmount = parseFloat(Discount || 0);
    const taxAmount = parseFloat(Tax || 0);
    const totalAmount = parseFloat(TotalAmount || 0);
    const finalAmount = totalAmount - discountAmount + taxAmount;
    const paidAmount = parseFloat(PaidAmount || 0);
    const remainingAmount = finalAmount - paidAmount;
    
    transaction = new sql.Transaction(pool);
    await transaction.begin();
    
    // Insert sale header with FinalAmount
    const saleResult = await transaction.request()
      .input('CustomerID', sql.Int, CustomerID || null)
      .input('TotalAmount', sql.Decimal(18, 2), totalAmount)
      .input('PaidAmount', sql.Decimal(18, 2), paidAmount)
      .input('Discount', sql.Decimal(18, 2), discountAmount)
      .input('Tax', sql.Decimal(18, 2), taxAmount)
      .input('FinalAmount', sql.Decimal(18, 2), finalAmount)
      .input('RemainingAmount', sql.Decimal(18, 2), remainingAmount)
      .input('PaymentMethod', sql.NVarChar(50), PaymentMethod || 'نقدي')
      .input('Notes', sql.NVarChar(sql.MAX), Notes || null)
      .query(`
        INSERT INTO Sales (CustomerID, SaleDate, TotalAmount, PaidAmount, Discount, Tax, FinalAmount, RemainingAmount, PaymentMethod, Notes)
        OUTPUT INSERTED.SaleID
        VALUES (@CustomerID, GETDATE(), @TotalAmount, @PaidAmount, @Discount, @Tax, @FinalAmount, @RemainingAmount, @PaymentMethod, @Notes)
      `);
    
    const saleId = saleResult.recordset[0].SaleID;
    
    // Insert sale items and update stock in one batch
    // إنشاء جدول مؤقت لتحديث المخزون دفعة واحدة
    let insertItemsQuery = '';
    let updateStockQuery = 'UPDATE Products SET Stock = CASE ProductID ';
    const productIds = [];
    
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
      
      // بناء استعلام التحديث الجماعي
      updateStockQuery += `WHEN ${item.ProductID} THEN Stock - ${item.Quantity} `;
      productIds.push(item.ProductID);
    }
    
    // تحديث المخزون لجميع المنتجات دفعة واحدة
    if (productIds.length > 0) {
      updateStockQuery += `END, UpdatedAt = GETDATE() WHERE ProductID IN (${productIds.join(',')})`;
      await transaction.request().query(updateStockQuery);
    }
    
    await transaction.commit();
    res.status(201).json({ id: saleId, message: 'Sale created successfully' });
    
  } catch (err) {
    if (transaction) {
      await transaction.rollback();
    }
    console.error('Error creating sale:', err);
    res.status(500).json({ error: err.message });
  }
});

// Delete sale
router.delete('/:id', async (req, res) => {
  let transaction;
  try {
    const pool = await getConnection();
    transaction = new sql.Transaction(pool);
    await transaction.begin();
    
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
    if (transaction) {
      await transaction.rollback();
    }
    console.error('Error deleting sale:', err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

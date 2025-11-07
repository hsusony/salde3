const express = require('express');
const router = express.Router();
const sql = require('mssql');

// Get all quotations
router.get('/', async (req, res, next) => {
  try {
    const pool = await sql.connect();
    
    // Get quotations
    const result = await pool.request().query(`
      SELECT 
        q.*,
        c.Name as customer_name,
        c.Phone as customer_phone
      FROM Quotations q
      LEFT JOIN Customers c ON q.CustomerID = c.CustomerID
      ORDER BY q.CreatedDate DESC
    `);

    // Get items for each quotation
    for (let quotation of result.recordset) {
      const itemsResult = await pool.request()
        .input('quotationId', sql.Int, quotation.QuotationID)
        .query(`
          SELECT 
            qi.*,
            p.Name as product_name,
            p.Barcode as product_barcode
          FROM QuotationItems qi
          INNER JOIN Products p ON qi.ProductID = p.ProductID
          WHERE qi.QuotationID = @quotationId
        `);
      
      quotation.items = itemsResult.recordset;
    }

    res.json(result.recordset);
  } catch (error) {
    next(error);
  }
});

// Get quotation by ID
router.get('/:id', async (req, res, next) => {
  try {
    const pool = await sql.connect();
    
    const result = await pool.request()
      .input('id', sql.Int, req.params.id)
      .query(`
        SELECT 
          q.*,
          c.Name as customer_name,
          c.Phone as customer_phone
        FROM Quotations q
        LEFT JOIN Customers c ON q.CustomerID = c.CustomerID
        WHERE q.QuotationID = @id
      `);

    if (result.recordset.length === 0) {
      return res.status(404).json({ error: 'Quotation not found' });
    }

    const quotation = result.recordset[0];

    // Get items
    const itemsResult = await pool.request()
      .input('quotationId', sql.Int, quotation.QuotationID)
      .query(`
        SELECT 
          qi.*,
          p.Name as product_name,
          p.Barcode as product_barcode
        FROM QuotationItems qi
        INNER JOIN Products p ON qi.ProductID = p.ProductID
        WHERE qi.QuotationID = @quotationId
      `);
    
    quotation.items = itemsResult.recordset;

    res.json(quotation);
  } catch (error) {
    next(error);
  }
});

// Generate quotation number
router.get('/generate/number', async (req, res, next) => {
  try {
    const pool = await sql.connect();
    
    const result = await pool.request().query(`
      SELECT TOP 1 QuotationNumber 
      FROM Quotations 
      ORDER BY QuotationID DESC
    `);

    let nextNumber = 1;
    if (result.recordset.length > 0) {
      const lastNumber = result.recordset[0].QuotationNumber;
      const match = lastNumber.match(/QT-(\d+)/);
      if (match) {
        nextNumber = parseInt(match[1]) + 1;
      }
    }

    const quotationNumber = `QT-${nextNumber.toString().padStart(6, '0')}`;
    res.json({ quotationNumber });
  } catch (error) {
    next(error);
  }
});

// Create new quotation
router.post('/', async (req, res, next) => {
  const transaction = new sql.Transaction();
  
  try {
    const {
      quotationNumber,
      customerId,
      customerName,
      totalAmount,
      discount,
      tax,
      finalAmount,
      validUntil,
      status,
      notes,
      items
    } = req.body;

    if (!quotationNumber || !items || items.length === 0) {
      return res.status(400).json({ 
        error: 'Quotation number and items are required' 
      });
    }

    await transaction.begin();
    const request = new sql.Request(transaction);

    // Insert quotation
    const result = await request
      .input('quotationNumber', sql.NVarChar(50), quotationNumber)
      .input('customerId', sql.Int, customerId || null)
      .input('customerName', sql.NVarChar(100), customerName || null)
      .input('totalAmount', sql.Decimal(10, 2), totalAmount)
      .input('discount', sql.Decimal(10, 2), discount || 0)
      .input('tax', sql.Decimal(10, 2), tax || 0)
      .input('finalAmount', sql.Decimal(10, 2), finalAmount)
      .input('validUntil', sql.DateTime, validUntil)
      .input('status', sql.NVarChar(20), status || 'pending')
      .input('notes', sql.NVarChar(sql.MAX), notes || null)
      .query(`
        INSERT INTO Quotations (
          QuotationNumber, CustomerID, CustomerName, 
          TotalAmount, Discount, Tax, FinalAmount,
          ValidUntil, Status, Notes, CreatedDate
        )
        OUTPUT INSERTED.QuotationID
        VALUES (
          @quotationNumber, @customerId, @customerName,
          @totalAmount, @discount, @tax, @finalAmount,
          @validUntil, @status, @notes, GETDATE()
        )
      `);

    const quotationId = result.recordset[0].QuotationID;

    // Insert items
    for (const item of items) {
      await transaction.request()
        .input('quotationId', sql.Int, quotationId)
        .input('productId', sql.Int, item.productId)
        .input('productName', sql.NVarChar(200), item.productName)
        .input('productBarcode', sql.NVarChar(50), item.productBarcode || null)
        .input('quantity', sql.Int, item.quantity)
        .input('unitPrice', sql.Decimal(10, 2), item.unitPrice)
        .input('totalPrice', sql.Decimal(10, 2), item.totalPrice)
        .input('discount', sql.Decimal(10, 2), item.discount || 0)
        .query(`
          INSERT INTO QuotationItems (
            QuotationID, ProductID, ProductName, ProductBarcode,
            Quantity, UnitPrice, TotalPrice, Discount
          )
          VALUES (
            @quotationId, @productId, @productName, @productBarcode,
            @quantity, @unitPrice, @totalPrice, @discount
          )
        `);
    }

    await transaction.commit();

    res.status(201).json({ 
      message: 'Quotation created successfully',
      quotationId 
    });
  } catch (error) {
    await transaction.rollback();
    next(error);
  }
});

// Update quotation
router.put('/:id', async (req, res, next) => {
  const transaction = new sql.Transaction();
  
  try {
    const {
      quotationNumber,
      customerId,
      customerName,
      totalAmount,
      discount,
      tax,
      finalAmount,
      validUntil,
      status,
      notes,
      items
    } = req.body;

    if (!items || items.length === 0) {
      return res.status(400).json({ error: 'Items are required' });
    }

    await transaction.begin();

    // Update quotation
    await transaction.request()
      .input('id', sql.Int, req.params.id)
      .input('quotationNumber', sql.NVarChar(50), quotationNumber)
      .input('customerId', sql.Int, customerId || null)
      .input('customerName', sql.NVarChar(100), customerName || null)
      .input('totalAmount', sql.Decimal(10, 2), totalAmount)
      .input('discount', sql.Decimal(10, 2), discount || 0)
      .input('tax', sql.Decimal(10, 2), tax || 0)
      .input('finalAmount', sql.Decimal(10, 2), finalAmount)
      .input('validUntil', sql.DateTime, validUntil)
      .input('status', sql.NVarChar(20), status || 'pending')
      .input('notes', sql.NVarChar(sql.MAX), notes || null)
      .query(`
        UPDATE Quotations 
        SET 
          QuotationNumber = @quotationNumber,
          CustomerID = @customerId,
          CustomerName = @customerName,
          TotalAmount = @totalAmount,
          Discount = @discount,
          Tax = @tax,
          FinalAmount = @finalAmount,
          ValidUntil = @validUntil,
          Status = @status,
          Notes = @notes
        WHERE QuotationID = @id
      `);

    // Delete old items
    await transaction.request()
      .input('quotationId', sql.Int, req.params.id)
      .query('DELETE FROM QuotationItems WHERE QuotationID = @quotationId');

    // Insert new items
    for (const item of items) {
      await transaction.request()
        .input('quotationId', sql.Int, req.params.id)
        .input('productId', sql.Int, item.productId)
        .input('productName', sql.NVarChar(200), item.productName)
        .input('productBarcode', sql.NVarChar(50), item.productBarcode || null)
        .input('quantity', sql.Int, item.quantity)
        .input('unitPrice', sql.Decimal(10, 2), item.unitPrice)
        .input('totalPrice', sql.Decimal(10, 2), item.totalPrice)
        .input('discount', sql.Decimal(10, 2), item.discount || 0)
        .query(`
          INSERT INTO QuotationItems (
            QuotationID, ProductID, ProductName, ProductBarcode,
            Quantity, UnitPrice, TotalPrice, Discount
          )
          VALUES (
            @quotationId, @productId, @productName, @productBarcode,
            @quantity, @unitPrice, @totalPrice, @discount
          )
        `);
    }

    await transaction.commit();

    res.json({ message: 'Quotation updated successfully' });
  } catch (error) {
    await transaction.rollback();
    next(error);
  }
});

// Update quotation status
router.patch('/:id/status', async (req, res, next) => {
  try {
    const { status } = req.body;

    if (!status) {
      return res.status(400).json({ error: 'Status is required' });
    }

    const pool = await sql.connect();
    
    await pool.request()
      .input('id', sql.Int, req.params.id)
      .input('status', sql.NVarChar(20), status)
      .query('UPDATE Quotations SET Status = @status WHERE QuotationID = @id');

    res.json({ message: 'Status updated successfully' });
  } catch (error) {
    next(error);
  }
});

// Delete quotation
router.delete('/:id', async (req, res, next) => {
  const transaction = new sql.Transaction();
  
  try {
    await transaction.begin();

    // Delete items first
    await transaction.request()
      .input('quotationId', sql.Int, req.params.id)
      .query('DELETE FROM QuotationItems WHERE QuotationID = @quotationId');

    // Delete quotation
    await transaction.request()
      .input('id', sql.Int, req.params.id)
      .query('DELETE FROM Quotations WHERE QuotationID = @id');

    await transaction.commit();

    res.json({ message: 'Quotation deleted successfully' });
  } catch (error) {
    await transaction.rollback();
    next(error);
  }
});

// Get quotations by status
router.get('/status/:status', async (req, res, next) => {
  try {
    const pool = await sql.connect();
    
    const result = await pool.request()
      .input('status', sql.NVarChar(20), req.params.status)
      .query(`
        SELECT 
          q.*,
          c.Name as customer_name,
          c.Phone as customer_phone
        FROM Quotations q
        LEFT JOIN Customers c ON q.CustomerID = c.CustomerID
        WHERE q.Status = @status
        ORDER BY q.CreatedDate DESC
      `);

    // Get items for each quotation
    for (let quotation of result.recordset) {
      const itemsResult = await pool.request()
        .input('quotationId', sql.Int, quotation.QuotationID)
        .query(`
          SELECT 
            qi.*,
            p.Name as product_name,
            p.Barcode as product_barcode
          FROM QuotationItems qi
          INNER JOIN Products p ON qi.ProductID = p.ProductID
          WHERE qi.QuotationID = @quotationId
        `);
      
      quotation.items = itemsResult.recordset;
    }

    res.json(result.recordset);
  } catch (error) {
    next(error);
  }
});

module.exports = router;

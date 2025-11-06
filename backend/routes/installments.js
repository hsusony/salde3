const express = require('express');
const router = express.Router();
const { getConnection } = require('../config/database');
const { asyncHandler } = require('../middleware/errorHandler');

// GET - جلب جميع الأقساط
router.get('/', asyncHandler(async (req, res) => {
  const pool = await getConnection();
  const result = await pool.request().query(`
    SELECT i.*, c.Name as CustomerName, c.Phone as CustomerPhone
    FROM Installments i
    JOIN Customers c ON i.CustomerID = c.CustomerID
    ORDER BY i.StartDate DESC
  `);
  res.json(result.recordset);
}));

// GET - جلب قسط واحد مع الدفعات
router.get('/:id', asyncHandler(async (req, res) => {
  const { id } = req.params;
  const pool = await getConnection();
  
  // جلب بيانات القسط
  const installment = await pool.request()
    .input('id', id)
    .query(`
      SELECT i.*, c.Name as CustomerName, c.Phone as CustomerPhone
      FROM Installments i
      JOIN Customers c ON i.CustomerID = c.CustomerID
      WHERE i.InstallmentID = @id
    `);
  
  if (installment.recordset.length === 0) {
    return res.status(404).json({ error: 'القسط غير موجود' });
  }
  
  // جلب الدفعات
  const payments = await pool.request()
    .input('id', id)
    .query(`
      SELECT * FROM InstallmentPayments 
      WHERE InstallmentID = @id 
      ORDER BY PaymentDate DESC
    `);
  
  res.json({
    ...installment.recordset[0],
    payments: payments.recordset
  });
}));

// GET - جلب أقساط عميل معين
router.get('/customer/:customerId', asyncHandler(async (req, res) => {
  const { customerId } = req.params;
  const pool = await getConnection();
  const result = await pool.request()
    .input('customerId', customerId)
    .query(`
      SELECT * FROM Installments 
      WHERE CustomerID = @customerId 
      ORDER BY StartDate DESC
    `);
  res.json(result.recordset);
}));

// POST - إضافة قسط جديد
router.post('/', asyncHandler(async (req, res) => {
  const { CustomerID, TotalAmount, PaidAmount, Notes } = req.body;
  const pool = await getConnection();
  
  const remainingAmount = TotalAmount - (PaidAmount || 0);
  
  const result = await pool.request()
    .input('CustomerID', CustomerID)
    .input('TotalAmount', TotalAmount)
    .input('PaidAmount', PaidAmount || 0)
    .input('RemainingAmount', remainingAmount)
    .input('Notes', Notes)
    .query(`
      INSERT INTO Installments (CustomerID, TotalAmount, PaidAmount, RemainingAmount, Notes)
      OUTPUT INSERTED.*
      VALUES (@CustomerID, @TotalAmount, @PaidAmount, @RemainingAmount, @Notes)
    `);
  
  res.status(201).json(result.recordset[0]);
}));

// POST - إضافة دفعة لقسط
router.post('/:id/payment', asyncHandler(async (req, res) => {
  const { id } = req.params;
  const { Amount, Notes } = req.body;
  const pool = await getConnection();
  
  const transaction = pool.transaction();
  await transaction.begin();
  
  try {
    // إضافة الدفعة
    const payment = await transaction.request()
      .input('InstallmentID', id)
      .input('Amount', Amount)
      .input('Notes', Notes)
      .query(`
        INSERT INTO InstallmentPayments (InstallmentID, Amount, Notes)
        OUTPUT INSERTED.*
        VALUES (@InstallmentID, @Amount, @Notes)
      `);
    
    // تحديث القسط
    await transaction.request()
      .input('id', id)
      .input('Amount', Amount)
      .query(`
        UPDATE Installments 
        SET PaidAmount = PaidAmount + @Amount,
            RemainingAmount = RemainingAmount - @Amount
        WHERE InstallmentID = @id
      `);
    
    await transaction.commit();
    res.status(201).json(payment.recordset[0]);
  } catch (error) {
    await transaction.rollback();
    throw error;
  }
}));

// PUT - تحديث قسط
router.put('/:id', asyncHandler(async (req, res) => {
  const { id } = req.params;
  const { TotalAmount, Notes } = req.body;
  const pool = await getConnection();
  
  const result = await pool.request()
    .input('id', id)
    .input('TotalAmount', TotalAmount)
    .input('Notes', Notes)
    .query(`
      UPDATE Installments 
      SET TotalAmount = @TotalAmount,
          RemainingAmount = @TotalAmount - PaidAmount,
          Notes = @Notes
      WHERE InstallmentID = @id
    `);
  
  if (result.rowsAffected[0] === 0) {
    return res.status(404).json({ error: 'القسط غير موجود' });
  }
  
  res.json({ message: 'تم تحديث القسط بنجاح' });
}));

// DELETE - حذف قسط
router.delete('/:id', asyncHandler(async (req, res) => {
  const { id } = req.params;
  const pool = await getConnection();
  
  // حذف الدفعات أولاً
  await pool.request()
    .input('id', id)
    .query('DELETE FROM InstallmentPayments WHERE InstallmentID = @id');
  
  // حذف القسط
  const result = await pool.request()
    .input('id', id)
    .query('DELETE FROM Installments WHERE InstallmentID = @id');
  
  if (result.rowsAffected[0] === 0) {
    return res.status(404).json({ error: 'القسط غير موجود' });
  }
  
  res.json({ message: 'تم حذف القسط بنجاح' });
}));

module.exports = router;

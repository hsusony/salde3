const express = require('express');
const router = express.Router();
const { getConnection } = require('../config/database');
const { asyncHandler } = require('../middleware/errorHandler');

// GET - جلب جميع الموردين
router.get('/', asyncHandler(async (req, res) => {
  const pool = await getConnection();
  const result = await pool.request().query('SELECT * FROM Suppliers ORDER BY Name');
  res.json(result.recordset);
}));

// GET - جلب مورد واحد
router.get('/:id', asyncHandler(async (req, res) => {
  const { id } = req.params;
  const pool = await getConnection();
  const result = await pool.request()
    .input('id', id)
    .query('SELECT * FROM Suppliers WHERE SupplierID = @id');
  
  if (result.recordset.length === 0) {
    return res.status(404).json({ error: 'المورد غير موجود' });
  }
  
  res.json(result.recordset[0]);
}));

// POST - إضافة مورد جديد
router.post('/', asyncHandler(async (req, res) => {
  const { Name, Phone, Address, Email, Notes } = req.body;
  const pool = await getConnection();
  
  const result = await pool.request()
    .input('Name', Name)
    .input('Phone', Phone)
    .input('Address', Address)
    .input('Email', Email)
    .input('Notes', Notes)
    .query(`
      INSERT INTO Suppliers (Name, Phone, Address, Email, Notes)
      OUTPUT INSERTED.*
      VALUES (@Name, @Phone, @Address, @Email, @Notes)
    `);
  
  res.status(201).json(result.recordset[0]);
}));

// PUT - تحديث مورد
router.put('/:id', asyncHandler(async (req, res) => {
  const { id } = req.params;
  const { Name, Phone, Address, Email, Notes } = req.body;
  const pool = await getConnection();
  
  const result = await pool.request()
    .input('id', id)
    .input('Name', Name)
    .input('Phone', Phone)
    .input('Address', Address)
    .input('Email', Email)
    .input('Notes', Notes)
    .query(`
      UPDATE Suppliers 
      SET Name = @Name, Phone = @Phone, Address = @Address, Email = @Email, Notes = @Notes
      WHERE SupplierID = @id
    `);
  
  if (result.rowsAffected[0] === 0) {
    return res.status(404).json({ error: 'المورد غير موجود' });
  }
  
  res.json({ message: 'تم تحديث المورد بنجاح' });
}));

// DELETE - حذف مورد
router.delete('/:id', asyncHandler(async (req, res) => {
  const { id } = req.params;
  const pool = await getConnection();
  
  const result = await pool.request()
    .input('id', id)
    .query('DELETE FROM Suppliers WHERE SupplierID = @id');
  
  if (result.rowsAffected[0] === 0) {
    return res.status(404).json({ error: 'المورد غير موجود' });
  }
  
  res.json({ message: 'تم حذف المورد بنجاح' });
}));

module.exports = router;

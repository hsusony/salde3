const express = require('express');
const router = express.Router();
const { getConnection } = require('../config/database');
const { asyncHandler } = require('../middleware/errorHandler');

// GET - جلب جميع المستودعات
router.get('/', asyncHandler(async (req, res) => {
  const pool = await getConnection();
  const result = await pool.request().query('SELECT * FROM Warehouses ORDER BY name');
  res.json({ data: result.recordset });
}));

// GET - جلب مستودع واحد
router.get('/:id', asyncHandler(async (req, res) => {
  const { id } = req.params;
  const pool = await getConnection();
  const result = await pool.request()
    .input('id', id)
    .query('SELECT * FROM Warehouses WHERE id = @id');
  
  if (result.recordset.length === 0) {
    return res.status(404).json({ error: 'المستودع غير موجود' });
  }
  
  res.json(result.recordset[0]);
}));

// GET - جلب مخزون مستودع معين
router.get('/:id/stock', asyncHandler(async (req, res) => {
  const { id } = req.params;
  const pool = await getConnection();
  const result = await pool.request()
    .input('id', id)
    .query(`
      SELECT ws.*, p.Name as ProductName, p.Barcode
      FROM WarehouseStock ws
      JOIN Products p ON ws.ProductId = p.ProductID
      WHERE ws.WarehouseId = @id
      ORDER BY p.Name
    `);
  
  res.json(result.recordset);
}));

// POST - إضافة مستودع جديد
router.post('/', asyncHandler(async (req, res) => {
  const { name, location, description, notes } = req.body;
  const pool = await getConnection();
  
  const result = await pool.request()
    .input('name', name)
    .input('location', location || '')
    .input('notes', notes || description || null)
    .query(`
      INSERT INTO Warehouses (name, location, notes, isActive)
      OUTPUT INSERTED.*
      VALUES (@name, @location, @notes, 1)
    `);
  
  res.status(201).json(result.recordset[0]);
}));

// PUT - تحديث مستودع
router.put('/:id', asyncHandler(async (req, res) => {
  const { id } = req.params;
  const { name, location, description, notes } = req.body;
  const pool = await getConnection();
  
  const result = await pool.request()
    .input('id', id)
    .input('name', name)
    .input('location', location || '')
    .input('notes', notes || description || null)
    .query(`
      UPDATE Warehouses 
      SET name = @name, location = @location, notes = @notes, updatedAt = GETDATE()
      WHERE id = @id
    `);
  
  if (result.rowsAffected[0] === 0) {
    return res.status(404).json({ error: 'المستودع غير موجود' });
  }
  
  res.json({ message: 'تم تحديث المستودع بنجاح' });
}));

// DELETE - حذف مستودع
router.delete('/:id', asyncHandler(async (req, res) => {
  const { id } = req.params;
  const pool = await getConnection();
  
  const result = await pool.request()
    .input('id', id)
    .query('DELETE FROM Warehouses WHERE id = @id');
  
  if (result.rowsAffected[0] === 0) {
    return res.status(404).json({ error: 'المستودع غير موجود' });
  }
  
  res.json({ message: 'تم حذف المستودع بنجاح' });
}));

module.exports = router;

const express = require('express');
const router = express.Router();
const { getConnection } = require('../config/database');
const { asyncHandler } = require('../middleware/errorHandler');

// GET - جلب جميع المستودعات
router.get('/', asyncHandler(async (req, res) => {
  const pool = await getConnection();
  const result = await pool.request().query('SELECT * FROM Warehouses ORDER BY Name');
  res.json(result.recordset);
}));

// GET - جلب مستودع واحد
router.get('/:id', asyncHandler(async (req, res) => {
  const { id } = req.params;
  const pool = await getConnection();
  const result = await pool.request()
    .input('id', id)
    .query('SELECT * FROM Warehouses WHERE WarehouseID = @id');
  
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
      JOIN Products p ON ws.ProductID = p.ProductID
      WHERE ws.WarehouseID = @id
      ORDER BY p.Name
    `);
  
  res.json(result.recordset);
}));

// POST - إضافة مستودع جديد
router.post('/', asyncHandler(async (req, res) => {
  const { Name, Location, Description } = req.body;
  const pool = await getConnection();
  
  const result = await pool.request()
    .input('Name', Name)
    .input('Location', Location)
    .input('Description', Description)
    .query(`
      INSERT INTO Warehouses (Name, Location, Description)
      OUTPUT INSERTED.*
      VALUES (@Name, @Location, @Description)
    `);
  
  res.status(201).json(result.recordset[0]);
}));

// PUT - تحديث مستودع
router.put('/:id', asyncHandler(async (req, res) => {
  const { id } = req.params;
  const { Name, Location, Description } = req.body;
  const pool = await getConnection();
  
  const result = await pool.request()
    .input('id', id)
    .input('Name', Name)
    .input('Location', Location)
    .input('Description', Description)
    .query(`
      UPDATE Warehouses 
      SET Name = @Name, Location = @Location, Description = @Description
      WHERE WarehouseID = @id
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
    .query('DELETE FROM Warehouses WHERE WarehouseID = @id');
  
  if (result.rowsAffected[0] === 0) {
    return res.status(404).json({ error: 'المستودع غير موجود' });
  }
  
  res.json({ message: 'تم حذف المستودع بنجاح' });
}));

module.exports = router;

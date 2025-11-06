const express = require('express');
const router = express.Router();
const { getConnection, sql } = require('../config/database');

// Get all customers
router.get('/', async (req, res) => {
  try {
    const pool = await getConnection();
    const result = await pool.request().query('SELECT * FROM Customers ORDER BY CustomerID DESC');
    res.json(result.recordset);
  } catch (err) {
    console.error('Error fetching customers:', err);
    res.status(500).json({ error: err.message });
  }
});

// Get customer by ID
router.get('/:id', async (req, res) => {
  try {
    const pool = await getConnection();
    const result = await pool.request()
      .input('id', sql.Int, req.params.id)
      .query('SELECT * FROM Customers WHERE CustomerID = @id');
    
    if (result.recordset.length === 0) {
      return res.status(404).json({ error: 'Customer not found' });
    }
    res.json(result.recordset[0]);
  } catch (err) {
    console.error('Error fetching customer:', err);
    res.status(500).json({ error: err.message });
  }
});

// Create new customer
router.post('/', async (req, res) => {
  try {
    const { Name, Phone, Address, Email, Notes } = req.body;
    const pool = await getConnection();
    
    const result = await pool.request()
      .input('Name', sql.NVarChar(200), Name)
      .input('Phone', sql.NVarChar(20), Phone || null)
      .input('Address', sql.NVarChar(500), Address || null)
      .input('Email', sql.NVarChar(100), Email || null)
      .input('Notes', sql.NVarChar(sql.MAX), Notes || null)
      .query(`
        INSERT INTO Customers (Name, Phone, Address, Email, Notes, CreatedAt)
        OUTPUT INSERTED.CustomerID
        VALUES (@Name, @Phone, @Address, @Email, @Notes, GETDATE())
      `);
    
    res.status(201).json({ id: result.recordset[0].CustomerID, message: 'Customer created successfully' });
  } catch (err) {
    console.error('Error creating customer:', err);
    res.status(500).json({ error: err.message });
  }
});

// Update customer
router.put('/:id', async (req, res) => {
  try {
    const { Name, Phone, Address, Email, Notes } = req.body;
    const pool = await getConnection();
    
    const result = await pool.request()
      .input('id', sql.Int, req.params.id)
      .input('Name', sql.NVarChar(200), Name)
      .input('Phone', sql.NVarChar(20), Phone)
      .input('Address', sql.NVarChar(500), Address)
      .input('Email', sql.NVarChar(100), Email)
      .input('Notes', sql.NVarChar(sql.MAX), Notes)
      .query(`
        UPDATE Customers SET
          Name = @Name,
          Phone = @Phone,
          Address = @Address,
          Email = @Email,
          Notes = @Notes,
          UpdatedAt = GETDATE()
        WHERE CustomerID = @id
      `);
    
    res.json({ message: 'Customer updated successfully', rowsAffected: result.rowsAffected[0] });
  } catch (err) {
    console.error('Error updating customer:', err);
    res.status(500).json({ error: err.message });
  }
});

// Delete customer
router.delete('/:id', async (req, res) => {
  try {
    const pool = await getConnection();
    const result = await pool.request()
      .input('id', sql.Int, req.params.id)
      .query('DELETE FROM Customers WHERE CustomerID = @id');
    
    res.json({ message: 'Customer deleted successfully', rowsAffected: result.rowsAffected[0] });
  } catch (err) {
    console.error('Error deleting customer:', err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

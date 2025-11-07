const express = require('express');
const router = express.Router();
const { getConnection, sql } = require('../config/database');
const cache = require('../utils/cache');

// Get all products with caching
router.get('/', async (req, res) => {
  try {
    const products = await cache.getOrFetch('products:all', async () => {
      const pool = await getConnection();
      const result = await pool.request().query('SELECT * FROM Products ORDER BY ProductID DESC');
      return result.recordset;
    }, 2 * 60 * 1000); // cache لمدة دقيقتين
    
    res.json(products);
  } catch (err) {
    console.error('Error fetching products:', err);
    res.status(500).json({ error: err.message });
  }
});

// Get product by ID with caching
router.get('/:id', async (req, res) => {
  try {
    const product = await cache.getOrFetch(`product:${req.params.id}`, async () => {
      const pool = await getConnection();
      const result = await pool.request()
        .input('id', sql.Int, req.params.id)
        .query('SELECT * FROM Products WHERE ProductID = @id');
      
      if (result.recordset.length === 0) {
        return null;
      }
      return result.recordset[0];
    }, 5 * 60 * 1000); // cache لمدة 5 دقائق
    
    if (!product) {
      return res.status(404).json({ error: 'Product not found' });
    }
    res.json(product);
  } catch (err) {
    console.error('Error fetching product:', err);
    res.status(500).json({ error: err.message });
  }
});

// Create new product
router.post('/', async (req, res) => {
  try {
    const { Name, Barcode, BuyingPrice, SellingPrice, Stock, MinStock, CategoryID, SupplierID, Description } = req.body;
    const pool = await getConnection();
    
    const result = await pool.request()
      .input('Name', sql.NVarChar(200), Name)
      .input('Barcode', sql.NVarChar(50), Barcode)
      .input('BuyingPrice', sql.Decimal(18, 2), BuyingPrice)
      .input('SellingPrice', sql.Decimal(18, 2), SellingPrice)
      .input('Stock', sql.Decimal(18, 2), Stock || 0)
      .input('MinStock', sql.Decimal(18, 2), MinStock || 0)
      .input('CategoryID', sql.Int, CategoryID || null)
      .input('SupplierID', sql.Int, SupplierID || null)
      .input('Description', sql.NVarChar(sql.MAX), Description || null)
      .query(`
        INSERT INTO Products (Name, Barcode, BuyingPrice, SellingPrice, Stock, MinStock, CategoryID, SupplierID, Description, CreatedAt)
        OUTPUT INSERTED.ProductID
        VALUES (@Name, @Barcode, @BuyingPrice, @SellingPrice, @Stock, @MinStock, @CategoryID, @SupplierID, @Description, GETDATE())
      `);
    
    // حذف الـ cache بعد الإضافة
    cache.delete('products:all');
    
    res.status(201).json({ id: result.recordset[0].ProductID, message: 'Product created successfully' });
  } catch (err) {
    console.error('Error creating product:', err);
    res.status(500).json({ error: err.message });
  }
});

// Update product
router.put('/:id', async (req, res) => {
  try {
    const { Name, Barcode, BuyingPrice, SellingPrice, Stock, MinStock, CategoryID, SupplierID, Description } = req.body;
    const pool = await getConnection();
    
    const result = await pool.request()
      .input('id', sql.Int, req.params.id)
      .input('Name', sql.NVarChar(200), Name)
      .input('Barcode', sql.NVarChar(50), Barcode)
      .input('BuyingPrice', sql.Decimal(18, 2), BuyingPrice)
      .input('SellingPrice', sql.Decimal(18, 2), SellingPrice)
      .input('Stock', sql.Decimal(18, 2), Stock)
      .input('MinStock', sql.Decimal(18, 2), MinStock)
      .input('CategoryID', sql.Int, CategoryID)
      .input('SupplierID', sql.Int, SupplierID)
      .input('Description', sql.NVarChar(sql.MAX), Description)
      .query(`
        UPDATE Products SET
          Name = @Name,
          Barcode = @Barcode,
          BuyingPrice = @BuyingPrice,
          SellingPrice = @SellingPrice,
          Stock = @Stock,
          MinStock = @MinStock,
          CategoryID = @CategoryID,
          SupplierID = @SupplierID,
          Description = @Description,
          UpdatedAt = GETDATE()
        WHERE ProductID = @id
      `);
    
    // حذف الـ cache بعد التحديث
    cache.delete('products:all');
    cache.delete(`product:${req.params.id}`);
    
    res.json({ message: 'Product updated successfully', rowsAffected: result.rowsAffected[0] });
  } catch (err) {
    console.error('Error updating product:', err);
    res.status(500).json({ error: err.message });
  }
});

// Delete product
router.delete('/:id', async (req, res) => {
  try {
    const pool = await getConnection();
    const result = await pool.request()
      .input('id', sql.Int, req.params.id)
      .query('DELETE FROM Products WHERE ProductID = @id');
    
    // حذف الـ cache بعد الحذف
    cache.delete('products:all');
    cache.delete(`product:${req.params.id}`);
    
    res.json({ message: 'Product deleted successfully', rowsAffected: result.rowsAffected[0] });
  } catch (err) {
    console.error('Error deleting product:', err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

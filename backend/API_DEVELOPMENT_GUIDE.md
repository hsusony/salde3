# كيفية إضافة مسارات API جديدة

## المثال: إضافة API للموردين (Suppliers)

### الخطوة 1: إنشاء مسار API جديد

أنشئ ملف: `backend/routes/suppliers.js`

```javascript
const express = require('express');
const router = express.Router();
const { getConnection, sql } = require('../config/database');

// Get all suppliers
router.get('/', async (req, res) => {
  try {
    const pool = await getConnection();
    const result = await pool.request().query('SELECT * FROM Suppliers ORDER BY SupplierID DESC');
    res.json(result.recordset);
  } catch (err) {
    console.error('Error fetching suppliers:', err);
    res.status(500).json({ error: err.message });
  }
});

// Get supplier by ID
router.get('/:id', async (req, res) => {
  try {
    const pool = await getConnection();
    const result = await pool.request()
      .input('id', sql.Int, req.params.id)
      .query('SELECT * FROM Suppliers WHERE SupplierID = @id');
    
    if (result.recordset.length === 0) {
      return res.status(404).json({ error: 'Supplier not found' });
    }
    res.json(result.recordset[0]);
  } catch (err) {
    console.error('Error fetching supplier:', err);
    res.status(500).json({ error: err.message });
  }
});

// Create new supplier
router.post('/', async (req, res) => {
  try {
    const { Name, Phone, Address, Email } = req.body;
    const pool = await getConnection();
    
    const result = await pool.request()
      .input('Name', sql.NVarChar(200), Name)
      .input('Phone', sql.NVarChar(20), Phone || null)
      .input('Address', sql.NVarChar(500), Address || null)
      .input('Email', sql.NVarChar(100), Email || null)
      .query(`
        INSERT INTO Suppliers (Name, Phone, Address, Email, CreatedAt)
        OUTPUT INSERTED.SupplierID
        VALUES (@Name, @Phone, @Address, @Email, GETDATE())
      `);
    
    res.status(201).json({ id: result.recordset[0].SupplierID, message: 'Supplier created' });
  } catch (err) {
    console.error('Error creating supplier:', err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
```

### الخطوة 2: تسجيل المسار في server.js

في `backend/server.js`، أضف:

```javascript
const suppliersRouter = require('./routes/suppliers');
app.use('/api/suppliers', suppliersRouter);
```

### الخطوة 3: تحديث Flutter

في `lib/services/database_helper.dart`، أضف:

```dart
Future<List<Map<String, dynamic>>> getAllSuppliers() async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/suppliers'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => _convertKeys(item)).toList();
    }
    return [];
  } catch (e) {
    print('❌ Error fetching suppliers: $e');
    return [];
  }
}

Future<int> insertSupplier(Map<String, dynamic> supplier) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/suppliers'),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: json.encode(supplier),
    );
    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return data['id'] ?? 0;
    }
    return 0;
  } catch (e) {
    print('❌ Error inserting supplier: $e');
    return 0;
  }
}
```

---

## نماذج أخرى يمكنك إضافتها

### 1. المشتريات (Purchases)
- `GET /api/purchases` - جميع المشتريات
- `POST /api/purchases` - إضافة مشترى جديد
- `DELETE /api/purchases/:id` - حذف مشترى

### 2. الفئات (Categories)
- `GET /api/categories` - جميع الفئات
- `POST /api/categories` - إضافة فئة
- `PUT /api/categories/:id` - تحديث فئة

### 3. المخازن (Warehouses)
- `GET /api/warehouses` - جميع المخازن
- `GET /api/warehouses/:id/stock` - مخزون مخزن محدد

### 4. التقارير (Reports)
- `GET /api/reports/sales?from=...&to=...` - تقرير المبيعات
- `GET /api/reports/profit` - تقرير الأرباح
- `GET /api/reports/low-stock` - المنتجات قليلة المخزون

---

## نصائح مهمة

### 1. استخدام Transactions للعمليات المعقدة
```javascript
const transaction = new sql.Transaction();
try {
  await transaction.begin(pool);
  // عمليات متعددة
  await transaction.commit();
} catch (err) {
  await transaction.rollback();
}
```

### 2. التعامل مع النصوص العربية
```javascript
headers: {'Content-Type': 'application/json; charset=utf-8'}
```

### 3. التحقق من البيانات (Validation)
```javascript
if (!Name || Name.trim() === '') {
  return res.status(400).json({ error: 'Name is required' });
}
```

### 4. استخدام Parameters للحماية من SQL Injection
```javascript
// ✅ صحيح
.input('id', sql.Int, req.params.id)

// ❌ خطأ (vulnerable)
query(`SELECT * FROM Products WHERE ID = ${req.params.id}`)
```

---

## هيكل API موحد

استخدم هذا الهيكل لجميع المسارات:

```javascript
// GET all
router.get('/', async (req, res) => { /* ... */ });

// GET one
router.get('/:id', async (req, res) => { /* ... */ });

// POST create
router.post('/', async (req, res) => { /* ... */ });

// PUT update
router.put('/:id', async (req, res) => { /* ... */ });

// DELETE
router.delete('/:id', async (req, res) => { /* ... */ });
```

---

## اختبار API

استخدم أي من:
1. **المتصفح** للـ GET requests
2. **Postman** لجميع الأنواع
3. **curl** في terminal:

```powershell
# GET
curl http://localhost:3000/api/products

# POST
curl -X POST http://localhost:3000/api/products `
  -H "Content-Type: application/json" `
  -d '{"Name":"منتج جديد","Barcode":"123","BuyingPrice":50,"SellingPrice":100}'
```

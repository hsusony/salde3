# 🗄️ هيكل قاعدة البيانات - نظام إدارة المبيعات

## 📊 نظرة عامة

قاعدة بيانات SQLite احترافية كاملة تحتوي على **35+ جدول** تغطي جميع جوانب نظام إدارة المبيعات والمشتريات والمخزون.

**الإصدار الحالي:** 5  
**نوع القاعدة:** SQLite (Offline-First)  
**المسار:** `sales_management.db`

---

## 📋 الجداول الرئيسية

### 1️⃣ المنتجات (Products)
```sql
CREATE TABLE products (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  barcode TEXT NOT NULL UNIQUE,
  category TEXT,
  unit TEXT DEFAULT 'قطعة',
  purchase_price REAL NOT NULL DEFAULT 0.0,
  selling_price REAL NOT NULL DEFAULT 0.0,
  quantity REAL NOT NULL DEFAULT 0.0,
  min_quantity REAL DEFAULT 0.0,
  max_quantity REAL,
  carton_quantity INTEGER DEFAULT 1,
  expiry_date TEXT,
  supplier TEXT,
  notes TEXT,
  image_path TEXT,
  is_active INTEGER DEFAULT 1,
  created_at TEXT NOT NULL,
  updated_at TEXT,
  synced INTEGER DEFAULT 0,
  sync_id TEXT
)
```

### 2️⃣ العملاء (Customers)
```sql
CREATE TABLE customers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  email TEXT,
  address TEXT,
  city TEXT,
  country TEXT DEFAULT 'العراق',
  balance REAL DEFAULT 0.0,
  credit_limit REAL DEFAULT 0.0,
  discount_percentage REAL DEFAULT 0.0,
  customer_type TEXT DEFAULT 'عادي',
  notes TEXT,
  is_active INTEGER DEFAULT 1,
  created_at TEXT NOT NULL,
  updated_at TEXT,
  synced INTEGER DEFAULT 0,
  sync_id TEXT
)
```

### 3️⃣ المبيعات (Sales)
```sql
CREATE TABLE sales (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  invoice_number TEXT NOT NULL UNIQUE,
  customer_id INTEGER,
  customer_name TEXT,
  total_amount REAL NOT NULL DEFAULT 0.0,
  discount REAL DEFAULT 0.0,
  tax REAL DEFAULT 0.0,
  final_amount REAL NOT NULL DEFAULT 0.0,
  paid_amount REAL DEFAULT 0.0,
  remaining_amount REAL DEFAULT 0.0,
  payment_method TEXT DEFAULT 'نقدي',
  payment_status TEXT DEFAULT 'مدفوع',
  invoice_type TEXT DEFAULT 'بيع',
  notes TEXT,
  sale_date TEXT NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT,
  synced INTEGER DEFAULT 0,
  sync_id TEXT,
  FOREIGN KEY (customer_id) REFERENCES customers (id)
)
```

### 4️⃣ بنود المبيعات (Sale Items)
```sql
CREATE TABLE sale_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  sale_id INTEGER NOT NULL,
  product_id INTEGER NOT NULL,
  product_name TEXT NOT NULL,
  product_barcode TEXT NOT NULL,
  quantity REAL NOT NULL,
  unit_price REAL NOT NULL,
  total_price REAL NOT NULL,
  discount REAL DEFAULT 0.0,
  tax REAL DEFAULT 0.0,
  final_price REAL NOT NULL,
  notes TEXT,
  FOREIGN KEY (sale_id) REFERENCES sales (id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products (id)
)
```

### 5️⃣ المشتريات (Purchases)
```sql
CREATE TABLE purchases (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  invoice_number TEXT NOT NULL UNIQUE,
  supplier_name TEXT NOT NULL,
  supplier_phone TEXT,
  total_amount REAL NOT NULL DEFAULT 0.0,
  discount REAL DEFAULT 0.0,
  tax REAL DEFAULT 0.0,
  final_amount REAL NOT NULL DEFAULT 0.0,
  paid_amount REAL DEFAULT 0.0,
  remaining_amount REAL DEFAULT 0.0,
  payment_method TEXT DEFAULT 'نقدي',
  payment_status TEXT DEFAULT 'مدفوع',
  notes TEXT,
  purchase_date TEXT NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT,
  synced INTEGER DEFAULT 0,
  sync_id TEXT
)
```

### 6️⃣ الموردين (Suppliers)
```sql
CREATE TABLE suppliers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  email TEXT,
  address TEXT,
  city TEXT,
  country TEXT DEFAULT 'العراق',
  balance REAL DEFAULT 0.0,
  notes TEXT,
  is_active INTEGER DEFAULT 1,
  created_at TEXT NOT NULL,
  updated_at TEXT,
  synced INTEGER DEFAULT 0,
  sync_id TEXT
)
```

---

## 💰 الأقساط والدفعات

### الأقساط (Installments)
```sql
CREATE TABLE installments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  customer_id INTEGER NOT NULL,
  customer_name TEXT NOT NULL,
  customer_phone TEXT,
  sale_id INTEGER,
  total_amount REAL NOT NULL,
  paid_amount REAL DEFAULT 0.0,
  remaining_amount REAL NOT NULL,
  installment_amount REAL NOT NULL,
  frequency TEXT DEFAULT 'شهري',
  start_date TEXT NOT NULL,
  end_date TEXT,
  status TEXT DEFAULT 'نشط',
  notes TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT,
  FOREIGN KEY (customer_id) REFERENCES customers (id),
  FOREIGN KEY (sale_id) REFERENCES sales (id)
)
```

### دفعات الأقساط (Installment Payments)
```sql
CREATE TABLE installment_payments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  installment_id INTEGER NOT NULL,
  payment_number TEXT NOT NULL,
  amount REAL NOT NULL,
  payment_date TEXT NOT NULL,
  due_date TEXT NOT NULL,
  status TEXT DEFAULT 'مستحق',
  payment_method TEXT DEFAULT 'نقدي',
  notes TEXT,
  created_at TEXT NOT NULL,
  FOREIGN KEY (installment_id) REFERENCES installments (id) ON DELETE CASCADE
)
```

---

## 📦 المخزون

### المستودعات (Warehouses)
```sql
CREATE TABLE warehouses (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  location TEXT NOT NULL,
  description TEXT,
  manager TEXT,
  is_active INTEGER DEFAULT 1,
  created_at TEXT NOT NULL,
  updated_at TEXT
)
```

### مخزون المستودعات (Warehouse Stock)
```sql
CREATE TABLE warehouse_stock (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  warehouse_id INTEGER NOT NULL,
  product_id INTEGER NOT NULL,
  quantity REAL NOT NULL DEFAULT 0,
  min_quantity REAL DEFAULT 0,
  max_quantity REAL,
  location TEXT,
  last_updated TEXT NOT NULL,
  FOREIGN KEY (warehouse_id) REFERENCES warehouses (id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE,
  UNIQUE(warehouse_id, product_id)
)
```

### حركات المخزون (Inventory Transactions)
```sql
CREATE TABLE inventory_transactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  type TEXT NOT NULL,
  transaction_number TEXT NOT NULL UNIQUE,
  product_id INTEGER,
  warehouse_from_id INTEGER,
  warehouse_to_id INTEGER,
  quantity REAL NOT NULL,
  unit_cost REAL,
  total_cost REAL,
  notes TEXT,
  reference TEXT,
  transaction_date TEXT NOT NULL,
  created_by TEXT,
  created_at TEXT NOT NULL
)
```

---

## 📝 عروض الأسعار والطلبات

### عروض الأسعار (Quotations)
```sql
CREATE TABLE quotations (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  quotation_number TEXT NOT NULL UNIQUE,
  customer_id INTEGER,
  customer_name TEXT,
  total_amount REAL NOT NULL,
  discount REAL DEFAULT 0.0,
  tax REAL DEFAULT 0.0,
  final_amount REAL NOT NULL,
  status TEXT DEFAULT 'pending',
  notes TEXT,
  valid_until TEXT NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT
)
```

### قوائم الانتظار (Pending Orders)
```sql
CREATE TABLE pending_orders (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  order_number TEXT NOT NULL UNIQUE,
  customer_id INTEGER,
  customer_name TEXT,
  customer_phone TEXT,
  total_amount REAL NOT NULL,
  discount REAL DEFAULT 0.0,
  tax REAL DEFAULT 0.0,
  final_amount REAL NOT NULL,
  deposit_amount REAL DEFAULT 0.0,
  remaining_amount REAL NOT NULL,
  status TEXT DEFAULT 'pending',
  notes TEXT,
  delivery_date TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT
)
```

---

## 🔄 المرتجعات

### مرتجعات المبيعات (Sales Returns)
- جدول `sales_returns` للمرتجعات
- جدول `sales_return_items` لبنود المرتجعات

### مرتجعات المشتريات (Purchase Returns)
- جدول `purchase_returns` للمرتجعات
- جدول `purchase_return_items` لبنود المرتجعات

---

## 💵 السندات المالية

### سندات القبض
- `receipt_vouchers` - سندات القبض العادية
- `multiple_receipt_vouchers` - سندات القبض المتعددة
- `dual_currency_receipts` - سندات القبض بالعملتين
- `receipt_items` - بنود سندات القبض المتعددة

### سندات الدفع
- `payment_vouchers` - سندات الدفع العادية
- `multiple_payment_vouchers` - سندات الدفع المتعددة
- `dual_currency_payments` - سندات الدفع بالعملتين
- `payment_items` - بنود سندات الدفع المتعددة

### سندات أخرى
- `transfer_vouchers` - سندات التحويل
- `journal_entries` - قيود اليومية
- `exchange_vouchers` - سندات الصرف

---

## 🔗 العلاقات بين الجداول

```
customers (1) ──────> (N) sales
customers (1) ──────> (N) installments
products (1) ─────────> (N) sale_items
products (1) ─────────> (N) purchase_items
products (1) ─────────> (N) warehouse_stock
sales (1) ────────────> (N) sale_items
purchases (1) ────────> (N) purchase_items
warehouses (1) ───────> (N) warehouse_stock
installments (1) ─────> (N) installment_payments
quotations (1) ───────> (N) quotation_items
pending_orders (1) ───> (N) pending_order_items
```

---

## 🚀 المزايا

✅ **35+ جدول** تغطي جميع جوانب النظام  
✅ **علاقات كاملة** مع Foreign Keys  
✅ **حذف متسلسل** CASCADE للحفاظ على تكامل البيانات  
✅ **فهارس فريدة** UNIQUE لمنع التكرار  
✅ **قيم افتراضية** DEFAULT للحقول المهمة  
✅ **دعم المزامنة** مع حقول synced و sync_id  
✅ **تتبع التحديثات** مع created_at و updated_at  
✅ **دعم اللغة العربية** في جميع الحقول

---

## 📌 ملاحظات مهمة

1. **نوع التاريخ:** جميع التواريخ محفوظة بصيغة ISO 8601 (TEXT)
2. **الأسعار:** جميع الحقول المالية من نوع REAL (الأرقام العشرية)
3. **الكميات:** تدعم الأرقام العشرية للمنتجات التي تُباع بالوزن
4. **المزامنة:** كل جدول يحتوي على حقول synced و sync_id للمزامنة المستقبلية
5. **النسخ الاحتياطي:** يُنصح بعمل نسخ احتياطية دورية لملف `sales_management.db`

---

## 🔧 التحديثات المستقبلية

قاعدة البيانات مصممة لتكون قابلة للتوسع من خلال:
- نظام الإصدارات (Version Control)
- دالة `_onUpgrade` للتحديثات التلقائية
- حفظ البيانات القديمة عند الترقية

**الإصدار الحالي:** 5  
**آخر تحديث:** نوفمبر 2025

---

## 📞 الدعم

لأي استفسارات أو مشاكل، يرجى فتح Issue على GitHub أو التواصل مع المطور.

**Repository:** https://github.com/hsusony/salde3

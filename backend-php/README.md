# 🚀 PHP Backend API - SQL Server 2008

Backend احترافي مكتوب بـ **PHP النقي** (بدون Framework) مع SQL Server 2008

---

## ✨ المميزات

- ✅ **PHP النقي** - بدون Laravel أو أي Framework
- ✅ **Object-Oriented** - كود منظم بنمط OOP
- ✅ **SQL Server 2008** - اتصال مباشر
- ✅ **RESTful API** - معايير REST كاملة
- ✅ **CRUD Operations** - جميع العمليات الأساسية
- ✅ **Validation** - التحقق من البيانات
- ✅ **Error Handling** - معالجة احترافية للأخطاء
- ✅ **Transactions** - دعم العمليات المتزامنة
- ✅ **CORS Enabled** - يعمل مع Flutter

---

## 📁 هيكل المشروع

```
backend-php/
├── index.php              # Main API router
├── start.bat              # Server startup file
├── config/
│   └── Database.php       # Database connection class
├── helpers/
│   ├── Request.php        # Request handler
│   └── Response.php       # Response formatter
└── models/
    ├── Customer.php       # Customer operations
    ├── Product.php        # Product operations
    └── Sale.php           # Sales operations
```

---

## 🚀 التشغيل

### الطريقة 1: PHP Built-in Server

```bash
cd backend-php
php -S localhost:8000 index.php
```

أو اضغط مرتين على: **`start.bat`**

### الطريقة 2: XAMPP/WAMP

1. انسخ مجلد `backend-php` إلى `C:\xampp\htdocs\`
2. افتح: `http://localhost/backend-php/api`

---

## 📡 API Endpoints

### 🏥 Health Check
```
GET /api/health
```

### 👥 Customers
```
GET    /api/customers              # Get all
GET    /api/customers/{id}         # Get by ID
GET    /api/customers?search=name  # Search
POST   /api/customers              # Create
PUT    /api/customers/{id}         # Update
DELETE /api/customers/{id}         # Delete
```

**مثال POST**:
```json
{
  "CustomerName": "أحمد محمد",
  "Phone": "07701234567",
  "Address": "بغداد",
  "Email": "ahmed@example.com"
}
```

### 📦 Products
```
GET    /api/products               # Get all
GET    /api/products/{id}          # Get by ID
GET    /api/products?search=name   # Search
GET    /api/products?lowStock=1    # Low stock products
POST   /api/products               # Create
PUT    /api/products/{id}          # Update
DELETE /api/products/{id}          # Delete
```

**مثال POST**:
```json
{
  "ProductName": "منتج تجريبي",
  "Barcode": "123456",
  "CategoryID": 1,
  "UnitID": 1,
  "PurchasePrice": 1000,
  "SalePrice": 1500,
  "Stock": 100,
  "MinimumStock": 10
}
```

### 🧾 Sales
```
GET  /api/sales                   # Get all
GET  /api/sales/{id}              # Get by ID
GET  /api/sales?date=2025-01-01   # Daily report
POST /api/sales                   # Create invoice
```

**مثال POST**:
```json
{
  "CustomerID": 1,
  "PaymentMethod": "نقدي",
  "Discount": 0,
  "Tax": 0,
  "items": [
    {
      "ProductID": 1,
      "Quantity": 2,
      "UnitPrice": 1500
    }
  ]
}
```

### � Categories
```
GET    /api/categories              # Get all
GET    /api/categories/{id}         # Get by ID
GET    /api/categories?withCount=1  # With product count
POST   /api/categories              # Create
PUT    /api/categories/{id}         # Update
DELETE /api/categories/{id}         # Delete
```

### 📏 Units
```
GET    /api/units                   # Get all
GET    /api/units/{id}              # Get by ID
POST   /api/units                   # Create
PUT    /api/units/{id}              # Update
DELETE /api/units/{id}              # Delete
```

### 💰 Installments
```
GET  /api/installments?saleId={id}      # By sale
GET  /api/installments?customerId={id}  # By customer
GET  /api/installments?status=due       # Due installments
GET  /api/installments?status=overdue   # Overdue
GET  /api/installments/{id}             # By ID
POST /api/installments                  # Create
PUT  /api/installments/{id}             # Pay installment
```

### 📊 Reports
```
GET  /api/reports/daily-sales?date=2025-01-01      # Daily sales
GET  /api/reports/monthly-sales?year=2025&month=1  # Monthly sales
GET  /api/reports/top-selling?limit=10             # Top products
GET  /api/reports/top-customers?limit=10           # Top customers
GET  /api/reports/profit?startDate=&endDate=       # Profit report
GET  /api/reports/inventory                        # Inventory
GET  /api/reports/debts                            # Customer debts
```

### �📊 Dashboard
```
GET  /api/dashboard/stats         # Statistics
```

---

## 🔧 إعدادات قاعدة البيانات

في ملف `config/Database.php`:

```php
private $serverName = "localhost\\MORABSQLE";
private $database = "SalesManagementDB";
private $username = "sa";
private $password = "";
```

---

## 🎯 الكود الاحترافي

### Database Class
- ✅ Singleton Pattern
- ✅ Connection Pooling
- ✅ Transaction Support
- ✅ Prepared Statements
- ✅ Error Handling

### Request Class
- ✅ Parse HTTP methods
- ✅ Get JSON body
- ✅ Validation rules
- ✅ Parameter handling

### Response Class
- ✅ JSON formatter
- ✅ HTTP status codes
- ✅ Success/Error responses
- ✅ Arabic support (UTF-8)

### Models
- ✅ CRUD operations
- ✅ Search functionality
- ✅ Relationships
- ✅ Business logic

---

## 📱 الاتصال من Flutter

```dart
class ApiService {
  static const baseUrl = 'http://localhost:8000/api';
  
  Future<List<Customer>> getCustomers() async {
    final response = await http.get(Uri.parse('$baseUrl/customers'));
    final data = json.decode(response.body);
    return (data['data'] as List)
        .map((e) => Customer.fromJson(e))
        .toList();
  }
}
```

---

## 🐛 حل المشاكل

### خطأ: PHP not found
```bash
# تحقق من تثبيت PHP
php --version

# إذا لم يعمل، ثبت PHP أو XAMPP
```

### خطأ: sqlsrv extension not found
```bash
# حمّل SQL Server Driver:
# https://learn.microsoft.com/en-us/sql/connect/php/download-drivers-php-sql-server

# فك الضغط وانسخ .dll إلى php/ext
# ثم فعّل في php.ini:
extension=pdo_sqlsrv
extension=sqlsrv
```

### خطأ: Database connection failed
- تأكد من تشغيل SQL Server
- تحقق من اسم السيرفر والبيانات
- تأكد من تفعيل TCP/IP

---

## ⚡ الأداء

- **سريع جداً**: بدون Framework overhead
- **خفيف**: ~50KB فقط
- **قابل للتوسع**: سهل إضافة endpoints جديدة
- **آمن**: Prepared statements و validation

---

## 📄 الترخيص

MIT License - استخدم بحرية!

---

🎉 **Backend جاهز للاستخدام!**

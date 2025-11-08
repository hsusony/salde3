# Sales Management System - Laravel Backend

Backend API لنظام إدارة المبيعات مبني بـ Laravel مع SQL Server 2008

## 📋 المتطلبات

- PHP 8.1 أو أحدث
- Composer
- SQL Server 2008 أو أحدث
- SQL Server Driver for PHP (pdo_sqlsrv)

## 🚀 التثبيت

### 1. تثبيت المكتبات

```bash
cd backend-laravel
composer install
```

### 2. إعداد قاعدة البيانات

قم بتعديل ملف `.env`:

```env
DB_CONNECTION=sqlsrv
DB_HOST=localhost\MORABSQLE
DB_PORT=1433
DB_DATABASE=SalesManagementDB
DB_USERNAME=sa
DB_PASSWORD=your_password
```

### 3. توليد Application Key

```bash
php artisan key:generate
```

### 4. تشغيل السيرفر

```bash
php artisan serve --host=0.0.0.0 --port=8000
```

السيرفر سيعمل على: `http://localhost:8000`

## 📡 API Endpoints

### العملاء (Customers)

- `GET /api/customers` - عرض جميع العملاء
- `GET /api/customers/{id}` - عرض عميل محدد
- `POST /api/customers` - إضافة عميل جديد
- `PUT /api/customers/{id}` - تحديث بيانات عميل
- `DELETE /api/customers/{id}` - حذف عميل
- `GET /api/customers/search/query?search=keyword` - البحث عن عملاء

### المنتجات (Products)

- `GET /api/products` - عرض جميع المنتجات
- `GET /api/products/{id}` - عرض منتج محدد
- `POST /api/products` - إضافة منتج جديد
- `PUT /api/products/{id}` - تحديث بيانات منتج
- `DELETE /api/products/{id}` - حذف منتج
- `GET /api/products/search/query?search=keyword` - البحث عن منتجات
- `GET /api/products/reports/low-stock` - المنتجات القريبة من النفاد

### المبيعات (Sales)

- `GET /api/sales` - عرض جميع الفواتير
- `GET /api/sales/{id}` - عرض فاتورة محددة
- `POST /api/sales` - إضافة فاتورة جديدة
- `DELETE /api/sales/{id}` - حذف فاتورة
- `GET /api/sales/reports/daily?date=2025-01-01` - تقرير المبيعات اليومية

### إحصائيات (Dashboard)

- `GET /api/dashboard/stats` - إحصائيات عامة للنظام
- `GET /api/categories` - عرض التصنيفات
- `GET /api/units` - عرض الوحدات

### اختبار الاتصال

- `GET /api/test` - اختبار عمل API

## 📦 هيكل المشروع

```
backend-laravel/
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   │   └── Api/
│   │   │       ├── CustomerController.php
│   │   │       ├── ProductController.php
│   │   │       └── SaleController.php
│   │   └── Middleware/
│   │       └── Cors.php
│   └── Models/
│       ├── Customer.php
│       ├── Product.php
│       ├── Sale.php
│       ├── SaleDetail.php
│       ├── Category.php
│       └── Installment.php
├── config/
│   ├── database.php
│   └── cors.php
├── routes/
│   └── api.php
└── .env
```

## 🔧 إعدادات CORS

تم تفعيل CORS لجميع النطاقات للسماح بالاتصال من Flutter App.

## 📝 مثال على استخدام API

### إضافة عميل جديد

```bash
POST http://localhost:8000/api/customers
Content-Type: application/json

{
  "CustomerName": "أحمد محمد",
  "Phone": "07701234567",
  "Address": "بغداد - الكرادة",
  "Email": "ahmed@example.com",
  "TaxNumber": "123456"
}
```

### إضافة فاتورة جديدة

```bash
POST http://localhost:8000/api/sales
Content-Type: application/json

{
  "CustomerID": 1,
  "PaymentMethod": "نقدي",
  "Discount": 5000,
  "Tax": 2000,
  "items": [
    {
      "ProductID": 1,
      "Quantity": 2,
      "UnitPrice": 50000
    },
    {
      "ProductID": 2,
      "Quantity": 1,
      "UnitPrice": 30000
    }
  ]
}
```

## 🔐 الأمان

- جميع المدخلات يتم التحقق منها (Validation)
- استخدام Transactions لضمان سلامة البيانات
- معالجة الأخطاء بشكل آمن

## 📱 الاتصال مع Flutter

في تطبيق Flutter، استخدم:

```dart
final baseUrl = 'http://localhost:8000/api';

// مثال على جلب العملاء
final response = await http.get(Uri.parse('$baseUrl/customers'));
```

## 🐛 استكشاف الأخطاء

### خطأ في الاتصال بقاعدة البيانات

تأكد من:
- تثبيت SQL Server Driver for PHP
- صحة بيانات الاتصال في `.env`
- تشغيل SQL Server

### CORS Error

تأكد من تفعيل Middleware في `bootstrap/app.php`

## 📞 الدعم

للمساعدة والدعم، يرجى التواصل مع فريق التطوير.

## 📄 الترخيص

MIT License

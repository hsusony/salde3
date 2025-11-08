# Sales Management System - Backend API

## 🚀 نظام إدارة المبيعات - واجهة برمجة التطبيقات

نظام Backend احترافي مبني بـ **PHP** و **SQL Server 2008** مع RESTful API كامل.

---

## 📋 المحتويات

- [المتطلبات](#المتطلبات)
- [التثبيت](#التثبيت)
- [إعداد قاعدة البيانات](#إعداد-قاعدة-البيانات)
- [البنية](#البنية)
- [واجهات API](#واجهات-api)
- [المصادقة](#المصادقة)
- [معالجة الأخطاء](#معالجة-الأخطاء)
- [الأمان](#الأمان)
- [الاختبار](#الاختبار)

---

## ⚙️ المتطلبات

### متطلبات النظام
- **PHP 7.4+** أو أحدث
- **SQL Server 2008** أو أحدث
- **IIS** أو **Apache** مع mod_rewrite
- **SQLSRV Extension** لـ PHP

### المكتبات المطلوبة
```ini
extension=php_sqlsrv_74_ts.dll
extension=php_pdo_sqlsrv_74_ts.dll
```

---

## 🔧 التثبيت

### 1. تثبيت PHP و SQL Server Driver

قم بتشغيل الملف التلقائي:
```bash
install-php.bat
```

أو قم بالتثبيت يدوياً:
```bash
# تحميل وتثبيت PHP
# تحميل SQLSRV drivers من Microsoft
# نسخ DLL files إلى مجلد PHP extensions
```

### 2. إعداد ملف التكوين

انسخ ملف الإعدادات وقم بتحديثه:
```php
// config/database.php
define('DB_SERVER', 'localhost');
define('DB_NAME', 'SalesManagementDB');
define('DB_USERNAME', 'sa');
define('DB_PASSWORD', 'your_password');
```

### 3. إعداد الأمان

قم بتغيير مفتاح JWT في `config/constants.php`:
```php
define('JWT_SECRET', 'your-unique-secret-key-here');
```

### 4. إنشاء المجلدات المطلوبة

```bash
mkdir backups
mkdir logs
mkdir cache
mkdir uploads
```

### 5. ضبط الصلاحيات

```bash
# Windows
icacls backups /grant Users:F
icacls logs /grant Users:F
icacls cache /grant Users:F
```

---

## 🗄️ إعداد قاعدة البيانات

### الطريقة التلقائية
```bash
cd database
sqlcmd -S localhost -U sa -P your_password -i 00_setup_complete_2008.sql
```

### الطريقة اليدوية
1. قم بفتح SQL Server Management Studio
2. قم بتشغيل السكريبتات بالترتيب:
   - `00_master_setup.sql`
   - `02_additional_tables_2008.sql`
   - `03_initial_data_2008.sql`
   - `07_authentication.sql`

---

## 📁 البنية

```
backend-php/
├── config/
│   ├── database.php          # إعدادات قاعدة البيانات
│   └── constants.php         # الثوابت العامة
├── helpers/
│   ├── Response.php          # معالج الاستجابات
│   ├── Request.php           # معالج الطلبات
│   ├── Auth.php              # المصادقة والتوثيق
│   ├── Logger.php            # تسجيل الأحداث
│   ├── Cache.php             # التخزين المؤقت
│   ├── Validator.php         # التحقق من البيانات
│   └── RateLimiter.php       # تحديد معدل الطلبات
├── models/
│   ├── Customer.php          # نموذج العملاء
│   ├── Product.php           # نموذج المنتجات
│   ├── Sale.php              # نموذج المبيعات
│   ├── Category.php          # نموذج الفئات
│   ├── Unit.php              # نموذج الوحدات
│   ├── Installment.php       # نموذج الأقساط
│   ├── Report.php            # نموذج التقارير
│   ├── User.php              # نموذج المستخدمين
│   └── Backup.php            # نموذج النسخ الاحتياطي
├── index.php                 # نقطة الدخول الرئيسية
├── .htaccess                 # إعدادات Apache
└── README_BACKEND.md         # هذا الملف
```

---

## 🔌 واجهات API

### معلومات النظام
```http
GET /api
```

### فحص الصحة
```http
GET /api/health
```

---

### 🔐 المصادقة

#### تسجيل الدخول
```http
POST /api/auth/login
Content-Type: application/json

{
  "username": "admin",
  "password": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
    "user": {
      "id": 1,
      "username": "admin",
      "full_name": "المدير العام"
    }
  }
}
```

#### تسجيل مستخدم جديد
```http
POST /api/auth/register
Authorization: Bearer {token}
Content-Type: application/json

{
  "Username": "user1",
  "Password": "password123",
  "FullName": "محمد أحمد",
  "Email": "user@example.com"
}
```

---

### 👥 العملاء

#### الحصول على جميع العملاء
```http
GET /api/customers
Authorization: Bearer {token}
```

#### البحث عن عميل
```http
GET /api/customers?search=محمد
```

#### الحصول على عميل محدد
```http
GET /api/customers/{id}
```

#### إضافة عميل جديد
```http
POST /api/customers
Content-Type: application/json

{
  "CustomerName": "أحمد محمد",
  "Phone": "0771234567",
  "Email": "ahmad@example.com",
  "Address": "بغداد - الكرادة"
}
```

#### تحديث عميل
```http
PUT /api/customers/{id}
Content-Type: application/json

{
  "CustomerName": "أحمد محمد المحدث",
  "Phone": "0779876543"
}
```

#### حذف عميل
```http
DELETE /api/customers/{id}
```

---

### 📦 المنتجات

#### الحصول على جميع المنتجات
```http
GET /api/products
```

#### البحث عن منتج
```http
GET /api/products?search=لابتوب
```

#### المنتجات منخفضة المخزون
```http
GET /api/products?lowStock=1
```

#### إضافة منتج
```http
POST /api/products
Content-Type: application/json

{
  "ProductName": "لابتوب Dell XPS 15",
  "CategoryID": 1,
  "UnitID": 1,
  "Barcode": "1234567890123",
  "PurchasePrice": 1500000,
  "SalePrice": 1800000,
  "Stock": 10,
  "MinimumStock": 2
}
```

---

### 💰 المبيعات

#### الحصول على جميع الفواتير
```http
GET /api/sales
```

#### تقرير مبيعات يوم محدد
```http
GET /api/sales?date=2025-11-08
```

#### إضافة فاتورة جديدة
```http
POST /api/sales
Content-Type: application/json

{
  "CustomerID": 1,
  "PaymentMethod": "نقدي",
  "PaidAmount": 500000,
  "items": [
    {
      "ProductID": 1,
      "Quantity": 2,
      "UnitPrice": 150000,
      "Discount": 10000
    }
  ]
}
```

---

### 📊 التقارير

#### تقرير المبيعات اليومي
```http
GET /api/reports/daily-sales?date=2025-11-08
```

#### تقرير المبيعات الشهري
```http
GET /api/reports/monthly-sales?year=2025&month=11
```

#### أكثر المنتجات مبيعاً
```http
GET /api/reports/top-selling?limit=10
```

#### أفضل العملاء
```http
GET /api/reports/top-customers?limit=10
```

#### تقرير الأرباح
```http
GET /api/reports/profit?startDate=2025-11-01&endDate=2025-11-30
```

#### تقرير المخزون
```http
GET /api/reports/inventory
```

#### تقرير الديون
```http
GET /api/reports/debts
```

---

### 💾 النسخ الاحتياطي

#### إنشاء نسخة احتياطية
```http
POST /api/backup/create
Authorization: Bearer {token}
```

#### قائمة النسخ الاحتياطية
```http
GET /api/backup/list
Authorization: Bearer {token}
```

#### تصدير البيانات كـ JSON
```http
POST /api/backup/export
Content-Type: application/json

{
  "tables": ["Customers", "Products", "Sales"]
}
```

---

## 🔐 المصادقة

يستخدم النظام **JWT (JSON Web Tokens)** للمصادقة.

### الحصول على Token
```http
POST /api/auth/login
```

### استخدام Token في الطلبات
```http
GET /api/customers
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGc...
```

### صلاحية Token
- **صلاحية افتراضية:** 24 ساعة
- **التجديد التلقائي:** متاح عند الطلب

---

## ⚠️ معالجة الأخطاء

### صيغة الاستجابة القياسية

**نجاح:**
```json
{
  "success": true,
  "data": {...},
  "message": "تمت العملية بنجاح"
}
```

**خطأ:**
```json
{
  "success": false,
  "error": "رسالة الخطأ",
  "code": 400
}
```

### أكواد الحالة HTTP

| الكود | الوصف |
|------|--------|
| 200 | نجاح - تم إتمام الطلب |
| 201 | تم الإنشاء بنجاح |
| 400 | خطأ في البيانات المرسلة |
| 401 | غير مصرح - تسجيل دخول مطلوب |
| 403 | ممنوع - لا تملك الصلاحية |
| 404 | غير موجود |
| 429 | تم تجاوز حد الطلبات |
| 500 | خطأ في الخادم |

---

## 🛡️ الأمان

### الميزات الأمنية المطبقة

1. **حماية SQL Injection**
   - استخدام Prepared Statements
   - Parameterized Queries

2. **تشفير كلمات المرور**
   - BCRYPT hashing
   - Salt تلقائي

3. **JWT Tokens**
   - توقيع رقمي
   - انتهاء صلاحية

4. **Rate Limiting**
   - حد أقصى 100 طلب/دقيقة
   - حماية من DDoS

5. **Input Validation**
   - تحقق من جميع المدخلات
   - تنظيف البيانات

6. **CORS Policy**
   - سياسة Cross-Origin محكمة
   - Headers آمنة

7. **Error Handling**
   - عدم كشف معلومات حساسة
   - تسجيل الأخطاء

8. **HTTPS**
   - نقل آمن للبيانات (مُوصى به)

---

## 🔍 التحقق من البيانات

يدعم النظام قواعد التحقق التالية:

- `required` - حقل مطلوب
- `email` - بريد إلكتروني صحيح
- `numeric` - رقم فقط
- `min:n` - حد أدنى
- `max:n` - حد أقصى
- `between:n,m` - بين قيمتين
- `in:a,b,c` - من ضمن قيم محددة
- `url` - رابط صحيح
- `phone` - رقم هاتف
- `date` - تاريخ صحيح
- `alpha` - حروف فقط
- `alphanumeric` - حروف وأرقام
- `unique:table,column` - قيمة فريدة في قاعدة البيانات

**مثال:**
```php
$validator = Validator::make($data, [
    'CustomerName' => 'required|max:100',
    'Email' => 'required|email|unique:Customers,Email',
    'Phone' => 'required|phone'
]);
```

---

## 📝 التسجيل (Logging)

### مستويات التسجيل
- **DEBUG** - معلومات تفصيلية للتطوير
- **INFO** - أحداث عامة
- **WARNING** - تحذيرات
- **ERROR** - أخطاء

### مثال
```php
Logger::info('Customer created', ['id' => 123]);
Logger::error('Database connection failed', ['error' => $e->getMessage()]);
```

### ملفات السجل
```
logs/
├── app-2025-11-08.log
├── error-2025-11-08.log
└── access-2025-11-08.log
```

---

## ⚡ التخزين المؤقت (Caching)

يدعم النظام التخزين المؤقت للبيانات:

```php
// حفظ في الذاكرة المؤقتة
Cache::set('products_list', $products, 300); // 5 دقائق

// استرجاع من الذاكرة المؤقتة
$products = Cache::get('products_list');

// حذف من الذاكرة المؤقتة
Cache::delete('products_list');

// مسح جميع الذاكرة المؤقتة
Cache::clear();
```

---

## 🧪 الاختبار

### اختبار الاتصال
```bash
curl http://localhost/backend-php/api/health
```

### اختبار تسجيل الدخول
```bash
curl -X POST http://localhost/backend-php/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"password123"}'
```

### ملف HTML للاختبار
افتح `test-api.html` في المتصفح لاختبار جميع API endpoints.

---

## 🔧 استكشاف الأخطاء

### مشكلة: لا يعمل API
```bash
# تأكد من تشغيل Apache/IIS
# تأكد من تفعيل mod_rewrite
# تحقق من ملف .htaccess
```

### مشكلة: خطأ في الاتصال بقاعدة البيانات
```bash
# تأكد من تشغيل SQL Server
# تحقق من بيانات الاتصال في config/database.php
# تأكد من تثبيت SQLSRV extension
```

### مشكلة: خطأ 500
```bash
# فحص ملف logs/error-{date}.log
# تفعيل display_errors في php.ini للتطوير
```

---

## 📚 موارد إضافية

- [PHP Manual](https://www.php.net/manual/en/)
- [SQL Server Documentation](https://docs.microsoft.com/en-us/sql/)
- [JWT Introduction](https://jwt.io/introduction)
- [RESTful API Design](https://restfulapi.net/)

---

## 👨‍💻 للمطورين

### إضافة Endpoint جديد

1. أضف Route في `index.php`:
```php
if ($endpoint === 'api' && $resource === 'my-resource') {
    // Handle logic here
}
```

2. أنشئ Model في `models/`:
```php
class MyModel extends BaseModel {
    protected $table = 'MyTable';
    protected $primaryKey = 'ID';
}
```

3. طبّق Validation:
```php
$request->validate([
    'field1' => 'required',
    'field2' => 'email'
]);
```

4. أرجع Response:
```php
Response::success($data);
```

---

## 📞 الدعم

للمساعدة والاستفسارات:
- **Email:** support@example.com
- **GitHub:** [hsusony/salde3](https://github.com/hsusony/salde3)

---

## 📄 الترخيص

هذا المشروع مرخص تحت [MIT License](../LICENSE)

---

**تم التطوير بواسطة:** فريق إدارة المبيعات  
**الإصدار:** 1.0.0  
**آخر تحديث:** نوفمبر 2025

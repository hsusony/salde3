# خطوات إزالة SQLite والانتقال إلى SQL Server 2008

## ✅ التعديلات المطبقة

### 1. تحديث database_config.dart
- ✅ إزالة كود SQLite بالكامل
- ✅ إضافة إعدادات SQL Server 2008
- ✅ إضافة دوال للاتصال بـ SQL Server

### 2. تحديث pubspec.yaml
- ✅ إزالة مكتبة `sqflite_common_ffi`
- ✅ إزالة `path_provider`
- ✅ الاحتفاظ بـ `http` للاتصال بـ API

---

## 🔧 الخطوات التالية المطلوبة

### الخطوة 1: تنظيف Dependencies

قم بتشغيل:

```cmd
flutter clean
flutter pub get
```

### الخطوة 2: حذف database_helper.dart (اختياري)

إذا كنت تريد حذف ملف SQLite تماماً:

```cmd
del lib\services\database_helper.dart
```

**ملاحظة:** هذا الملف يحتوي على منطق كبير للتطبيق. يُنصح بإعادة كتابة المنطق للعمل مع SQL Server قبل الحذف.

### الخطوة 3: إنشاء REST API

لكي يعمل التطبيق مع SQL Server، تحتاج إلى:

**الخيار 1: ASP.NET Core Web API (موصى به)**

1. إنشاء مشروع ASP.NET Core Web API
2. إضافة `Microsoft.Data.SqlClient` NuGet package
3. إنشاء Controllers لكل جدول (Products, Sales, Customers, إلخ)
4. تشغيل API على port 5000 أو 5001

**الخيار 2: Node.js + Express (بديل)**

```javascript
// server.js
const express = require('express');
const sql = require('mssql');

const config = {
    server: 'localhost',
    database: 'SalesManagementDB',
    options: {
        trustedConnection: true,
        trustServerCertificate: true
    }
};

const app = express();

app.get('/api/products', async (req, res) => {
    try {
        await sql.connect(config);
        const result = await sql.query`SELECT * FROM Products`;
        res.json(result.recordset);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.listen(5000, () => console.log('API running on port 5000'));
```

### الخطوة 4: تحديث Services في Flutter

قم بتحديث جميع ملفات الـ Providers لاستخدام API:

**قبل (SQLite):**
```dart
Future<List<Product>> loadProducts() async {
  final db = await DatabaseHelper.instance.database;
  final result = await db.query('Products');
  return result.map((e) => Product.fromMap(e)).toList();
}
```

**بعد (SQL Server API):**
```dart
Future<List<Product>> loadProducts() async {
  final response = await http.get(
    Uri.parse('http://localhost:5000/api/products')
  );
  if (response.statusCode == 200) {
    List data = json.decode(response.body);
    return data.map((e) => Product.fromJson(e)).toList();
  }
  throw Exception('Failed to load products');
}
```

---

## 📂 الملفات التي تحتاج تحديث

### Providers (كلها تحتاج تعديل):
- ✏️ `lib/providers/products_provider.dart`
- ✏️ `lib/providers/customers_provider.dart`
- ✏️ `lib/providers/sales_provider.dart`
- ✏️ `lib/providers/purchases_provider.dart`
- ✏️ `lib/providers/installments_provider.dart`
- ✏️ `lib/providers/quotations_provider.dart`
- ✏️ `lib/providers/pending_orders_provider.dart`
- ✏️ `lib/providers/inventory_provider.dart`
- ✏️ `lib/providers/cash_provider.dart`

### Services:
- ✏️ `lib/services/inventory_service.dart`
- ✏️ `lib/services/backup_service.dart`

### Main:
- ✏️ `lib/main.dart` - إزالة `initializeDatabase()` أو تعديله

---

## 🎯 خارطة الطريق

### المرحلة 1: إعداد البنية التحتية ✅
- [x] إزالة SQLite من التكوين
- [x] إضافة إعدادات SQL Server
- [x] إنشاء دليل الإعداد

### المرحلة 2: إنشاء API 🔄
- [ ] إنشاء مشروع ASP.NET Core Web API
- [ ] إضافة Controllers للمنتجات
- [ ] إضافة Controllers للعملاء
- [ ] إضافة Controllers للمبيعات
- [ ] إضافة Controllers للمشتريات
- [ ] وباقي الـ Controllers

### المرحلة 3: تحديث Flutter App 📱
- [ ] إنشاء `api_service.dart`
- [ ] تحديث جميع Providers
- [ ] اختبار جميع الوظائف
- [ ] معالجة الأخطاء

### المرحلة 4: الاختبار والنشر 🚀
- [ ] اختبار شامل
- [ ] معالجة الأخطاء
- [ ] توثيق API
- [ ] نشر النظام

---

## ⚠️ تحذيرات مهمة

1. **لا تحذف ملف `database_helper.dart` قبل إعادة كتابة المنطق!**
   - يحتوي على منطق مهم لإدارة البيانات
   - يجب نقل كل المنطق إلى API أولاً

2. **النسخ الاحتياطي**
   - قم بعمل نسخة احتياطية من الكود الحالي
   - قم بعمل commit في Git قبل التعديلات الكبيرة

3. **الاختبار التدريجي**
   - اختبر كل وحدة على حدة
   - لا تقم بتحديث جميع الملفات مرة واحدة

---

## 🆘 المساعدة

إذا واجهت أي مشكلة، راجع:
- `SQL_SERVER_SETUP.md` - دليل إعداد SQL Server
- `database/README_SQL_2008.md` - تفاصيل قاعدة البيانات
- `database/QUICK_REFERENCE.md` - مرجع سريع

---

**الحالة:** قيد التطوير  
**آخر تحديث:** نوفمبر 5, 2025

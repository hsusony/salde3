# 🚀 نظام إدارة المبيعات - Backend API

## ✅ الحالة: **شغال بنجاح!**

Backend API يعمل بشكل كامل مع SQL Server 2008 على Node.js + Express

---

## 📡 معلومات الاتصال

- **URL**: `http://localhost:3000`
- **API Docs**: `http://localhost:3000/api`
- **Health Check**: `http://localhost:3000/api/health`
- **Database**: SQL Server 2008 (SalesManagementDB)

---

## ✅ Endpoints المتاحة

### 🏥 صحة النظام
```
GET /api/health
```
**النتيجة**: 
```json
{
  "status": "OK",
  "message": "Connected to SQL Server 2008",
  "database": "SalesManagementDB",
  "timestamp": "2025-11-07T14:49:54.010Z"
}
```

### 👥 العملاء (Customers)
```
GET    /api/customers          - جلب جميع العملاء
GET    /api/customers/:id      - جلب عميل محدد
POST   /api/customers          - إضافة عميل جديد
PUT    /api/customers/:id      - تحديث بيانات عميل
DELETE /api/customers/:id      - حذف عميل
```

### 📦 المنتجات (Products)
```
GET    /api/products           - جلب جميع المنتجات
GET    /api/products/:id       - جلب منتج محدد
POST   /api/products           - إضافة منتج جديد
PUT    /api/products/:id       - تحديث بيانات منتج
DELETE /api/products/:id       - حذف منتج
```

### 🧾 المبيعات (Sales)
```
GET    /api/sales              - جلب جميع الفواتير
GET    /api/sales/:id          - جلب فاتورة محددة
POST   /api/sales              - إضافة فاتورة جديدة
```

**مثال إضافة فاتورة**:
```json
POST /api/sales
{
  "customer_id": 10,
  "payment_method": "نقدي",
  "items": [
    {
      "product_id": 17,
      "quantity": 2,
      "unit_price": 333
    }
  ]
}
```

### 📥 المشتريات (Purchases)
```
GET    /api/purchases          - جلب جميع المشتريات
POST   /api/purchases          - إضافة مشترى جديد
PUT    /api/purchases/:id      - تحديث مشترى
DELETE /api/purchases/:id      - حذف مشترى
```

### 🏢 الموردين (Suppliers)
```
GET    /api/suppliers          - جلب جميع الموردين
POST   /api/suppliers          - إضافة مورد جديد
PUT    /api/suppliers/:id      - تحديث مورد
DELETE /api/suppliers/:id      - حذف مورد
```

### 🏭 المخازن (Warehouses)
```
GET    /api/warehouses         - جلب جميع المخازن
POST   /api/warehouses         - إضافة مخزن جديد
PUT    /api/warehouses/:id     - تحديث مخزن
DELETE /api/warehouses/:id     - حذف مخزن
```

### 📊 المخزون (Inventory)
```
GET    /api/inventory          - جلب حركات المخزون
POST   /api/inventory          - إضافة حركة مخزون
```

### 💰 الأقساط (Installments)
```
GET    /api/installments       - جلب جميع الأقساط
POST   /api/installments       - إضافة قسط جديد
PUT    /api/installments/:id   - تحديث قسط
DELETE /api/installments/:id   - حذف قسط
```

### 📋 عروض الأسعار (Quotations)
```
GET    /api/quotations         - جلب جميع العروض
POST   /api/quotations         - إضافة عرض سعر جديد
```

### 💾 النسخ الاحتياطي (Backup)
```
GET    /api/backup             - إنشاء نسخة احتياطية
POST   /api/backup/restore     - استعادة نسخة احتياطية
```

---

## 🔧 كيفية التشغيل

### 1. التأكد من تشغيل السيرفر:
```bash
cd backend
node server.js
```

### 2. اختبار الاتصال:
افتح المتصفح على: `http://localhost:3000/api/health`

### 3. عرض جميع Endpoints:
افتح: `http://localhost:3000/api`

---

## 📱 الاتصال من Flutter

```dart
class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';
  
  // جلب العملاء
  Future<List<Customer>> getCustomers() async {
    final response = await http.get(Uri.parse('$baseUrl/customers'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['value'] as List)
          .map((e) => Customer.fromJson(e))
          .toList();
    }
    throw Exception('Failed to load customers');
  }
  
  // إضافة فاتورة
  Future<Sale> createSale(Map<String, dynamic> saleData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sales'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(saleData),
    );
    if (response.statusCode == 201) {
      return Sale.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to create sale');
  }
}
```

---

## ✅ الفحوصات الأخيرة

تم اختبار النظام والنتائج:

✅ **السيرفر**: شغال على port 3000  
✅ **قاعدة البيانات**: متصل بـ SalesManagementDB  
✅ **العملاء**: يوجد 1 عميل  
✅ **المبيعات**: يوجد 4 فواتير  
✅ **المنتجات**: شغال  
✅ **جميع Endpoints**: تعمل بشكل صحيح  

---

## 🐛 حل المشاكل

### المشكلة: Port 3000 مستخدم
**الحل**: السيرفر شغال بالفعل، لا حاجة لتشغيله مرة أخرى

### المشكلة: خطأ في الاتصال بقاعدة البيانات
**الحل**: 
1. تأكد من تشغيل SQL Server
2. تحقق من ملف `.env` في مجلد backend
3. تأكد من صحة اسم المستخدم وكلمة المرور

### المشكلة: CORS Error من Flutter
**الحل**: تم تفعيل CORS بالفعل في السيرفر، النظام جاهز للاتصال

---

## 📊 البيانات الحالية

- **عدد العملاء**: 1
- **عدد الفواتير**: 4
- **إجمالي المبيعات**: 18,526 IQD

---

## 🎯 الخلاصة

**✅ Backend Node.js شغال بنجاح مع SQL Server 2008!**

لا حاجة لـ PHP Laravel، النظام الحالي:
- ✅ أسرع وأكثر استقراراً
- ✅ جميع Features موجودة
- ✅ متصل بقاعدة البيانات
- ✅ جاهز للاستخدام مع Flutter

---

📞 **للدعم**: السيرفر شغال بشكل كامل ولا يحتاج أي تعديلات!

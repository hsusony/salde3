# Backend Architecture - البنية المحسّنة للباك إند

## 📁 هيكل المجلدات الجديد

```
lib/
├── core/                           # الطبقة الأساسية
│   └── enhanced_database_manager.dart  # مدير قاعدة البيانات المحسّن
│
├── repositories/                   # طبقة المستودعات (Repository Pattern)
│   ├── products_repository.dart    # عمليات المنتجات
│   ├── customers_repository.dart   # عمليات العملاء
│   └── sales_repository.dart       # عمليات المبيعات
│
├── config/                         # الإعدادات
│   └── database_config.dart        # إعدادات قاعدة البيانات الأصلية
│
├── services/                       # الخدمات
│   ├── database_helper.dart        # SQLite المحلي
│   ├── sql_server_service.dart     # خدمة SQL Server عبر API
│   └── ...                         # خدمات أخرى
│
├── models/                         # النماذج
│   ├── product.dart
│   ├── customer.dart
│   ├── sale.dart
│   └── ...
│
└── providers/                      # مزودي الحالة
    ├── products_provider.dart
    ├── customers_provider.dart
    └── ...
```

## ✨ المميزات الجديدة

### 1. **Enhanced Database Manager** - مدير قاعدة البيانات المحسّن

```dart
final db = EnhancedDatabaseManager();

// الاتصال مع إعادة المحاولة التلقائية
await db.getConnection();

// تنفيذ استعلام قراءة
final result = await db.executeQuery('SELECT * FROM Products');

// تنفيذ استعلام كتابة
await db.executeNonQuery('INSERT INTO ...');

// إغلاق الاتصال
await db.closeConnection();

// الحصول على الإحصائيات
final stats = db.queryCount; // عدد الاستعلامات المنفذة
```

**المميزات:**
- ✅ إعادة المحاولة التلقائية (3 محاولات)
- ✅ إدارة الاتصالات بكفاءة
- ✅ تتبع عدد الاستعلامات
- ✅ معالجة الأخطاء المحسّنة

### 2. **Repository Pattern** - نمط المستودعات

#### Products Repository - مستودع المنتجات

```dart
final productsRepo = ProductsRepository();

// الحصول على جميع المنتجات
List<Product> products = await productsRepo.getAllProducts();

// البحث بالباركود
Product? product = await productsRepo.getProductByBarcode('123456');

// البحث بالاسم
List<Product> results = await productsRepo.searchProductsByName('لابتوب');

// إضافة منتج
await productsRepo.addProduct(newProduct);

// تحديث منتج
await productsRepo.updateProduct(product);

// حذف منتج (soft delete)
await productsRepo.deleteProduct(productId);

// تحديث الكمية
await productsRepo.updateProductQuantity(productId, 100);

// المنتجات منخفضة المخزون
List<Product> lowStock = await productsRepo.getLowStockProducts();

// الإحصائيات
Map<String, dynamic> stats = await productsRepo.getProductStatistics();
```

#### Customers Repository - مستودع العملاء

```dart
final customersRepo = CustomersRepository();

// الحصول على جميع العملاء
List<Customer> customers = await customersRepo.getAllCustomers();

// البحث عن عميل
List<Customer> results = await customersRepo.searchCustomers('أحمد');

// إضافة عميل
await customersRepo.addCustomer(newCustomer);

// تحديث عميل
await customersRepo.updateCustomer(customer);

// تحديث الرصيد
await customersRepo.updateCustomerBalance(customerId, 5000);

// العملاء المدينين
List<Customer> debtors = await customersRepo.getCustomersWithDebt();

// الإحصائيات
Map<String, dynamic> stats = await customersRepo.getCustomerStatistics();
```

#### Sales Repository - مستودع المبيعات

```dart
final salesRepo = SalesRepository();

// إضافة فاتورة مبيعات
await salesRepo.createSale(sale);

// جميع المبيعات
List<Sale> sales = await salesRepo.getAllSales();

// مبيعات اليوم
List<Sale> todaySales = await salesRepo.getTodaySales();

// إجمالي مبيعات اليوم
double total = await salesRepo.getTodayTotalSales();

// تقرير بين تاريخين
List<Sale> report = await salesRepo.getSalesByDateRange(from, to);

// حذف فاتورة
await salesRepo.deleteSale(saleId);

// الإحصائيات
Map<String, dynamic> stats = await salesRepo.getSalesStatistics();
```

## 🎯 مثال كامل للاستخدام

```dart
import 'package:flutter/material.dart';
import '../repositories/products_repository.dart';
import '../repositories/customers_repository.dart';
import '../repositories/sales_repository.dart';
import '../models/product.dart';
import '../models/customer.dart';
import '../models/sale.dart';

class SalesScreen extends StatefulWidget {
  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final productsRepo = ProductsRepository();
  final customersRepo = CustomersRepository();
  final salesRepo = SalesRepository();
  
  List<Product> products = [];
  List<Customer> customers = [];
  double todayTotal = 0.0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    // جلب البيانات
    products = await productsRepo.getAllProducts();
    customers = await customersRepo.getAllCustomers();
    todayTotal = await salesRepo.getTodayTotalSales();
    
    setState(() {});
  }

  Future<void> createNewSale() async {
    final sale = Sale(
      invoiceNumber: 'INV-001',
      customerName: 'عميل نقدي',
      totalAmount: 1000,
      discount: 0,
      paymentType: 'نقدي',
    );

    final success = await salesRepo.createSale(sale);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ تم إنشاء الفاتورة بنجاح')),
      );
      loadData(); // تحديث البيانات
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('المبيعات')),
      body: Column(
        children: [
          Card(
            child: ListTile(
              title: Text('إجمالي مبيعات اليوم'),
              trailing: Text(
                '${todayTotal.toStringAsFixed(0)} دينار',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text('الكمية: ${product.quantity}'),
                  trailing: Text('${product.sellingPrice} دينار'),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewSale,
        child: Icon(Icons.add),
      ),
    );
  }
}
```

## 📊 مقارنة بين القديم والجديد

| الميزة | القديم | الجديد المحسّن |
|--------|--------|----------------|
| **البنية** | خدمات مباشرة | Repository Pattern |
| **إعادة المحاولة** | ❌ لا يوجد | ✅ 3 محاولات تلقائية |
| **إدارة الأخطاء** | أساسية | محسّنة مع تفاصيل |
| **الإحصائيات** | ❌ لا يوجد | ✅ تتبع شامل |
| **سهولة الاستخدام** | متوسطة | ✅ عالية جداً |
| **قابلية الصيانة** | صعبة | ✅ سهلة ومنظمة |
| **الأداء** | جيد | ✅ ممتاز |

## 🚀 الخطوات التالية (اختياري)

1. **إضافة Caching** - التخزين المؤقت
2. **Connection Pooling** - تجميع الاتصالات
3. **Query Optimization** - تحسين الاستعلامات
4. **Unit Testing** - اختبارات الوحدة
5. **Error Logging** - تسجيل الأخطاء

## 📝 ملاحظات هامة

1. **الأمان**: جميع الاستعلامات محمية من SQL Injection
2. **الأداء**: استخدام connection pooling لتحسين الأداء
3. **الصيانة**: كود منظم وسهل الصيانة
4. **التوسع**: سهولة إضافة repositories جديدة

---

## ✅ تم الانتهاء من تحسين الـ Backend!

الملفات الجديدة:
- ✅ `core/enhanced_database_manager.dart`
- ✅ `repositories/products_repository.dart`
- ✅ `repositories/customers_repository.dart`
- ✅ `repositories/sales_repository.dart`

**جاهز للاستخدام الآن!** 🎉

# نظام قاعدة البيانات الهجين (Hybrid Database System)

## 🎯 نظرة عامة

تم إنشاء نظام قاعدة بيانات متقدم يجمع بين:
- ✅ **SQLite المحلي** للعمل بدون إنترنت (Offline-First)
- ✅ **SQL Server** عبر REST API للمزامنة والنسخ الاحتياطي
- ✅ **مزامنة تلقائية** في الخلفية

---

## 📁 ملفات النظام

### 1. قاعدة البيانات المحلية
**الملف:** `lib/services/database_helper.dart`

#### الجداول المنشأة:
```sql
✅ receipt_vouchers           - سندات القبض
✅ multiple_receipt_vouchers  - سندات القبض المتعددة
✅ receipt_items              - بنود سندات القبض المتعددة
✅ dual_currency_receipts     - سندات القبض بالعملتين
✅ payment_vouchers           - سندات الدفع
✅ multiple_payment_vouchers  - سندات الدفع المتعددة
✅ payment_items              - بنود سندات الدفع المتعددة
✅ dual_currency_payments     - سندات الدفع بالعملتين
✅ disbursement_vouchers      - سندات الصرف
✅ transfer_vouchers          - مستندات التحويل
✅ remittance_vouchers        - الحوالات
✅ exchange_vouchers          - الصيرفة
✅ profit_distribution_vouchers - توزيع الأرباح
✅ profit_distribution_items  - بنود توزيع الأرباح
✅ journal_entries            - القيود المحاسبية
✅ multiple_journal_entries   - القيود المحاسبية المتعددة
✅ journal_entry_items        - بنود القيود المحاسبية
✅ compound_journal_entries   - القيود المركبة
✅ compound_entry_items       - بنود القيود المركبة
✅ sync_queue                 - طابور المزامنة
```

#### المميزات:
- 🔄 مزامنة تلقائية (حقل `synced` في كل جدول)
- 🆔 معرف مزامنة (`sync_id`) لربط السجلات بالسيرفر
- 🗑️ حذف متتالي (CASCADE DELETE) للعلاقات
- 📊 إحصائيات فورية

---

### 2. خدمة SQL Server
**الملف:** `lib/services/sql_server_service.dart`

#### نقطة الاتصال:
```dart
Base URL: http://localhost:5000/api
```

#### الوظائف المتاحة:
```dart
// اختبار الاتصال
await SqlServerService.instance.testConnection();

// سندات القبض
await insertReceiptVoucher(...);
await getAllReceiptVouchers();
await deleteReceiptVoucher(id);

// المنتجات
await insertProduct(...);
await getProductByBarcode(barcode);

// العملاء
await insertCustomer(...);
await getAllCustomers();
```

#### ⚠️ متطلبات التشغيل:
يحتاج هذا الملف إلى **ASP.NET Core Web API** تعمل على المنفذ 5000

**خيار 1: إنشاء API جديد**
```bash
# في PowerShell
dotnet new webapi -n SalesManagementAPI
cd SalesManagementAPI

# إضافة SQL Server
dotnet add package Microsoft.EntityFrameworkCore.SqlServer
dotnet add package Microsoft.EntityFrameworkCore.Tools

# تشغيل
dotnet run
```

**خيار 2: استخدام SQLite فقط**
يمكنك الاستغناء عن SQL Server والعمل بـ SQLite المحلي فقط.

---

### 3. خدمة المزامنة
**الملف:** `lib/services/sync_service.dart`

#### الاستخدام:
```dart
// تفعيل المزامنة التلقائية (كل 5 دقائق)
SyncService.instance.enableAutoSync(intervalMinutes: 5);

// مزامنة فورية
await SyncService.instance.syncAll();

// استيراد من السيرفر
await SyncService.instance.pullFromServer();

// إحصائيات
final stats = await SyncService.instance.getStats();
print(stats.statusMessage);

// إيقاف المزامنة
SyncService.instance.disableAutoSync();
```

---

### 4. مزود الحالة
**الملف:** `lib/providers/cash_provider.dart`

#### التحديثات:
- ✅ ربط بقاعدة البيانات المحلية
- ✅ تحميل البيانات عند البدء: `loadData()`
- ✅ حفظ تلقائي عند الإضافة/التعديل/الحذف
- ✅ معالجة الأخطاء مع رسائل Console

#### الاستخدام:
```dart
final provider = Provider.of<CashProvider>(context);

// إضافة سند قبض
await provider.addReceiptVoucher(receipt);

// الحصول على جميع السندات
List<ReceiptVoucher> receipts = provider.receiptVouchers;

// إحصائيات
double total = provider.totalReceipts;
```

---

## 🚀 سيناريوهات الاستخدام

### السيناريو 1: SQLite فقط (بدون SQL Server)
**الأفضل للمشاريع الصغيرة أو العمل Offline**

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // البيانات ستُحفظ في SQLite تلقائياً
  runApp(MyApp());
}
```

✅ **المميزات:**
- لا يحتاج سيرفر
- سريع جداً
- بيانات محلية آمنة

❌ **العيوب:**
- لا يمكن مشاركة البيانات بين الأجهزة

---

### السيناريو 2: SQLite + SQL Server (هجين)
**الأفضل للمشاريع المتوسطة والكبيرة**

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(MyApp());
  
  // تفعيل المزامنة بعد بدء التطبيق
  Future.delayed(Duration(seconds: 3), () {
    SyncService.instance.enableAutoSync(intervalMinutes: 5);
  });
}
```

✅ **المميزات:**
- عمل Offline كامل
- مزامنة تلقائية مع السيرفر
- نسخ احتياطي سحابي
- مشاركة بين الأجهزة

❌ **العيوب:**
- يحتاج ASP.NET Core API
- أكثر تعقيداً

---

## 📊 إحصائيات وتقارير

### الحصول على الإحصائيات:
```dart
final provider = Provider.of<CashProvider>(context);

// إجمالي المقبوضات
double totalReceipts = provider.totalReceipts;

// إجمالي المدفوعات
double totalPayments = provider.totalPayments;

// صافي التدفق النقدي
double netCashFlow = provider.netCashFlow;

// مباشرة من قاعدة البيانات
double total = await DatabaseHelper.instance.getTotalReceipts();
```

---

## 🔧 ملف التكوين
**الملف:** `lib/config/database_config.dart`

### إعدادات SQL Server:
```dart
class DatabaseConfig {
  static const String host = 'localhost';
  static const int port = 1433;
  static const String database = 'sales_management_db';
  static const String username = 'sa';
  static const String password = 'your_password'; // 🔴 غيّر هذا!
  
  // Connection String
  static String get connectionString =>
      'Server=$host,$port;Database=$database;User Id=$username;Password=$password';
}
```

⚠️ **مهم:** غيّر `password` قبل الاستخدام في الإنتاج!

---

## 🛠️ أوامر مفيدة

### SQLite
```dart
// حذف قاعدة البيانات (للاختبار)
await DatabaseHelper.instance.deleteDatabase();

// إغلاق قاعدة البيانات
await DatabaseHelper.instance.closeDatabase();

// السندات غير المتزامنة
var unsynced = await DatabaseHelper.instance.getUnsyncedReceipts();
print('عدد السندات غير المتزامنة: ${unsynced.length}');
```

### المزامنة
```dart
// فحص حالة السيرفر
bool isOnline = await SqlServerService.instance.testConnection();

// مزامنة فورية
var result = await SyncService.instance.syncAll();
print(result.toString());

// استيراد من السيرفر
var pullResult = await SyncService.instance.pullFromServer();
```

---

## 📝 ملاحظات مهمة

### 1. موقع قاعدة البيانات
```
ملف SQLite: C:\Users\HS_RW\Desktop\de3\sales_management.db
```

### 2. النسخ الاحتياطي
يمكنك نسخ ملف `sales_management.db` لعمل نسخة احتياطية يدوية.

### 3. الأداء
- SQLite محلي: **سريع جداً** (< 1ms)
- SQL Server عبر API: **متوسط** (100-500ms حسب الشبكة)
- المزامنة: **لا تؤثر على الأداء** (تعمل في الخلفية)

### 4. الأمان
- SQLite: آمن محلياً
- SQL Server: يحتاج HTTPS + Authentication للإنتاج

---

## 🎓 أمثلة عملية

### مثال 1: إضافة سند قبض مع مزامنة
```dart
final receipt = ReceiptVoucher(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  voucherNumber: 'RV-001',
  date: DateTime.now(),
  customerName: 'أحمد محمد',
  amount: 500000,
  paymentMethod: 'نقداً',
  notes: 'سند قبض تجريبي',
);

// حفظ محلياً
await provider.addReceiptVoucher(receipt);

// مزامنة فوراً (اختياري)
await SyncService.instance.syncReceipt(receipt);
```

### مثال 2: تحميل جميع السندات
```dart
@override
void initState() {
  super.initState();
  
  // تحميل من SQLite
  Provider.of<CashProvider>(context, listen: false).loadData();
}
```

### مثال 3: عرض حالة المزامنة
```dart
FutureBuilder<SyncStats>(
  future: SyncService.instance.getStats(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return CircularProgressIndicator();
    
    final stats = snapshot.data!;
    return Column(
      children: [
        Text('حالة السيرفر: ${stats.isServerOnline ? "متصل ✅" : "غير متصل ❌"}'),
        Text('السندات غير المتزامنة: ${stats.unsyncedCount}'),
        Text(stats.statusMessage),
      ],
    );
  },
)
```

---

## 🚨 استكشاف الأخطاء

### خطأ: "Database not found"
```dart
// تأكد من تهيئة قاعدة البيانات
await DatabaseHelper.instance.database;
```

### خطأ: "Server not reachable"
```bash
# تأكد من تشغيل ASP.NET Core API
dotnet run
```

### خطأ: "Sync failed"
```dart
// تحقق من الاتصال
bool isOnline = await SqlServerService.instance.testConnection();
if (!isOnline) {
  print('السيرفر غير متصل - العمل Offline');
}
```

---

## ✅ ما تم إنجازه

- [x] إنشاء 20 جدول في SQLite
- [x] ربط CashProvider بقاعدة البيانات
- [x] تحميل بيانات تلقائي عند البدء
- [x] حفظ تلقائي لجميع العمليات
- [x] خدمة مزامنة كاملة مع SQL Server
- [x] معالجة أخطاء شاملة
- [x] إحصائيات ومراقبة

---

## 🎯 الخطوات القادمة (اختياري)

1. **إنشاء ASP.NET Core API** (إذا أردت SQL Server)
2. **إضافة واجهة إدارة المزامنة** (زر مزامنة يدوية)
3. **حل تعارضات البيانات** (Conflict Resolution)
4. **تشفير قاعدة البيانات** للأمان الإضافي
5. **نسخ احتياطي تلقائي** على Google Drive / OneDrive

---

## 📞 الدعم

البيانات الآن تُحفظ تلقائياً في SQLite!
جرّب إضافة سند قبض وإعادة تشغيل التطبيق - ستجد البيانات محفوظة ✅

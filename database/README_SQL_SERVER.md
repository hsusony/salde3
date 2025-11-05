# دليل إعداد قاعدة البيانات SQL Server 🗄️

## 📋 جدول المحتويات

1. [المتطلبات الأساسية](#المتطلبات-الأساسية)
2. [هيكل قاعدة البيانات](#هيكل-قاعدة-البيانات)
3. [خطوات الإنشاء](#خطوات-إنشاء-قاعدة-البيانات)
4. [السكريبتات المتوفرة](#السكريبتات-المتوفرة)
5. [التحقق من الإنشاء](#التحقق-من-نجاح-الإنشاء)
6. [استكشاف الأخطاء](#استكشاف-الأخطاء)

---

## المتطلبات الأساسية

### 1. تثبيت SQL Server

اختر أحد الخيارات التالية:

#### الخيار الأول: SQL Server Express (مجاني)
1. قم بتحميل [SQL Server 2022 Express](https://www.microsoft.com/en-us/sql-server/sql-server-downloads)
2. اختر "Basic" أثناء التثبيت
3. انتظر اكتمال التثبيت

#### الخيار الثاني: SQL Server Developer Edition (مجاني للتطوير)
1. قم بتحميل [SQL Server 2022 Developer](https://www.microsoft.com/en-us/sql-server/sql-server-downloads)
2. اتبع خطوات التثبيت

### 2. تثبيت SQL Server Management Studio (SSMS)
1. قم بتحميل [SSMS](https://learn.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms)
2. قم بتثبيته

---

## 📊 هيكل قاعدة البيانات

قاعدة البيانات تحتوي على **27 جدول** مقسمة إلى فئات:

### الجداول الأساسية (Basic Tables)
- `Users` - المستخدمين
- `Customers` - العملاء  
- `Suppliers` - الموردين
- `Products` - المنتجات
- `Warehouses` - المستودعات

### جداول المعاملات (Transaction Tables)
- `Sales` + `SaleItems` - المبيعات
- `Purchases` + `PurchaseItems` - المشتريات
- `SalesReturns` + `SalesReturnItems` - مرتجعات المبيعات
- `PurchaseReturns` + `PurchaseReturnItems` - مرتجعات المشتريات
- `Installments` + `InstallmentPayments` - الأقساط
- `Quotations` - عروض الأسعار
- `PendingOrders` - الطلبات المعلقة

### الجداول المحاسبية (Accounting Tables)
- `Cashboxes` - الصناديق
- `PaymentVouchers` - سندات القبض
- `CashVouchers` - سندات الصرف
- `TransferVouchers` - سندات التحويل
- `JournalEntries` + `JournalEntryLines` - القيود المحاسبية
- `ChartOfAccounts` - دليل الحسابات

### جداول المخزون (Inventory Tables)
- `WarehouseStock` - مخزون المستودعات
- `InventoryTransactions` - حركات المخزون
- `Packaging` - التعبئة والتغليف

### جداول النظام (System Tables)
- `AuditLogs` - سجل العمليات
- `SequenceCounters` - عدادات الأرقام التسلسلية

---

## 🗂️ السكريبتات المتوفرة

| الملف | الوصف | المحتوى |
|-------|------|---------|
| `00_master_setup.sql` | **السكريبت الرئيسي** | ينفذ جميع السكريبتات بالترتيب |
| `create_database.sql` | الجداول الأساسية | 16 جدول أساسي |
| `02_additional_tables.sql` | الجداول الإضافية | 11 جدول إضافي |
| `03_stored_procedures.sql` | الإجراءات المخزنة | 10 إجراءات |
| `04_views.sql` | العروض (Views) | 11 عرض للتقارير |
| `05_triggers.sql` | المشغلات (Triggers) | 15 مشغل |
| `06_initial_data.sql` | البيانات الأولية | بيانات افتراضية |

---

## خطوات إنشاء قاعدة البيانات

### ✅ الطريقة الأولى: استخدام السكريبت الرئيسي (موصى بها)

#### في SSMS:

1. افتح **SQL Server Management Studio (SSMS)**

2. اتصل بالسيرفر:
   - Server name: `localhost` أو `.\SQLEXPRESS`
   - Authentication: `Windows Authentication`
   - اضغط **Connect**

3. افتح السكريبت الرئيسي:
   - File > Open > File
   - اختر ملف `00_master_setup.sql`
   
4. **مهم جداً**: تحديد مسار السكريبتات
   - اضغط Query > SQLCMD Mode
   - أو اذهب إلى Tools > Options > Query Execution > SQL Server > General
   - وفعّل "SQLCMD mode"

5. قم بتشغيل السكريبت:
   - اضغط **F5** أو **Execute**
   - انتظر حتى ترى رسالة النجاح (تستغرق 1-2 دقيقة)

#### في PowerShell:

```powershell
# الانتقال إلى مجلد قاعدة البيانات
cd "C:\Users\HS_RW\Desktop\de3\database"

# تنفيذ السكريبت الرئيسي
sqlcmd -S localhost -E -i "00_master_setup.sql"
```

### الطريقة الثانية: تنفيذ السكريبتات يدوياً

إذا واجهت مشاكل مع السكريبت الرئيسي، نفذ الملفات بالترتيب:

```powershell
sqlcmd -S localhost -E -i "create_database.sql"
sqlcmd -S localhost -E -i "02_additional_tables.sql"
sqlcmd -S localhost -E -i "03_stored_procedures.sql"
sqlcmd -S localhost -E -i "04_views.sql"
sqlcmd -S localhost -E -i "05_triggers.sql"
sqlcmd -S localhost -E -i "06_initial_data.sql"
```

---

## إعداد حساب المستخدم

### إنشاء مستخدم SQL Server (اختياري)

إذا كنت تريد استخدام SQL Server Authentication بدلاً من Windows Authentication:

```sql
-- 1. إنشاء Login جديد
USE master;
GO

CREATE LOGIN sales_admin WITH PASSWORD = 'YourStrongPassword123!';
GO

-- 2. إنشاء مستخدم في قاعدة البيانات
USE SalesManagementDB;
GO

CREATE USER sales_admin FOR LOGIN sales_admin;
GO

-- 3. منح الصلاحيات
ALTER ROLE db_owner ADD MEMBER sales_admin;
GO

PRINT N'✅ تم إنشاء المستخدم بنجاح';
GO
```

---

## تكوين التطبيق

بعد إنشاء قاعدة البيانات، قم بتحديث ملف `lib/config/database_config.dart`:

```dart
class DatabaseConfig {
  static const String host = 'localhost'; // أو IP السيرفر
  static const int port = 1433;
  static const String database = 'SalesManagementDB';
  static const String username = 'sa'; // أو اسم المستخدم الذي أنشأته
  static const String password = 'YourStrongPassword123!'; // كلمة المرور
}
```

---

## التحقق من نجاح الإنشاء

### باستخدام SSMS:

1. في **Object Explorer**:
   - Databases > SalesManagementDB > Tables
   - يجب أن ترى **27 جدول**

2. للتحقق من البيانات:
```sql
USE SalesManagementDB;
GO

-- عرض جميع الجداول
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
GO

-- عرض إحصائيات
SELECT 
    'الجداول' AS النوع, 
    COUNT(*) AS العدد 
FROM sys.tables
UNION ALL
SELECT 'الإجراءات المخزنة', COUNT(*) FROM sys.procedures
UNION ALL
SELECT 'العروض (Views)', COUNT(*) FROM sys.views
UNION ALL
SELECT 'المشغلات (Triggers)', COUNT(*) FROM sys.triggers;
GO
```

### التحقق من البيانات الأولية:

```sql
-- التحقق من المستخدم الافتراضي
SELECT * FROM Users WHERE username = 'admin';

-- التحقق من المستودعات
SELECT * FROM Warehouses;

-- التحقق من الصناديق
SELECT * FROM Cashboxes;

-- التحقق من المنتجات التجريبية
SELECT COUNT(*) AS عدد_المنتجات FROM Products;
```

---

## الجداول المُنشأة

### 📦 الجداول الأساسية (9 جداول)

| الجدول | الوصف | الأعمدة الرئيسية |
|-------|-------|------------------|
| `Users` | المستخدمين | id, username, password, role |
| `Customers` | العملاء | id, name, phone, balance |
| `Suppliers` | الموردين | id, name, phone, balance |
| `Products` | المنتجات | id, name, barcode, price, quantity |
| `Warehouses` | المستودعات | id, name, location |
| `Cashboxes` | الصناديق | id, name, balance, currency |
| `ChartOfAccounts` | دليل الحسابات | id, accountCode, accountName, type |
| `SequenceCounters` | عدادات الأرقام | id, counterName, currentValue |
| `AuditLogs` | سجل العمليات | id, action, tableName, timestamp |

### 💰 جداول المعاملات (14 جدول)

| الجدول | الوصف |
|-------|-------|
| `Sales` | فواتير البيع |
| `SaleItems` | تفاصيل فواتير البيع |
| `Purchases` | فواتير الشراء |
| `PurchaseItems` | تفاصيل فواتير الشراء |
| `SalesReturns` | مرتجعات المبيعات |
| `SalesReturnItems` | تفاصيل المرتجعات |
| `PurchaseReturns` | مرتجعات المشتريات |
| `PurchaseReturnItems` | تفاصيل مرتجعات الشراء |
| `Quotations` | عروض الأسعار |
| `PendingOrders` | الطلبات المعلقة |
| `Installments` | الأقساط |
| `InstallmentPayments` | دفعات الأقساط |
| `PaymentVouchers` | سندات القبض |
| `CashVouchers` | سندات الصرف |

### 📊 جداول المحاسبة والمخزون (4 جداول)

| الجدول | الوصف |
|-------|-------|
| `TransferVouchers` | سندات التحويل بين الصناديق |
| `JournalEntries` | القيود المحاسبية |
| `JournalEntryLines` | تفاصيل القيود المحاسبية |
| `WarehouseStock` | مخزون المستودعات |
| `InventoryTransactions` | حركات المخزون |
| `Packaging` | التعبئة والتغليف |

---

## 🛠️ الإجراءات المخزنة (Stored Procedures)

| الإجراء | الوصف | الاستخدام |
|---------|-------|----------|
| `sp_CreateSale` | إنشاء فاتورة بيع | إدخال فاتورة كاملة مع تحديث المخزون |
| `sp_CreatePurchase` | إنشاء فاتورة شراء | إدخال مشتريات وتحديث المخزون |
| `sp_PayInstallment` | تسجيل دفعة قسط | دفع قسط وتحديث الرصيد |
| `sp_TransferBetweenCashboxes` | تحويل بين صناديق | نقل نقدية بين الصناديق |
| `sp_CreateSalesReturn` | إنشاء مرتجع مبيعات | إرجاع منتجات للمخزون |
| `sp_GetDailySalesReport` | تقرير المبيعات اليومية | إحصائيات يومية |
| `sp_GetTopSellingProducts` | أفضل المنتجات مبيعاً | تحليل المبيعات |
| `sp_GetTopCustomers` | أفضل العملاء | تحليل العملاء |
| `sp_CalculateProfit` | حساب الأرباح | تقرير الأرباح |
| `sp_GetNextSequence` | الحصول على رقم تسلسلي | توليد أرقام الفواتير |

### مثال استخدام:

```sql
-- إنشاء فاتورة بيع
DECLARE @saleId INT;
DECLARE @items NVARCHAR(MAX) = '[
    {"productId": 1, "productName": "منتج 1", "quantity": 5, "unitPrice": 1000, "totalPrice": 5000},
    {"productId": 2, "productName": "منتج 2", "quantity": 3, "unitPrice": 2000, "totalPrice": 6000}
]';

EXEC sp_CreateSale 
    @invoiceNumber = 'INV-2025-0001',
    @customerId = 1,
    @customerName = N'أحمد محمد',
    @totalAmount = 11000,
    @discount = 1000,
    @paidAmount = 10000,
    @paymentType = N'نقدي',
    @saleItems = @items,
    @newSaleId = @saleId OUTPUT;
```

---

## 👁️ العروض (Views) للتقارير

| العرض | الوصف | الاستخدام |
|-------|-------|----------|
| `vw_SalesWithDetails` | مبيعات مع التفاصيل | تقارير المبيعات الشاملة |
| `vw_PurchasesWithDetails` | مشتريات مع التفاصيل | تقارير المشتريات |
| `vw_CurrentInventory` | المخزون الحالي | حالة المخزون |
| `vw_WarehouseInventory` | مخزون المستودعات | تفصيل المخزون بالمستودعات |
| `vw_CustomerBalances` | أرصدة العملاء | حسابات العملاء |
| `vw_SupplierBalances` | أرصدة الموردين | حسابات الموردين |
| `vw_ActiveInstallments` | الأقساط النشطة | متابعة الأقساط |
| `vw_CashboxMovements` | حركة الصناديق | حركة النقدية |
| `vw_TopSellingProducts` | الأكثر مبيعاً | تحليل المنتجات |
| `vw_ProfitLoss` | الأرباح والخسائر | التقارير المالية |
| `vw_InventoryMovements` | حركات المخزون | تتبع المخزون |

### مثال استخدام:

```sql
-- عرض المخزون الحالي
SELECT * FROM vw_CurrentInventory WHERE stockStatus = N'منخفض';

-- عرض أفضل 10 منتجات مبيعاً
SELECT TOP 10 * FROM vw_TopSellingProducts ORDER BY totalRevenue DESC;

-- عرض الأرباح اليومية
SELECT * FROM vw_ProfitLoss 
WHERE reportDate >= DATEADD(MONTH, -1, GETDATE())
ORDER BY reportDate DESC;
```

---

## استكشاف الأخطاء

### مشكلة: لا يمكن الاتصال بـ SQL Server

**الحل 1**: تفعيل TCP/IP Protocol
```
1. افتح SQL Server Configuration Manager
2. SQL Server Network Configuration > Protocols for SQLEXPRESS
3. انقر بزر الماوس الأيمن على TCP/IP > Enable
4. أعد تشغيل SQL Server Service
```

**الحل 2**: تفعيل SQL Server Authentication
```sql
-- في SSMS، انقر بزر الماوس الأيمن على السيرفر > Properties
-- Security > SQL Server and Windows Authentication mode
-- ثم أعد تشغيل SQL Server
```

### مشكلة: خطأ في الصلاحيات

```sql
-- امنح صلاحيات للمستخدم
USE SalesManagementDB;
GO
ALTER ROLE db_owner ADD MEMBER [YourUsername];
GO
```

---

## النسخ الاحتياطي

### إنشاء نسخة احتياطية:

```sql
BACKUP DATABASE SalesManagementDB
TO DISK = 'C:\Backups\SalesManagementDB.bak'
WITH FORMAT,
    MEDIANAME = 'SalesManagementBackup',
    NAME = 'Full Backup of SalesManagementDB';
GO
```

### استعادة نسخة احتياطية:

```sql
RESTORE DATABASE SalesManagementDB
FROM DISK = 'C:\Backups\SalesManagementDB.bak'
WITH REPLACE;
GO
```

---

## ملاحظات مهمة

⚠️ **الأمان**: 
- غيّر كلمة المرور الافتراضية `YourStrongPassword123!`
- استخدم كلمة مرور قوية تحتوي على: أحرف كبيرة، صغيرة، أرقام، ورموز

⚠️ **الأداء**:
- تم إنشاء Indexes على الأعمدة الأكثر استخداماً
- استخدم WHERE clauses في الاستعلامات لتحسين الأداء

⚠️ **النسخ الاحتياطي**:
- قم بإنشاء نسخ احتياطية بشكل دوري
- احفظ النسخ في مكان آمن

---

## الدعم

إذا واجهت أي مشاكل:
1. تحقق من ملف `database\troubleshooting.md`
2. راجع سجلات الأخطاء في SSMS
3. تحقق من اتصال الشبكة والصلاحيات

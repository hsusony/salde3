# دليل قاعدة بيانات SQL Server 2008 🗄️
# SQL Server 2008 Database Guide

## 📋 نظرة عامة | Overview

نسخة متكاملة من نظام إدارة المبيعات متوافقة مع **SQL Server 2008** والإصدارات الأحدث.
يحتوي النظام على **27 جدول** كامل مع جميع الميزات الأساسية والمتقدمة.

A complete version of the Sales Management System compatible with **SQL Server 2008** and later versions.
The system contains **27 complete tables** with all essential and advanced features.

---

## ✨ المميزات الرئيسية | Key Features

- ✅ **توافق كامل** مع SQL Server 2008, 2008 R2, 2012, 2014, 2016, 2017, 2019, 2022
- ✅ **27 جدول متكامل**: 16 جدول أساسي + 11 جدول متقدم
- ✅ **إدارة المبيعات**: فواتير، مرتجعات، أقساط، عروض أسعار
- ✅ **إدارة المشتريات**: فواتير مشتريات، مرتجعات، موردين
- ✅ **نظام محاسبي**: قيود محاسبية، دليل حسابات، صناديق متعددة
- ✅ **إدارة المخزون**: مستودعات متعددة، حركة المخزون، تعبئة وتغليف
- ✅ **سجل التدقيق**: تتبع شامل لجميع العمليات
- ✅ **بيانات أولية**: مستخدمين، منتجات، مستودعات جاهزة للاستخدام

---

## 📊 هيكل قاعدة البيانات | Database Structure

### الجداول الأساسية (16 جدول) | Core Tables

| الجدول | الوصف | Description |
|--------|--------|-------------|
| `Users` | المستخدمين | System users |
| `Customers` | العملاء | Customer records |
| `Products` | المنتجات | Product catalog |
| `Sales` | المبيعات | Sales invoices |
| `SaleItems` | تفاصيل المبيعات | Sale line items |
| `Purchases` | المشتريات | Purchase invoices |
| `PurchaseItems` | تفاصيل المشتريات | Purchase line items |
| `Installments` | الأقساط | Payment installments |
| `Warehouses` | المستودعات | Warehouse locations |
| `InventoryTransactions` | حركة المخزون | Inventory movements |
| `CashVouchers` | سندات القبض | Receipt vouchers |
| `PaymentVouchers` | سندات الصرف | Payment vouchers |
| `PendingOrders` | الطلبيات المعلقة | Pending orders |
| `Quotations` | عروض الأسعار | Price quotations |
| `QuotationItems` | تفاصيل العروض | Quotation line items |
| `AuditLogs` | سجل التدقيق | Audit trail |

### الجداول المتقدمة (11 جدول) | Advanced Tables

| الجدول | الوصف | Description |
|--------|--------|-------------|
| `Cashboxes` | الصناديق | Cash registers |
| `TransferVouchers` | سندات التحويل | Transfer vouchers |
| `JournalEntries` | القيود المحاسبية | Journal entries |
| `JournalEntryLines` | تفاصيل القيود | Journal entry lines |
| `Packaging` | التعبئة والتغليف | Packaging units |
| `WarehouseStock` | مخزون المستودعات | Warehouse inventory |
| `SalesReturns` | مرتجعات المبيعات | Sales returns |
| `SalesReturnItems` | تفاصيل المرتجعات | Return line items |
| `PurchaseReturns` | مرتجعات المشتريات | Purchase returns |
| `PurchaseReturnItems` | تفاصيل مرتجعات المشتريات | Purchase return items |
| `ChartOfAccounts` | دليل الحسابات | Chart of accounts |
| `Suppliers` | الموردين | Supplier records |

---

## 🚀 التثبيت السريع | Quick Installation

### الطريقة 1: ملف التثبيت التلقائي (الأسهل) ⚡

```batch
# في مجلد database، قم بتنفيذ:
setup_database_2008.bat
```

سيقوم الملف بـ:
1. التحقق من وجود `sqlcmd`
2. طلب معلومات الاتصال بـ SQL Server
3. تنفيذ جميع السكربتات تلقائياً
4. عرض تقرير بالنتائج

### الطريقة 2: التثبيت اليدوي عبر SSMS

1. **افتح SQL Server Management Studio**
2. **اتصل بالخادم**
3. **نفذ السكربتات بالترتيب:**

```sql
-- 1. الجداول الأساسية (16 جدول)
:r create_database_2008.sql

-- 2. الجداول المتقدمة (11 جدول)
:r 02_additional_tables_2008.sql

-- 3. البيانات الأولية
:r 03_initial_data_2008.sql
```

### الطريقة 3: التثبيت الشامل (سكربت واحد)

```sql
:r 00_setup_complete_2008.sql
```

---

## 🔐 معلومات الدخول الافتراضية | Default Login

```
اسم المستخدم / Username: admin
كلمة المرور / Password:   admin123
```

> ⚠️ **تحذير أمني**: يُرجى تغيير كلمة المرور فوراً بعد التثبيت!

---

## 📝 أمثلة الاستخدام | Usage Examples

### 1. إضافة عميل جديد | Add New Customer

```sql
INSERT INTO Customers (name, phone, address, balance, notes)
VALUES (N'محمد علي', '07701234567', N'بغداد - الكرادة', 0, N'عميل جديد');
```

### 2. إضافة منتج جديد | Add New Product

```sql
INSERT INTO Products (
    name, barcode, category, unit, 
    purchasePrice, sellingPrice, quantity, minQuantity, isActive
)
VALUES (
    N'لابتوب Dell', '1234567890123', N'إلكترونيات', N'حبة',
    500000, 650000, 10, 2, 1
);
```

### 3. إنشاء فاتورة مبيعات | Create Sales Invoice

```sql
-- إدخال الفاتورة الرئيسية
INSERT INTO Sales (
    invoiceNumber, customerId, customerName, totalAmount,
    discount, paymentType, saleDate
)
VALUES (
    'INV-001', 1, N'محمد علي', 650000,
    0, N'نقدي', GETDATE()
);

-- الحصول على معرف الفاتورة
DECLARE @saleId INT = SCOPE_IDENTITY();

-- إضافة تفاصيل الفاتورة
INSERT INTO SaleItems (saleId, productId, productName, quantity, unitPrice, totalPrice)
VALUES (@saleId, 1, N'لابتوب Dell', 1, 650000, 650000);

-- تحديث المخزون
UPDATE Products 
SET quantity = quantity - 1 
WHERE id = 1;
```

### 4. إنشاء قيد محاسبي | Create Journal Entry

```sql
-- إنشاء القيد
INSERT INTO JournalEntries (
    entryNumber, entryDate, description,
    totalDebit, totalCredit, isBalanced, status
)
VALUES (
    'JE-001', GETDATE(), N'قيد بيع نقدي',
    650000, 650000, 1, N'معتمد'
);

DECLARE @entryId INT = SCOPE_IDENTITY();

-- إضافة سطور القيد
INSERT INTO JournalEntryLines (journalEntryId, accountName, accountCode, debit, credit)
VALUES 
    (@entryId, N'النقدية بالصندوق', '1110', 650000, 0),
    (@entryId, N'إيرادات المبيعات', '4100', 0, 650000);
```

### 5. تحويل بين صندوقين | Transfer Between Cashboxes

```sql
INSERT INTO TransferVouchers (
    voucherNumber, fromCashboxId, toCashboxId,
    amount, notes, transferDate
)
VALUES (
    'TR-001', 1, 2, 100000,
    N'تحويل للفرع الأول', GETDATE()
);

-- تحديث أرصدة الصناديق
UPDATE Cashboxes SET balance = balance - 100000 WHERE id = 1;
UPDATE Cashboxes SET balance = balance + 100000 WHERE id = 2;
```

### 6. إنشاء مرتجع مبيعات | Create Sales Return

```sql
-- إدخال المرتجع
INSERT INTO SalesReturns (
    returnNumber, saleId, originalInvoiceNumber,
    customerId, customerName, totalAmount, refundAmount,
    refundType, reason, returnDate
)
VALUES (
    'RET-001', 1, 'INV-001',
    1, N'محمد علي', 650000, 650000,
    N'نقدي', N'المنتج معيب', GETDATE()
);

DECLARE @returnId INT = SCOPE_IDENTITY();

-- إضافة تفاصيل المرتجع
INSERT INTO SalesReturnItems (
    salesReturnId, productId, productName,
    quantity, unitPrice, totalPrice
)
VALUES (@returnId, 1, N'لابتوب Dell', 1, 650000, 650000);

-- إعادة المخزون
UPDATE Products 
SET quantity = quantity + 1 
WHERE id = 1;
```

---

## 📊 استعلامات مفيدة | Useful Queries

### رصيد العملاء | Customer Balances

```sql
SELECT 
    name AS [اسم العميل],
    phone AS [الهاتف],
    balance AS [الرصيد],
    CASE WHEN balance > 0 THEN N'له' ELSE N'عليه' END AS [الحالة]
FROM Customers
WHERE isActive = 1
ORDER BY balance DESC;
```

### المنتجات الأكثر مبيعاً | Top Selling Products

```sql
SELECT TOP 10
    p.name AS [المنتج],
    SUM(si.quantity) AS [الكمية المباعة],
    SUM(si.totalPrice) AS [إجمالي المبيعات]
FROM Products p
INNER JOIN SaleItems si ON p.id = si.productId
INNER JOIN Sales s ON si.saleId = s.id
WHERE s.saleDate >= DATEADD(MONTH, -1, GETDATE())
GROUP BY p.id, p.name
ORDER BY SUM(si.totalPrice) DESC;
```

### المخزون الحالي | Current Inventory

```sql
SELECT 
    p.name AS [المنتج],
    p.category AS [الفئة],
    w.name AS [المستودع],
    ws.quantity AS [الكمية],
    ws.minQuantity AS [الحد الأدنى],
    CASE 
        WHEN ws.quantity <= ws.minQuantity THEN N'⚠️ تحذير'
        ELSE N'✅ جيد'
    END AS [الحالة]
FROM WarehouseStock ws
INNER JOIN Products p ON ws.productId = p.id
INNER JOIN Warehouses w ON ws.warehouseId = w.id
ORDER BY ws.quantity;
```

### الأرباح اليومية | Daily Profit

```sql
SELECT 
    CONVERT(DATE, saleDate) AS [التاريخ],
    COUNT(*) AS [عدد الفواتير],
    SUM(totalAmount - discount) AS [إجمالي المبيعات],
    SUM((si.unitPrice - p.purchasePrice) * si.quantity) AS [صافي الربح]
FROM Sales s
INNER JOIN SaleItems si ON s.id = si.saleId
INNER JOIN Products p ON si.productId = p.id
WHERE s.saleDate >= DATEADD(DAY, -30, GETDATE())
GROUP BY CONVERT(DATE, saleDate)
ORDER BY [التاريخ] DESC;
```

### أرصدة الصناديق | Cashbox Balances

```sql
SELECT 
    name AS [اسم الصندوق],
    code AS [الكود],
    balance AS [الرصيد],
    currency AS [العملة],
    CASE WHEN isActive = 1 THEN N'نشط' ELSE N'غير نشط' END AS [الحالة]
FROM Cashboxes
ORDER BY balance DESC;
```

---

## 🔧 الصيانة والنسخ الاحتياطي | Maintenance & Backup

### نسخ احتياطي لقاعدة البيانات | Database Backup

```sql
BACKUP DATABASE SalesManagementDB 
TO DISK = 'C:\Backups\SalesDB_Backup.bak'
WITH FORMAT, 
     NAME = 'Full Database Backup',
     DESCRIPTION = 'نسخة احتياطية كاملة';
```

### استعادة من نسخة احتياطية | Restore from Backup

```sql
RESTORE DATABASE SalesManagementDB 
FROM DISK = 'C:\Backups\SalesDB_Backup.bak'
WITH REPLACE;
```

### تحسين الأداء | Performance Optimization

```sql
-- إعادة بناء الفهارس
ALTER INDEX ALL ON Products REBUILD;
ALTER INDEX ALL ON Sales REBUILD;
ALTER INDEX ALL ON SaleItems REBUILD;

-- تحديث الإحصائيات
UPDATE STATISTICS Products;
UPDATE STATISTICS Sales;
UPDATE STATISTICS SaleItems;
```

---

## 🔄 التوافق والترقية | Compatibility & Upgrade

### الفروقات عن الإصدار الحديث | Differences from Modern Version

| الميزة | SQL Server 2008 | SQL Server 2012+ |
|--------|-----------------|------------------|
| نوع التاريخ | `DATETIME` | `DATETIME2` |
| دقة التاريخ | 3.33 مللي ثانية | 100 نانو ثانية |
| دعم JSON | ❌ غير متوفر | ✅ `FOR JSON`, `OPENJSON` |
| الإجراءات المخزنة | مبسطة | متقدمة مع JSON |
| Window Functions | محدودة | كاملة |

### الترقية للإصدار الحديث | Upgrade to Modern Version

```sql
-- تحويل DATETIME إلى DATETIME2
ALTER TABLE Sales ALTER COLUMN saleDate DATETIME2(7);
ALTER TABLE Purchases ALTER COLUMN purchaseDate DATETIME2(7);
-- ... كرر لجميع الجداول
```

---

## ⚠️ ملاحظات هامة | Important Notes

1. **الأمان**: غيّر كلمة المرور الافتراضية فوراً
2. **النسخ الاحتياطي**: قم بإنشاء نسخة احتياطية يومية
3. **الفهارس**: راقب أداء الفهارس وأعد بناءها عند الحاجة
4. **الصلاحيات**: امنح المستخدمين الصلاحيات المناسبة فقط
5. **السجلات**: راجع جدول `AuditLogs` بانتظام
6. **المخزون**: راقب المنتجات التي وصلت للحد الأدنى

---

## 📞 الدعم والمساعدة | Support

للمزيد من المعلومات، راجع:
- 📄 `DATABASE_STRUCTURE.md` - هيكل قاعدة البيانات التفصيلي
- 📄 `HOW_DATABASE_WORKS.md` - شرح آلية عمل القاعدة
- 📄 `README.md` - الملف الرئيسي للمشروع

---

## 📜 الرخصة | License

هذا المشروع مرخص تحت رخصة MIT - راجع ملف `LICENSE` للتفاصيل.

---

<div dir="rtl">

## ✅ قائمة التحقق من التثبيت

- [ ] تثبيت SQL Server 2008+
- [ ] تنفيذ `create_database_2008.sql`
- [ ] تنفيذ `02_additional_tables_2008.sql`
- [ ] تنفيذ `03_initial_data_2008.sql`
- [ ] تسجيل الدخول بـ admin/admin123
- [ ] تغيير كلمة المرور الافتراضية
- [ ] إنشاء نسخة احتياطية أولية
- [ ] اختبار إنشاء فاتورة مبيعات
- [ ] التحقق من عمل المخزون

</div>

---

**تم بناؤه بـ ❤️ للمطورين العرب**

**Built with ❤️ for Arab Developers**

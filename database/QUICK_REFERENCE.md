# Database Quick Reference Guide 📚
# دليل مرجعي سريع لقاعدة البيانات

## 🚀 البدء السريع

### تثبيت قاعدة البيانات في 3 خطوات:

```bash
# 1. انتقل لمجلد قاعدة البيانات
cd database

# 2. شغل سكريبت الإعداد
setup_database.bat

# 3. انتظر رسالة النجاح ✅
```

---

## 📊 إحصائيات قاعدة البيانات

- **إجمالي الجداول**: 27 جدول
- **الإجراءات المخزنة**: 10 إجراءات
- **العروض (Views)**: 11 عرض
- **المشغلات (Triggers)**: 15 مشغل
- **الفهارس (Indexes)**: 25+ فهرس

---

## 🔐 بيانات الدخول الافتراضية

```
Username: admin
Password: admin123
```

⚠️ **مهم**: غيّر كلمة المرور فوراً بعد أول دخول!

---

## 📋 الجداول الرئيسية

### إدارة المبيعات
```sql
-- استعلام مبيعات اليوم
SELECT * FROM vw_SalesWithDetails 
WHERE CAST(saleDate AS DATE) = CAST(GETDATE() AS DATE);

-- إجمالي المبيعات اليومية
EXEC sp_GetDailySalesReport @reportDate = '2025-11-03';
```

### إدارة المخزون
```sql
-- المنتجات المنخفضة
SELECT * FROM vw_CurrentInventory WHERE stockStatus = N'منخفض';

-- حركات المخزون
SELECT * FROM vw_InventoryMovements 
WHERE transactionDate >= DATEADD(DAY, -7, GETDATE());
```

### التقارير المالية
```sql
-- تقرير الأرباح
EXEC sp_CalculateProfit 
    @startDate = '2025-01-01',
    @endDate = '2025-12-31';

-- أفضل العملاء
EXEC sp_GetTopCustomers @topN = 10;
```

---

## 🛠️ عمليات شائعة

### إنشاء فاتورة بيع

```sql
DECLARE @saleId INT;
DECLARE @items NVARCHAR(MAX) = '[
    {
        "productId": 1, 
        "productName": "منتج تجريبي", 
        "quantity": 5, 
        "unitPrice": 10000, 
        "totalPrice": 50000
    }
]';

EXEC sp_CreateSale 
    @invoiceNumber = 'INV-2025-0001',
    @customerId = 1,
    @customerName = N'عميل تجريبي',
    @totalAmount = 50000,
    @discount = 0,
    @paidAmount = 50000,
    @paymentType = N'نقدي',
    @saleItems = @items,
    @newSaleId = @saleId OUTPUT;
```

### إنشاء فاتورة شراء

```sql
DECLARE @purchaseId INT;
DECLARE @items NVARCHAR(MAX) = '[
    {
        "productId": 1, 
        "productName": "منتج للشراء", 
        "quantity": 100, 
        "unitPrice": 5000, 
        "totalPrice": 500000
    }
]';

EXEC sp_CreatePurchase 
    @invoiceNumber = 'PUR-2025-0001',
    @supplierId = 1,
    @supplierName = N'مورد تجريبي',
    @totalAmount = 500000,
    @paidAmount = 500000,
    @paymentType = N'نقدي',
    @purchaseItems = @items,
    @newPurchaseId = @purchaseId OUTPUT;
```

### تحويل بين الصناديق

```sql
EXEC sp_TransferBetweenCashboxes 
    @voucherNumber = 'TRN-2025-0001',
    @fromCashboxId = 1,
    @toCashboxId = 2,
    @amount = 100000,
    @transferType = N'صندوق إلى صندوق',
    @notes = N'تحويل تجريبي';
```

---

## 📈 التقارير المتوفرة

### 1. تقرير المبيعات اليومية
```sql
EXEC sp_GetDailySalesReport @reportDate = GETDATE();
```

### 2. أفضل 10 منتجات مبيعاً
```sql
EXEC sp_GetTopSellingProducts 
    @topN = 10,
    @startDate = '2025-01-01',
    @endDate = '2025-12-31';
```

### 3. أفضل العملاء
```sql
EXEC sp_GetTopCustomers 
    @topN = 10,
    @startDate = '2025-01-01',
    @endDate = '2025-12-31';
```

### 4. تقرير الأرباح
```sql
EXEC sp_CalculateProfit 
    @startDate = '2025-01-01',
    @endDate = '2025-12-31';
```

### 5. أرصدة العملاء
```sql
SELECT * FROM vw_CustomerBalances 
WHERE balance > 0 
ORDER BY balance DESC;
```

### 6. حالة المخزون
```sql
SELECT * FROM vw_CurrentInventory 
ORDER BY 
    CASE stockStatus 
        WHEN N'نفذ' THEN 1
        WHEN N'منخفض' THEN 2
        ELSE 3
    END;
```

---

## 🔢 الحصول على رقم فاتورة تلقائي

```sql
DECLARE @nextInvoice NVARCHAR(50);

EXEC sp_GetNextSequence 
    @counterName = N'فواتير البيع',
    @nextNumber = @nextInvoice OUTPUT;

SELECT @nextInvoice AS InvoiceNumber;
-- النتيجة: INV-2025-0001
```

---

## 🔍 استعلامات مفيدة

### عرض جميع الجداول
```sql
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
```

### عرض جميع الإجراءات المخزنة
```sql
SELECT name 
FROM sys.procedures 
ORDER BY name;
```

### عرض جميع العروض (Views)
```sql
SELECT name 
FROM sys.views 
ORDER BY name;
```

### عرض جميع المشغلات (Triggers)
```sql
SELECT name, OBJECT_NAME(parent_id) AS TableName
FROM sys.triggers 
ORDER BY name;
```

---

## 🗃️ النسخ الاحتياطي والاستعادة

### إنشاء نسخة احتياطية
```sql
BACKUP DATABASE SalesManagementDB
TO DISK = 'C:\Backups\SalesDB_20251103.bak'
WITH FORMAT, COMPRESSION,
    NAME = 'SalesManagementDB Full Backup';
```

### استعادة نسخة احتياطية
```sql
-- أولاً، ضع قاعدة البيانات في وضع Single User
ALTER DATABASE SalesManagementDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

-- استعادة النسخة
RESTORE DATABASE SalesManagementDB
FROM DISK = 'C:\Backups\SalesDB_20251103.bak'
WITH REPLACE;

-- إعادة قاعدة البيانات لوضع Multi User
ALTER DATABASE SalesManagementDB SET MULTI_USER;
```

---

## 🔧 الصيانة الدورية

### إعادة بناء الفهارس
```sql
USE SalesManagementDB;
GO

-- إعادة بناء جميع الفهارس
EXEC sp_MSforeachtable @command1="DBCC DBREINDEX('?')";
```

### تحديث الإحصائيات
```sql
USE SalesManagementDB;
GO

-- تحديث إحصائيات جميع الجداول
EXEC sp_updatestats;
```

### تقليص حجم قاعدة البيانات
```sql
-- تقليص ملفات السجل
DBCC SHRINKFILE (SalesManagementDB_log, 1);

-- تقليص ملفات البيانات
DBCC SHRINKDATABASE (SalesManagementDB);
```

---

## 🐛 استكشاف الأخطاء

### مشكلة: لا يمكن الاتصال بقاعدة البيانات

```sql
-- تحقق من حالة SQL Server
SELECT @@SERVERNAME AS ServerName, @@VERSION AS Version;

-- تحقق من قواعد البيانات المتاحة
SELECT name FROM sys.databases;
```

### مشكلة: خطأ في الصلاحيات

```sql
-- منح صلاحيات للمستخدم الحالي
USE SalesManagementDB;
GO
ALTER ROLE db_owner ADD MEMBER [YourUsername];
```

### مشكلة: بطء الأداء

```sql
-- عرض الاستعلامات البطيئة
SELECT TOP 10
    total_elapsed_time/execution_count AS avg_elapsed_time,
    SUBSTRING(st.text, (qs.statement_start_offset/2)+1,
        ((CASE qs.statement_end_offset
            WHEN -1 THEN DATALENGTH(st.text)
            ELSE qs.statement_end_offset
        END - qs.statement_start_offset)/2) + 1) AS statement_text
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
ORDER BY avg_elapsed_time DESC;
```

---

## 📞 الدعم والمساعدة

- **الوثائق الكاملة**: `README_SQL_SERVER.md`
- **السكريبتات**: موجودة في مجلد `database/`
- **الملفات المهمة**:
  - `create_database.sql` - الجداول الأساسية
  - `02_additional_tables.sql` - الجداول الإضافية
  - `03_stored_procedures.sql` - الإجراءات المخزنة
  - `04_views.sql` - العروض
  - `05_triggers.sql` - المشغلات
  - `06_initial_data.sql` - البيانات الأولية

---

**آخر تحديث**: نوفمبر 2025  
**الإصدار**: 1.0.0

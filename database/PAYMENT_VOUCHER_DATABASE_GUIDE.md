# 🗄️ دليل قاعدة بيانات سندات الدفع

## نظرة عامة

تم إنشاء نظام متكامل لإدارة سندات الدفع يشمل:
- سندات الدفع العادية
- سندات الدفع المتعددة
- سندات الدفع بعملتين
- سندات الصرف
- إدارة أرصدة العملات

## 📊 هيكل الجداول

### 1. PaymentVouchers (سندات الدفع الرئيسية)

```sql
id INT                          -- المعرف الفريد
voucherNumber NVARCHAR(50)      -- رقم السند
voucherDate DATETIME2           -- تاريخ السند
accountName NVARCHAR(200)       -- اسم الحساب
cashAccount NVARCHAR(100)       -- حساب الصندوق (181، 182، 183)
amount DECIMAL(18, 2)           -- المبلغ الأصلي
discount DECIMAL(18, 2)         -- الخصم المكتسب
totalAmount (حساب تلقائي)       -- المبلغ الإجمالي = amount - discount
amountInWords NVARCHAR(500)     -- المبلغ كتابة
currency NVARCHAR(50)           -- العملة (دينار، دولار، يورو)
exchangeRate DECIMAL(18, 4)     -- سعر الصرف
notes NVARCHAR(MAX)             -- ملاحظات
description NVARCHAR(MAX)       -- البيان
previousOrder DECIMAL(18, 2)    -- الطلب السابق
currentOrder DECIMAL(18, 2)     -- الطلب الحالي
status NVARCHAR(50)             -- الحالة (مكتمل، ملغي، معلق)
isPrinted BIT                   -- هل تم طباعة السند
printCount INT                  -- عدد مرات الطباعة
createdBy INT                   -- المستخدم الذي أنشأ السند
approvedBy INT                  -- المستخدم الذي وافق على السند
createdAt DATETIME2             -- تاريخ الإنشاء
updatedAt DATETIME2             -- تاريخ آخر تعديل
approvedAt DATETIME2            -- تاريخ الموافقة
```

**الفهارس (Indexes):**
- `IX_PaymentVouchers_VoucherNumber` - على رقم السند
- `IX_PaymentVouchers_VoucherDate` - على التاريخ
- `IX_PaymentVouchers_AccountName` - على اسم الحساب
- `IX_PaymentVouchers_Status` - على الحالة
- `IX_PaymentVouchers_CreatedAt` - على تاريخ الإنشاء

### 2. MultiplePaymentVouchers (سندات الدفع المتعددة)

```sql
id INT                          -- المعرف الفريد
voucherNumber NVARCHAR(50)      -- رقم السند
voucherDate DATETIME2           -- تاريخ السند
beneficiaryName NVARCHAR(200)   -- اسم المستفيد
totalAmount DECIMAL(18, 2)      -- المبلغ الإجمالي (يتم حسابه تلقائياً)
notes NVARCHAR(MAX)             -- ملاحظات
status NVARCHAR(50)             -- الحالة
isPrinted BIT                   -- هل تم طباعة السند
createdAt DATETIME2             -- تاريخ الإنشاء
updatedAt DATETIME2             -- تاريخ آخر تعديل
```

### 3. PaymentVoucherItems (تفاصيل السندات المتعددة)

```sql
id INT                          -- المعرف الفريد
voucherId INT                   -- معرف السند الرئيسي
accountName NVARCHAR(200)       -- اسم الحساب
currentAmount DECIMAL(18, 2)    -- المبلغ الحالي
previousAmount DECIMAL(18, 2)   -- المبلغ السابق
totalAmount (حساب تلقائي)       -- المبلغ الكلي = current + previous
notes NVARCHAR(MAX)             -- ملاحظات
createdAt DATETIME2             -- تاريخ الإنشاء
```

### 4. DualCurrencyPayments (سندات الدفع بعملتين)

```sql
id INT                          -- المعرف الفريد
voucherNumber NVARCHAR(50)      -- رقم السند
voucherDate DATETIME2           -- تاريخ السند
beneficiaryName NVARCHAR(200)   -- اسم المستفيد

-- معلومات الدينار العراقي
amountIQD DECIMAL(18, 2)        -- المبلغ بالدينار
paymentMethodIQD NVARCHAR(50)   -- طريقة الدفع (نقدي، شيك)
checkNumberIQD NVARCHAR(50)     -- رقم الشيك
checkDateIQD DATETIME2          -- تاريخ الشيك
bankNameIQD NVARCHAR(200)       -- اسم البنك

-- معلومات الدولار
amountUSD DECIMAL(18, 2)        -- المبلغ بالدولار
paymentMethodUSD NVARCHAR(50)   -- طريقة الدفع
checkNumberUSD NVARCHAR(50)     -- رقم الشيك
checkDateUSD DATETIME2          -- تاريخ الشيك
bankNameUSD NVARCHAR(200)       -- اسم البنك

exchangeRate DECIMAL(18, 4)     -- سعر الصرف
notes NVARCHAR(MAX)             -- ملاحظات
status NVARCHAR(50)             -- الحالة
isPrinted BIT                   -- هل تم طباعة السند
createdAt DATETIME2             -- تاريخ الإنشاء
updatedAt DATETIME2             -- تاريخ آخر تعديل
```

### 5. DisbursementVouchers (سندات الصرف)

```sql
id INT                          -- المعرف الفريد
voucherNumber NVARCHAR(50)      -- رقم السند
voucherDate DATETIME2           -- تاريخ السند
recipientName NVARCHAR(200)     -- اسم المستلم
recipientIdNumber NVARCHAR(50)  -- رقم الهوية
amount DECIMAL(18, 2)           -- المبلغ
amountInWords NVARCHAR(500)     -- المبلغ كتابة
purpose NVARCHAR(200)           -- الغرض من الصرف
category NVARCHAR(100)          -- التصنيف (مصروفات عامة، رواتب، إلخ)
notes NVARCHAR(MAX)             -- ملاحظات
status NVARCHAR(50)             -- الحالة
isPrinted BIT                   -- هل تم طباعة السند
createdAt DATETIME2             -- تاريخ الإنشاء
updatedAt DATETIME2             -- تاريخ آخر تعديل
```

### 6. CurrencyBalances (أرصدة العملات)

```sql
id INT                          -- المعرف الفريد
currency NVARCHAR(50)           -- نوع العملة
balance DECIMAL(18, 2)          -- الرصيد
lastUpdated DATETIME2           -- تاريخ آخر تحديث
createdAt DATETIME2             -- تاريخ الإنشاء
updatedAt DATETIME2             -- تاريخ آخر تعديل
```

## 🔧 Stored Procedures

### sp_AddPaymentVoucher - إضافة سند دفع

```sql
EXEC sp_AddPaymentVoucher
    @voucherNumber = N'PAY-2025-001',
    @voucherDate = '2025-01-15',
    @accountName = N'محمد أحمد',
    @cashAccount = N'صندوق 181',
    @amount = 1000000,
    @discount = 50000,
    @amountInWords = N'تسعمائة وخمسون ألف دينار',
    @currency = N'دينار',
    @exchangeRate = 1.0,
    @notes = N'دفع مستحقات',
    @description = N'دفع لحساب رأس المال',
    @previousOrder = 0,
    @currentOrder = 950000,
    @createdBy = 1,
    @newId = @id OUTPUT;
```

### sp_GetPaymentVouchers - عرض سندات الدفع

```sql
-- عرض جميع السندات
EXEC sp_GetPaymentVouchers;

-- عرض السندات في فترة محددة
EXEC sp_GetPaymentVouchers 
    @startDate = '2025-01-01',
    @endDate = '2025-12-31';

-- عرض السندات حسب الحالة
EXEC sp_GetPaymentVouchers 
    @status = N'مكتمل';

-- عرض السندات حسب اسم الحساب
EXEC sp_GetPaymentVouchers 
    @accountName = N'محمد';
```

### sp_DeletePaymentVoucher - حذف سند دفع

```sql
EXEC sp_DeletePaymentVoucher @id = 1;
```

## 📈 Views (العروض)

### vw_PaymentVouchersDetails - تفاصيل السندات

```sql
SELECT * FROM vw_PaymentVouchersDetails
WHERE voucherYear = 2025
ORDER BY voucherDate DESC;
```

### vw_PaymentVouchersStats - إحصائيات السندات

```sql
SELECT * FROM vw_PaymentVouchersStats;
```

**النتيجة:**
```
currency    | voucherCount | totalPaid  | averagePaid | minPaid | maxPaid
------------|--------------|------------|-------------|---------|--------
دينار       | 150          | 75,000,000 | 500,000     | 10,000  | 5,000,000
دولار       | 50           | 25,000     | 500         | 50      | 2,000
```

## 🔧 Functions

### fn_GetPaymentVoucherTotalByPeriod - المجموع حسب الفترة

```sql
-- المجموع لجميع العملات
SELECT dbo.fn_GetPaymentVoucherTotalByPeriod(
    '2025-01-01', 
    '2025-12-31', 
    NULL
) as TotalForYear;

-- المجموع بالدينار فقط
SELECT dbo.fn_GetPaymentVoucherTotalByPeriod(
    '2025-01-01', 
    '2025-12-31', 
    N'دينار'
) as TotalIQD;
```

## 🔄 Triggers (المشغلات)

### TR_UpdateMultiplePaymentVoucherTotal

يتم تشغيله تلقائياً عند:
- إضافة بند جديد لسند دفع متعدد
- تعديل بند في سند دفع متعدد
- حذف بند من سند دفع متعدد

**الوظيفة:** تحديث المبلغ الإجمالي للسند تلقائياً

### TR_UpdatePaymentVoucherTimestamp

يتم تشغيله تلقائياً عند:
- تعديل أي سند دفع

**الوظيفة:** تحديث حقل `updatedAt` تلقائياً

## 📝 أمثلة الاستخدام

### مثال 1: إضافة سند دفع بسيط

```sql
DECLARE @newVoucherId INT;

EXEC sp_AddPaymentVoucher
    @voucherNumber = N'PAY-2025-' + CAST(NEXT VALUE FOR VoucherSeq AS NVARCHAR),
    @voucherDate = GETDATE(),
    @accountName = N'علي حسن',
    @cashAccount = N'صندوق 181',
    @amount = 500000,
    @discount = 0,
    @amountInWords = N'خمسمائة ألف دينار عراقي',
    @currency = N'دينار',
    @exchangeRate = 1.0,
    @notes = N'دفع لحساب التوريدات',
    @description = N'دفع مستحقات المورد',
    @currentOrder = 500000,
    @createdBy = 1,
    @newId = @newVoucherId OUTPUT;

SELECT @newVoucherId as NewVoucherId;
```

### مثال 2: البحث عن السندات

```sql
-- البحث بالرقم
SELECT * FROM PaymentVouchers 
WHERE voucherNumber = N'PAY-2025-001';

-- البحث بالتاريخ
SELECT * FROM PaymentVouchers 
WHERE voucherDate BETWEEN '2025-01-01' AND '2025-01-31';

-- البحث بالمبلغ
SELECT * FROM PaymentVouchers 
WHERE totalAmount > 1000000;

-- البحث باسم الحساب
SELECT * FROM PaymentVouchers 
WHERE accountName LIKE N'%محمد%';
```

### مثال 3: الإحصائيات

```sql
-- إجمالي المدفوعات اليوم
SELECT SUM(totalAmount) as TotalToday
FROM PaymentVouchers
WHERE CAST(voucherDate AS DATE) = CAST(GETDATE() AS DATE);

-- عدد السندات حسب الحالة
SELECT status, COUNT(*) as Count, SUM(totalAmount) as Total
FROM PaymentVouchers
GROUP BY status;

-- أكبر 10 مدفوعات
SELECT TOP 10 
    voucherNumber,
    accountName,
    totalAmount,
    voucherDate
FROM PaymentVouchers
ORDER BY totalAmount DESC;
```

### مثال 4: التقارير

```sql
-- تقرير شهري
SELECT 
    YEAR(voucherDate) as Year,
    MONTH(voucherDate) as Month,
    COUNT(*) as VoucherCount,
    SUM(amount) as TotalAmount,
    SUM(discount) as TotalDiscount,
    SUM(totalAmount) as NetAmount
FROM PaymentVouchers
WHERE status = N'مكتمل'
GROUP BY YEAR(voucherDate), MONTH(voucherDate)
ORDER BY Year DESC, Month DESC;

-- تقرير حسب الصندوق
SELECT 
    cashAccount,
    COUNT(*) as VoucherCount,
    SUM(totalAmount) as Total,
    AVG(totalAmount) as Average
FROM PaymentVouchers
WHERE status = N'مكتمل'
GROUP BY cashAccount;

-- تقرير حسب العملة
SELECT 
    currency,
    COUNT(*) as VoucherCount,
    SUM(totalAmount) as Total
FROM PaymentVouchers
WHERE status = N'مكتمل'
GROUP BY currency;
```

## 🔒 الأمان والصلاحيات

### تطبيق صلاحيات المستخدمين

```sql
-- منح صلاحيات القراءة
GRANT SELECT ON PaymentVouchers TO CashierRole;
GRANT SELECT ON vw_PaymentVouchersDetails TO CashierRole;

-- منح صلاحيات الإضافة
GRANT INSERT ON PaymentVouchers TO CashierRole;
GRANT EXECUTE ON sp_AddPaymentVoucher TO CashierRole;

-- منح صلاحيات التعديل (للمديرين فقط)
GRANT UPDATE ON PaymentVouchers TO ManagerRole;

-- منح صلاحيات الحذف (للمديرين فقط)
GRANT DELETE ON PaymentVouchers TO ManagerRole;
GRANT EXECUTE ON sp_DeletePaymentVoucher TO ManagerRole;
```

## 🔧 الصيانة

### النسخ الاحتياطي

```sql
-- نسخ احتياطي للجدول
SELECT * INTO PaymentVouchers_Backup_20250115
FROM PaymentVouchers;

-- استعادة من النسخة الاحتياطية
INSERT INTO PaymentVouchers
SELECT * FROM PaymentVouchers_Backup_20250115
WHERE id NOT IN (SELECT id FROM PaymentVouchers);
```

### إعادة بناء الفهارس

```sql
-- إعادة بناء جميع الفهارس
ALTER INDEX ALL ON PaymentVouchers REBUILD;

-- تحديث الإحصائيات
UPDATE STATISTICS PaymentVouchers;
```

### تنظيف البيانات القديمة

```sql
-- حذف السندات الملغاة القديمة (أقدم من سنة)
DELETE FROM PaymentVouchers
WHERE status = N'ملغي'
AND voucherDate < DATEADD(YEAR, -1, GETDATE());

-- أرشفة السندات القديمة
INSERT INTO PaymentVouchers_Archive
SELECT * FROM PaymentVouchers
WHERE voucherDate < DATEADD(YEAR, -2, GETDATE());
```

## 📊 الأداء

### نصائح لتحسين الأداء

1. **استخدام الفهارس المناسبة**
   - تم إنشاء فهارس على الأعمدة الأكثر استخداماً في البحث

2. **تجنب SELECT ***
   - حدد الأعمدة المطلوبة فقط

3. **استخدام Views للاستعلامات المعقدة**
   - استخدم `vw_PaymentVouchersDetails` بدلاً من JOIN

4. **تقسيم البيانات (Partitioning)**
   ```sql
   -- تقسيم الجدول حسب السنة (للبيانات الكبيرة)
   CREATE PARTITION FUNCTION PF_PaymentVouchers_Year (DATETIME2)
   AS RANGE RIGHT FOR VALUES ('2024-01-01', '2025-01-01', '2026-01-01');
   ```

## 🐛 استكشاف الأخطاء

### مشكلة: خطأ في إضافة سند دفع

```sql
-- التحقق من رقم السند المكرر
SELECT * FROM PaymentVouchers 
WHERE voucherNumber = N'PAY-2025-001';

-- التحقق من القيود
SELECT * FROM sys.check_constraints 
WHERE parent_object_id = OBJECT_ID('PaymentVouchers');
```

### مشكلة: المجموع غير صحيح في السندات المتعددة

```sql
-- إعادة حساب المجموع يدوياً
UPDATE MultiplePaymentVouchers
SET totalAmount = (
    SELECT SUM(currentAmount + previousAmount)
    FROM PaymentVoucherItems
    WHERE voucherId = MultiplePaymentVouchers.id
);
```

## 📞 الدعم

للمزيد من المعلومات أو المساعدة:
- راجع ملف `PAYMENT_VOUCHER_API.md` لربط Flutter
- راجع ملف `PAYMENT_VOUCHER_IMPROVEMENTS.md` للتحسينات
- راجع ملف `DATABASE_STRUCTURE.md` للهيكل الكامل

---

**تاريخ الإنشاء**: نوفمبر 2025
**الإصدار**: 1.0
**الحالة**: ✅ جاهز للإنتاج

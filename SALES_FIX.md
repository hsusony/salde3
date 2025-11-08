# إصلاح مشكلة المبلغ الإجمالي في صفحة الفواتير

## المشكلة
- صفحة الفواتير تعرض "المبلغ الإجمالي: 0 د.ع" رغم وجود 3 فواتير
- الفواتير المحفوظة في قاعدة البيانات:
  - `InvoiceNumber = NULL`
  - `FinalAmount = NULL`

## السبب
1. **Backend API** لم يكن يحفظ `InvoiceNumber` عند إضافة فاتورة جديدة
2. **Backend API** كان يحسب `FinalAmount` لكن لا يحفظه في جدول `Sales`

## الحل المطبق

### 1. تعديل Backend API (`backend/routes/sales.js`)

#### إضافة InvoiceNumber
```javascript
// توليد رقم فاتورة تلقائي إذا لم يُزوَّد
let invoiceNumber = InvoiceNumber;
if (!invoiceNumber) {
  const timestamp = Date.now();
  const random = Math.floor(Math.random() * 1000);
  invoiceNumber = `INV-${timestamp}-${random}`;
}
```

#### إضافة InvoiceNumber إلى INSERT
```javascript
.input('InvoiceNumber', sql.NVarChar(100), invoiceNumber)
.query(`
  INSERT INTO Sales (InvoiceNumber, CustomerID, SaleDate, TotalAmount, ...)
  OUTPUT INSERTED.SaleID, INSERTED.InvoiceNumber
  VALUES (@InvoiceNumber, @CustomerID, GETDATE(), @TotalAmount, ...)
`)
```

#### تحسين Response
```javascript
res.status(201).json({ 
  id: saleId, 
  invoiceNumber: returnedInvoiceNumber,
  finalAmount: finalAmount,
  message: 'Sale created successfully' 
});
```

### 2. إصلاح البيانات الموجودة (`database/fix_existing_sales.sql`)

```sql
-- تحديث FinalAmount للفواتير التي القيمة NULL
UPDATE Sales
SET 
    FinalAmount = ISNULL(TotalAmount, 0) - ISNULL(Discount, 0) + ISNULL(Tax, 0),
    InvoiceNumber = CASE 
        WHEN InvoiceNumber IS NULL THEN 'INV-' + CAST(DATEPART(YEAR, GETDATE()) AS VARCHAR) + '-' + RIGHT('0000' + CAST(SaleID AS VARCHAR), 4)
        ELSE InvoiceNumber
    END,
    UpdatedAt = GETDATE()
WHERE FinalAmount IS NULL OR InvoiceNumber IS NULL;
```

#### نتائج التحديث
- SaleID 19: FinalAmount = 1,332 د.ع, InvoiceNumber = INV-2025-0019
- SaleID 20: FinalAmount = 13,762 د.ع, InvoiceNumber = INV-2025-0020
- SaleID 21: FinalAmount = 2,399 د.ع, InvoiceNumber = INV-2025-0021

**إجمالي المبيعات: 17,493 د.ع** ✅

## التحسينات

### 1. حساب تلقائي للمبلغ النهائي
```javascript
const finalAmount = totalAmount - discountAmount + taxAmount;
const remainingAmount = finalAmount - paidAmount;
```

### 2. توليد تلقائي لرقم الفاتورة
- إذا لم يُزوَّد رقم فاتورة، يتم توليد واحد تلقائياً
- الصيغة: `INV-{timestamp}-{random}`
- مثال: `INV-1699123456789-123`

### 3. إرجاع بيانات كاملة
- API الآن يرجع: `id`, `invoiceNumber`, `finalAmount`
- يساعد في تأكيد الحفظ الصحيح

## الملفات المعدلة

### Backend
- ✅ `backend/routes/sales.js` - إضافة InvoiceNumber وحساب FinalAmount

### Database
- ✅ `database/fix_existing_sales.sql` - سكريبت إصلاح البيانات القديمة

## التحقق من الإصلاح

### 1. فحص API
```bash
curl http://localhost:3000/api/sales
```

**النتيجة:**
```json
[
  {
    "SaleID": 21,
    "InvoiceNumber": "INV-2025-0021",
    "FinalAmount": 2399,
    "TotalAmount": 2399,
    ...
  }
]
```

### 2. فحص قاعدة البيانات
```sql
SELECT SaleID, InvoiceNumber, TotalAmount, FinalAmount 
FROM Sales 
ORDER BY SaleID DESC;
```

**النتيجة:**
| SaleID | InvoiceNumber | TotalAmount | FinalAmount |
|--------|---------------|-------------|-------------|
| 21     | INV-2025-0021 | 2,399.00    | 2,399.00    |
| 20     | INV-2025-0020 | 13,762.00   | 13,762.00   |
| 19     | INV-2025-0019 | 1,332.00    | 1,332.00    |

### 3. التحقق من التطبيق
1. افتح صفحة "الفواتير" في التطبيق
2. يجب أن تظهر:
   - **إجمالي المبيعات: 17,493 د.ع** ✅
   - **عدد الفواتير: 3 فاتورة** ✅
   - **متوسط الفاتورة: 5,831 د.ع** ✅

## ملاحظات مهمة

### 1. إعادة تشغيل Backend
بعد التعديلات، يجب إعادة تشغيل Backend Server:
```bash
cd backend
node server.js
```

### 2. إعادة تحميل البيانات
في التطبيق، اسحب للأسفل لإعادة تحميل البيانات أو أعد تشغيل التطبيق:
```bash
flutter run -d windows
```

### 3. الفواتير الجديدة
جميع الفواتير الجديدة سيتم حفظها بشكل صحيح مع:
- رقم فاتورة تلقائي
- FinalAmount محسوب صحيح
- جميع البيانات المطلوبة

## الفوائد

1. ✅ **دقة البيانات**: جميع الفواتير لها FinalAmount صحيح
2. ✅ **تتبع أفضل**: كل فاتورة لها رقم فريد
3. ✅ **تقارير صحيحة**: إجمالي المبيعات يحسب بشكل دقيق
4. ✅ **منع المشاكل المستقبلية**: التوليد التلقائي لرقم الفاتورة

## الخطوات التالية

1. اختبار إضافة فاتورة جديدة
2. التحقق من ظهور المبالغ الصحيحة
3. اختبار التقارير والإحصائيات

---

**تاريخ الإصلاح**: 7 نوفمبر 2025  
**الحالة**: ✅ تم الإصلاح بنجاح

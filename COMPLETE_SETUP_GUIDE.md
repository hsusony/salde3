# دليل إعداد النظام الكامل - SQL Server 2008

## الحالة الحالية ✅

✅ **تم إنجازه:**
- REST API جاهز وشغال على `http://localhost:3000`
- تطبيق Flutter محدث للاتصال بـ API
- قاعدة البيانات SQL Server معدة (السكريبتات جاهزة)

❌ **المتبقي:**
- تثبيت وتشغيل SQL Server 2008
- تشغيل سكريبتات إنشاء قاعدة البيانات

---

## الخطوة 1: تثبيت SQL Server 2008

### خيار A: SQL Server 2008 R2 Express (مجاني)
1. حمّل SQL Server 2008 R2 Express من Microsoft
2. شغّل ملف التثبيت
3. اختر:
   - Database Engine Services ✅
   - Management Tools - Basic ✅
4. في Authentication Mode:
   - اختر **Mixed Mode**
   - اضبط كلمة مرور للمستخدم `sa`

### خيار B: SQL Server محلي موجود
إذا كان لديك SQL Server مثبت:
1. تأكد من تشغيل الخدمة
2. تأكد من تفعيل TCP/IP في SQL Server Configuration Manager

---

## الخطوة 2: تفعيل TCP/IP

1. افتح **SQL Server Configuration Manager**
2. اذهب إلى: `SQL Server Network Configuration` → `Protocols for SQLEXPRESS`
3. انقر بزر الماوس الأيمن على **TCP/IP** → اختر **Enable**
4. انقر بزر الماوس الأيمن على **TCP/IP** → اختر **Properties**
5. في تبويب **IP Addresses**، ابحث عن **IPAll**:
   - اضبط `TCP Port` = `1433`
6. أعد تشغيل خدمة SQL Server

---

## الخطوة 3: إنشاء قاعدة البيانات

### الطريقة A: استخدام SQL Server Management Studio
```sql
-- 1. افتح SSMS وسجل دخول
-- 2. افتح ملف: database/00_setup_complete_2008.sql
-- 3. اضغط Execute (F5)
```

### الطريقة B: استخدام سطر الأوامر
```powershell
# من مجلد المشروع الرئيسي
cd database
.\setup_database_2008.bat
```

---

## الخطوة 4: تحديث إعدادات الاتصال

### في ملف `backend\.env`:
```env
DB_SERVER=localhost\SQLEXPRESS
DB_DATABASE=SalesManagementDB
DB_USER=sa
DB_PASSWORD=YOUR_SA_PASSWORD_HERE
DB_PORT=1433
DB_ENCRYPT=false
DB_TRUST_CERTIFICATE=true
```

**ملاحظة:** إذا كنت تستخدم instance محدد، غيّر:
- من: `localhost`
- إلى: `localhost\SQLEXPRESS` أو اسم الـ instance الخاص بك

---

## الخطوة 5: اختبار الاتصال

### 1. أعد تشغيل API
```powershell
cd backend
node server.js
```

يجب أن ترى:
```
🚀 Server running on http://localhost:3000
📡 API Documentation: http://localhost:3000
✅ Database connection successful
```

### 2. اختبر API في المتصفح
افتح: `http://localhost:3000/api/health`

يجب أن ترى:
```json
{
  "status": "OK",
  "message": "Connected to SQL Server 2008",
  "timestamp": "2025-11-05T..."
}
```

---

## الخطوة 6: تشغيل التطبيق

```powershell
flutter run -d windows
```

الآن يجب أن يتصل التطبيق بـ API وتحصل على البيانات الفعلية!

---

## حل المشاكل الشائعة

### ❌ لا يمكن الاتصال بـ SQL Server

**السبب:** خدمة SQL Server متوقفة
```powershell
# تحقق من حالة الخدمة
Get-Service MSSQL*

# شغّل الخدمة
Start-Service MSSQL$SQLEXPRESS
```

**السبب:** TCP/IP معطل
- راجع الخطوة 2 أعلاه

**السبب:** Firewall يمنع المنفذ 1433
```powershell
# أضف قاعدة في Windows Firewall
New-NetFirewallRule -DisplayName "SQL Server" -Direction Inbound -LocalPort 1433 -Protocol TCP -Action Allow
```

### ❌ خطأ في تسجيل الدخول

**السبب:** كلمة المرور خاطئة
- تأكد من كلمة مرور `sa` في `.env`

**السبب:** Mixed Mode Authentication معطل
```sql
-- في SSMS، نفذ:
USE master;
GO
EXEC xp_instance_regwrite 
  N'HKEY_LOCAL_MACHINE', 
  N'Software\Microsoft\MSSQLServer\MSSQLServer',
  N'LoginMode', REG_DWORD, 2;
GO
-- ثم أعد تشغيل SQL Server
```

### ❌ قاعدة البيانات غير موجودة

```powershell
# شغّل سكريبت الإعداد
cd database
.\setup_database_2008.bat
```

---

## البيانات التجريبية (اختياري)

إذا أردت بيانات تجريبية للاختبار:

```sql
-- في SSMS
USE SalesManagementDB;
GO

-- أضف منتجات
INSERT INTO Products (Name, Barcode, BuyingPrice, SellingPrice, Stock, MinStock)
VALUES 
  (N'منتج تجريبي 1', '1001', 50, 100, 100, 10),
  (N'منتج تجريبي 2', '1002', 30, 60, 50, 5);

-- أضف عملاء
INSERT INTO Customers (Name, Phone)
VALUES 
  (N'عميل تجريبي 1', '0771234567'),
  (N'عميل تجريبي 2', '0779876543');
```

---

## الخلاصة

**ترتيب التشغيل:**
1. شغّل SQL Server
2. أنشئ قاعدة البيانات (مرة واحدة فقط)
3. شغّل API: `cd backend && node server.js`
4. شغّل التطبيق: `flutter run -d windows`

**الآن النظام متكامل 100% مع SQL Server 2008!** 🎉

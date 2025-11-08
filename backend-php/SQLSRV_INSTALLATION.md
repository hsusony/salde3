# 📥 دليل تثبيت SQL Server Driver لـ PHP

## المشكلة الحالية

PHP لا يحتوي على SQL Server Driver المطلوب للاتصال بـ SQL Server 2008.

---

## ✅ الحل: تثبيت SQLSRV Extension

### الخطوة 1️⃣: تحميل Driver

1. اذهب إلى: https://learn.microsoft.com/en-us/sql/connect/php/download-drivers-php-sql-server

2. حمّل **Microsoft Drivers for PHP for SQL Server**

3. اختر الإصدار المناسب لـ PHP 8.2:
   - **SQLSRV82 THREAD SAFE (TS) x64**

4. فك الملف المضغوط

---

### الخطوة 2️⃣: نسخ الملفات

1. افتح مجلد PHP:
   ```
   C:\xampp\php
   ```

2. افتح مجلد `ext`:
   ```
   C:\xampp\php\ext
   ```

3. انسخ الملفات التالية من الملف المحمل:
   - `php_sqlsrv_82_ts_x64.dll`
   - `php_pdo_sqlsrv_82_ts_x64.dll`
   
   إلى مجلد `C:\xampp\php\ext\`

---

### الخطوة 3️⃣: تفعيل Extensions

1. افتح ملف `php.ini`:
   ```
   C:\xampp\php\php.ini
   ```

2. إذا لم يكن موجود، انسخ `php.ini-development` واحفظه باسم `php.ini`

3. أضف السطور التالية في نهاية الملف:
   ```ini
   extension=php_sqlsrv_82_ts_x64
   extension=php_pdo_sqlsrv_82_ts_x64
   ```

4. احفظ الملف

---

### الخطوة 4️⃣: إعادة تشغيل Apache

1. افتح **XAMPP Control Panel**
2. اضغط **Stop** على Apache
3. اضغط **Start** على Apache

---

### الخطوة 5️⃣: اختبار

شغّل في Command Prompt:

```bash
cd C:\xampp\php
php -m | findstr sqlsrv
```

يجب أن تظهر:
```
pdo_sqlsrv
sqlsrv
```

---

## 🔧 حل سريع: استخدام السكريبت

اضغط مرتين على:
```
backend-php\install-sqlsrv.bat
```

واتبع التعليمات!

---

## ✅ بعد التثبيت

1. افتح: http://localhost/backend-php/api/health
2. يجب أن تظهر رسالة نجاح الاتصال بـ SQL Server

---

## ❌ المشاكل الشائعة

### خطأ: "Call to undefined function sqlsrv_connect()"
**الحل:** Extension غير مفعل في php.ini

### خطأ: "The specified module could not be found"
**الحل:** ملفات DLL غير موجودة في مجلد ext

### خطأ: "Unable to load dynamic library"
**الحل:** إصدار PHP غير متوافق مع Driver

---

🎉 **بعد التثبيت النظام سيعمل مع SQL Server 2008!**

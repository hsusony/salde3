# 📥 دليل تثبيت PHP

## الطريقة 1️⃣: XAMPP (الأسهل - موصى بها)

### خطوات التثبيت:

1. **حمّل XAMPP:**
   - الرابط المباشر: https://www.apachefriends.org/xampp-files/8.2.12/xampp-windows-x64-8.2.12-0-VS16-installer.exe
   - أو اضغط مرتين على: `install-php.bat`

2. **ثبّت XAMPP:**
   - شغّل ملف الـ installer
   - اختر المكونات: **Apache + PHP + MySQL** (فقط)
   - مسار التثبيت: `C:\xampp`
   - أكمل التثبيت

3. **شغّل Apache:**
   - افتح **XAMPP Control Panel**
   - اضغط **Start** على Apache
   - يجب أن يظهر باللون الأخضر

4. **انسخ Backend:**
   ```
   انسخ مجلد: C:\Users\HS_RW\Desktop\de3\backend-php
   إلى: C:\xampp\htdocs\backend-php
   ```

5. **افتح في المتصفح:**
   ```
   http://localhost/backend-php/api
   ```

---

## الطريقة 2️⃣: PHP فقط (متقدم)

### خطوات التثبيت:

1. **حمّل PHP:**
   - الرابط: https://windows.php.net/downloads/releases/php-8.2.12-Win32-vs16-x64.zip
   - أو: https://windows.php.net/download

2. **فك الملف:**
   - فك المجلد المضغوط في: `C:\php`

3. **أضف للـ PATH:**
   - ابحث عن: **Environment Variables**
   - افتح: **Edit the system environment variables**
   - اضغط: **Environment Variables**
   - في **System Variables**، اختر **Path**
   - اضغط **Edit** → **New**
   - أضف: `C:\php`
   - اضغط **OK** على الكل

4. **حمّل SQL Server Driver:**
   - الرابط: https://learn.microsoft.com/en-us/sql/connect/php/download-drivers-php-sql-server
   - حمّل: **SQLSRV82 THREAD SAFE (TS) x64**
   - فك الملف وانسخ:
     - `php_sqlsrv_82_ts_x64.dll`
     - `php_pdo_sqlsrv_82_ts_x64.dll`
   - إلى: `C:\php\ext\`

5. **فعّل Extensions:**
   - افتح ملف: `C:\php\php.ini-development`
   - احفظه باسم: `C:\php\php.ini`
   - ابحث عن وأزل `;` من أول السطر:
     ```ini
     ;extension=pdo_sqlsrv
     ;extension=sqlsrv
     ```
   - لتصبح:
     ```ini
     extension=pdo_sqlsrv
     extension=sqlsrv
     ```

6. **اختبر التثبيت:**
   ```powershell
   php --version
   ```

7. **شغّل Backend:**
   ```powershell
   cd C:\Users\HS_RW\Desktop\de3\backend-php
   php -S localhost:8000 index.php
   ```

8. **افتح في المتصفح:**
   ```
   http://localhost:8000/api
   ```

---

## 🔧 حل المشاكل

### خطأ: "php is not recognized"
- تأكد من إضافة `C:\php` للـ PATH
- أعد تشغيل PowerShell بعد التعديل

### خطأ: "sqlsrv extension not found"
- تأكد من نسخ ملفات `.dll` لـ `C:\php\ext\`
- تأكد من تفعيل السطور في `php.ini`
- أعد تشغيل الـ Server

### خطأ: "Database connection failed"
- تأكد من تشغيل SQL Server
- تحقق من اسم السيرفر في `config/Database.php`
- جرّب: `localhost\MORABSQLE`

---

## ✅ التحقق من النجاح

إذا فتحت `http://localhost:8000/api` أو `http://localhost/backend-php/api`

يجب أن تشوف:

```json
{
  "success": true,
  "data": {
    "name": "Sales Management System API",
    "version": "1.0.0",
    "endpoints": [...]
  }
}
```

---

## 🎯 التوصية

**للمبتدئين:** استخدم **XAMPP** (الطريقة 1)
- أسهل في التثبيت
- يأتي مع كل شيء
- واجهة رسومية

**للمحترفين:** استخدم **PHP فقط** (الطريقة 2)
- أخف وأسرع
- تحكم كامل
- بدون برامج إضافية

---

🎉 **بالتوفيق!**

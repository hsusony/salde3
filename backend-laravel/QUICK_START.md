# تثبيت PHP و Composer و Laravel

## للتثبيت التلقائي:

اضغط مرتين على: **`install.bat`**

سيقوم بـ:
1. فحص PHP
2. فحص Composer
3. تثبيت المكتبات
4. توليد Application Key

---

## إذا ظهرت أخطاء:

### ❌ PHP is not installed

**الحل:**
1. حمّل PHP من: https://windows.php.net/download/
2. اختر: **PHP 8.1+ Thread Safe x64**
3. افك الضغط في `C:\php`
4. افتح PowerShell كـ Administrator:
```powershell
[System.Environment]::SetEnvironmentVariable('Path', $env:Path + ';C:\php', 'Machine')
```
5. أعد تشغيل PowerShell
6. جرب: `php --version`

### ❌ Composer is not installed

**الحل:**
1. حمّل من: https://getcomposer.org/Composer-Setup.exe
2. شغل الملف واتبع الخطوات
3. أعد تشغيل PowerShell
4. جرب: `composer --version`

### ❌ SQL Server Driver مفقود

**الحل:**
1. حمّل من: https://docs.microsoft.com/en-us/sql/connect/php/download-drivers-php-sql-server
2. اختر الإصدار المناسب لـ PHP 8.1
3. انسخ الملفات إلى `C:\php\ext\`
4. افتح `C:\php\php.ini`
5. أضف:
```ini
extension=pdo_sqlsrv
extension=sqlsrv
```
6. أعد تشغيل PowerShell

---

## بعد التثبيت:

1. افتح `.env`
2. ضع كلمة مرور SQL Server:
```
DB_PASSWORD=your_password
```
3. شغل: `start-server.bat`
4. افتح: http://localhost:8000/api

---

## لتشغيل السيرفر يدوياً:

```powershell
cd backend-laravel
php artisan serve
```

# دليل تثبيت وتشغيل Laravel Backend

## 📋 المتطلبات

1. PHP 8.1 or higher
2. Composer
3. SQL Server 2008
4. SQL Server Driver for PHP

---

## 🔧 خطوات التثبيت

### 1️⃣ تثبيت PHP

**تحميل PHP:**
1. اذهب إلى: https://windows.php.net/download/
2. حمّل: **PHP 8.1 Thread Safe (x64)** أو أحدث
3. افك الضغط في: `C:\php`

**إعداد PHP:**
1. افتح Command Prompt كـ Administrator
2. أضف PHP للـ PATH:
```cmd
setx PATH "%PATH%;C:\php" /M
```

3. انسخ ملف الإعدادات:
```cmd
cd C:\php
copy php.ini-development php.ini
```

4. افتح `php.ini` وفعّل هذه الـ extensions (احذف `;` من أمامها):
```ini
extension=curl
extension=fileinfo
extension=mbstring
extension=openssl
extension=pdo_sqlsrv
extension=sqlsrv
```

### 2️⃣ تثبيت SQL Server Driver للـ PHP

1. حمّل من: https://docs.microsoft.com/en-us/sql/connect/php/download-drivers-php-sql-server
2. اختر الإصدار المناسب لـ PHP 8.1
3. انسخ الملفات إلى: `C:\php\ext\`

الملفات المطلوبة:
- `php_sqlsrv_81_ts_x64.dll`
- `php_pdo_sqlsrv_81_ts_x64.dll`

### 3️⃣ تثبيت Composer

1. حمّل من: https://getcomposer.org/download/
2. شغل: `Composer-Setup.exe`
3. اتبع خطوات التثبيت

للتحقق:
```cmd
composer --version
```

### 4️⃣ تثبيت Laravel Dependencies

افتح PowerShell في مجلد المشروع:

```powershell
cd C:\Users\HS_RW\Desktop\de3\backend-laravel
composer install
```

### 5️⃣ إعداد Laravel

1. **توليد Application Key:**
```powershell
php artisan key:generate
```

2. **تعديل ملف `.env`:**
افتح `backend-laravel\.env` وضع كلمة مرور SQL Server:
```env
DB_CONNECTION=sqlsrv
DB_HOST=localhost\MORABSQLE
DB_PORT=1433
DB_DATABASE=SalesManagementDB
DB_USERNAME=sa
DB_PASSWORD=your_password_here
```

### 6️⃣ تشغيل السيرفر

```powershell
cd backend-laravel
php artisan serve
```

السيرفر سيعمل على: **http://localhost:8000**

---

## ✅ اختبار API

افتح المتصفح على:
- http://localhost:8000/api/test
- http://localhost:8000/api/customers
- http://localhost:8000/api/products

---

## 🐛 حل المشاكل الشائعة

### المشكلة: `php: command not found`
**الحل:** أعد تشغيل PowerShell بعد إضافة PHP للـ PATH

### المشكلة: `Class 'PDO' not found`
**الحل:** تأكد من تفعيل `extension=pdo_sqlsrv` في `php.ini`

### المشكلة: خطأ في الاتصال بـ SQL Server
**الحل:** 
1. تأكد من تشغيل SQL Server
2. تحقق من كلمة المرور في `.env`
3. تأكد من تثبيت SQL Server Driver

### المشكلة: `composer: command not found`
**الحل:** أعد تشغيل PowerShell بعد تثبيت Composer

---

## 📞 روابط مهمة

- PHP Downloads: https://windows.php.net/download/
- Composer: https://getcomposer.org/
- SQL Server PHP Drivers: https://docs.microsoft.com/en-us/sql/connect/php/
- Laravel Docs: https://laravel.com/docs

---

## ⚡ تشغيل سريع (إذا كان كل شيء مثبت)

```powershell
cd C:\Users\HS_RW\Desktop\de3\backend-laravel
php artisan serve --host=0.0.0.0 --port=8000
```

أو اضغط مرتين على: `start-server.bat`

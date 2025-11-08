# 🚀 Laravel Backend - SQL Server 2008

## ⚠️ المشكلة الحالية: PHP غير مثبت!

Backend Laravel جاهز لكن يحتاج PHP للعمل.

---

## 📥 التثبيت السريع

### 1. تحميل PHP 8.1+
**الرابط**: https://windows.php.net/downloads/releases/php-8.1.31-Win32-vs16-x64.zip

**خطوات التثبيت**:
1. فك الضغط في `C:\php`
2. إضافة `C:\php` إلى PATH
3. نسخ `php.ini-development` إلى `php.ini`
4. فتح `php.ini` وإزالة `;` من السطور التالية:
   ```ini
   extension=pdo_sqlsrv
   extension=sqlsrv
   extension=mbstring
   extension=openssl
   ```

### 2. تحميل SQL Server Driver
**الرابط**: https://learn.microsoft.com/en-us/sql/connect/php/download-drivers-php-sql-server

نسخ ملفات `.dll` إلى `C:\php\ext`

### 3. تحميل Composer
**الرابط**: https://getcomposer.org/Composer-Setup.exe

تشغيل التثبيت العادي.

---

## ⚡ بديل أسرع: استخدام XAMPP

### تحميل XAMPP (يحتوي PHP + Apache):
**الرابط**: https://www.apachefriends.org/download.html

**بعد التثبيت**:
```bash
cd C:\xampp\htdocs
mklink /D laravel-api C:\Users\HS_RW\Desktop\de3\backend-laravel
cd laravel-api
composer install
php artisan serve
```

---

## 🔧 بعد تثبيت PHP

### 1. التحقق من التثبيت:
```bash
php --version
composer --version
```

### 2. إعداد Laravel:
```bash
cd backend-laravel
composer install
php artisan key:generate
```

### 3. تشغيل السيرفر:
اضغط مرتين على: `start.bat`

أو:
```bash
php artisan serve --host=0.0.0.0 --port=8000
```

---

## 📡 Endpoints المتاحة

جميع الـ endpoints جاهزة في `routes/api.php`:

```
GET  /api/test              - اختبار API
GET  /api/health            - فحص الاتصال بقاعدة البيانات
GET  /api/customers         - جميع العملاء
GET  /api/customers/{id}    - عميل محدد
POST /api/customers         - إضافة عميل
GET  /api/products          - جميع المنتجات
GET  /api/products/{id}     - منتج محدد
GET  /api/sales             - جميع المبيعات
POST /api/sales             - إضافة فاتورة
GET  /api/dashboard/stats   - إحصائيات
GET  /api/categories        - التصنيفات
GET  /api/units             - الوحدات
```

---

## 🎯 الملفات الجاهزة

✅ `setup.bat` - تثبيت المكتبات  
✅ `start.bat` - تشغيل السيرفر  
✅ `routes/api.php` - جميع endpoints بدون Controllers  
✅ `config/database.php` - إعدادات SQL Server 2008  
✅ `.env` - بيانات الاتصال  

---

## 💡 ملاحظة مهمة

**Backend بسيط جداً**:
- لا يستخدم Models أو Controllers
- يستخدم DB query builder مباشرة
- خفيف وسريع
- جاهز للعمل فوراً بعد تثبيت PHP

---

## 🆘 هل تريد مساعدة؟

إذا واجهت مشاكل في تثبيت PHP، يمكننا:
1. استخدام XAMPP (الأسهل)
2. استخدام Laragon (بديل خفيف)
3. العودة لـ Node.js Backend (كان شغال!)

---

📞 **الخلاصة**: Backend Laravel جاهز، فقط محتاج PHP!

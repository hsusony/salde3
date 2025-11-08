@echo off
title تثبيت SQL Server Driver لـ PHP
color 0A

echo ========================================
echo   تثبيت SQL Server Driver
echo ========================================
echo.

REM Check PHP version
php --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] PHP غير مثبت!
    echo.
    pause
    exit /b 1
)

echo [INFO] فحص إصدار PHP...
php -v

echo.
echo ========================================
echo الخطوة 1: تحميل SQL Server Driver
echo ========================================
echo.
echo يجب تحميل الملفات التالية:
echo.
echo من: https://learn.microsoft.com/en-us/sql/connect/php/download-drivers-php-sql-server
echo.
echo الملفات المطلوبة (PHP 8.2):
echo - php_sqlsrv_82_ts_x64.dll
echo - php_pdo_sqlsrv_82_ts_x64.dll
echo.

set /p downloaded="هل حملت الملفات؟ (y/n): "
if /i not "%downloaded%"=="y" (
    start https://learn.microsoft.com/en-us/sql/connect/php/download-drivers-php-sql-server
    echo.
    echo [INFO] تم فتح صفحة التحميل
    echo بعد التحميل، شغل هذا السكريبت مرة ثانية
    echo.
    pause
    exit /b 0
)

echo.
echo ========================================
echo الخطوة 2: نسخ الملفات
echo ========================================
echo.

REM Get PHP extension directory
for /f "tokens=*" %%i in ('php -r "echo ini_get('extension_dir');"') do set PHP_EXT_DIR=%%i

echo [INFO] مجلد Extensions: %PHP_EXT_DIR%
echo.

set /p dll_path="أدخل مسار مجلد الملفات المحملة: "

if not exist "%dll_path%\php_sqlsrv_82_ts_x64.dll" (
    echo [ERROR] الملف غير موجود!
    pause
    exit /b 1
)

echo.
echo [INFO] نسخ الملفات...
copy "%dll_path%\php_sqlsrv_82_ts_x64.dll" "%PHP_EXT_DIR%\" /Y
copy "%dll_path%\php_pdo_sqlsrv_82_ts_x64.dll" "%PHP_EXT_DIR%\" /Y

echo [SUCCESS] تم نسخ الملفات بنجاح!
echo.

echo ========================================
echo الخطوة 3: تفعيل Extensions
echo ========================================
echo.

REM Get PHP ini file
for /f "tokens=*" %%i in ('php --ini ^| findstr "Loaded"') do set PHP_INI_LINE=%%i
for /f "tokens=3" %%i in ("%PHP_INI_LINE%") do set PHP_INI=%%i

echo [INFO] ملف PHP.ini: %PHP_INI%
echo.

if not exist "%PHP_INI%" (
    echo [ERROR] ملف php.ini غير موجود!
    echo يجب إنشاء ملف php.ini من php.ini-development
    pause
    exit /b 1
)

echo [INFO] إضافة Extensions...
echo extension=php_sqlsrv_82_ts_x64.dll >> "%PHP_INI%"
echo extension=php_pdo_sqlsrv_82_ts_x64.dll >> "%PHP_INI%"

echo [SUCCESS] تم تفعيل Extensions!
echo.

echo ========================================
echo الخطوة 4: اختبار
echo ========================================
echo.

php -m | findstr sqlsrv
if errorlevel 1 (
    echo [ERROR] Extensions غير مفعلة!
    echo.
    echo يجب:
    echo 1. إعادة تشغيل Apache
    echo 2. التأكد من ملف php.ini الصحيح
    pause
    exit /b 1
) else (
    echo [SUCCESS] Extensions مفعلة بنجاح!
    echo.
    echo - sqlsrv
    echo - pdo_sqlsrv
)

echo.
echo ========================================
echo   تم التثبيت بنجاح!
echo ========================================
echo.
echo الآن يمكنك استخدام SQL Server 2008
echo.
pause

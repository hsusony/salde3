@echo off
title تثبيت PHP تلقائياً
color 0A

echo ========================================
echo   تحميل وتثبيت PHP
echo ========================================
echo.

REM Check if PHP already installed
php --version >nul 2>&1
if not errorlevel 1 (
    echo [SUCCESS] PHP مثبت بالفعل!
    php --version
    echo.
    pause
    exit /b 0
)

echo [INFO] PHP غير مثبت. جاري التحميل...
echo.

REM Create temp directory
if not exist "%TEMP%\php_installer" mkdir "%TEMP%\php_installer"
cd /d "%TEMP%\php_installer"

echo ========================================
echo الخيار 1: تحميل XAMPP (موصى به)
echo ========================================
echo.
echo XAMPP يحتوي على:
echo - PHP 8.2
echo - Apache Server
echo - MySQL
echo - phpMyAdmin
echo.
echo الحجم: ~150 MB
echo الرابط: https://www.apachefriends.org/download.html
echo.

set /p choice="هل تريد فتح رابط التحميل؟ (y/n): "
if /i "%choice%"=="y" (
    start https://www.apachefriends.org/xampp-files/8.2.12/xampp-windows-x64-8.2.12-0-VS16-installer.exe
    echo.
    echo [INFO] تم فتح رابط التحميل في المتصفح
    echo.
    echo بعد التحميل:
    echo 1. شغل الملف xampp-windows-x64-8.2.12-0-VS16-installer.exe
    echo 2. اختر المكونات: Apache + PHP + MySQL
    echo 3. اختر مسار التثبيت: C:\xampp
    echo 4. أكمل التثبيت
    echo 5. بعد التثبيت، شغل XAMPP Control Panel
    echo 6. اضغط Start على Apache
    echo.
    echo ثم انسخ مجلد backend-php إلى:
    echo C:\xampp\htdocs\backend-php
    echo.
    echo وافتح في المتصفح:
    echo http://localhost/backend-php/api
    echo.
    pause
    exit /b 0
)

echo.
echo ========================================
echo الخيار 2: تحميل PHP فقط
echo ========================================
echo.
echo PHP Thread Safe 8.2
echo الحجم: ~30 MB
echo.

set /p choice2="هل تريد فتح رابط التحميل؟ (y/n): "
if /i "%choice2%"=="y" (
    start https://windows.php.net/downloads/releases/php-8.2.12-Win32-vs16-x64.zip
    echo.
    echo [INFO] تم فتح رابط التحميل في المتصفح
    echo.
    echo بعد التحميل:
    echo 1. فك الملف المضغوط في مجلد: C:\php
    echo 2. أضف C:\php للـ PATH:
    echo    - ابحث عن "Environment Variables" في Windows
    echo    - اضغط "Edit the system environment variables"
    echo    - اضغط "Environment Variables"
    echo    - في System Variables، اختر Path واضغط Edit
    echo    - اضغط New وأضف: C:\php
    echo    - اضغط OK على الكل
    echo 3. افتح PowerShell جديد واكتب: php --version
    echo.
    echo ملاحظة: PHP بدون Apache يحتاج SQL Server Driver يدوي
    echo.
    pause
    exit /b 0
)

echo.
echo [INFO] لم يتم اختيار أي خيار
echo.
echo يمكنك تحميل يدوياً من:
echo - XAMPP: https://www.apachefriends.org
echo - PHP: https://windows.php.net/download
echo.
pause

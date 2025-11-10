@echo off
chcp 65001 >nul
echo ========================================
echo إعداد PHP والباك اند
echo PHP and Backend Setup
echo ========================================
echo.

REM فحص وجود PHP
if not exist "C:\php\php.exe" (
    echo ❌ خطأ: PHP غير موجود في C:\php
    echo.
    echo يرجى:
    echo 1. تحميل PHP من: https://windows.php.net/download/
    echo 2. استخراج الملف إلى C:\php
    echo 3. تشغيل هذا الملف مرة أخرى
    echo.
    pause
    exit /b 1
)

echo ✅ PHP موجود
echo.

REM إضافة PHP إلى PATH للجلسة الحالية
set PATH=%PATH%;C:\php

REM اختبار PHP
echo [1/3] اختبار PHP...
php --version
echo.

REM نسخ ملف الإعدادات إذا لم يكن موجود
if not exist "C:\php\php.ini" (
    echo [2/3] إنشاء ملف php.ini...
    copy "C:\php\php.ini-development" "C:\php\php.ini"
    echo ✅ تم إنشاء php.ini
) else (
    echo [2/3] ملف php.ini موجود
)
echo.

REM تشغيل الباك اند
echo [3/3] تشغيل الباك اند...
echo.
echo ========================================
echo 🚀 الباك اند يعمل الآن!
echo Backend is running!
echo ========================================
echo.
echo 📡 URL: http://localhost:8000
echo 📁 المجلد: backend-php
echo.
echo اضغط Ctrl+C للإيقاف
echo Press Ctrl+C to stop
echo.
echo ========================================
echo.

cd backend-php
php -S localhost:8000 index.php

pause

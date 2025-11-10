@echo off
chcp 65001 >nul
title نظام إدارة المبيعات - التثبيت

echo.
echo ═══════════════════════════════════════════════════════════
echo    نظام إدارة المبيعات v1.1.0 - التثبيت
echo    Sales Management System v1.1.0 - Installation
echo ═══════════════════════════════════════════════════════════
echo.
echo 📦 جاري تشغيل ملف التنصيب...
echo    Starting installer...
echo.

REM التحقق من وجود الملف
if not exist "SalesManagementSystem_v1.1.0_Setup.exe" (
    echo ❌ خطأ: ملف التنصيب غير موجود!
    echo    Error: Installer file not found!
    pause
    exit /b 1
)

REM تشغيل الـ installer
echo ✅ تم العثور على ملف التنصيب
echo    Installer file found
echo.
echo 🚀 جاري التشغيل...
echo    Launching...
echo.

start "" "SalesManagementSystem_v1.1.0_Setup.exe"

echo.
echo ✨ تم تشغيل ملف التنصيب بنجاح!
echo    Installer launched successfully!
echo.
echo 📋 الخطوات التالية:
echo    Next steps:
echo.
echo    1. اتبع تعليمات المثبت
echo       Follow installer instructions
echo.
echo    2. بعد التثبيت، شغل setup_payment_vouchers.bat من مجلد database
echo       After installation, run setup_payment_vouchers.bat from database folder
echo.
echo    3. استمتع باستخدام النظام!
echo       Enjoy using the system!
echo.
echo ═══════════════════════════════════════════════════════════

timeout /t 5 /nobreak >nul
exit /b 0

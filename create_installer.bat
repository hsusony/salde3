@echo off
chcp 65001 > nul
echo ========================================
echo    إنشاء ملف التنصيب - نظام إدارة المبيعات
echo ========================================
echo.

echo [1/3] تنظيف المشروع...
call flutter clean
echo.

echo [2/3] بناء التطبيق للإصدار النهائي (Release)...
call flutter build windows --release
if %errorlevel% neq 0 (
    echo.
    echo ❌ فشل في بناء التطبيق!
    pause
    exit /b %errorlevel%
)
echo.

echo [3/3] التحقق من وجود ملفات البناء...
if not exist "build\windows\x64\runner\Release\sales_management_system.exe" (
    echo ❌ لم يتم العثور على ملف التطبيق!
    pause
    exit /b 1
)

echo.
echo ✅ تم بناء التطبيق بنجاح!
echo.
echo 📁 ملفات التطبيق موجودة في:
echo    build\windows\x64\runner\Release\
echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo لإنشاء ملف التنصيب (.exe):
echo.
echo 1. قم بتحميل وتثبيت Inno Setup من:
echo    https://jrsoftware.org/isdl.php
echo.
echo 2. افتح ملف installer_script.iss باستخدام Inno Setup
echo.
echo 3. اضغط على Build أو F9
echo.
echo 4. سيتم إنشاء ملف التنصيب في مجلد installer_output
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.

pause

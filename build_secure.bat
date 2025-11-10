@echo off
chcp 65001 > nul
echo ========================================
echo    بناء نسخة محمية من البرنامج
echo ========================================
echo.

echo [1/4] تنظيف المشروع...
call flutter clean
echo.

echo [2/4] بناء التطبيق مع التشفير والحماية...
echo      - تفعيل Obfuscation
echo      - إزالة رموز التصحيح
echo      - تقليل حجم الكود
call flutter build windows --release --obfuscate --split-debug-info=debug_info
if %errorlevel% neq 0 (
    echo.
    echo ❌ فشل في بناء التطبيق!
    pause
    exit /b %errorlevel%
)
echo.

echo [3/4] إزالة ملفات التصحيح (Debug Info)...
if exist "debug_info" (
    rmdir /s /q "debug_info"
    echo ✅ تم حذف ملفات التصحيح
)
echo.

echo [4/4] التحقق من وجود ملفات البناء...
if not exist "build\windows\x64\runner\Release\sales_management_system.exe" (
    echo ❌ لم يتم العثور على ملف التطبيق!
    pause
    exit /b 1
)

echo.
echo ✅ تم بناء النسخة المحمية بنجاح!
echo.
echo 📁 ملفات التطبيق المحمية في:
echo    build\windows\x64\runner\Release\
echo.
echo 🔒 الحماية المطبقة:
echo    ✓ تشفير الكود (Obfuscation)
echo    ✓ إزالة رموز التصحيح
echo    ✓ تقليل حجم الملف
echo    ✓ صعوبة فك التشفير
echo.

pause

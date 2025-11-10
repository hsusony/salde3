@echo off
chcp 65001 > nul
echo ========================================
echo       تحديث أيقونة البرنامج
echo ========================================
echo.

echo 📍 موقع الأيقونة الحالية:
echo    windows\runner\resources\app_icon.ico
echo.

echo 📝 لتحديث الأيقونة:
echo.
echo 1. قم بتحضير أيقونة جديدة بصيغة .ico
echo    - الحجم الموصى به: 256x256 بكسل
echo    - يمكنك تحويل PNG إلى ICO من:
echo      https://convertio.co/ar/png-ico/
echo.
echo 2. احذف الأيقونة القديمة أو استبدلها:
echo    windows\runner\resources\app_icon.ico
echo.
echo 3. ضع الأيقونة الجديدة في نفس المكان
echo    وسمّها: app_icon.ico
echo.
echo 4. شغّل هذا الملف مرة أخرى واضغط Y
echo.

set /p continue="هل قمت بوضع الأيقونة الجديدة؟ (Y/N): "
if /i "%continue%" NEQ "Y" (
    echo.
    echo تم الإلغاء. قم بتحضير الأيقونة أولاً!
    pause
    exit /b 0
)

echo.
echo ========================================
echo    بدء إعادة البناء مع الأيقونة الجديدة
echo ========================================
echo.

echo [1/3] التحقق من وجود الأيقونة...
if not exist "windows\runner\resources\app_icon.ico" (
    echo ❌ لم يتم العثور على app_icon.ico!
    echo    تأكد من وضع الأيقونة في المكان الصحيح.
    pause
    exit /b 1
)
echo ✅ تم العثور على الأيقونة

echo.
echo [2/3] تنظيف المشروع...
call flutter clean

echo.
echo [3/3] بناء البرنامج مع الأيقونة الجديدة...
call flutter build windows --release --obfuscate --split-debug-info=debug_info

if %errorlevel% neq 0 (
    echo.
    echo ❌ فشل في البناء!
    pause
    exit /b %errorlevel%
)

echo.
echo حذف ملفات التصحيح...
if exist "debug_info" (
    rmdir /s /q "debug_info"
)

echo.
echo ========================================
echo ✅ تم تحديث الأيقونة بنجاح!
echo ========================================
echo.
echo 📁 ملف البرنامج الجديد في:
echo    build\windows\x64\runner\Release\sales_management_system.exe
echo.
echo 🎨 الأيقونة الجديدة مطبقة على:
echo    ✓ ملف .exe
echo    ✓ اختصار سطح المكتب
echo    ✓ شريط المهام
echo.
echo 💡 لإنشاء ملف تنصيب جديد:
echo    1. افتح installer_script.iss
echo    2. اضغط F9
echo    3. سيتم إنشاء تنصيب بالأيقونة الجديدة
echo.

pause

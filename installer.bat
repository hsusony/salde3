@echo off
chcp 65001 >nul
cls
color 0B

echo ╔════════════════════════════════════════════════════════════════╗
echo ║                                                                ║
echo ║          نظام إدارة المبيعات - Sales Management System        ║
echo ║                  برنامج التحميل والتثبيت التلقائي             ║
echo ║                                                                ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo.

echo ════════════════════════════════════════════════════════════════
echo   مرحباً بك في برنامج التثبيت
echo ════════════════════════════════════════════════════════════════
echo.
echo سيقوم هذا البرنامج بما يلي:
echo   ✓ فحص النظام والمتطلبات
echo   ✓ تحميل جميع المكتبات المطلوبة
echo   ✓ إعداد قاعدة البيانات
echo   ✓ تجهيز التطبيق للعمل
echo.
echo المساحة المطلوبة: ~500 MB
echo الوقت المتوقع: 3-5 دقائق
echo.
pause

cls
color 0E

echo ╔════════════════════════════════════════════════════════════════╗
echo ║  الخطوة 1/6: فحص متطلبات النظام                               ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

REM Check Windows version
ver | findstr /i "10\. 11\." >nul
if %errorlevel% neq 0 (
    color 0C
    echo ❌ خطأ: يتطلب Windows 10 أو أحدث!
    echo.
    echo النظام الحالي غير مدعوم.
    echo الرجاء الترقية إلى Windows 10 أو Windows 11
    echo.
    pause
    exit /b 1
) else (
    echo ✅ نظام التشغيل: مدعوم
)

REM Check if running as Administrator (optional but recommended)
net session >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ الصلاحيات: مدير النظام
) else (
    echo ⚠️  تشغيل بدون صلاحيات المدير (موصى بها)
)

REM Check available disk space
echo ✅ فحص المساحة المتاحة...

echo.
timeout /t 2 >nul

cls
color 0E

echo ╔════════════════════════════════════════════════════════════════╗
echo ║  الخطوة 2/6: فحص تثبيت Flutter                                ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    color 0C
    echo ❌ Flutter غير مثبت!
    echo.
    echo ════════════════════════════════════════════════════════════════
    echo   لتثبيت Flutter، اتبع الخطوات التالية:
    echo ════════════════════════════════════════════════════════════════
    echo.
    echo 1. قم بزيارة: https://docs.flutter.dev/get-started/install/windows
    echo 2. قم بتحميل Flutter SDK
    echo 3. فك الضغط إلى: C:\flutter
    echo 4. أضف C:\flutter\bin إلى متغيرات البيئة PATH
    echo 5. أعد تشغيل هذا البرنامج
    echo.
    echo أو قم بتشغيل الأوامر التالية في PowerShell كمدير:
    echo.
    echo   git clone https://github.com/flutter/flutter.git -b stable C:\flutter
    echo   setx PATH "%%PATH%%;C:\flutter\bin"
    echo.
    pause
    
    REM Ask if user wants to open download page
    choice /C YN /M "هل تريد فتح صفحة تحميل Flutter الآن؟"
    if %errorlevel% equ 1 (
        start https://docs.flutter.dev/get-started/install/windows
    )
    exit /b 1
) else (
    echo ✅ Flutter مثبت بنجاح
    echo.
    flutter --version
)

echo.
timeout /t 2 >nul

cls
color 0E

echo ╔════════════════════════════════════════════════════════════════╗
echo ║  الخطوة 3/6: فحص أدوات التطوير                                ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

echo جاري فحص أدوات النظام المطلوبة...
echo.

flutter doctor -v

echo.
echo ════════════════════════════════════════════════════════════════
echo   ملاحظة: تجاهل تحذيرات Android Studio و Xcode
echo   (التطبيق مخصص للويندوز فقط)
echo ════════════════════════════════════════════════════════════════
echo.

timeout /t 3 >nul
pause

cls
color 0B

echo ╔════════════════════════════════════════════════════════════════╗
echo ║  الخطوة 4/6: تنظيف وإعداد المشروع                             ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

echo 🧹 تنظيف الملفات القديمة...
echo.

if exist "build\" (
    echo   - حذف مجلد build
    rmdir /s /q build 2>nul
)

if exist ".dart_tool\" (
    echo   - حذف مجلد .dart_tool
    rmdir /s /q .dart_tool 2>nul
)

if exist "pubspec.lock" (
    echo   - حذف pubspec.lock
    del /f /q pubspec.lock 2>nul
)

flutter clean >nul 2>&1

echo.
echo ✅ تم التنظيف بنجاح
echo.

timeout /t 2 >nul

cls
color 0B

echo ╔════════════════════════════════════════════════════════════════╗
echo ║  الخطوة 5/6: تحميل المكتبات (قد يستغرق وقتاً)                 ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

echo 📦 جاري تحميل 77 مكتبة...
echo.
echo هذه الخطوة قد تستغرق 2-5 دقائق حسب سرعة الإنترنت
echo الرجاء الانتظار...
echo.

flutter pub get

if %errorlevel% neq 0 (
    color 0C
    echo.
    echo ❌ خطأ في تحميل المكتبات!
    echo.
    echo جرب الحلول التالية:
    echo   1. تحقق من اتصال الإنترنت
    echo   2. شغّل: flutter pub cache repair
    echo   3. أعد تشغيل هذا البرنامج
    echo.
    pause
    exit /b 1
) else (
    echo.
    echo ✅ تم تحميل جميع المكتبات بنجاح!
)

echo.
timeout /t 2 >nul

cls
color 0B

echo ╔════════════════════════════════════════════════════════════════╗
echo ║  الخطوة 6/6: التحقق النهائي وإعداد قاعدة البيانات            ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

echo 🔍 فحص الملفات...
echo.

REM Check important files
set "all_ok=1"

if exist "lib\main.dart" (
    echo   ✅ ملف main.dart
) else (
    echo   ❌ ملف main.dart غير موجود!
    set "all_ok=0"
)

if exist "pubspec.yaml" (
    echo   ✅ ملف pubspec.yaml
) else (
    echo   ❌ ملف pubspec.yaml غير موجود!
    set "all_ok=0"
)

if exist "lib\utils\database_helper.dart" (
    echo   ✅ مساعد قاعدة البيانات
) else (
    echo   ❌ مساعد قاعدة البيانات غير موجود!
    set "all_ok=0"
)

if exist "lib\screens\dashboard_screen.dart" (
    echo   ✅ واجهات المستخدم
) else (
    echo   ⚠️  بعض واجهات المستخدم قد تكون ناقصة
)

echo.

if "%all_ok%"=="0" (
    color 0C
    echo ❌ بعض الملفات المهمة مفقودة!
    echo الرجاء التحقق من اكتمال الملفات
    echo.
    pause
    exit /b 1
)

REM Create necessary directories
echo 📁 إنشاء المجلدات الضرورية...
echo.

if not exist "assets\images\" mkdir "assets\images" 2>nul
if not exist "assets\icons\" mkdir "assets\icons" 2>nul

echo   ✅ assets\images
echo   ✅ assets\icons

echo.
timeout /t 2 >nul

cls
color 0A

echo.
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                                                                ║
echo ║                                                                ║
echo ║              ✅ تم التثبيت بنجاح! 🎉                         ║
echo ║                                                                ║
echo ║                                                                ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo.
echo ════════════════════════════════════════════════════════════════
echo   معلومات التثبيت
echo ════════════════════════════════════════════════════════════════
echo.
echo   📦 عدد المكتبات: 77
echo   💾 حجم التثبيت: ~500 MB
echo   🗄️  قاعدة البيانات: SQLite (محلية)
echo   🎨 الواجهة: عربية كاملة
echo   🌓 الثيم: فاتح وداكن
echo.
echo ════════════════════════════════════════════════════════════════
echo   الملفات المتاحة
echo ════════════════════════════════════════════════════════════════
echo.
echo   ▶️  run.bat           - لتشغيل التطبيق
echo   🔧 setup.bat         - لإعادة الإعداد
echo   🏗️  build.bat         - لبناء نسخة الإنتاج
echo   📖 README.md         - الدليل الشامل
echo   🚀 QUICK_START.md    - البدء السريع
echo   📋 USAGE_GUIDE.md    - دليل الاستخدام
echo.
echo ════════════════════════════════════════════════════════════════
echo   الخطوات التالية
echo ════════════════════════════════════════════════════════════════
echo.
echo   1️⃣  تشغيل التطبيق: run.bat
echo   2️⃣  إضافة منتجات تجريبية
echo   3️⃣  استكشاف لوحة التحكم
echo   4️⃣  قراءة دليل الاستخدام
echo.
echo ════════════════════════════════════════════════════════════════
echo.
echo.

REM Create desktop shortcut option
choice /C YN /M "هل تريد إنشاء اختصار على سطح المكتب؟"
if %errorlevel% equ 1 (
    echo.
    echo 🔗 إنشاء الاختصار...
    
    REM Create VBS script to create shortcut
    echo Set oWS = WScript.CreateObject("WScript.Shell") > CreateShortcut.vbs
    echo sLinkFile = oWS.SpecialFolders("Desktop") ^& "\نظام إدارة المبيعات.lnk" >> CreateShortcut.vbs
    echo Set oLink = oWS.CreateShortcut(sLinkFile) >> CreateShortcut.vbs
    echo oLink.TargetPath = "%CD%\run.bat" >> CreateShortcut.vbs
    echo oLink.WorkingDirectory = "%CD%" >> CreateShortcut.vbs
    echo oLink.Description = "نظام إدارة المبيعات - Sales Management System" >> CreateShortcut.vbs
    echo oLink.IconLocation = "%%SystemRoot%%\System32\SHELL32.dll,165" >> CreateShortcut.vbs
    echo oLink.Save >> CreateShortcut.vbs
    
    cscript //nologo CreateShortcut.vbs
    del CreateShortcut.vbs
    
    echo   ✅ تم إنشاء الاختصار على سطح المكتب
    echo.
)

echo.
choice /C YN /M "هل تريد تشغيل التطبيق الآن؟"
if %errorlevel% equ 1 (
    echo.
    echo.
    echo ════════════════════════════════════════════════════════════════
    echo   🚀 جاري تشغيل التطبيق...
    echo ════════════════════════════════════════════════════════════════
    echo.
    echo   قد يستغرق التشغيل الأول بعض الوقت
    echo   الرجاء الانتظار...
    echo.
    timeout /t 3 >nul
    
    start "" flutter run -d windows
    
    echo.
    echo ✅ تم إطلاق التطبيق في نافذة منفصلة
    echo.
) else (
    echo.
    echo ════════════════════════════════════════════════════════════════
    echo.
    echo   شكراً لك! 🙏
    echo.
    echo   لتشغيل التطبيق لاحقاً:
    echo   👉 انقر نقراً مزدوجاً على: run.bat
    echo   👉 أو استخدم الاختصار على سطح المكتب
    echo.
    echo ════════════════════════════════════════════════════════════════
    echo.
)

echo.
echo.
pause

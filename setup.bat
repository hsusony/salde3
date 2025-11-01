@echo off
chcp 65001 >nul
cls
color 0B

echo ╔════════════════════════════════════════════════════════════════╗
echo ║                                                                ║
echo ║          نظام إدارة المبيعات - Sales Management System        ║
echo ║                      برنامج الإعداد والتثبيت                  ║
echo ║                                                                ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo.

echo [1/5] فحص متطلبات النظام...
echo ════════════════════════════════════════════════════════════════
echo.

REM Check if Flutter is installed
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    color 0C
    echo ❌ خطأ: Flutter غير مثبت!
    echo.
    echo الرجاء تثبيت Flutter من:
    echo https://docs.flutter.dev/get-started/install/windows
    echo.
    pause
    exit /b 1
) else (
    echo ✅ Flutter مثبت بنجاح
)

echo.
echo [2/5] عرض معلومات Flutter...
echo ════════════════════════════════════════════════════════════════
echo.
flutter --version
echo.

echo.
echo [3/5] فحص حالة النظام...
echo ════════════════════════════════════════════════════════════════
echo.
flutter doctor
echo.

echo.
echo [4/5] تنظيف المشروع...
echo ════════════════════════════════════════════════════════════════
echo.
flutter clean
if %errorlevel% neq 0 (
    color 0E
    echo ⚠️ تحذير: حدث خطأ أثناء التنظيف
    echo.
)

echo.
echo [5/5] تحميل وتثبيت المكتبات المطلوبة...
echo ════════════════════════════════════════════════════════════════
echo.
flutter pub get
if %errorlevel% neq 0 (
    color 0C
    echo ❌ خطأ: فشل تحميل المكتبات!
    echo.
    echo جرب الأوامر التالية يدوياً:
    echo   1. flutter clean
    echo   2. flutter pub get
    echo.
    pause
    exit /b 1
)

echo.
echo.
color 0A
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                                                                ║
echo ║                ✅ تم الإعداد بنجاح!                          ║
echo ║                                                                ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo.
echo ══════════════════════════════════════════════════════════════
echo   الخطوات التالية:
echo ══════════════════════════════════════════════════════════════
echo.
echo   1️⃣  لتشغيل التطبيق:
echo      👉 انقر نقراً مزدوجاً على: run.bat
echo      👉 أو اكتب: flutter run -d windows
echo.
echo   2️⃣  لبناء التطبيق للإنتاج:
echo      👉 انقر نقراً مزدوجاً على: build.bat
echo      👉 أو اكتب: flutter build windows --release
echo.
echo   3️⃣  لقراءة دليل الاستخدام:
echo      👉 افتح: QUICK_START.md
echo.
echo ══════════════════════════════════════════════════════════════
echo.
echo.

choice /C YN /M "هل تريد تشغيل التطبيق الآن؟ (Y/N)"
if %errorlevel% equ 1 (
    echo.
    echo جاري تشغيل التطبيق...
    echo.
    flutter run -d windows
) else (
    echo.
    echo شكراً لك! يمكنك تشغيل التطبيق لاحقاً من run.bat
    echo.
)

pause

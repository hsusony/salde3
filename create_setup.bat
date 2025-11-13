@echo off
chcp 65001 >nul
echo ═══════════════════════════════════════════════════════════
echo     نظام إدارة المبيعات - 9Soft
echo     بناء ملف Setup التثبيت
echo ═══════════════════════════════════════════════════════════
echo.

REM التحقق من وجود Inno Setup
set INNO_PATH="C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
if not exist %INNO_PATH% (
    set INNO_PATH="C:\Program Files\Inno Setup 6\ISCC.exe"
)

if not exist %INNO_PATH% (
    echo.
    echo ⚠️  خطأ: Inno Setup غير مثبت!
    echo.
    echo الرجاء تحميل وتثبيت Inno Setup من:
    echo https://jrsoftware.org/isdl.php
    echo.
    echo أو يمكنك استخدام الملف المضغوط الجاهز:
    echo SalesSystem_v3.0_Nov2025.zip
    echo.
    pause
    exit /b 1
)

echo ✓ تم العثور على Inno Setup
echo.

REM التحقق من وجود ملف البناء
if not exist "build\windows\x64\runner\Release\sales_management_system.exe" (
    echo.
    echo ⚠️  خطأ: ملف البرنامج غير موجود!
    echo.
    echo الرجاء بناء البرنامج أولاً باستخدام:
    echo flutter build windows --release
    echo.
    pause
    exit /b 1
)

echo ✓ ملف البرنامج موجود
echo.

REM إنشاء مجلد المخرجات
if not exist "installer_output" mkdir installer_output

echo جاري بناء ملف Setup...
echo.

REM بناء Setup
%INNO_PATH% "sales_system_setup.iss"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ═══════════════════════════════════════════════════════════
    echo     ✅ تم بناء ملف Setup بنجاح!
    echo ═══════════════════════════════════════════════════════════
    echo.
    echo الملف موجود في:
    echo installer_output\SalesSystem_Setup_v3.0.0.exe
    echo.
    
    REM نسخ إلى سطح المكتب
    echo جاري نسخ الملف إلى سطح المكتب...
    copy "installer_output\SalesSystem_Setup_v3.0.0.exe" "%USERPROFILE%\Desktop\SalesSystem_Setup_v3.0.0.exe" >nul
    
    if %ERRORLEVEL% EQU 0 (
        echo ✓ تم النسخ إلى سطح المكتب بنجاح!
        echo.
        
        REM عرض معلومات الملف
        for %%F in ("installer_output\SalesSystem_Setup_v3.0.0.exe") do (
            set size=%%~zF
            set /a sizeMB=!size!/1048576
            echo 📦 حجم الملف: !sizeMB! MB
        )
        echo.
        echo 🎯 الملف جاهز للتوزيع!
        echo.
        
        REM فتح المجلد
        echo هل تريد فتح مجلد المخرجات؟ (Y/N)
        choice /c YN /n
        if errorlevel 2 goto end
        if errorlevel 1 explorer "installer_output"
    )
) else (
    echo.
    echo ═══════════════════════════════════════════════════════════
    echo     ❌ فشل بناء ملف Setup!
    echo ═══════════════════════════════════════════════════════════
    echo.
    echo الرجاء التحقق من:
    echo 1. ملف sales_system_setup.iss
    echo 2. وجود جميع الملفات المطلوبة
    echo 3. صلاحيات الكتابة
    echo.
)

:end
echo.
pause

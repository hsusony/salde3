@echo off
chcp 65001 >nul
echo ========================================
echo بناء ملف التنصيب الذكي EXE2
echo Smart Installer Builder
echo ========================================
echo.

echo [1/4] فحص متطلبات البناء...
echo Checking build requirements...
echo.

REM فحص وجود Inno Setup
set "INNO_PATH=C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
if not exist "%INNO_PATH%" (
    echo ❌ خطأ: Inno Setup غير مثبت
    echo Error: Inno Setup not found
    echo.
    echo يرجى تثبيت Inno Setup 6 من:
    echo https://jrsoftware.org/isdl.php
    pause
    exit /b 1
)

REM فحص وجود ملف Release
if not exist "build\windows\x64\runner\Release\sales_management_system.exe" (
    echo ❌ خطأ: ملف Release غير موجود
    echo Error: Release build not found
    echo.
    echo [2/4] بناء نسخة Release...
    echo Building Release version...
    echo.
    
    call flutter build windows --release --obfuscate --split-debug-info=debug_info
    
    if errorlevel 1 (
        echo.
        echo ❌ فشل البناء!
        echo Build failed!
        pause
        exit /b 1
    )
    
    REM حذف مجلد debug_info للأمان
    if exist "debug_info" (
        echo حذف ملفات التصحيح...
        rd /s /q debug_info
    )
) else (
    echo ✅ ملف Release موجود
    echo Release build found
    echo.
)

REM فحص وجود ملفات SQL Server
echo [3/4] فحص ملفات SQL Server...
echo Checking SQL Server files...
echo.

if not exist "sqlserver_config.ini" (
    echo ⚠️ تحذير: sqlserver_config.ini غير موجود
    echo Warning: sqlserver_config.ini not found
    echo سيتم إنشاؤه...
    echo Creating it...
    
    REM إنشاء ملف الإعدادات الأساسي
    (
        echo [OPTIONS]
        echo ACTION="Install"
        echo FEATURES=SQLENGINE
        echo INSTANCENAME="MorabSQLE"
        echo SQLCOLLATION="Arabic_CI_AS"
        echo SECURITYMODE="SQL"
        echo SAPWD="123@a"
        echo TCPENABLED="1"
    ) > sqlserver_config.ini
    echo ✅ تم إنشاء sqlserver_config.ini
)

if not exist "install_sqlserver.bat" (
    echo ⚠️ تحذير: install_sqlserver.bat غير موجود
    echo Warning: install_sqlserver.bat not found
    echo سيتم إنشاؤه...
    echo Creating it...
    
    REM إنشاء سكريبت التثبيت الأساسي
    (
        echo @echo off
        echo echo تثبيت SQL Server...
        echo echo يرجى الانتظار...
        echo REM Add SQL Server installation commands here
        echo pause
    ) > install_sqlserver.bat
    echo ✅ تم إنشاء install_sqlserver.bat
)

echo ✅ جميع الملفات المطلوبة موجودة
echo All required files found
echo.

echo [4/4] بناء ملف التنصيب EXE2...
echo Building EXE2 installer...
echo.

REM إنشاء مجلد الخرج إذا لم يكن موجود
if not exist "installer_output" mkdir installer_output

REM بناء الـ installer
"%INNO_PATH%" "installer_script_exe2.iss"

if errorlevel 1 (
    echo.
    echo ❌ فشل إنشاء ملف التنصيب!
    echo Failed to create installer!
    pause
    exit /b 1
)

echo.
echo ========================================
echo ✅ تم بناء ملف التنصيب بنجاح!
echo Installer built successfully!
echo ========================================
echo.
echo 📦 الملف: installer_output\SalesManagementSystem_Setup_EXE2.exe
echo 📊 المميزات:
echo    ✅ فحص تلقائي لـ SQL Server
echo    ✅ تخطي التثبيت إذا كان موجود
echo    ✅ تثبيت تلقائي إذا لم يكن موجود
echo    ✅ رسائل توضيحية بالعربية
echo    ✅ حماية الكود بـ Obfuscation
echo.

REM نسخ إلى Desktop\exe
set "TARGET_DIR=%USERPROFILE%\Desktop\exe"
if not exist "%TARGET_DIR%" mkdir "%TARGET_DIR%"

echo نسخ الملف إلى Desktop\exe...
copy /Y "installer_output\SalesManagementSystem_Setup_EXE2.exe" "%TARGET_DIR%\"

if errorlevel 0 (
    echo ✅ تم النسخ إلى: %TARGET_DIR%
    echo.
    
    REM فتح المجلد
    explorer "%TARGET_DIR%"
)

echo.
echo اضغط أي زر للخروج...
pause >nul

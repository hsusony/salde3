@echo off
chcp 65001 >nul
echo ═══════════════════════════════════════════════════════════
echo     نظام إدارة المبيعات - إنشاء Setup محمول
echo ═══════════════════════════════════════════════════════════
echo.

REM إنشاء مجلد Setup
set SETUP_DIR=SalesSystem_Portable_Setup
if exist "%SETUP_DIR%" rmdir /s /q "%SETUP_DIR%"
mkdir "%SETUP_DIR%"

echo ✓ إنشاء مجلد Setup...
echo.

REM نسخ ملفات البرنامج
echo جاري نسخ ملفات البرنامج...
xcopy "build\windows\x64\runner\Release\*" "%SETUP_DIR%\" /E /I /H /Y >nul

echo ✓ تم نسخ البرنامج
echo.

REM إنشاء ملف تثبيت تلقائي
echo جاري إنشاء ملف التثبيت...
(
echo @echo off
echo chcp 65001 ^>nul
echo cls
echo.
echo ═══════════════════════════════════════════════════════════
echo      نظام إدارة المبيعات - 9Soft
echo      التثبيت التلقائي - الإصدار 3.0.0
echo ═══════════════════════════════════════════════════════════
echo.
echo مرحباً بك في معالج التثبيت!
echo.
echo سيتم تثبيت البرنامج في:
echo C:\Program Files\9Soft\SalesSystem
echo.
echo الرجاء الانتظار...
echo.
echo.
timeout /t 2 /nobreak ^>nul
echo ✓ جاري إنشاء المجلدات...
if not exist "C:\Program Files\9Soft" mkdir "C:\Program Files\9Soft"
if not exist "C:\Program Files\9Soft\SalesSystem" mkdir "C:\Program Files\9Soft\SalesSystem"
echo.
echo ✓ جاري نسخ الملفات...
xcopy "*.*" "C:\Program Files\9Soft\SalesSystem\" /E /I /H /Y ^>nul
echo.
echo ✓ جاري إنشاء اختصارات...
powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\نظام إدارة المبيعات.lnk'^); $Shortcut.TargetPath = 'C:\Program Files\9Soft\SalesSystem\sales_management_system.exe'; $Shortcut.Save(^)"
echo.
echo ═══════════════════════════════════════════════════════════
echo      ✅ تم التثبيت بنجاح!
echo ═══════════════════════════════════════════════════════════
echo.
echo تم إنشاء:
echo   ✓ المجلد: C:\Program Files\9Soft\SalesSystem
echo   ✓ اختصار على سطح المكتب
echo.
echo اسم المستخدم: admin
echo كلمة المرور: admin
echo.
echo هل تريد تشغيل البرنامج الآن؟ (Y/N^)
choice /c YN /n
if errorlevel 2 goto end
if errorlevel 1 start "" "C:\Program Files\9Soft\SalesSystem\sales_management_system.exe"
:end
echo.
echo شكراً لاستخدام 9Soft!
echo.
pause
) > "%SETUP_DIR%\تثبيت.bat"

echo ✓ تم إنشاء ملف التثبيت
echo.

REM إنشاء ملف تشغيل مباشر
(
echo @echo off
echo start "" "sales_management_system.exe"
) > "%SETUP_DIR%\تشغيل.bat"

REM نسخ ملفات التوثيق
copy "9soft.md" "%SETUP_DIR%\README.txt" >nul 2>&1
copy "LICENSE" "%SETUP_DIR%\LICENSE.txt" >nul 2>&1

echo ✓ تم نسخ ملفات التوثيق
echo.

REM ضغط المجلد
echo جاري إنشاء ملف Setup مضغوط...
powershell -Command "Compress-Archive -Path '%SETUP_DIR%\*' -DestinationPath '%USERPROFILE%\Desktop\SalesSystem_Setup_v3.0.0.zip' -Force"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ═══════════════════════════════════════════════════════════
    echo      ✅ تم إنشاء Setup بنجاح!
    echo ═══════════════════════════════════════════════════════════
    echo.
    echo الملف موجود على سطح المكتب:
    echo SalesSystem_Setup_v3.0.0.zip
    echo.
    for %%F in ("%USERPROFILE%\Desktop\SalesSystem_Setup_v3.0.0.zip") do (
        set size=%%~zF
        set /a sizeMB=!size!/1048576
        echo 📦 الحجم: !sizeMB! MB
    )
    echo.
    echo 🎯 جاهز للتوزيع!
    echo.
    echo فتح سطح المكتب؟ (Y/N)
    choice /c YN /n
    if errorlevel 2 goto finish
    if errorlevel 1 explorer "%USERPROFILE%\Desktop"
) else (
    echo.
    echo ❌ حدث خطأ أثناء الضغط
)

:finish
echo.
pause

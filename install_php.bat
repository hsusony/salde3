@echo off
chcp 65001 >nul
echo ========================================
echo تثبيت PHP لتشغيل الباك اند
echo Installing PHP for Backend
echo ========================================
echo.

echo [1/4] تحميل PHP 8.2...
echo Downloading PHP 8.2...
echo.

REM تحميل PHP Thread Safe
set "PHP_URL=https://windows.php.net/downloads/releases/php-8.2.13-Win32-vs16-x64.zip"
set "DOWNLOAD_PATH=%TEMP%\php.zip"
set "INSTALL_PATH=C:\php"

echo تحميل من: %PHP_URL%
powershell -Command "Invoke-WebRequest -Uri '%PHP_URL%' -OutFile '%DOWNLOAD_PATH%'"

if not exist "%DOWNLOAD_PATH%" (
    echo ❌ فشل التحميل!
    echo Download failed!
    pause
    exit /b 1
)

echo ✅ تم التحميل بنجاح
echo.

echo [2/4] استخراج الملفات...
echo Extracting files...
echo.

if exist "%INSTALL_PATH%" (
    echo حذف المجلد القديم...
    rd /s /q "%INSTALL_PATH%"
)

mkdir "%INSTALL_PATH%"
powershell -Command "Expand-Archive -Path '%DOWNLOAD_PATH%' -DestinationPath '%INSTALL_PATH%' -Force"

echo ✅ تم الاستخراج
echo.

echo [3/4] إعداد PHP...
echo Configuring PHP...
echo.

REM نسخ ملف الإعدادات
copy "%INSTALL_PATH%\php.ini-development" "%INSTALL_PATH%\php.ini"

REM تفعيل الإضافات المطلوبة
powershell -Command "(Get-Content '%INSTALL_PATH%\php.ini') -replace ';extension=pdo_sqlsrv', 'extension=pdo_sqlsrv' | Set-Content '%INSTALL_PATH%\php.ini'"
powershell -Command "(Get-Content '%INSTALL_PATH%\php.ini') -replace ';extension=sqlsrv', 'extension=sqlsrv' | Set-Content '%INSTALL_PATH%\php.ini'"
powershell -Command "(Get-Content '%INSTALL_PATH%\php.ini') -replace ';extension=mbstring', 'extension=mbstring' | Set-Content '%INSTALL_PATH%\php.ini'"
powershell -Command "(Get-Content '%INSTALL_PATH%\php.ini') -replace ';extension=openssl', 'extension=openssl' | Set-Content '%INSTALL_PATH%\php.ini'"
powershell -Command "(Get-Content '%INSTALL_PATH%\php.ini') -replace ';extension=curl', 'extension=curl' | Set-Content '%INSTALL_PATH%\php.ini'"

echo ✅ تم الإعداد
echo.

echo [4/4] إضافة PHP إلى PATH...
echo Adding PHP to PATH...
echo.

REM إضافة PHP إلى PATH
setx PATH "%PATH%;%INSTALL_PATH%" /M

echo.
echo ========================================
echo ✅ تم تثبيت PHP بنجاح!
echo PHP installed successfully!
echo ========================================
echo.
echo 📍 المسار: %INSTALL_PATH%
echo 📍 Path: %INSTALL_PATH%
echo.
echo ⚠️ ملاحظة: قد تحتاج لإعادة تشغيل الـ Terminal
echo Note: You may need to restart the Terminal
echo.
echo الآن يمكنك تشغيل الباك اند:
echo Now you can run the backend:
echo.
echo   cd backend-php
echo   php -S localhost:8000
echo.

REM تنظيف
del "%DOWNLOAD_PATH%"

pause

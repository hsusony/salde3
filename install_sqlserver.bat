@echo off
chcp 65001 > nul
echo ========================================
echo   تثبيت SQL Server 2008 R2 Express
echo ========================================
echo.

REM التحقق من صلاحيات المسؤول
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ يجب تشغيل هذا الملف كمسؤول!
    echo    انقر بزر الماوس الأيمن واختر "تشغيل كمسؤول"
    pause
    exit /b 1
)

echo [1/4] التحقق من وجود SQL Server...
sc query MSSQL$MorabSQLE >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ SQL Server مثبت بالفعل
    echo    اسم الـ Instance: MorabSQLE
    pause
    exit /b 0
)

echo.
echo [2/4] تحميل SQL Server 2008 R2 Express...
echo    الحجم: ~250 MB
echo    قد يستغرق بعض الوقت...
echo.

set DOWNLOAD_URL=https://download.microsoft.com/download/0/4/B/04BE03CD-EAF3-4797-9D8D-2E08E316C998/SQLEXPR_x64_ENU.exe
set SETUP_FILE=%TEMP%\SQLEXPR_x64_ENU.exe

REM تحميل SQL Server
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile '%SETUP_FILE%'}"

if not exist "%SETUP_FILE%" (
    echo ❌ فشل في تحميل SQL Server!
    echo    تأكد من اتصالك بالإنترنت
    pause
    exit /b 1
)

echo ✅ تم التحميل بنجاح
echo.

echo [3/4] استخراج ملفات التثبيت...
"%SETUP_FILE%" /x:%TEMP%\SQLServer2008 /q
timeout /t 5 >nul

echo.
echo [4/4] تثبيت SQL Server...
echo    🔧 جاري التثبيت الصامت...
echo    ⏳ قد يستغرق 10-15 دقيقة
echo.

"%TEMP%\SQLServer2008\setup.exe" /CONFIGURATIONFILE="%~dp0sqlserver_config.ini" /Q

if %errorlevel% neq 0 (
    echo.
    echo ❌ حدث خطأ في التثبيت!
    echo    كود الخطأ: %errorlevel%
    pause
    exit /b %errorlevel%
)

echo.
echo ========================================
echo ✅ تم تثبيت SQL Server بنجاح!
echo ========================================
echo.
echo 📊 معلومات الاتصال:
echo    Server Name: .\MorabSQLE
echo    Instance: MorabSQLE
echo    Authentication: SQL Server Authentication
echo    Username: sa
echo    Password: 123@a
echo.
echo 🔌 البروتوكولات المفعلة:
echo    ✓ TCP/IP
echo    ✓ Named Pipes
echo.
echo 💡 لاستخدام SQL Server Management Studio:
echo    1. افتح SSMS
echo    2. Server name: .\MorabSQLE
echo    3. Authentication: SQL Server Authentication
echo    4. Login: sa
echo    5. Password: 123@a
echo.

REM تنظيف الملفات المؤقتة
echo تنظيف الملفات المؤقتة...
del /q "%SETUP_FILE%" 2>nul
rmdir /s /q "%TEMP%\SQLServer2008" 2>nul

pause

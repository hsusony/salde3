@echo off
chcp 65001 >nul
echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo 🚀 تثبيت قاعدة بيانات نظام المبيعات - SQL Server 2008+
echo 🚀 Sales Management Database Setup - SQL Server 2008+
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.

REM التحقق من وجود sqlcmd
where sqlcmd >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ خطأ: لم يتم العثور على sqlcmd
    echo ❌ Error: sqlcmd not found
    echo.
    echo 📌 يرجى تثبيت SQL Server Command Line Utilities
    echo 📌 Please install SQL Server Command Line Utilities
    echo.
    pause
    exit /b 1
)

echo 📌 تم العثور على sqlcmd
echo.

REM المعلومات الافتراضية
set SERVER=localhost
set AUTH_MODE=Windows

REM طلب معلومات الاتصال
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo معلومات الاتصال بـ SQL Server
echo SQL Server Connection Information
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.

set /p SERVER=اسم الخادم [localhost]: 
if "%SERVER%"=="" set SERVER=localhost

echo.
echo اختر طريقة المصادقة / Choose Authentication:
echo 1. Windows Authentication (الافتراضي)
echo 2. SQL Server Authentication
echo.
set /p AUTH_CHOICE=الاختيار [1]: 
if "%AUTH_CHOICE%"=="" set AUTH_CHOICE=1

if "%AUTH_CHOICE%"=="2" (
    set AUTH_MODE=SQL
    echo.
    set /p SQL_USER=اسم المستخدم / Username [sa]: 
    if "!SQL_USER!"=="" set SQL_USER=sa
    
    set /p SQL_PASS=كلمة المرور / Password: 
)

echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo 📋 ملخص معلومات الاتصال
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo الخادم: %SERVER%
if "%AUTH_MODE%"=="Windows" (
    echo المصادقة: Windows Authentication
) else (
    echo المصادقة: SQL Server Authentication
    echo المستخدم: %SQL_USER%
)
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.
echo هل تريد المتابعة؟ [Y/N]
set /p CONFIRM=
if /i not "%CONFIRM%"=="Y" if /i not "%CONFIRM%"=="y" (
    echo.
    echo ❌ تم الإلغاء
    pause
    exit /b 0
)

echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo 🔧 جاري تنفيذ الإعداد...
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.

REM بناء أمر sqlcmd
set SQLCMD_BASE=sqlcmd -S %SERVER% -d master

if "%AUTH_MODE%"=="Windows" (
    set SQLCMD=%SQLCMD_BASE% -E
) else (
    set SQLCMD=%SQLCMD_BASE% -U %SQL_USER% -P %SQL_PASS%
)

REM تنفيذ السكربت الرئيسي
echo 📝 تنفيذ: 00_setup_complete_2008.sql
%SQLCMD% -i "00_setup_complete_2008.sql" -o "setup_log.txt"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ❌ حدث خطأ أثناء التثبيت
    echo ❌ Error during installation
    echo.
    echo 📄 يرجى مراجعة ملف: setup_log.txt
    echo 📄 Please check: setup_log.txt
    echo.
    pause
    exit /b 1
)

echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo ✅✅✅ اكتمل التثبيت بنجاح! ✅✅✅
echo ✅✅✅ Installation Completed Successfully! ✅✅✅
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.
echo 📌 معلومات الدخول:
echo    اسم المستخدم: admin
echo    كلمة المرور: admin123
echo.
echo ⚠️  يرجى تغيير كلمة المرور فوراً!
echo.
echo 📄 تم حفظ سجل التثبيت في: setup_log.txt
echo 📖 للمزيد من المعلومات: README_SQL_2008.md
echo.
pause

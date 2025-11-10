@echo off
chcp 65001 > nul
echo.
echo ═══════════════════════════════════════════════════════════════
echo    تنفيذ سكريبت نظام سندات الدفع الكامل
echo    Complete Payment Voucher System Setup
echo ═══════════════════════════════════════════════════════════════
echo.

REM التحقق من وجود SQL Server
echo 🔍 التحقق من SQL Server...
sqlcmd -S localhost -Q "SELECT @@VERSION" > nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ خطأ: SQL Server غير متوفر
    echo    تأكد من تشغيل SQL Server
    pause
    exit /b 1
)

echo ✅ SQL Server متصل
echo.

REM المتغيرات
set SERVER=localhost
set DATABASE=SalesManagementDB
set SCRIPT=08_payment_vouchers_complete.sql

echo 📋 إعدادات الاتصال:
echo    • الخادم: %SERVER%
echo    • قاعدة البيانات: %DATABASE%
echo    • الملف: %SCRIPT%
echo.

REM التحقق من وجود قاعدة البيانات
echo 🔍 التحقق من وجود قاعدة البيانات...
sqlcmd -S %SERVER% -Q "IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'%DATABASE%') PRINT 'NOT_FOUND'" -h -1 -W | findstr "NOT_FOUND" > nul
if %errorlevel% equ 0 (
    echo ⚠️  قاعدة البيانات %DATABASE% غير موجودة
    echo    يرجى تشغيل create_database_2008.sql أولاً
    pause
    exit /b 1
)

echo ✅ قاعدة البيانات موجودة
echo.

REM التحقق من وجود الملف
if not exist "%SCRIPT%" (
    echo ❌ خطأ: الملف %SCRIPT% غير موجود
    pause
    exit /b 1
)

echo ✅ الملف موجود
echo.

echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo    بدء تنفيذ السكريبت...
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.

REM تنفيذ السكريبت
sqlcmd -S %SERVER% -d %DATABASE% -i "%SCRIPT%" -o payment_voucher_setup.log
if %errorlevel% neq 0 (
    echo.
    echo ❌ فشل تنفيذ السكريبت
    echo    راجع ملف payment_voucher_setup.log للتفاصيل
    pause
    exit /b 1
)

echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo    ✅ تم تنفيذ السكريبت بنجاح!
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.

REM عرض ملخص
echo 📊 ملخص العملية:
echo.

REM عدد الجداول
echo 📋 الجداول المُنشأة:
sqlcmd -S %SERVER% -d %DATABASE% -Q "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME IN ('PaymentVouchers', 'MultiplePaymentVouchers', 'PaymentVoucherItems', 'DualCurrencyPayments', 'DisbursementVouchers', 'CurrencyBalances') ORDER BY TABLE_NAME" -h -1 -W
echo.

REM عدد Stored Procedures
echo ⚙️ Stored Procedures:
sqlcmd -S %SERVER% -d %DATABASE% -Q "SELECT name FROM sys.procedures WHERE name LIKE 'sp_%Payment%' ORDER BY name" -h -1 -W
echo.

REM عدد Views
echo 📈 Views:
sqlcmd -S %SERVER% -d %DATABASE% -Q "SELECT name FROM sys.views WHERE name LIKE 'vw_%Payment%' ORDER BY name" -h -1 -W
echo.

REM عدد السندات التجريبية
echo 📝 البيانات التجريبية:
sqlcmd -S %SERVER% -d %DATABASE% -Q "SELECT COUNT(*) as 'عدد السندات التجريبية' FROM PaymentVouchers" -h -1 -W
echo.

REM عرض السندات التجريبية
echo 💰 السندات المُضافة:
sqlcmd -S %SERVER% -d %DATABASE% -Q "SELECT voucherNumber as 'رقم السند', accountName as 'اسم الحساب', totalAmount as 'المبلغ', currency as 'العملة' FROM PaymentVouchers" -h -1 -W
echo.

echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo    🎉 النظام جاهز للاستخدام!
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.
echo 📖 للمزيد من المعلومات:
echo    • راجع PAYMENT_VOUCHER_DATABASE_GUIDE.md
echo    • راجع payment_voucher_setup.log للتفاصيل الكاملة
echo.

pause

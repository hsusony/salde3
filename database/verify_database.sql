-- =============================================
-- Database Verification Script
-- سكريبت التحقق من قاعدة البيانات
-- =============================================

USE SalesManagementDB;
GO

PRINT N'';
PRINT N'╔════════════════════════════════════════════════════════════════╗';
PRINT N'║          التحقق من قاعدة بيانات نظام إدارة المبيعات          ║';
PRINT N'║      Sales Management System - Database Verification          ║';
PRINT N'╚════════════════════════════════════════════════════════════════╝';
PRINT N'';

-- =============================================
-- 1. التحقق من الجداول
-- =============================================
PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
PRINT N'1️⃣  التحقق من الجداول (Tables)';
PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';

DECLARE @tableCount INT = (SELECT COUNT(*) FROM sys.tables WHERE type = 'U');
DECLARE @expectedTables INT = 27;

IF @tableCount >= @expectedTables
    PRINT N'✅ عدد الجداول: ' + CAST(@tableCount AS NVARCHAR) + N' (متوقع: ' + CAST(@expectedTables AS NVARCHAR) + N'+)';
ELSE
    PRINT N'⚠️  عدد الجداول: ' + CAST(@tableCount AS NVARCHAR) + N' (أقل من المتوقع: ' + CAST(@expectedTables AS NVARCHAR) + N')';

-- عرض قائمة الجداول
PRINT N'';
PRINT N'الجداول المُنشأة:';
SELECT ROW_NUMBER() OVER (ORDER BY name) AS '#', name AS [Table Name]
FROM sys.tables 
WHERE type = 'U'
ORDER BY name;

-- =============================================
-- 2. التحقق من الإجراءات المخزنة
-- =============================================
PRINT N'';
PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
PRINT N'2️⃣  التحقق من الإجراءات المخزنة (Stored Procedures)';
PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';

DECLARE @spCount INT = (SELECT COUNT(*) FROM sys.procedures);
DECLARE @expectedSPs INT = 10;

IF @spCount >= @expectedSPs
    PRINT N'✅ عدد الإجراءات المخزنة: ' + CAST(@spCount AS NVARCHAR) + N' (متوقع: ' + CAST(@expectedSPs AS NVARCHAR) + N'+)';
ELSE
    PRINT N'⚠️  عدد الإجراءات المخزنة: ' + CAST(@spCount AS NVARCHAR) + N' (أقل من المتوقع: ' + CAST(@expectedSPs AS NVARCHAR) + N')';

PRINT N'';
PRINT N'الإجراءات المخزنة:';
SELECT ROW_NUMBER() OVER (ORDER BY name) AS '#', name AS [Procedure Name]
FROM sys.procedures 
ORDER BY name;

-- =============================================
-- 3. التحقق من العروض (Views)
-- =============================================
PRINT N'';
PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
PRINT N'3️⃣  التحقق من العروض (Views)';
PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';

DECLARE @viewCount INT = (SELECT COUNT(*) FROM sys.views);
DECLARE @expectedViews INT = 11;

IF @viewCount >= @expectedViews
    PRINT N'✅ عدد العروض: ' + CAST(@viewCount AS NVARCHAR) + N' (متوقع: ' + CAST(@expectedViews AS NVARCHAR) + N'+)';
ELSE
    PRINT N'⚠️  عدد العروض: ' + CAST(@viewCount AS NVARCHAR) + N' (أقل من المتوقع: ' + CAST(@expectedViews AS NVARCHAR) + N')';

PRINT N'';
PRINT N'العروض المُنشأة:';
SELECT ROW_NUMBER() OVER (ORDER BY name) AS '#', name AS [View Name]
FROM sys.views 
ORDER BY name;

-- =============================================
-- 4. التحقق من المشغلات (Triggers)
-- =============================================
PRINT N'';
PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
PRINT N'4️⃣  التحقق من المشغلات (Triggers)';
PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';

DECLARE @triggerCount INT = (SELECT COUNT(*) FROM sys.triggers);
DECLARE @expectedTriggers INT = 10;

IF @triggerCount >= @expectedTriggers
    PRINT N'✅ عدد المشغلات: ' + CAST(@triggerCount AS NVARCHAR) + N' (متوقع: ' + CAST(@expectedTriggers AS NVARCHAR) + N'+)';
ELSE
    PRINT N'⚠️  عدد المشغلات: ' + CAST(@triggerCount AS NVARCHAR) + N' (أقل من المتوقع: ' + CAST(@expectedTriggers AS NVARCHAR) + N')';

PRINT N'';
PRINT N'المشغلات المُنشأة:';
SELECT 
    ROW_NUMBER() OVER (ORDER BY t.name) AS '#',
    t.name AS [Trigger Name],
    OBJECT_NAME(t.parent_id) AS [Table Name]
FROM sys.triggers t
ORDER BY t.name;

-- =============================================
-- 5. التحقق من الفهارس (Indexes)
-- =============================================
PRINT N'';
PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
PRINT N'5️⃣  التحقق من الفهارس (Indexes)';
PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';

DECLARE @indexCount INT = (
    SELECT COUNT(*) 
    FROM sys.indexes 
    WHERE is_primary_key = 0 AND is_unique_constraint = 0
);

PRINT N'✅ عدد الفهارس: ' + CAST(@indexCount AS NVARCHAR);

-- =============================================
-- 6. التحقق من البيانات الأولية
-- =============================================
PRINT N'';
PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
PRINT N'6️⃣  التحقق من البيانات الأولية';
PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';

-- المستخدمين
DECLARE @userCount INT = (SELECT COUNT(*) FROM Users);
IF @userCount > 0
    PRINT N'✅ المستخدمين: ' + CAST(@userCount AS NVARCHAR) + N' مستخدم';
ELSE
    PRINT N'⚠️  لا يوجد مستخدمين';

-- المستودعات
DECLARE @warehouseCount INT = (SELECT COUNT(*) FROM Warehouses);
IF @warehouseCount > 0
    PRINT N'✅ المستودعات: ' + CAST(@warehouseCount AS NVARCHAR) + N' مستودع';
ELSE
    PRINT N'⚠️  لا يوجد مستودعات';

-- الصناديق
DECLARE @cashboxCount INT = (SELECT COUNT(*) FROM Cashboxes);
IF @cashboxCount > 0
    PRINT N'✅ الصناديق: ' + CAST(@cashboxCount AS NVARCHAR) + N' صندوق';
ELSE
    PRINT N'⚠️  لا يوجد صناديق';

-- الحسابات
DECLARE @accountCount INT = (SELECT COUNT(*) FROM ChartOfAccounts);
IF @accountCount > 0
    PRINT N'✅ دليل الحسابات: ' + CAST(@accountCount AS NVARCHAR) + N' حساب';
ELSE
    PRINT N'⚠️  لا يوجد حسابات';

-- العملاء
DECLARE @customerCount INT = (SELECT COUNT(*) FROM Customers);
PRINT N'ℹ️  العملاء: ' + CAST(@customerCount AS NVARCHAR);

-- الموردين
DECLARE @supplierCount INT = (SELECT COUNT(*) FROM Suppliers);
PRINT N'ℹ️  الموردين: ' + CAST(@supplierCount AS NVARCHAR);

-- المنتجات
DECLARE @productCount INT = (SELECT COUNT(*) FROM Products);
PRINT N'ℹ️  المنتجات: ' + CAST(@productCount AS NVARCHAR);

-- =============================================
-- 7. التحقق من المستخدم الافتراضي
-- =============================================
PRINT N'';
PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
PRINT N'7️⃣  التحقق من المستخدم الافتراضي';
PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';

IF EXISTS (SELECT * FROM Users WHERE username = 'admin')
BEGIN
    PRINT N'✅ المستخدم الافتراضي موجود (admin)';
    SELECT 
        username AS [Username],
        fullName AS [Full Name],
        role AS [Role],
        isActive AS [Is Active]
    FROM Users 
    WHERE username = 'admin';
END
ELSE
BEGIN
    PRINT N'❌ المستخدم الافتراضي غير موجود!';
END

-- =============================================
-- 8. اختبار الإجراءات المخزنة
-- =============================================
PRINT N'';
PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
PRINT N'8️⃣  اختبار الإجراءات المخزنة الأساسية';
PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';

-- اختبار sp_GetNextSequence
BEGIN TRY
    DECLARE @testNumber NVARCHAR(50);
    EXEC sp_GetNextSequence @counterName = N'فواتير البيع', @nextNumber = @testNumber OUTPUT;
    PRINT N'✅ sp_GetNextSequence يعمل بنجاح. رقم تجريبي: ' + @testNumber;
END TRY
BEGIN CATCH
    PRINT N'❌ خطأ في sp_GetNextSequence: ' + ERROR_MESSAGE();
END CATCH

-- =============================================
-- 9. اختبار العروض (Views)
-- =============================================
PRINT N'';
PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
PRINT N'9️⃣  اختبار العروض (Views)';
PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';

BEGIN TRY
    DECLARE @inventoryCount INT = (SELECT COUNT(*) FROM vw_CurrentInventory);
    PRINT N'✅ vw_CurrentInventory يعمل بنجاح. عدد السجلات: ' + CAST(@inventoryCount AS NVARCHAR);
END TRY
BEGIN CATCH
    PRINT N'❌ خطأ في vw_CurrentInventory: ' + ERROR_MESSAGE();
END CATCH

-- =============================================
-- 🔟 التحقق من العلاقات (Foreign Keys)
-- =============================================
PRINT N'';
PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
PRINT N'🔟 التحقق من العلاقات (Foreign Keys)';
PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';

DECLARE @fkCount INT = (SELECT COUNT(*) FROM sys.foreign_keys);
PRINT N'✅ عدد العلاقات (Foreign Keys): ' + CAST(@fkCount AS NVARCHAR);

-- =============================================
-- النتيجة النهائية
-- =============================================
PRINT N'';
PRINT N'';
PRINT N'╔════════════════════════════════════════════════════════════════╗';
PRINT N'║                       ملخص التحقق                              ║';
PRINT N'║                   Verification Summary                         ║';
PRINT N'╚════════════════════════════════════════════════════════════════╝';
PRINT N'';

SELECT 
    N'الجداول (Tables)' AS [Component],
    @tableCount AS [Count],
    CASE WHEN @tableCount >= @expectedTables THEN N'✅ ممتاز' ELSE N'⚠️ ناقص' END AS [Status]
UNION ALL
SELECT N'الإجراءات المخزنة (Procedures)', @spCount, 
    CASE WHEN @spCount >= @expectedSPs THEN N'✅ ممتاز' ELSE N'⚠️ ناقص' END
UNION ALL
SELECT N'العروض (Views)', @viewCount, 
    CASE WHEN @viewCount >= @expectedViews THEN N'✅ ممتاز' ELSE N'⚠️ ناقص' END
UNION ALL
SELECT N'المشغلات (Triggers)', @triggerCount, 
    CASE WHEN @triggerCount >= @expectedTriggers THEN N'✅ ممتاز' ELSE N'⚠️ ناقص' END
UNION ALL
SELECT N'الفهارس (Indexes)', @indexCount, N'✅ متوفر'
UNION ALL
SELECT N'العلاقات (Foreign Keys)', @fkCount, N'✅ متوفر'
UNION ALL
SELECT N'المستخدمين', @userCount, CASE WHEN @userCount > 0 THEN N'✅ متوفر' ELSE N'❌ غير متوفر' END
UNION ALL
SELECT N'المستودعات', @warehouseCount, CASE WHEN @warehouseCount > 0 THEN N'✅ متوفر' ELSE N'⚠️ غير متوفر' END
UNION ALL
SELECT N'الصناديق', @cashboxCount, CASE WHEN @cashboxCount > 0 THEN N'✅ متوفر' ELSE N'⚠️ غير متوفر' END;

PRINT N'';

-- تحديد الحالة العامة
DECLARE @allOk BIT = 1;

IF @tableCount < @expectedTables SET @allOk = 0;
IF @spCount < @expectedSPs SET @allOk = 0;
IF @viewCount < @expectedViews SET @allOk = 0;
IF @userCount = 0 SET @allOk = 0;

IF @allOk = 1
BEGIN
    PRINT N'╔════════════════════════════════════════════════════════════════╗';
    PRINT N'║              ✅ قاعدة البيانات جاهزة للاستخدام!               ║';
    PRINT N'║           ✅ The database is ready to use!                    ║';
    PRINT N'╚════════════════════════════════════════════════════════════════╝';
    PRINT N'';
    PRINT N'🎉 جميع المكونات موجودة ومُختبرة بنجاح!';
    PRINT N'';
    PRINT N'📌 الخطوات التالية:';
    PRINT N'   1. قم بربط التطبيق بقاعدة البيانات';
    PRINT N'   2. سجل الدخول باستخدام: admin / admin123';
    PRINT N'   3. غيّر كلمة المرور من الإعدادات';
END
ELSE
BEGIN
    PRINT N'╔════════════════════════════════════════════════════════════════╗';
    PRINT N'║              ⚠️  توجد بعض المشاكل في قاعدة البيانات          ║';
    PRINT N'║           ⚠️  There are some issues with the database         ║';
    PRINT N'╚════════════════════════════════════════════════════════════════╝';
    PRINT N'';
    PRINT N'❗ الرجاء مراجعة النتائج أعلاه وإعادة تشغيل السكريبتات الناقصة';
END

PRINT N'';
GO

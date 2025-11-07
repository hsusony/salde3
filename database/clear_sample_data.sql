-- =============================================
-- حذف البيانات الوهمية من النظام
-- Clear Sample Data - Keep Only Essential Records
-- =============================================

USE SalesManagementDB;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
PRINT N'🗑️  جاري حذف البيانات الوهمية...';
PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
GO

-- تعطيل القيود المؤقتة لتسهيل الحذف
BEGIN TRY
    ALTER TABLE SaleItems NOCHECK CONSTRAINT ALL;
    ALTER TABLE Sales NOCHECK CONSTRAINT ALL;
    ALTER TABLE PurchaseItems NOCHECK CONSTRAINT ALL;
    ALTER TABLE Purchases NOCHECK CONSTRAINT ALL;
    ALTER TABLE WarehouseStock NOCHECK CONSTRAINT ALL;
    ALTER TABLE Products NOCHECK CONSTRAINT ALL;
    ALTER TABLE Customers NOCHECK CONSTRAINT ALL;
    ALTER TABLE Suppliers NOCHECK CONSTRAINT ALL;
    ALTER TABLE Installments NOCHECK CONSTRAINT ALL;
    ALTER TABLE InstallmentPayments NOCHECK CONSTRAINT ALL;
    ALTER TABLE JournalEntryLines NOCHECK CONSTRAINT ALL;
    ALTER TABLE JournalEntries NOCHECK CONSTRAINT ALL;
    ALTER TABLE SalesReturns NOCHECK CONSTRAINT ALL;
    ALTER TABLE SalesReturnItems NOCHECK CONSTRAINT ALL;
    ALTER TABLE PurchaseReturns NOCHECK CONSTRAINT ALL;
    ALTER TABLE PurchaseReturnItems NOCHECK CONSTRAINT ALL;
    ALTER TABLE Quotations NOCHECK CONSTRAINT ALL;
    ALTER TABLE QuotationItems NOCHECK CONSTRAINT ALL;
END TRY
BEGIN CATCH
    PRINT N'⚠️  تحذير: بعض القيود غير موجودة';
END CATCH
GO

-- =============================================
-- 1. حذف بيانات المبيعات والمشتريات
-- =============================================
PRINT N'🔄 حذف بيانات المبيعات...';

-- حذف أقساط المبيعات
DELETE FROM InstallmentPayments;
PRINT N'   ✅ تم حذف دفعات الأقساط';

-- حذف الأقساط
DELETE FROM Installments;
PRINT N'   ✅ تم حذف الأقساط';

-- حذف مرتجعات المبيعات
DELETE FROM SalesReturnItems;
DELETE FROM SalesReturns;
PRINT N'   ✅ تم حذف مرتجعات المبيعات';

-- حذف عناصر المبيعات
DELETE FROM SaleItems;
PRINT N'   ✅ تم حذف عناصر المبيعات';

-- حذف فواتير المبيعات
DELETE FROM Sales;
PRINT N'   ✅ تم حذف فواتير المبيعات';

PRINT N'🔄 حذف بيانات المشتريات...';

-- حذف مرتجعات المشتريات
DELETE FROM PurchaseReturnItems;
DELETE FROM PurchaseReturns;
PRINT N'   ✅ تم حذف مرتجعات المشتريات';

-- حذف عناصر المشتريات
DELETE FROM PurchaseItems;
PRINT N'   ✅ تم حذف عناصر المشتريات';

-- حذف فواتير المشتريات
DELETE FROM Purchases;
PRINT N'   ✅ تم حذف فواتير المشتريات';

-- حذف عروض الأسعار
DELETE FROM QuotationItems;
DELETE FROM Quotations;
PRINT N'   ✅ تم حذف عروض الأسعار';

-- =============================================
-- 2. حذف القيود المحاسبية
-- =============================================
PRINT N'🔄 حذف القيود المحاسبية...';
DELETE FROM JournalEntryLines;
DELETE FROM JournalEntries;
PRINT N'   ✅ تم حذف القيود المحاسبية';

-- =============================================
-- 3. حذف المخزون من المستودعات
-- =============================================
PRINT N'🔄 حذف بيانات المخزون...';
DELETE FROM WarehouseStock;
PRINT N'   ✅ تم حذف مخزون المستودعات';

-- =============================================
-- 4. حذف المنتجات الوهمية
-- =============================================
PRINT N'🔄 حذف المنتجات الوهمية...';
DELETE FROM Products;
PRINT N'   ✅ تم حذف جميع المنتجات';

-- =============================================
-- 5. حذف العملاء الوهميين (باستثناء العميل النقدي)
-- =============================================
PRINT N'🔄 حذف العملاء الوهميين...';
DELETE FROM Customers WHERE name != N'عميل نقدي';
PRINT N'   ✅ تم حذف العملاء الوهميين (تم الاحتفاظ بالعميل النقدي)';

-- =============================================
-- 6. حذف الموردين الوهميين
-- =============================================
PRINT N'🔄 حذف الموردين الوهميين...';
DELETE FROM Suppliers;
PRINT N'   ✅ تم حذف جميع الموردين';

-- =============================================
-- 7. إعادة تعيين أرصدة الحسابات المحاسبية
-- =============================================
PRINT N'🔄 إعادة تعيين أرصدة الحسابات...';
UPDATE ChartOfAccounts SET balance = 0;
PRINT N'   ✅ تم إعادة تعيين أرصدة جميع الحسابات إلى صفر';

-- =============================================
-- 8. إعادة تعيين أرصدة الصناديق
-- =============================================
PRINT N'🔄 إعادة تعيين أرصدة الصناديق...';
UPDATE Cashboxes SET balance = 0;
PRINT N'   ✅ تم إعادة تعيين أرصدة جميع الصناديق إلى صفر';

-- =============================================
-- 9. حذف سجلات التدقيق القديمة (اختياري)
-- =============================================
PRINT N'🔄 حذف سجلات التدقيق...';
DELETE FROM AuditLogs;
PRINT N'   ✅ تم حذف سجلات التدقيق';

-- =============================================
-- 10. إعادة تفعيل القيود
-- =============================================
BEGIN TRY
    ALTER TABLE SaleItems CHECK CONSTRAINT ALL;
    ALTER TABLE Sales CHECK CONSTRAINT ALL;
    ALTER TABLE PurchaseItems CHECK CONSTRAINT ALL;
    ALTER TABLE Purchases CHECK CONSTRAINT ALL;
    ALTER TABLE WarehouseStock CHECK CONSTRAINT ALL;
    ALTER TABLE Products CHECK CONSTRAINT ALL;
    ALTER TABLE Customers CHECK CONSTRAINT ALL;
    ALTER TABLE Suppliers CHECK CONSTRAINT ALL;
    ALTER TABLE Installments CHECK CONSTRAINT ALL;
    ALTER TABLE InstallmentPayments CHECK CONSTRAINT ALL;
    ALTER TABLE JournalEntryLines CHECK CONSTRAINT ALL;
    ALTER TABLE JournalEntries CHECK CONSTRAINT ALL;
    ALTER TABLE SalesReturns CHECK CONSTRAINT ALL;
    ALTER TABLE SalesReturnItems CHECK CONSTRAINT ALL;
    ALTER TABLE PurchaseReturns CHECK CONSTRAINT ALL;
    ALTER TABLE PurchaseReturnItems CHECK CONSTRAINT ALL;
    ALTER TABLE Quotations CHECK CONSTRAINT ALL;
    ALTER TABLE QuotationItems CHECK CONSTRAINT ALL;
    PRINT N'   ✅ تم إعادة تفعيل جميع القيود';
END TRY
BEGIN CATCH
    PRINT N'⚠️  تحذير: بعض القيود لم يتم تفعيلها';
END CATCH
GO

-- =============================================
-- عرض ملخص البيانات المتبقية
-- =============================================
PRINT N'';
PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
PRINT N'📊 ملخص البيانات المتبقية في النظام:';
PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';

SELECT N'المستخدمين' AS [الجدول], COUNT(*) AS [العدد] FROM Users
UNION ALL
SELECT N'المستودعات', COUNT(*) FROM Warehouses
UNION ALL
SELECT N'الصناديق', COUNT(*) FROM Cashboxes
UNION ALL
SELECT N'الحسابات المحاسبية', COUNT(*) FROM ChartOfAccounts
UNION ALL
SELECT N'العملاء', COUNT(*) FROM Customers
UNION ALL
SELECT N'الموردين', COUNT(*) FROM Suppliers
UNION ALL
SELECT N'المنتجات', COUNT(*) FROM Products
UNION ALL
SELECT N'فواتير المبيعات', COUNT(*) FROM Sales
UNION ALL
SELECT N'فواتير المشتريات', COUNT(*) FROM Purchases
UNION ALL
SELECT N'القيود المحاسبية', COUNT(*) FROM JournalEntries;

PRINT N'';
PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
PRINT N'✅ اكتمل حذف البيانات الوهمية بنجاح!';
PRINT N'';
PRINT N'📌 البيانات المتبقية:';
PRINT N'   ✓ مستخدم المدير (admin)';
PRINT N'   ✓ المستودعات';
PRINT N'   ✓ الصناديق النقدية';
PRINT N'   ✓ دليل الحسابات';
PRINT N'   ✓ عميل نقدي واحد';
PRINT N'';
PRINT N'🎯 النظام الآن جاهز لإدخال البيانات الحقيقية';
PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
GO

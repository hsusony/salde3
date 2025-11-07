-- ═══════════════════════════════════════════════════════════
-- تحسين الأداء وإضافة Indexes لتسريع قاعدة البيانات
-- ═══════════════════════════════════════════════════════════

USE SalesManagementDB;
GO

-- تعيين الخيارات المطلوبة للفهارس المصفاة
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

PRINT '🚀 بدء تحسين الأداء...';
GO

-- ═══════════════════════════════════════════════════════════
-- 1. إنشاء Indexes على جدول Products
-- ═══════════════════════════════════════════════════════════

-- Index على Barcode لتسريع البحث بالباركود
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Products_Barcode' AND object_id = OBJECT_ID('Products'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Products_Barcode
    ON Products(Barcode)
    INCLUDE (Name, SellingPrice, Stock);
    PRINT '✅ Index على Barcode تم إنشاؤه';
END

-- Index على Name لتسريع البحث بالاسم
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Products_Name' AND object_id = OBJECT_ID('Products'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Products_Name
    ON Products(Name)
    INCLUDE (Barcode, SellingPrice, Stock);
    PRINT '✅ Index على Name تم إنشاؤه';
END

-- Index على Stock لتسريع الاستعلامات عن المخزون
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Products_Stock' AND object_id = OBJECT_ID('Products'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Products_Stock
    ON Products(Stock);
    PRINT '✅ Index على Stock تم إنشاؤه';
END

-- ═══════════════════════════════════════════════════════════
-- 2. إنشاء Indexes على جدول Sales
-- ═══════════════════════════════════════════════════════════

-- Index على InvoiceNumber لتسريع البحث برقم الفاتورة
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Sales_InvoiceNumber' AND object_id = OBJECT_ID('Sales'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX IX_Sales_InvoiceNumber
    ON Sales(InvoiceNumber)
    WHERE InvoiceNumber IS NOT NULL;
    PRINT '✅ Index على InvoiceNumber تم إنشاؤه';
END

-- Index على SaleDate لتسريع التقارير حسب التاريخ
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Sales_SaleDate' AND object_id = OBJECT_ID('Sales'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Sales_SaleDate
    ON Sales(SaleDate DESC)
    INCLUDE (FinalAmount, CustomerID);
    PRINT '✅ Index على SaleDate تم إنشاؤه';
END

-- Index على CustomerID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Sales_CustomerID' AND object_id = OBJECT_ID('Sales'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Sales_CustomerID
    ON Sales(CustomerID)
    WHERE CustomerID IS NOT NULL;
    PRINT '✅ Index على CustomerID تم إنشاؤه';
END

-- ═══════════════════════════════════════════════════════════
-- 3. إنشاء Indexes على جدول SaleItems
-- ═══════════════════════════════════════════════════════════

-- Index على SaleID لتسريع جلب أصناف الفاتورة
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_SaleItems_SaleID' AND object_id = OBJECT_ID('SaleItems'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_SaleItems_SaleID
    ON SaleItems(SaleID)
    INCLUDE (ProductID, Quantity, UnitPrice, TotalPrice);
    PRINT '✅ Index على SaleItems.SaleID تم إنشاؤه';
END

-- Index على ProductID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_SaleItems_ProductID' AND object_id = OBJECT_ID('SaleItems'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_SaleItems_ProductID
    ON SaleItems(ProductID);
    PRINT '✅ Index على SaleItems.ProductID تم إنشاؤه';
END

-- ═══════════════════════════════════════════════════════════
-- 4. إنشاء Indexes على جدول Customers
-- ═══════════════════════════════════════════════════════════

-- Index على Phone لتسريع البحث برقم الهاتف
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Customers_Phone' AND object_id = OBJECT_ID('Customers'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Customers_Phone
    ON Customers(Phone)
    INCLUDE (Name, Address);
    PRINT '✅ Index على Customers.Phone تم إنشاؤه';
END

-- Index على Name
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Customers_Name' AND object_id = OBJECT_ID('Customers'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Customers_Name
    ON Customers(Name);
    PRINT '✅ Index على Customers.Name تم إنشاؤه';
END

-- ═══════════════════════════════════════════════════════════
-- 5. إنشاء Indexes على جدول Purchases
-- ═══════════════════════════════════════════════════════════

-- Index على PurchaseDate
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Purchases_PurchaseDate' AND object_id = OBJECT_ID('Purchases'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Purchases_PurchaseDate
    ON Purchases(PurchaseDate DESC);
    PRINT '✅ Index على PurchaseDate تم إنشاؤه';
END

-- Index على SupplierID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Purchases_SupplierID' AND object_id = OBJECT_ID('Purchases'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Purchases_SupplierID
    ON Purchases(SupplierID);
    PRINT '✅ Index على SupplierID تم إنشاؤه';
END

-- ═══════════════════════════════════════════════════════════
-- 6. إنشاء Indexes على جدول PurchaseItems
-- ═══════════════════════════════════════════════════════════

-- Index على PurchaseID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_PurchaseItems_PurchaseID' AND object_id = OBJECT_ID('PurchaseItems'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_PurchaseItems_PurchaseID
    ON PurchaseItems(PurchaseID)
    INCLUDE (ProductID, Quantity, UnitPrice);
    PRINT '✅ Index على PurchaseItems.PurchaseID تم إنشاؤه';
END

-- Index على ProductID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_PurchaseItems_ProductID' AND object_id = OBJECT_ID('PurchaseItems'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_PurchaseItems_ProductID
    ON PurchaseItems(ProductID);
    PRINT '✅ Index على PurchaseItems.ProductID تم إنشاؤه';
END

-- ═══════════════════════════════════════════════════════════
-- 7. تحديث إحصائيات الجداول
-- ═══════════════════════════════════════════════════════════

PRINT '';
PRINT '📊 تحديث إحصائيات الجداول...';

UPDATE STATISTICS Products WITH FULLSCAN;
UPDATE STATISTICS Sales WITH FULLSCAN;
UPDATE STATISTICS SaleItems WITH FULLSCAN;
UPDATE STATISTICS Customers WITH FULLSCAN;
UPDATE STATISTICS Purchases WITH FULLSCAN;
UPDATE STATISTICS PurchaseItems WITH FULLSCAN;

PRINT '✅ تم تحديث جميع الإحصائيات';

-- ═══════════════════════════════════════════════════════════
-- 8. عرض معلومات الـ Indexes المُنشأة
-- ═══════════════════════════════════════════════════════════

PRINT '';
PRINT '📋 قائمة Indexes المنشأة:';
PRINT '';

SELECT 
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,
    i.type_desc AS IndexType,
    CASE WHEN i.is_unique = 1 THEN 'نعم' ELSE 'لا' END AS IsUnique
FROM sys.indexes i
WHERE i.object_id IN (
    OBJECT_ID('Products'),
    OBJECT_ID('Sales'),
    OBJECT_ID('SaleItems'),
    OBJECT_ID('Customers'),
    OBJECT_ID('Purchases'),
    OBJECT_ID('PurchaseItems')
)
AND i.type > 0  -- استبعاد HEAP
ORDER BY TableName, IndexName;

PRINT '';
PRINT '════════════════════════════════════════════════════════════';
PRINT '✅ تم تحسين الأداء بنجاح!';
PRINT '🚀 قاعدة البيانات أصبحت أسرع بكثير';
PRINT '════════════════════════════════════════════════════════════';

GO

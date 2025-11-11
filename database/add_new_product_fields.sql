-- إضافة الحقول الجديدة لجدول Products
-- تاريخ الإنشاء: 2025-11-11
-- الوصف: إضافة حقول الخصومات، الضرائب، والبيانات الإضافية

USE SalesDB;
GO

-- التحقق من وجود الأعمدة قبل إضافتها لتجنب الأخطاء

-- إضافة سعر البيع بالجملة
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Products') AND name = 'WholesalePrice')
BEGIN
    ALTER TABLE Products ADD WholesalePrice DECIMAL(18,2) NULL;
    PRINT 'تم إضافة عمود WholesalePrice';
END

-- إضافة أسعار الكارتونة
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Products') AND name = 'CartonPurchasePrice')
BEGIN
    ALTER TABLE Products ADD CartonPurchasePrice DECIMAL(18,2) NULL;
    PRINT 'تم إضافة عمود CartonPurchasePrice';
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Products') AND name = 'CartonSellingPrice')
BEGIN
    ALTER TABLE Products ADD CartonSellingPrice DECIMAL(18,2) NULL;
    PRINT 'تم إضافة عمود CartonSellingPrice';
END

-- إضافة نسبة الخصم
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Products') AND name = 'DiscountPercent')
BEGIN
    ALTER TABLE Products ADD DiscountPercent DECIMAL(5,2) NULL;
    PRINT 'تم إضافة عمود DiscountPercent';
END

-- إضافة الضرائب
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Products') AND name = 'TaxBuy')
BEGIN
    ALTER TABLE Products ADD TaxBuy DECIMAL(5,2) NULL;
    PRINT 'تم إضافة عمود TaxBuy';
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Products') AND name = 'TaxSell')
BEGIN
    ALTER TABLE Products ADD TaxSell DECIMAL(5,2) NULL;
    PRINT 'تم إضافة عمود TaxSell';
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Products') AND name = 'ExemptFromTax')
BEGIN
    ALTER TABLE Products ADD ExemptFromTax BIT DEFAULT 0 NOT NULL;
    PRINT 'تم إضافة عمود ExemptFromTax';
END

-- إضافة المواصفات والبيانات الإضافية
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Products') AND name = 'Specifications')
BEGIN
    ALTER TABLE Products ADD Specifications NVARCHAR(500) NULL;
    PRINT 'تم إضافة عمود Specifications';
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Products') AND name = 'Source')
BEGIN
    ALTER TABLE Products ADD Source NVARCHAR(200) NULL;
    PRINT 'تم إضافة عمود Source';
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Products') AND name = 'UnitNumber')
BEGIN
    ALTER TABLE Products ADD UnitNumber NVARCHAR(50) NULL;
    PRINT 'تم إضافة عمود UnitNumber';
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Products') AND name = 'Location')
BEGIN
    ALTER TABLE Products ADD Location NVARCHAR(200) NULL;
    PRINT 'تم إضافة عمود Location';
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Products') AND name = 'MinLimit')
BEGIN
    ALTER TABLE Products ADD MinLimit DECIMAL(18,2) NULL;
    PRINT 'تم إضافة عمود MinLimit';
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Products') AND name = 'SerialNumber')
BEGIN
    ALTER TABLE Products ADD SerialNumber NVARCHAR(100) NULL;
    PRINT 'تم إضافة عمود SerialNumber';
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Products') AND name = 'Note')
BEGIN
    ALTER TABLE Products ADD Note NVARCHAR(1000) NULL;
    PRINT 'تم إضافة عمود Note';
END

PRINT '';
PRINT '✅ تم تحديث جدول Products بنجاح!';
PRINT 'تم إضافة جميع الأعمدة الجديدة للمنتجات.';
GO

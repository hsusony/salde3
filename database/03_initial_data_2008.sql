-- =============================================
-- Initial Data for SQL Server 2008
-- البيانات الأولية لـ SQL Server 2008
-- =============================================

USE SalesManagementDB;
GO

PRINT N'جاري إدخال البيانات الأولية...';
GO

-- =============================================
-- 1. إنشاء مستخدم مدير النظام
-- =============================================
IF NOT EXISTS (SELECT * FROM Users WHERE username = 'admin')
BEGIN
    INSERT INTO Users (username, password, fullName, role, isActive)
    VALUES (
        'admin',
        'admin123',
        N'مدير النظام',
        'admin',
        1
    );
    PRINT N'✅ تم إنشاء مستخدم المدير (admin/admin123)';
END
GO

-- =============================================
-- 2. إنشاء مستودعات افتراضية
-- =============================================
IF NOT EXISTS (SELECT * FROM Warehouses WHERE name = N'المستودع الرئيسي')
BEGIN
    INSERT INTO Warehouses (name, location, isActive, notes)
    VALUES 
        (N'المستودع الرئيسي', N'الطابق الأرضي', 1, N'المستودع الرئيسي للشركة'),
        (N'مستودع الفرع الأول', N'شارع الرشيد', 1, N'مستودع الفرع الأول'),
        (N'مستودع المواد سريعة التلف', N'الطابق السفلي - مبرد', 1, N'للمواد التي تحتاج تبريد');
    
    PRINT N'✅ تم إنشاء المستودعات الافتراضية';
END
GO

-- =============================================
-- 3. إنشاء صناديق نقدية افتراضية
-- =============================================
IF NOT EXISTS (SELECT * FROM Cashboxes WHERE name = N'الصندوق الرئيسي')
BEGIN
    INSERT INTO Cashboxes (name, code, balance, currency, isActive, notes)
    VALUES 
        (N'الصندوق الرئيسي', 'CB001', 0, 'IQD', 1, N'الصندوق الرئيسي - دينار عراقي'),
        (N'صندوق الفرع الأول', 'CB002', 0, 'IQD', 1, N'صندوق الفرع الأول'),
        (N'صندوق الدولار', 'CB003', 0, 'USD', 1, N'صندوق العملة الأجنبية');
    
    PRINT N'✅ تم إنشاء الصناديق النقدية الافتراضية';
END
GO

-- =============================================
-- 4. إنشاء دليل حسابات أساسي
-- =============================================
IF NOT EXISTS (SELECT * FROM ChartOfAccounts WHERE accountCode = '1000')
BEGIN
    -- الأصول
    INSERT INTO ChartOfAccounts (accountCode, accountName, accountType, balance, isActive)
    VALUES ('1000', N'الأصول', N'أصول', 0, 1);
    
    DECLARE @assetsId INT = SCOPE_IDENTITY();
    
    INSERT INTO ChartOfAccounts (accountCode, accountName, accountType, parentAccountId, balance, isActive)
    VALUES ('1100', N'الأصول المتداولة', N'أصول', @assetsId, 0, 1);
    
    DECLARE @currentAssetsId INT = SCOPE_IDENTITY();
    
    INSERT INTO ChartOfAccounts (accountCode, accountName, accountType, parentAccountId, balance, isActive)
    VALUES 
        ('1110', N'النقدية بالصندوق', N'أصول', @currentAssetsId, 0, 1),
        ('1120', N'البنوك', N'أصول', @currentAssetsId, 0, 1),
        ('1130', N'العملاء', N'أصول', @currentAssetsId, 0, 1),
        ('1140', N'المخزون', N'أصول', @currentAssetsId, 0, 1);
    
    -- الالتزامات
    INSERT INTO ChartOfAccounts (accountCode, accountName, accountType, balance, isActive)
    VALUES ('2000', N'الالتزامات', N'التزامات', 0, 1);
    
    DECLARE @liabilitiesId INT = SCOPE_IDENTITY();
    
    INSERT INTO ChartOfAccounts (accountCode, accountName, accountType, parentAccountId, balance, isActive)
    VALUES ('2100', N'الالتزامات المتداولة', N'التزامات', @liabilitiesId, 0, 1);
    
    DECLARE @currentLiabilitiesId INT = SCOPE_IDENTITY();
    
    INSERT INTO ChartOfAccounts (accountCode, accountName, accountType, parentAccountId, balance, isActive)
    VALUES 
        ('2110', N'الموردين', N'التزامات', @currentLiabilitiesId, 0, 1),
        ('2120', N'مصاريف مستحقة', N'التزامات', @currentLiabilitiesId, 0, 1);
    
    -- حقوق الملكية
    INSERT INTO ChartOfAccounts (accountCode, accountName, accountType, balance, isActive)
    VALUES ('3000', N'حقوق الملكية', N'حقوق ملكية', 0, 1);
    
    DECLARE @equityId INT = SCOPE_IDENTITY();
    
    INSERT INTO ChartOfAccounts (accountCode, accountName, accountType, parentAccountId, balance, isActive)
    VALUES 
        ('3100', N'رأس المال', N'حقوق ملكية', @equityId, 0, 1),
        ('3200', N'الأرباح المحتجزة', N'حقوق ملكية', @equityId, 0, 1);
    
    -- الإيرادات
    INSERT INTO ChartOfAccounts (accountCode, accountName, accountType, balance, isActive)
    VALUES ('4000', N'الإيرادات', N'إيرادات', 0, 1);
    
    DECLARE @revenueId INT = SCOPE_IDENTITY();
    
    INSERT INTO ChartOfAccounts (accountCode, accountName, accountType, parentAccountId, balance, isActive)
    VALUES 
        ('4100', N'إيرادات المبيعات', N'إيرادات', @revenueId, 0, 1),
        ('4200', N'إيرادات أخرى', N'إيرادات', @revenueId, 0, 1);
    
    -- المصروفات
    INSERT INTO ChartOfAccounts (accountCode, accountName, accountType, balance, isActive)
    VALUES ('5000', N'المصروفات', N'مصروفات', 0, 1);
    
    DECLARE @expensesId INT = SCOPE_IDENTITY();
    
    INSERT INTO ChartOfAccounts (accountCode, accountName, accountType, parentAccountId, balance, isActive)
    VALUES 
        ('5100', N'تكلفة البضاعة المباعة', N'مصروفات', @expensesId, 0, 1),
        ('5200', N'مصاريف إدارية', N'مصروفات', @expensesId, 0, 1),
        ('5300', N'مصاريف تشغيلية', N'مصروفات', @expensesId, 0, 1),
        ('5400', N'رواتب وأجور', N'مصروفات', @expensesId, 0, 1);
    
    PRINT N'✅ تم إنشاء دليل الحسابات الأساسي';
END
GO

-- =============================================
-- 5. إنشاء بيانات تجريبية للعملاء
-- =============================================
IF NOT EXISTS (SELECT * FROM Customers)
BEGIN
    INSERT INTO Customers (name, phone, address, balance, notes)
    VALUES 
        (N'عميل نقدي', '0000000000', N'', 0, N'العميل الافتراضي للمبيعات النقدية'),
        (N'أحمد محمد', '07701234567', N'بغداد - الكرادة', 0, N'عميل تجريبي'),
        (N'فاطمة حسن', '07709876543', N'بغداد - المنصور', 0, N'عميل تجريبي'),
        (N'علي خالد', '07751234567', N'البصرة - المعقل', 0, N'عميل تجريبي');
    
    PRINT N'✅ تم إنشاء عملاء تجريبيين';
END
GO

-- =============================================
-- 6. إنشاء بيانات تجريبية للموردين
-- =============================================
IF NOT EXISTS (SELECT * FROM Suppliers)
BEGIN
    INSERT INTO Suppliers (name, phone, email, address, balance, notes)
    VALUES 
        (N'شركة الإمداد الذهبي', '07801234567', 'golden@example.com', N'بغداد - الكاظمية', 0, N'مورد رئيسي'),
        (N'مؤسسة التجارة الحديثة', '07809876543', 'modern@example.com', N'أربيل - المركز', 0, N'مورد مواد غذائية'),
        (N'شركة النجاح التجارية', '07851234567', 'success@example.com', N'البصرة - الزبير', 0, N'مورد إلكترونيات');
    
    PRINT N'✅ تم إنشاء موردين تجريبيين';
END
GO

-- =============================================
-- 7. إنشاء منتجات تجريبية
-- =============================================
IF NOT EXISTS (SELECT * FROM Products)
BEGIN
    INSERT INTO Products (name, barcode, category, unit, purchasePrice, sellingPrice, quantity, minQuantity, isActive)
    VALUES 
        -- منتجات غذائية
        (N'أرز أمريكي - كيس 5 كغم', '1234567890001', N'مواد غذائية', N'كيس', 12000, 15000, 100, 20, 1),
        (N'زيت نباتي - لتر', '1234567890002', N'مواد غذائية', N'زجاجة', 3500, 4500, 150, 30, 1),
        (N'سكر - كيس 2 كغم', '1234567890003', N'مواد غذائية', N'كيس', 4000, 5000, 80, 15, 1),
        (N'طحين - كيس 10 كغم', '1234567890004', N'مواد غذائية', N'كيس', 8000, 10000, 60, 10, 1),
        
        -- منتجات تنظيف
        (N'مسحوق غسيل - 3 كغم', '1234567890005', N'مواد تنظيف', N'علبة', 8000, 10000, 50, 10, 1),
        (N'صابون سائل - لتر', '1234567890006', N'مواد تنظيف', N'زجاجة', 3000, 4000, 70, 15, 1),
        
        -- قرطاسية
        (N'دفتر 100 ورقة', '1234567890007', N'قرطاسية', N'حبة', 1000, 1500, 200, 50, 1),
        (N'قلم جاف - أزرق', '1234567890008', N'قرطاسية', N'حبة', 250, 500, 500, 100, 1),
        (N'قلم رصاص HB', '1234567890009', N'قرطاسية', N'حبة', 200, 400, 300, 50, 1),
        
        -- إلكترونيات
        (N'كابل شحن USB', '1234567890010', N'إلكترونيات', N'حبة', 2000, 3500, 100, 20, 1);
    
    PRINT N'✅ تم إنشاء منتجات تجريبية';
END
GO

-- =============================================
-- 8. توزيع المخزون على المستودعات
-- =============================================
IF NOT EXISTS (SELECT * FROM WarehouseStock)
BEGIN
    DECLARE @mainWarehouseId INT = (SELECT TOP 1 id FROM Warehouses WHERE name = N'المستودع الرئيسي');
    
    IF @mainWarehouseId IS NOT NULL
    BEGIN
        INSERT INTO WarehouseStock (warehouseId, productId, quantity, minQuantity)
        SELECT 
            @mainWarehouseId,
            id,
            quantity,
            minQuantity
        FROM Products;
        
        PRINT N'✅ تم توزيع المخزون على المستودع الرئيسي';
    END
END
GO

PRINT N'';
PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
PRINT N'📊 ملخص البيانات الأولية:';
PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';

SELECT N'المستخدمين' AS [الجدول], COUNT(*) AS [العدد] FROM Users
UNION ALL
SELECT N'المستودعات', COUNT(*) FROM Warehouses
UNION ALL
SELECT N'الصناديق', COUNT(*) FROM Cashboxes
UNION ALL
SELECT N'الحسابات', COUNT(*) FROM ChartOfAccounts
UNION ALL
SELECT N'العملاء', COUNT(*) FROM Customers
UNION ALL
SELECT N'الموردين', COUNT(*) FROM Suppliers
UNION ALL
SELECT N'المنتجات', COUNT(*) FROM Products
UNION ALL
SELECT N'مخزون المستودعات', COUNT(*) FROM WarehouseStock;

PRINT N'';
PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
PRINT N'✅ اكتمل إدخال البيانات الأولية بنجاح!';
PRINT N'';
PRINT N'📌 بيانات الدخول:';
PRINT N'   اسم المستخدم: admin';
PRINT N'   كلمة المرور: admin123';
PRINT N'';
PRINT N'⚠️  ملاحظة: يُنصح بتغيير كلمة المرور بعد الدخول الأول';
PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
GO

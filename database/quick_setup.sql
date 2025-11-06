-- إنشاء قاعدة بيانات نظام المبيعات
-- SQL Server 2008 Compatible

USE master;
GO

-- حذف قاعدة البيانات إذا كانت موجودة
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'SalesManagementDB')
BEGIN
    ALTER DATABASE SalesManagementDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE SalesManagementDB;
END
GO

-- إنشاء قاعدة البيانات
CREATE DATABASE SalesManagementDB;
GO

USE SalesManagementDB;
GO

PRINT N'✅ تم إنشاء قاعدة البيانات: SalesManagementDB';
GO

-- جدول المنتجات
CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(200) NOT NULL,
    Barcode NVARCHAR(50),
    BuyingPrice DECIMAL(18,2) DEFAULT 0,
    SellingPrice DECIMAL(18,2) DEFAULT 0,
    Stock DECIMAL(18,2) DEFAULT 0,
    MinStock DECIMAL(18,2) DEFAULT 0,
    CategoryID INT NULL,
    SupplierID INT NULL,
    Description NVARCHAR(MAX) NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME NULL
);
GO

PRINT N'✅ تم إنشاء جدول: Products';
GO

-- جدول العملاء
CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(200) NOT NULL,
    Phone NVARCHAR(20) NULL,
    Address NVARCHAR(500) NULL,
    Email NVARCHAR(100) NULL,
    Notes NVARCHAR(MAX) NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME NULL
);
GO

PRINT N'✅ تم إنشاء جدول: Customers';
GO

-- جدول المبيعات
CREATE TABLE Sales (
    SaleID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NULL,
    SaleDate DATETIME DEFAULT GETDATE(),
    TotalAmount DECIMAL(18,2) NOT NULL DEFAULT 0,
    PaidAmount DECIMAL(18,2) DEFAULT 0,
    Discount DECIMAL(18,2) DEFAULT 0,
    PaymentMethod NVARCHAR(50) NULL,
    Notes NVARCHAR(MAX) NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);
GO

PRINT N'✅ تم إنشاء جدول: Sales';
GO

-- جدول تفاصيل المبيعات
CREATE TABLE SaleItems (
    SaleItemID INT IDENTITY(1,1) PRIMARY KEY,
    SaleID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity DECIMAL(18,2) NOT NULL DEFAULT 0,
    UnitPrice DECIMAL(18,2) NOT NULL DEFAULT 0,
    TotalPrice DECIMAL(18,2) NOT NULL DEFAULT 0,
    FOREIGN KEY (SaleID) REFERENCES Sales(SaleID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
GO

PRINT N'✅ تم إنشاء جدول: SaleItems';
GO

-- إدخال بيانات تجريبية
INSERT INTO Products (Name, Barcode, BuyingPrice, SellingPrice, Stock, MinStock)
VALUES 
    (N'لابتوب HP', '101', 500, 750, 10, 2),
    (N'ماوس لاسلكي', '102', 10, 20, 50, 10),
    (N'لوحة مفاتيح', '103', 15, 30, 30, 5),
    (N'شاشة سامسونج 24 بوصة', '104', 150, 250, 15, 3);
GO

PRINT N'✅ تم إدخال بيانات تجريبية في Products';
GO

INSERT INTO Customers (Name, Phone, Address)
VALUES 
    (N'أحمد محمد', '0771234567', N'بغداد - الكرادة'),
    (N'فاطمة علي', '0779876543', N'بغداد - المنصور'),
    (N'محمد حسن', '0781122334', N'البصرة - المعقل');
GO

PRINT N'✅ تم إدخال بيانات تجريبية في Customers';
GO

-- إدخال مبيعة تجريبية
DECLARE @SaleID INT;

INSERT INTO Sales (CustomerID, TotalAmount, PaidAmount, PaymentMethod)
VALUES (1, 770, 770, N'نقدي');

SET @SaleID = SCOPE_IDENTITY();

INSERT INTO SaleItems (SaleID, ProductID, Quantity, UnitPrice, TotalPrice)
VALUES 
    (@SaleID, 1, 1, 750, 750),
    (@SaleID, 2, 1, 20, 20);

UPDATE Products SET Stock = Stock - 1 WHERE ProductID = 1;
UPDATE Products SET Stock = Stock - 1 WHERE ProductID = 2;

GO

PRINT N'✅ تم إدخال بيع تجريبي';
GO

PRINT N'';
PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
PRINT N'✅✅✅ اكتمل الإعداد بنجاح! ✅✅✅';
PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
PRINT N'';
PRINT N'📊 الإحصائيات:';
SELECT N'المنتجات' AS الجدول, COUNT(*) AS العدد FROM Products
UNION ALL
SELECT N'العملاء', COUNT(*) FROM Customers
UNION ALL
SELECT N'المبيعات', COUNT(*) FROM Sales;
PRINT N'';
PRINT N'🚀 يمكنك الآن تشغيل API Server';
GO

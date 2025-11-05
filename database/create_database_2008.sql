-- =============================================
-- Sales Management System - SQL Server 2008 Database
-- نظام إدارة المبيعات - قاعدة بيانات SQL Server 2008
-- =============================================
-- ملاحظة: هذا الإصدار متوافق مع SQL Server 2008 والإصدارات الأحدث
-- Note: This version is compatible with SQL Server 2008 and later
-- =============================================

-- Create Database
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'SalesManagementDB')
BEGIN
    CREATE DATABASE SalesManagementDB;
    PRINT N'✅ تم إنشاء قاعدة البيانات SalesManagementDB بنجاح';
END
GO

USE SalesManagementDB;
GO

-- =============================================
-- جدول المستخدمين (Users)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Users')
BEGIN
    CREATE TABLE Users (
        id INT IDENTITY(1,1) PRIMARY KEY,
        username NVARCHAR(100) NOT NULL UNIQUE,
        password NVARCHAR(255) NOT NULL,
        fullName NVARCHAR(200),
        role NVARCHAR(50) NOT NULL DEFAULT 'user',
        isActive BIT NOT NULL DEFAULT 1,
        createdAt DATETIME NOT NULL DEFAULT GETDATE(),
        updatedAt DATETIME NOT NULL DEFAULT GETDATE()
    );
    PRINT N'✅ تم إنشاء جدول Users';
END
GO

-- =============================================
-- جدول العملاء (Customers)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Customers')
BEGIN
    CREATE TABLE Customers (
        id INT IDENTITY(1,1) PRIMARY KEY,
        name NVARCHAR(200) NOT NULL,
        phone NVARCHAR(20),
        address NVARCHAR(500),
        balance DECIMAL(18, 2) NOT NULL DEFAULT 0,
        notes NVARCHAR(MAX),
        createdAt DATETIME NOT NULL DEFAULT GETDATE(),
        updatedAt DATETIME NOT NULL DEFAULT GETDATE()
    );
    PRINT N'✅ تم إنشاء جدول Customers';
END
GO

-- =============================================
-- جدول المنتجات (Products)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Products')
BEGIN
    CREATE TABLE Products (
        id INT IDENTITY(1,1) PRIMARY KEY,
        name NVARCHAR(200) NOT NULL,
        barcode NVARCHAR(100) UNIQUE,
        category NVARCHAR(100),
        unit NVARCHAR(50),
        purchasePrice DECIMAL(18, 2) NOT NULL DEFAULT 0,
        sellingPrice DECIMAL(18, 2) NOT NULL DEFAULT 0,
        quantity INT NOT NULL DEFAULT 0,
        minQuantity INT NOT NULL DEFAULT 0,
        isActive BIT NOT NULL DEFAULT 1,
        notes NVARCHAR(MAX),
        createdAt DATETIME NOT NULL DEFAULT GETDATE(),
        updatedAt DATETIME NOT NULL DEFAULT GETDATE()
    );
    PRINT N'✅ تم إنشاء جدول Products';
END
GO

-- =============================================
-- جدول المبيعات (Sales)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Sales')
BEGIN
    CREATE TABLE Sales (
        id INT IDENTITY(1,1) PRIMARY KEY,
        invoiceNumber NVARCHAR(50) NOT NULL UNIQUE,
        customerId INT,
        customerName NVARCHAR(200),
        totalAmount DECIMAL(18, 2) NOT NULL DEFAULT 0,
        discount DECIMAL(18, 2) NOT NULL DEFAULT 0,
        netAmount DECIMAL(18, 2) NOT NULL DEFAULT 0,
        paidAmount DECIMAL(18, 2) NOT NULL DEFAULT 0,
        remainingAmount DECIMAL(18, 2) NOT NULL DEFAULT 0,
        paymentType NVARCHAR(50) NOT NULL DEFAULT N'نقدي',
        status NVARCHAR(50) NOT NULL DEFAULT N'مكتمل',
        notes NVARCHAR(MAX),
        saleDate DATETIME NOT NULL DEFAULT GETDATE(),
        createdAt DATETIME NOT NULL DEFAULT GETDATE(),
        updatedAt DATETIME NOT NULL DEFAULT GETDATE(),
        FOREIGN KEY (customerId) REFERENCES Customers(id) ON DELETE SET NULL
    );
    PRINT N'✅ تم إنشاء جدول Sales';
END
GO

-- =============================================
-- جدول تفاصيل المبيعات (SaleItems)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'SaleItems')
BEGIN
    CREATE TABLE SaleItems (
        id INT IDENTITY(1,1) PRIMARY KEY,
        saleId INT NOT NULL,
        productId INT,
        productName NVARCHAR(200) NOT NULL,
        quantity INT NOT NULL,
        unitPrice DECIMAL(18, 2) NOT NULL,
        totalPrice DECIMAL(18, 2) NOT NULL,
        notes NVARCHAR(MAX),
        createdAt DATETIME NOT NULL DEFAULT GETDATE(),
        FOREIGN KEY (saleId) REFERENCES Sales(id) ON DELETE CASCADE,
        FOREIGN KEY (productId) REFERENCES Products(id) ON DELETE SET NULL
    );
    PRINT N'✅ تم إنشاء جدول SaleItems';
END
GO

-- =============================================
-- جدول المشتريات (Purchases)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Purchases')
BEGIN
    CREATE TABLE Purchases (
        id INT IDENTITY(1,1) PRIMARY KEY,
        invoiceNumber NVARCHAR(50) NOT NULL UNIQUE,
        supplierName NVARCHAR(200),
        totalAmount DECIMAL(18, 2) NOT NULL DEFAULT 0,
        paidAmount DECIMAL(18, 2) NOT NULL DEFAULT 0,
        remainingAmount DECIMAL(18, 2) NOT NULL DEFAULT 0,
        paymentType NVARCHAR(50) NOT NULL DEFAULT N'نقدي',
        status NVARCHAR(50) NOT NULL DEFAULT N'مكتمل',
        notes NVARCHAR(MAX),
        purchaseDate DATETIME NOT NULL DEFAULT GETDATE(),
        createdAt DATETIME NOT NULL DEFAULT GETDATE(),
        updatedAt DATETIME NOT NULL DEFAULT GETDATE()
    );
    PRINT N'✅ تم إنشاء جدول Purchases';
END
GO

-- =============================================
-- جدول تفاصيل المشتريات (PurchaseItems)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PurchaseItems')
BEGIN
    CREATE TABLE PurchaseItems (
        id INT IDENTITY(1,1) PRIMARY KEY,
        purchaseId INT NOT NULL,
        productId INT,
        productName NVARCHAR(200) NOT NULL,
        quantity INT NOT NULL,
        unitPrice DECIMAL(18, 2) NOT NULL,
        totalPrice DECIMAL(18, 2) NOT NULL,
        notes NVARCHAR(MAX),
        createdAt DATETIME NOT NULL DEFAULT GETDATE(),
        FOREIGN KEY (purchaseId) REFERENCES Purchases(id) ON DELETE CASCADE,
        FOREIGN KEY (productId) REFERENCES Products(id) ON DELETE SET NULL
    );
    PRINT N'✅ تم إنشاء جدول PurchaseItems';
END
GO

-- =============================================
-- جدول الأقساط (Installments)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Installments')
BEGIN
    CREATE TABLE Installments (
        id INT IDENTITY(1,1) PRIMARY KEY,
        customerId INT NOT NULL,
        customerName NVARCHAR(200) NOT NULL,
        totalAmount DECIMAL(18, 2) NOT NULL,
        paidAmount DECIMAL(18, 2) NOT NULL DEFAULT 0,
        remainingAmount DECIMAL(18, 2) NOT NULL,
        installmentAmount DECIMAL(18, 2) NOT NULL,
        numberOfInstallments INT NOT NULL,
        status NVARCHAR(50) NOT NULL DEFAULT N'نشط',
        notes NVARCHAR(MAX),
        startDate DATETIME NOT NULL DEFAULT GETDATE(),
        createdAt DATETIME NOT NULL DEFAULT GETDATE(),
        updatedAt DATETIME NOT NULL DEFAULT GETDATE(),
        FOREIGN KEY (customerId) REFERENCES Customers(id) ON DELETE CASCADE
    );
    PRINT N'✅ تم إنشاء جدول Installments';
END
GO

-- =============================================
-- جدول دفعات الأقساط (InstallmentPayments)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'InstallmentPayments')
BEGIN
    CREATE TABLE InstallmentPayments (
        id INT IDENTITY(1,1) PRIMARY KEY,
        installmentId INT NOT NULL,
        amount DECIMAL(18, 2) NOT NULL,
        paymentDate DATETIME NOT NULL DEFAULT GETDATE(),
        notes NVARCHAR(MAX),
        createdAt DATETIME NOT NULL DEFAULT GETDATE(),
        FOREIGN KEY (installmentId) REFERENCES Installments(id) ON DELETE CASCADE
    );
    PRINT N'✅ تم إنشاء جدول InstallmentPayments';
END
GO

-- =============================================
-- جدول عروض الأسعار (Quotations)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Quotations')
BEGIN
    CREATE TABLE Quotations (
        id INT IDENTITY(1,1) PRIMARY KEY,
        quotationNumber NVARCHAR(50) NOT NULL UNIQUE,
        customerId INT,
        customerName NVARCHAR(200),
        totalAmount DECIMAL(18, 2) NOT NULL DEFAULT 0,
        discount DECIMAL(18, 2) NOT NULL DEFAULT 0,
        netAmount DECIMAL(18, 2) NOT NULL DEFAULT 0,
        status NVARCHAR(50) NOT NULL DEFAULT N'قيد الانتظار',
        validUntil DATETIME,
        notes NVARCHAR(MAX),
        quotationDate DATETIME NOT NULL DEFAULT GETDATE(),
        createdAt DATETIME NOT NULL DEFAULT GETDATE(),
        updatedAt DATETIME NOT NULL DEFAULT GETDATE(),
        FOREIGN KEY (customerId) REFERENCES Customers(id) ON DELETE SET NULL
    );
    PRINT N'✅ تم إنشاء جدول Quotations';
END
GO

-- =============================================
-- جدول الطلبات المعلقة (PendingOrders)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PendingOrders')
BEGIN
    CREATE TABLE PendingOrders (
        id INT IDENTITY(1,1) PRIMARY KEY,
        orderNumber NVARCHAR(50) NOT NULL UNIQUE,
        customerId INT,
        customerName NVARCHAR(200),
        totalAmount DECIMAL(18, 2) NOT NULL DEFAULT 0,
        paidAmount DECIMAL(18, 2) NOT NULL DEFAULT 0,
        remainingAmount DECIMAL(18, 2) NOT NULL DEFAULT 0,
        status NVARCHAR(50) NOT NULL DEFAULT N'معلق',
        notes NVARCHAR(MAX),
        orderDate DATETIME NOT NULL DEFAULT GETDATE(),
        createdAt DATETIME NOT NULL DEFAULT GETDATE(),
        updatedAt DATETIME NOT NULL DEFAULT GETDATE(),
        FOREIGN KEY (customerId) REFERENCES Customers(id) ON DELETE SET NULL
    );
    PRINT N'✅ تم إنشاء جدول PendingOrders';
END
GO

-- =============================================
-- جدول سندات القبض (PaymentVouchers)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PaymentVouchers')
BEGIN
    CREATE TABLE PaymentVouchers (
        id INT IDENTITY(1,1) PRIMARY KEY,
        voucherNumber NVARCHAR(50) NOT NULL UNIQUE,
        customerId INT,
        customerName NVARCHAR(200) NOT NULL,
        amount DECIMAL(18, 2) NOT NULL,
        paymentType NVARCHAR(50) NOT NULL DEFAULT N'نقدي',
        notes NVARCHAR(MAX),
        voucherDate DATETIME NOT NULL DEFAULT GETDATE(),
        createdAt DATETIME NOT NULL DEFAULT GETDATE(),
        FOREIGN KEY (customerId) REFERENCES Customers(id) ON DELETE SET NULL
    );
    PRINT N'✅ تم إنشاء جدول PaymentVouchers';
END
GO

-- =============================================
-- جدول سندات الصرف (CashVouchers)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CashVouchers')
BEGIN
    CREATE TABLE CashVouchers (
        id INT IDENTITY(1,1) PRIMARY KEY,
        voucherNumber NVARCHAR(50) NOT NULL UNIQUE,
        recipientName NVARCHAR(200) NOT NULL,
        amount DECIMAL(18, 2) NOT NULL,
        purpose NVARCHAR(200),
        notes NVARCHAR(MAX),
        voucherDate DATETIME NOT NULL DEFAULT GETDATE(),
        createdAt DATETIME NOT NULL DEFAULT GETDATE()
    );
    PRINT N'✅ تم إنشاء جدول CashVouchers';
END
GO

-- =============================================
-- جدول المخازن (Warehouses)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Warehouses')
BEGIN
    CREATE TABLE Warehouses (
        id INT IDENTITY(1,1) PRIMARY KEY,
        name NVARCHAR(200) NOT NULL UNIQUE,
        location NVARCHAR(500),
        isActive BIT NOT NULL DEFAULT 1,
        notes NVARCHAR(MAX),
        createdAt DATETIME NOT NULL DEFAULT GETDATE(),
        updatedAt DATETIME NOT NULL DEFAULT GETDATE()
    );
    PRINT N'✅ تم إنشاء جدول Warehouses';
END
GO

-- =============================================
-- جدول حركات المخزون (InventoryTransactions)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'InventoryTransactions')
BEGIN
    CREATE TABLE InventoryTransactions (
        id INT IDENTITY(1,1) PRIMARY KEY,
        transactionNumber NVARCHAR(50) NOT NULL UNIQUE,
        warehouseId INT,
        transactionType NVARCHAR(50) NOT NULL,
        productId INT,
        productName NVARCHAR(200) NOT NULL,
        quantity INT NOT NULL,
        notes NVARCHAR(MAX),
        transactionDate DATETIME NOT NULL DEFAULT GETDATE(),
        createdAt DATETIME NOT NULL DEFAULT GETDATE(),
        FOREIGN KEY (warehouseId) REFERENCES Warehouses(id) ON DELETE SET NULL,
        FOREIGN KEY (productId) REFERENCES Products(id) ON DELETE SET NULL
    );
    PRINT N'✅ تم إنشاء جدول InventoryTransactions';
END
GO

-- =============================================
-- جدول سجل العمليات (AuditLogs)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'AuditLogs')
BEGIN
    CREATE TABLE AuditLogs (
        id INT IDENTITY(1,1) PRIMARY KEY,
        userId INT,
        userName NVARCHAR(200),
        action NVARCHAR(200) NOT NULL,
        tableName NVARCHAR(100),
        recordId INT,
        oldValue NVARCHAR(MAX),
        newValue NVARCHAR(MAX),
        ipAddress NVARCHAR(50),
        createdAt DATETIME NOT NULL DEFAULT GETDATE(),
        FOREIGN KEY (userId) REFERENCES Users(id) ON DELETE SET NULL
    );
    PRINT N'✅ تم إنشاء جدول AuditLogs';
END
GO

-- =============================================
-- إنشاء الفهارس (Indexes) لتحسين الأداء
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Sales_InvoiceNumber' AND object_id = OBJECT_ID('Sales'))
    CREATE NONCLUSTERED INDEX IX_Sales_InvoiceNumber ON Sales(invoiceNumber);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Sales_CustomerId' AND object_id = OBJECT_ID('Sales'))
    CREATE NONCLUSTERED INDEX IX_Sales_CustomerId ON Sales(customerId);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Sales_Date' AND object_id = OBJECT_ID('Sales'))
    CREATE NONCLUSTERED INDEX IX_Sales_Date ON Sales(saleDate);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Purchases_InvoiceNumber' AND object_id = OBJECT_ID('Purchases'))
    CREATE NONCLUSTERED INDEX IX_Purchases_InvoiceNumber ON Purchases(invoiceNumber);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Purchases_Date' AND object_id = OBJECT_ID('Purchases'))
    CREATE NONCLUSTERED INDEX IX_Purchases_Date ON Purchases(purchaseDate);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Products_Barcode' AND object_id = OBJECT_ID('Products'))
    CREATE NONCLUSTERED INDEX IX_Products_Barcode ON Products(barcode);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Products_Name' AND object_id = OBJECT_ID('Products'))
    CREATE NONCLUSTERED INDEX IX_Products_Name ON Products(name);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Customers_Name' AND object_id = OBJECT_ID('Customers'))
    CREATE NONCLUSTERED INDEX IX_Customers_Name ON Customers(name);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Customers_Phone' AND object_id = OBJECT_ID('Customers'))
    CREATE NONCLUSTERED INDEX IX_Customers_Phone ON Customers(phone);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Installments_CustomerId' AND object_id = OBJECT_ID('Installments'))
    CREATE NONCLUSTERED INDEX IX_Installments_CustomerId ON Installments(customerId);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Installments_Status' AND object_id = OBJECT_ID('Installments'))
    CREATE NONCLUSTERED INDEX IX_Installments_Status ON Installments(status);

PRINT N'✅ تم إنشاء جميع الفهارس بنجاح';
GO

PRINT N'';
PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
PRINT N'✅ اكتمل إنشاء قاعدة البيانات الأساسية بنجاح!';
PRINT N'✅ Database created successfully!';
PRINT N'✅ متوافق مع SQL Server 2008+';
PRINT N'';
PRINT N'📋 الجداول المُنشأة (16 جدول):';
PRINT N'   - Users (المستخدمين)';
PRINT N'   - Customers (العملاء)';
PRINT N'   - Products (المنتجات)';
PRINT N'   - Sales (المبيعات)';
PRINT N'   - SaleItems (تفاصيل المبيعات)';
PRINT N'   - Purchases (المشتريات)';
PRINT N'   - PurchaseItems (تفاصيل المشتريات)';
PRINT N'   - Installments (الأقساط)';
PRINT N'   - Warehouses (المستودعات)';
PRINT N'   - InventoryTransactions (حركة المخزون)';
PRINT N'   - CashVouchers (سندات القبض)';
PRINT N'   - PaymentVouchers (سندات الصرف)';
PRINT N'   - PendingOrders (الطلبيات المعلقة)';
PRINT N'   - Quotations (عروض الأسعار)';
PRINT N'   - QuotationItems (تفاصيل عروض الأسعار)';
PRINT N'   - AuditLogs (سجل التدقيق)';
PRINT N'';
PRINT N'📌 الخطوات التالية:';
PRINT N'   1. تنفيذ: 02_additional_tables_2008.sql (11 جدول إضافي)';
PRINT N'   2. تنفيذ: 03_initial_data_2008.sql (البيانات الأولية)';
PRINT N'';
PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
GO

-- =============================================
-- Additional Tables for SQL Server 2008
-- الجداول الإضافية لـ SQL Server 2008
-- =============================================

USE SalesManagementDB;
GO

-- =============================================
-- جدول الصناديق (Cashboxes)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Cashboxes')
BEGIN
    CREATE TABLE Cashboxes (
        id INT IDENTITY(1,1) PRIMARY KEY,
        name NVARCHAR(200) NOT NULL UNIQUE,
        code NVARCHAR(50) UNIQUE,
        balance DECIMAL(18, 2) NOT NULL DEFAULT 0,
        currency NVARCHAR(10) NOT NULL DEFAULT 'IQD',
        isActive BIT NOT NULL DEFAULT 1,
        notes NVARCHAR(MAX),
        createdAt DATETIME NOT NULL DEFAULT GETDATE(),
        updatedAt DATETIME NOT NULL DEFAULT GETDATE()
    );
    PRINT N'✅ تم إنشاء جدول Cashboxes';
END
GO

-- =============================================
-- جدول التحويلات بين الصناديق (TransferVouchers)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TransferVouchers')
BEGIN
    CREATE TABLE TransferVouchers (
        id INT IDENTITY(1,1) PRIMARY KEY,
        voucherNumber NVARCHAR(50) NOT NULL UNIQUE,
        fromCashboxId INT NOT NULL,
        toCashboxId INT NOT NULL,
        amount DECIMAL(18, 2) NOT NULL,
        transferType NVARCHAR(50) NOT NULL DEFAULT N'صندوق إلى صندوق',
        notes NVARCHAR(MAX),
        transferDate DATETIME NOT NULL DEFAULT GETDATE(),
        createdAt DATETIME NOT NULL DEFAULT GETDATE(),
        FOREIGN KEY (fromCashboxId) REFERENCES Cashboxes(id),
        FOREIGN KEY (toCashboxId) REFERENCES Cashboxes(id),
        CONSTRAINT CK_TransferDifferentBoxes CHECK (fromCashboxId <> toCashboxId)
    );
    PRINT N'✅ تم إنشاء جدول TransferVouchers';
END
GO

-- =============================================
-- جدول القيود المحاسبية (JournalEntries)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'JournalEntries')
BEGIN
    CREATE TABLE JournalEntries (
        id INT IDENTITY(1,1) PRIMARY KEY,
        entryNumber NVARCHAR(50) NOT NULL UNIQUE,
        entryDate DATETIME NOT NULL DEFAULT GETDATE(),
        description NVARCHAR(500),
        totalDebit DECIMAL(18, 2) NOT NULL DEFAULT 0,
        totalCredit DECIMAL(18, 2) NOT NULL DEFAULT 0,
        isBalanced BIT NOT NULL DEFAULT 0,
        status NVARCHAR(50) NOT NULL DEFAULT N'مسودة',
        createdBy INT,
        approvedBy INT,
        notes NVARCHAR(MAX),
        createdAt DATETIME NOT NULL DEFAULT GETDATE(),
        updatedAt DATETIME NOT NULL DEFAULT GETDATE(),
        FOREIGN KEY (createdBy) REFERENCES Users(id) ON DELETE SET NULL,
        CONSTRAINT CK_JournalBalanced CHECK (totalDebit = totalCredit OR isBalanced = 0)
    );
    PRINT N'✅ تم إنشاء جدول JournalEntries';
END
GO

-- =============================================
-- جدول تفاصيل القيود المحاسبية (JournalEntryLines)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'JournalEntryLines')
BEGIN
    CREATE TABLE JournalEntryLines (
        id INT IDENTITY(1,1) PRIMARY KEY,
        journalEntryId INT NOT NULL,
        accountName NVARCHAR(200) NOT NULL,
        accountCode NVARCHAR(50),
        debit DECIMAL(18, 2) NOT NULL DEFAULT 0,
        credit DECIMAL(18, 2) NOT NULL DEFAULT 0,
        description NVARCHAR(500),
        createdAt DATETIME NOT NULL DEFAULT GETDATE(),
        FOREIGN KEY (journalEntryId) REFERENCES JournalEntries(id) ON DELETE CASCADE,
        CONSTRAINT CK_DebitOrCredit CHECK (
            (debit > 0 AND credit = 0) OR 
            (debit = 0 AND credit > 0) OR 
            (debit = 0 AND credit = 0)
        )
    );
    PRINT N'✅ تم إنشاء جدول JournalEntryLines';
END
GO

-- =============================================
-- جدول التعبئة والتغليف (Packaging)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Packaging')
BEGIN
    CREATE TABLE Packaging (
        id INT IDENTITY(1,1) PRIMARY KEY,
        productId INT NOT NULL,
        packageType NVARCHAR(100) NOT NULL,
        unitsPerPackage INT NOT NULL DEFAULT 1,
        packageBarcode NVARCHAR(100) UNIQUE,
        packagePrice DECIMAL(18, 2),
        isDefault BIT NOT NULL DEFAULT 0,
        notes NVARCHAR(MAX),
        createdAt DATETIME NOT NULL DEFAULT GETDATE(),
        updatedAt DATETIME NOT NULL DEFAULT GETDATE(),
        FOREIGN KEY (productId) REFERENCES Products(id) ON DELETE CASCADE
    );
    PRINT N'✅ تم إنشاء جدول Packaging';
END
GO

-- =============================================
-- جدول مخزون المستودعات (WarehouseStock)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'WarehouseStock')
BEGIN
    CREATE TABLE WarehouseStock (
        id INT IDENTITY(1,1) PRIMARY KEY,
        warehouseId INT NOT NULL,
        productId INT NOT NULL,
        quantity INT NOT NULL DEFAULT 0,
        minQuantity INT NOT NULL DEFAULT 0,
        maxQuantity INT,
        lastRestockDate DATETIME,
        expiryDate DATETIME,
        batchNumber NVARCHAR(100),
        notes NVARCHAR(MAX),
        createdAt DATETIME NOT NULL DEFAULT GETDATE(),
        updatedAt DATETIME NOT NULL DEFAULT GETDATE(),
        FOREIGN KEY (warehouseId) REFERENCES Warehouses(id) ON DELETE CASCADE,
        FOREIGN KEY (productId) REFERENCES Products(id) ON DELETE CASCADE
    );
    PRINT N'✅ تم إنشاء جدول WarehouseStock';
END
GO

-- إنشاء فهرس فريد مركب
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'UQ_WarehouseProduct' AND object_id = OBJECT_ID('WarehouseStock'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX UQ_WarehouseProduct 
    ON WarehouseStock(warehouseId, productId, batchNumber);
END
GO

-- =============================================
-- جدول مرتجعات المبيعات (SalesReturns)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'SalesReturns')
BEGIN
    CREATE TABLE SalesReturns (
        id INT IDENTITY(1,1) PRIMARY KEY,
        returnNumber NVARCHAR(50) NOT NULL UNIQUE,
        saleId INT,
        originalInvoiceNumber NVARCHAR(50),
        customerId INT,
        customerName NVARCHAR(200),
        totalAmount DECIMAL(18, 2) NOT NULL DEFAULT 0,
        refundAmount DECIMAL(18, 2) NOT NULL DEFAULT 0,
        refundType NVARCHAR(50) NOT NULL DEFAULT N'نقدي',
        reason NVARCHAR(500),
        status NVARCHAR(50) NOT NULL DEFAULT N'مكتمل',
        notes NVARCHAR(MAX),
        returnDate DATETIME NOT NULL DEFAULT GETDATE(),
        createdAt DATETIME NOT NULL DEFAULT GETDATE(),
        updatedAt DATETIME NOT NULL DEFAULT GETDATE(),
        FOREIGN KEY (saleId) REFERENCES Sales(id) ON DELETE SET NULL,
        FOREIGN KEY (customerId) REFERENCES Customers(id) ON DELETE SET NULL
    );
    PRINT N'✅ تم إنشاء جدول SalesReturns';
END
GO

-- =============================================
-- جدول تفاصيل مرتجعات المبيعات (SalesReturnItems)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'SalesReturnItems')
BEGIN
    CREATE TABLE SalesReturnItems (
        id INT IDENTITY(1,1) PRIMARY KEY,
        salesReturnId INT NOT NULL,
        productId INT,
        productName NVARCHAR(200) NOT NULL,
        quantity INT NOT NULL,
        unitPrice DECIMAL(18, 2) NOT NULL,
        totalPrice DECIMAL(18, 2) NOT NULL,
        notes NVARCHAR(MAX),
        createdAt DATETIME NOT NULL DEFAULT GETDATE(),
        FOREIGN KEY (salesReturnId) REFERENCES SalesReturns(id) ON DELETE CASCADE,
        FOREIGN KEY (productId) REFERENCES Products(id) ON DELETE SET NULL
    );
    PRINT N'✅ تم إنشاء جدول SalesReturnItems';
END
GO

-- =============================================
-- جدول مرتجعات المشتريات (PurchaseReturns)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PurchaseReturns')
BEGIN
    CREATE TABLE PurchaseReturns (
        id INT IDENTITY(1,1) PRIMARY KEY,
        returnNumber NVARCHAR(50) NOT NULL UNIQUE,
        purchaseId INT,
        originalInvoiceNumber NVARCHAR(50),
        supplierName NVARCHAR(200),
        totalAmount DECIMAL(18, 2) NOT NULL DEFAULT 0,
        refundAmount DECIMAL(18, 2) NOT NULL DEFAULT 0,
        refundType NVARCHAR(50) NOT NULL DEFAULT N'نقدي',
        reason NVARCHAR(500),
        status NVARCHAR(50) NOT NULL DEFAULT N'مكتمل',
        notes NVARCHAR(MAX),
        returnDate DATETIME NOT NULL DEFAULT GETDATE(),
        createdAt DATETIME NOT NULL DEFAULT GETDATE(),
        updatedAt DATETIME NOT NULL DEFAULT GETDATE(),
        FOREIGN KEY (purchaseId) REFERENCES Purchases(id) ON DELETE SET NULL
    );
    PRINT N'✅ تم إنشاء جدول PurchaseReturns';
END
GO

-- =============================================
-- جدول تفاصيل مرتجعات المشتريات (PurchaseReturnItems)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PurchaseReturnItems')
BEGIN
    CREATE TABLE PurchaseReturnItems (
        id INT IDENTITY(1,1) PRIMARY KEY,
        purchaseReturnId INT NOT NULL,
        productId INT,
        productName NVARCHAR(200) NOT NULL,
        quantity INT NOT NULL,
        unitPrice DECIMAL(18, 2) NOT NULL,
        totalPrice DECIMAL(18, 2) NOT NULL,
        notes NVARCHAR(MAX),
        createdAt DATETIME NOT NULL DEFAULT GETDATE(),
        FOREIGN KEY (purchaseReturnId) REFERENCES PurchaseReturns(id) ON DELETE CASCADE,
        FOREIGN KEY (productId) REFERENCES Products(id) ON DELETE SET NULL
    );
    PRINT N'✅ تم إنشاء جدول PurchaseReturnItems';
END
GO

-- =============================================
-- جدول الحسابات المحاسبية (ChartOfAccounts)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ChartOfAccounts')
BEGIN
    CREATE TABLE ChartOfAccounts (
        id INT IDENTITY(1,1) PRIMARY KEY,
        accountCode NVARCHAR(50) NOT NULL UNIQUE,
        accountName NVARCHAR(200) NOT NULL,
        accountType NVARCHAR(50) NOT NULL,
        parentAccountId INT,
        balance DECIMAL(18, 2) NOT NULL DEFAULT 0,
        isActive BIT NOT NULL DEFAULT 1,
        notes NVARCHAR(MAX),
        createdAt DATETIME NOT NULL DEFAULT GETDATE(),
        updatedAt DATETIME NOT NULL DEFAULT GETDATE(),
        FOREIGN KEY (parentAccountId) REFERENCES ChartOfAccounts(id)
    );
    PRINT N'✅ تم إنشاء جدول ChartOfAccounts';
END
GO

-- =============================================
-- جدول الموردين (Suppliers)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Suppliers')
BEGIN
    CREATE TABLE Suppliers (
        id INT IDENTITY(1,1) PRIMARY KEY,
        name NVARCHAR(200) NOT NULL,
        phone NVARCHAR(20),
        email NVARCHAR(100),
        address NVARCHAR(500),
        balance DECIMAL(18, 2) NOT NULL DEFAULT 0,
        taxNumber NVARCHAR(50),
        notes NVARCHAR(MAX),
        isActive BIT NOT NULL DEFAULT 1,
        createdAt DATETIME NOT NULL DEFAULT GETDATE(),
        updatedAt DATETIME NOT NULL DEFAULT GETDATE()
    );
    PRINT N'✅ تم إنشاء جدول Suppliers';
END
GO

-- إضافة عمود المورد لجدول المشتريات
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Purchases') AND name = 'supplierId')
BEGIN
    ALTER TABLE Purchases ADD supplierId INT NULL;
    ALTER TABLE Purchases ADD CONSTRAINT FK_Purchases_Suppliers 
        FOREIGN KEY (supplierId) REFERENCES Suppliers(id) ON DELETE SET NULL;
    PRINT N'✅ تم إضافة علاقة الموردين مع المشتريات';
END
GO

-- =============================================
-- إنشاء الفهارس للجداول الجديدة
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Cashboxes_Code' AND object_id = OBJECT_ID('Cashboxes'))
    CREATE NONCLUSTERED INDEX IX_Cashboxes_Code ON Cashboxes(code);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_TransferVouchers_Number' AND object_id = OBJECT_ID('TransferVouchers'))
    CREATE NONCLUSTERED INDEX IX_TransferVouchers_Number ON TransferVouchers(voucherNumber);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_TransferVouchers_Date' AND object_id = OBJECT_ID('TransferVouchers'))
    CREATE NONCLUSTERED INDEX IX_TransferVouchers_Date ON TransferVouchers(transferDate);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_JournalEntries_Number' AND object_id = OBJECT_ID('JournalEntries'))
    CREATE NONCLUSTERED INDEX IX_JournalEntries_Number ON JournalEntries(entryNumber);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_JournalEntries_Date' AND object_id = OBJECT_ID('JournalEntries'))
    CREATE NONCLUSTERED INDEX IX_JournalEntries_Date ON JournalEntries(entryDate);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_JournalEntries_Status' AND object_id = OBJECT_ID('JournalEntries'))
    CREATE NONCLUSTERED INDEX IX_JournalEntries_Status ON JournalEntries(status);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_WarehouseStock_Warehouse' AND object_id = OBJECT_ID('WarehouseStock'))
    CREATE NONCLUSTERED INDEX IX_WarehouseStock_Warehouse ON WarehouseStock(warehouseId);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_WarehouseStock_Product' AND object_id = OBJECT_ID('WarehouseStock'))
    CREATE NONCLUSTERED INDEX IX_WarehouseStock_Product ON WarehouseStock(productId);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_SalesReturns_Number' AND object_id = OBJECT_ID('SalesReturns'))
    CREATE NONCLUSTERED INDEX IX_SalesReturns_Number ON SalesReturns(returnNumber);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_SalesReturns_Date' AND object_id = OBJECT_ID('SalesReturns'))
    CREATE NONCLUSTERED INDEX IX_SalesReturns_Date ON SalesReturns(returnDate);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_PurchaseReturns_Number' AND object_id = OBJECT_ID('PurchaseReturns'))
    CREATE NONCLUSTERED INDEX IX_PurchaseReturns_Number ON PurchaseReturns(returnNumber);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_PurchaseReturns_Date' AND object_id = OBJECT_ID('PurchaseReturns'))
    CREATE NONCLUSTERED INDEX IX_PurchaseReturns_Date ON PurchaseReturns(returnDate);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ChartOfAccounts_Code' AND object_id = OBJECT_ID('ChartOfAccounts'))
    CREATE NONCLUSTERED INDEX IX_ChartOfAccounts_Code ON ChartOfAccounts(accountCode);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ChartOfAccounts_Type' AND object_id = OBJECT_ID('ChartOfAccounts'))
    CREATE NONCLUSTERED INDEX IX_ChartOfAccounts_Type ON ChartOfAccounts(accountType);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Suppliers_Name' AND object_id = OBJECT_ID('Suppliers'))
    CREATE NONCLUSTERED INDEX IX_Suppliers_Name ON Suppliers(name);

PRINT N'✅ تم إنشاء جميع الفهارس للجداول الإضافية';
GO

PRINT N'';
PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
PRINT N'✅ اكتمل إنشاء الجداول الإضافية بنجاح!';
PRINT N'✅ Additional tables created successfully!';
PRINT N'✅ متوافق مع SQL Server 2008+';
PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
GO

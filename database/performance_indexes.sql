-- ========================================
-- PERFORMANCE INDEXES للأداء الأفضل
-- ========================================
USE SalesManagementDB;
GO

PRINT '🚀 إنشاء Indexes لتحسين الأداء...';

-- ====== CUSTOMERS TABLE ======
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Customers_Phone')
BEGIN
    CREATE INDEX IX_Customers_Phone ON Customers(Phone);
    PRINT '✅ Index: Customers.Phone';
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Customers_Name')
BEGIN
    CREATE INDEX IX_Customers_Name ON Customers(Name);
    PRINT '✅ Index: Customers.Name';
END

-- ====== PRODUCTS TABLE ======
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Products_Name')
BEGIN
    CREATE INDEX IX_Products_Name ON Products(Name);
    PRINT '✅ Index: Products.Name';
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Products_Barcode')
BEGIN
    CREATE INDEX IX_Products_Barcode ON Products(Barcode);
    PRINT '✅ Index: Products.Barcode';
END

-- ====== SALES TABLE ======
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Sales_SaleDate')
BEGIN
    CREATE INDEX IX_Sales_SaleDate ON Sales(SaleDate);
    PRINT '✅ Index: Sales.SaleDate';
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Sales_CustomerId')
BEGIN
    CREATE INDEX IX_Sales_CustomerId ON Sales(CustomerId);
    PRINT '✅ Index: Sales.CustomerId';
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Sales_PaymentMethod')
BEGIN
    CREATE INDEX IX_Sales_PaymentMethod ON Sales(PaymentMethod);
    PRINT '✅ Index: Sales.PaymentMethod';
END

-- ====== SALE ITEMS TABLE ======
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_SaleItems_SaleId')
BEGIN
    CREATE INDEX IX_SaleItems_SaleId ON SaleItems(SaleId);
    PRINT '✅ Index: SaleItems.SaleId';
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_SaleItems_ProductId')
BEGIN
    CREATE INDEX IX_SaleItems_ProductId ON SaleItems(ProductId);
    PRINT '✅ Index: SaleItems.ProductId';
END

-- ====== PURCHASES TABLE ======
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Purchases_PurchaseDate')
BEGIN
    CREATE INDEX IX_Purchases_PurchaseDate ON Purchases(PurchaseDate);
    PRINT '✅ Index: Purchases.PurchaseDate';
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Purchases_SupplierId')
BEGIN
    CREATE INDEX IX_Purchases_SupplierId ON Purchases(SupplierId);
    PRINT '✅ Index: Purchases.SupplierId';
END

-- ====== PURCHASE ITEMS TABLE ======
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_PurchaseItems_PurchaseId')
BEGIN
    CREATE INDEX IX_PurchaseItems_PurchaseId ON PurchaseItems(PurchaseId);
    PRINT '✅ Index: PurchaseItems.PurchaseId';
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_PurchaseItems_ProductId')
BEGIN
    CREATE INDEX IX_PurchaseItems_ProductId ON PurchaseItems(ProductId);
    PRINT '✅ Index: PurchaseItems.ProductId';
END

-- ====== WAREHOUSE STOCK TABLE ======
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_WarehouseStock_WarehouseId')
BEGIN
    CREATE INDEX IX_WarehouseStock_WarehouseId ON WarehouseStock(WarehouseId);
    PRINT '✅ Index: WarehouseStock.WarehouseId';
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_WarehouseStock_ProductId')
BEGIN
    CREATE INDEX IX_WarehouseStock_ProductId ON WarehouseStock(ProductId);
    PRINT '✅ Index: WarehouseStock.ProductId';
END

-- ====== INVENTORY TRANSACTIONS TABLE ======
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_InventoryTransactions_WarehouseId')
BEGIN
    CREATE INDEX IX_InventoryTransactions_WarehouseId ON InventoryTransactions(WarehouseId);
    PRINT '✅ Index: InventoryTransactions.WarehouseId';
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_InventoryTransactions_ProductId')
BEGIN
    CREATE INDEX IX_InventoryTransactions_ProductId ON InventoryTransactions(ProductId);
    PRINT '✅ Index: InventoryTransactions.ProductId';
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_InventoryTransactions_CreatedAt')
BEGIN
    CREATE INDEX IX_InventoryTransactions_CreatedAt ON InventoryTransactions(CreatedAt);
    PRINT '✅ Index: InventoryTransactions.CreatedAt';
END

-- ====== INSTALLMENTS TABLE ======
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Installments_CustomerId')
BEGIN
    CREATE INDEX IX_Installments_CustomerId ON Installments(CustomerId);
    PRINT '✅ Index: Installments.CustomerId';
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Installments_StartDate')
BEGIN
    CREATE INDEX IX_Installments_StartDate ON Installments(StartDate);
    PRINT '✅ Index: Installments.StartDate';
END

-- ====== INSTALLMENT PAYMENTS TABLE ======
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_InstallmentPayments_InstallmentId')
BEGIN
    CREATE INDEX IX_InstallmentPayments_InstallmentId ON InstallmentPayments(InstallmentId);
    PRINT '✅ Index: InstallmentPayments.InstallmentId';
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_InstallmentPayments_PaymentDate')
BEGIN
    CREATE INDEX IX_InstallmentPayments_PaymentDate ON InstallmentPayments(PaymentDate);
    PRINT '✅ Index: InstallmentPayments.PaymentDate';
END

PRINT '';
PRINT '✨ تم إنشاء جميع الـ Indexes بنجاح!';
PRINT '🚀 الأداء سيكون أسرع بكثير الآن';
GO

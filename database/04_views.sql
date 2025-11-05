-- =============================================
-- Views for Reporting in Sales Management System
-- العروض (Views) لإعداد التقارير في نظام إدارة المبيعات
-- =============================================

USE SalesManagementDB;
GO

-- =============================================
-- View: عرض شامل للمبيعات مع التفاصيل
-- =============================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_SalesWithDetails')
    DROP VIEW vw_SalesWithDetails;
GO

CREATE VIEW vw_SalesWithDetails
AS
SELECT 
    s.id AS saleId,
    s.invoiceNumber,
    s.saleDate,
    s.customerId,
    s.customerName,
    c.phone AS customerPhone,
    s.totalAmount,
    s.discount,
    s.netAmount,
    s.paidAmount,
    s.remainingAmount,
    s.paymentType,
    s.status,
    si.productId,
    si.productName,
    si.quantity,
    si.unitPrice,
    si.totalPrice AS itemTotal,
    p.purchasePrice,
    (si.unitPrice - p.purchasePrice) * si.quantity AS itemProfit
FROM Sales s
INNER JOIN SaleItems si ON s.id = si.saleId
LEFT JOIN Customers c ON s.customerId = c.id
LEFT JOIN Products p ON si.productId = p.id;
GO

-- =============================================
-- View: عرض شامل للمشتريات مع التفاصيل
-- =============================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_PurchasesWithDetails')
    DROP VIEW vw_PurchasesWithDetails;
GO

CREATE VIEW vw_PurchasesWithDetails
AS
SELECT 
    p.id AS purchaseId,
    p.invoiceNumber,
    p.purchaseDate,
    p.supplierId,
    p.supplierName,
    s.phone AS supplierPhone,
    p.totalAmount,
    p.paidAmount,
    p.remainingAmount,
    p.paymentType,
    p.status,
    pi.productId,
    pi.productName,
    pi.quantity,
    pi.unitPrice,
    pi.totalPrice AS itemTotal
FROM Purchases p
INNER JOIN PurchaseItems pi ON p.id = pi.purchaseId
LEFT JOIN Suppliers s ON p.supplierId = s.id;
GO

-- =============================================
-- View: عرض المخزون الحالي لجميع المنتجات
-- =============================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_CurrentInventory')
    DROP VIEW vw_CurrentInventory;
GO

CREATE VIEW vw_CurrentInventory
AS
SELECT 
    p.id AS productId,
    p.name AS productName,
    p.barcode,
    p.category,
    p.unit,
    p.quantity AS totalQuantity,
    p.minQuantity,
    p.purchasePrice,
    p.sellingPrice,
    (p.sellingPrice - p.purchasePrice) AS profitPerUnit,
    p.quantity * p.purchasePrice AS inventoryValue,
    p.quantity * p.sellingPrice AS potentialRevenue,
    CASE 
        WHEN p.quantity <= 0 THEN N'نفذ'
        WHEN p.quantity <= p.minQuantity THEN N'منخفض'
        ELSE N'متوفر'
    END AS stockStatus,
    p.isActive
FROM Products p;
GO

-- =============================================
-- View: عرض المخزون حسب المستودعات
-- =============================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_WarehouseInventory')
    DROP VIEW vw_WarehouseInventory;
GO

CREATE VIEW vw_WarehouseInventory
AS
SELECT 
    w.id AS warehouseId,
    w.name AS warehouseName,
    w.location,
    p.id AS productId,
    p.name AS productName,
    p.barcode,
    ws.quantity,
    ws.minQuantity,
    ws.maxQuantity,
    ws.batchNumber,
    ws.expiryDate,
    CASE 
        WHEN ws.quantity <= 0 THEN N'نفذ'
        WHEN ws.quantity <= ws.minQuantity THEN N'منخفض'
        WHEN ws.maxQuantity IS NOT NULL AND ws.quantity >= ws.maxQuantity THEN N'ممتلئ'
        ELSE N'متوفر'
    END AS stockStatus,
    ws.lastRestockDate,
    DATEDIFF(DAY, GETDATE(), ws.expiryDate) AS daysUntilExpiry
FROM WarehouseStock ws
INNER JOIN Warehouses w ON ws.warehouseId = w.id
INNER JOIN Products p ON ws.productId = p.id;
GO

-- =============================================
-- View: عرض أرصدة العملاء
-- =============================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_CustomerBalances')
    DROP VIEW vw_CustomerBalances;
GO

CREATE VIEW vw_CustomerBalances
AS
SELECT 
    c.id AS customerId,
    c.name AS customerName,
    c.phone,
    c.address,
    c.balance,
    COUNT(DISTINCT s.id) AS totalInvoices,
    ISNULL(SUM(s.netAmount), 0) AS totalPurchases,
    ISNULL(SUM(s.paidAmount), 0) AS totalPaid,
    ISNULL(SUM(s.remainingAmount), 0) AS totalRemaining,
    MAX(s.saleDate) AS lastPurchaseDate,
    CASE 
        WHEN c.balance > 0 THEN N'مدين'
        WHEN c.balance < 0 THEN N'دائن'
        ELSE N'متوازن'
    END AS balanceStatus
FROM Customers c
LEFT JOIN Sales s ON c.id = s.customerId
GROUP BY c.id, c.name, c.phone, c.address, c.balance;
GO

-- =============================================
-- View: عرض أرصدة الموردين
-- =============================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_SupplierBalances')
    DROP VIEW vw_SupplierBalances;
GO

CREATE VIEW vw_SupplierBalances
AS
SELECT 
    s.id AS supplierId,
    s.name AS supplierName,
    s.phone,
    s.email,
    s.address,
    s.balance,
    COUNT(DISTINCT p.id) AS totalInvoices,
    ISNULL(SUM(p.totalAmount), 0) AS totalPurchases,
    ISNULL(SUM(p.paidAmount), 0) AS totalPaid,
    ISNULL(SUM(p.remainingAmount), 0) AS totalRemaining,
    MAX(p.purchaseDate) AS lastPurchaseDate,
    CASE 
        WHEN s.balance > 0 THEN N'مدين'
        WHEN s.balance < 0 THEN N'دائن'
        ELSE N'متوازن'
    END AS balanceStatus
FROM Suppliers s
LEFT JOIN Purchases p ON s.id = p.supplierId
GROUP BY s.id, s.name, s.phone, s.email, s.address, s.balance;
GO

-- =============================================
-- View: عرض الأقساط النشطة والمتأخرة
-- =============================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_ActiveInstallments')
    DROP VIEW vw_ActiveInstallments;
GO

CREATE VIEW vw_ActiveInstallments
AS
SELECT 
    i.id AS installmentId,
    i.customerId,
    i.customerName,
    c.phone AS customerPhone,
    i.totalAmount,
    i.paidAmount,
    i.remainingAmount,
    i.installmentAmount,
    i.numberOfInstallments,
    CEILING(i.remainingAmount / i.installmentAmount) AS remainingInstallments,
    i.status,
    i.startDate,
    COUNT(ip.id) AS paymentsMade,
    MAX(ip.paymentDate) AS lastPaymentDate,
    DATEDIFF(DAY, MAX(ip.paymentDate), GETDATE()) AS daysSinceLastPayment,
    CASE 
        WHEN i.status = N'مكتمل' THEN N'مكتمل'
        WHEN DATEDIFF(DAY, MAX(ip.paymentDate), GETDATE()) > 30 THEN N'متأخر'
        ELSE N'نشط'
    END AS paymentStatus
FROM Installments i
INNER JOIN Customers c ON i.customerId = c.id
LEFT JOIN InstallmentPayments ip ON i.id = ip.installmentId
GROUP BY i.id, i.customerId, i.customerName, c.phone, i.totalAmount, 
         i.paidAmount, i.remainingAmount, i.installmentAmount, 
         i.numberOfInstallments, i.status, i.startDate;
GO

-- =============================================
-- View: عرض حركة الصناديق
-- =============================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_CashboxMovements')
    DROP VIEW vw_CashboxMovements;
GO

CREATE VIEW vw_CashboxMovements
AS
SELECT 
    cb.id AS cashboxId,
    cb.name AS cashboxName,
    cb.code AS cashboxCode,
    cb.balance AS currentBalance,
    cb.currency,
    
    -- إجمالي الإيرادات
    ISNULL((SELECT SUM(pv.amount) 
            FROM PaymentVouchers pv 
            WHERE pv.voucherDate >= CAST(GETDATE() AS DATE)), 0) AS todayRevenue,
    
    -- إجمالي المصروفات
    ISNULL((SELECT SUM(cv.amount) 
            FROM CashVouchers cv 
            WHERE cv.voucherDate >= CAST(GETDATE() AS DATE)), 0) AS todayExpenses,
    
    -- التحويلات الواردة
    ISNULL((SELECT SUM(tv.amount) 
            FROM TransferVouchers tv 
            WHERE tv.toCashboxId = cb.id 
            AND tv.transferDate >= CAST(GETDATE() AS DATE)), 0) AS incomingTransfers,
    
    -- التحويلات الصادرة
    ISNULL((SELECT SUM(tv.amount) 
            FROM TransferVouchers tv 
            WHERE tv.fromCashboxId = cb.id 
            AND tv.transferDate >= CAST(GETDATE() AS DATE)), 0) AS outgoingTransfers,
    
    cb.isActive
FROM Cashboxes cb;
GO

-- =============================================
-- View: عرض المنتجات الأكثر مبيعاً
-- =============================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_TopSellingProducts')
    DROP VIEW vw_TopSellingProducts;
GO

CREATE VIEW vw_TopSellingProducts
AS
SELECT 
    p.id AS productId,
    p.name AS productName,
    p.barcode,
    p.category,
    p.sellingPrice,
    COUNT(DISTINCT si.saleId) AS numberOfSales,
    SUM(si.quantity) AS totalQuantitySold,
    SUM(si.totalPrice) AS totalRevenue,
    AVG(si.quantity) AS avgQuantityPerSale,
    MAX(s.saleDate) AS lastSaleDate
FROM Products p
INNER JOIN SaleItems si ON p.id = si.productId
INNER JOIN Sales s ON si.saleId = s.id
WHERE s.saleDate >= DATEADD(MONTH, -3, GETDATE())
GROUP BY p.id, p.name, p.barcode, p.category, p.sellingPrice;
GO

-- =============================================
-- View: عرض تقرير الأرباح والخسائر
-- =============================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_ProfitLoss')
    DROP VIEW vw_ProfitLoss;
GO

CREATE VIEW vw_ProfitLoss
AS
SELECT 
    CAST(s.saleDate AS DATE) AS reportDate,
    
    -- الإيرادات
    SUM(s.netAmount) AS totalRevenue,
    
    -- تكلفة البضاعة المباعة
    SUM(si.quantity * p.purchasePrice) AS costOfGoodsSold,
    
    -- مجمل الربح
    SUM(s.netAmount) - SUM(si.quantity * p.purchasePrice) AS grossProfit,
    
    -- الخصومات
    SUM(s.discount) AS totalDiscounts,
    
    -- عدد الفواتير
    COUNT(DISTINCT s.id) AS numberOfInvoices,
    
    -- متوسط قيمة الفاتورة
    AVG(s.netAmount) AS avgInvoiceValue
FROM Sales s
INNER JOIN SaleItems si ON s.id = si.saleId
INNER JOIN Products p ON si.productId = p.id
GROUP BY CAST(s.saleDate AS DATE);
GO

-- =============================================
-- View: عرض حركات المخزون
-- =============================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_InventoryMovements')
    DROP VIEW vw_InventoryMovements;
GO

CREATE VIEW vw_InventoryMovements
AS
SELECT 
    it.id AS transactionId,
    it.transactionNumber,
    it.transactionType,
    it.transactionDate,
    w.name AS warehouseName,
    p.name AS productName,
    p.barcode,
    it.quantity,
    CASE 
        WHEN it.transactionType IN (N'شراء', N'إدخال', N'مرتجع مبيعات') THEN it.quantity
        ELSE 0
    END AS quantityIn,
    CASE 
        WHEN it.transactionType IN (N'بيع', N'إخراج', N'مرتجع مشتريات') THEN it.quantity
        ELSE 0
    END AS quantityOut,
    it.notes
FROM InventoryTransactions it
LEFT JOIN Warehouses w ON it.warehouseId = w.id
LEFT JOIN Products p ON it.productId = p.id;
GO

PRINT N'';
PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
PRINT N'✅ تم إنشاء جميع العروض (Views) بنجاح!';
PRINT N'✅ All views created successfully!';
PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
GO

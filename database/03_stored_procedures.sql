-- =============================================
-- Stored Procedures for Sales Management System
-- الإجراءات المخزنة لنظام إدارة المبيعات
-- =============================================

USE SalesManagementDB;
GO

-- =============================================
-- SP: إنشاء فاتورة بيع جديدة
-- =============================================
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_CreateSale')
    DROP PROCEDURE sp_CreateSale;
GO

CREATE PROCEDURE sp_CreateSale
    @invoiceNumber NVARCHAR(50),
    @customerId INT = NULL,
    @customerName NVARCHAR(200) = NULL,
    @totalAmount DECIMAL(18, 2),
    @discount DECIMAL(18, 2) = 0,
    @paidAmount DECIMAL(18, 2),
    @paymentType NVARCHAR(50) = N'نقدي',
    @notes NVARCHAR(MAX) = NULL,
    @saleItems NVARCHAR(MAX), -- JSON array of items
    @newSaleId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DECLARE @netAmount DECIMAL(18, 2) = @totalAmount - @discount;
        DECLARE @remainingAmount DECIMAL(18, 2) = @netAmount - @paidAmount;
        
        -- إنشاء الفاتورة
        INSERT INTO Sales (invoiceNumber, customerId, customerName, totalAmount, discount, 
                          netAmount, paidAmount, remainingAmount, paymentType, notes)
        VALUES (@invoiceNumber, @customerId, @customerName, @totalAmount, @discount,
                @netAmount, @paidAmount, @remainingAmount, @paymentType, @notes);
        
        SET @newSaleId = SCOPE_IDENTITY();
        
        -- إدراج تفاصيل الفاتورة من JSON
        INSERT INTO SaleItems (saleId, productId, productName, quantity, unitPrice, totalPrice)
        SELECT 
            @newSaleId,
            JSON_VALUE(value, '$.productId'),
            JSON_VALUE(value, '$.productName'),
            JSON_VALUE(value, '$.quantity'),
            JSON_VALUE(value, '$.unitPrice'),
            JSON_VALUE(value, '$.totalPrice')
        FROM OPENJSON(@saleItems);
        
        -- تحديث المخزون
        UPDATE p
        SET p.quantity = p.quantity - CAST(JSON_VALUE(items.value, '$.quantity') AS INT),
            p.updatedAt = GETDATE()
        FROM Products p
        INNER JOIN OPENJSON(@saleItems) items 
            ON p.id = CAST(JSON_VALUE(items.value, '$.productId') AS INT);
        
        -- تحديث رصيد العميل إذا كان هناك مبلغ متبقي
        IF @customerId IS NOT NULL AND @remainingAmount > 0
        BEGIN
            UPDATE Customers
            SET balance = balance + @remainingAmount,
                updatedAt = GETDATE()
            WHERE id = @customerId;
        END
        
        COMMIT TRANSACTION;
        PRINT N'✅ تم إنشاء فاتورة البيع بنجاح';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- =============================================
-- SP: إنشاء فاتورة شراء جديدة
-- =============================================
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_CreatePurchase')
    DROP PROCEDURE sp_CreatePurchase;
GO

CREATE PROCEDURE sp_CreatePurchase
    @invoiceNumber NVARCHAR(50),
    @supplierId INT = NULL,
    @supplierName NVARCHAR(200) = NULL,
    @totalAmount DECIMAL(18, 2),
    @paidAmount DECIMAL(18, 2),
    @paymentType NVARCHAR(50) = N'نقدي',
    @notes NVARCHAR(MAX) = NULL,
    @purchaseItems NVARCHAR(MAX), -- JSON array
    @newPurchaseId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DECLARE @remainingAmount DECIMAL(18, 2) = @totalAmount - @paidAmount;
        
        -- إنشاء فاتورة الشراء
        INSERT INTO Purchases (invoiceNumber, supplierId, supplierName, totalAmount, 
                              paidAmount, remainingAmount, paymentType, notes)
        VALUES (@invoiceNumber, @supplierId, @supplierName, @totalAmount,
                @paidAmount, @remainingAmount, @paymentType, @notes);
        
        SET @newPurchaseId = SCOPE_IDENTITY();
        
        -- إدراج تفاصيل الشراء
        INSERT INTO PurchaseItems (purchaseId, productId, productName, quantity, unitPrice, totalPrice)
        SELECT 
            @newPurchaseId,
            JSON_VALUE(value, '$.productId'),
            JSON_VALUE(value, '$.productName'),
            JSON_VALUE(value, '$.quantity'),
            JSON_VALUE(value, '$.unitPrice'),
            JSON_VALUE(value, '$.totalPrice')
        FROM OPENJSON(@purchaseItems);
        
        -- تحديث المخزون (زيادة الكمية)
        UPDATE p
        SET p.quantity = p.quantity + CAST(JSON_VALUE(items.value, '$.quantity') AS INT),
            p.updatedAt = GETDATE()
        FROM Products p
        INNER JOIN OPENJSON(@purchaseItems) items 
            ON p.id = CAST(JSON_VALUE(items.value, '$.productId') AS INT);
        
        -- تحديث رصيد المورد إذا كان هناك مبلغ متبقي
        IF @supplierId IS NOT NULL AND @remainingAmount > 0
        BEGIN
            UPDATE Suppliers
            SET balance = balance + @remainingAmount,
                updatedAt = GETDATE()
            WHERE id = @supplierId;
        END
        
        COMMIT TRANSACTION;
        PRINT N'✅ تم إنشاء فاتورة الشراء بنجاح';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        RAISERROR(ERROR_MESSAGE(), 16, 1);
    END CATCH
END
GO

-- =============================================
-- SP: تسجيل دفعة قسط
-- =============================================
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_PayInstallment')
    DROP PROCEDURE sp_PayInstallment;
GO

CREATE PROCEDURE sp_PayInstallment
    @installmentId INT,
    @amount DECIMAL(18, 2),
    @notes NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- تسجيل الدفعة
        INSERT INTO InstallmentPayments (installmentId, amount, notes)
        VALUES (@installmentId, @amount, @notes);
        
        -- تحديث القسط
        UPDATE Installments
        SET paidAmount = paidAmount + @amount,
            remainingAmount = remainingAmount - @amount,
            status = CASE 
                WHEN (remainingAmount - @amount) <= 0 THEN N'مكتمل'
                ELSE N'نشط'
            END,
            updatedAt = GETDATE()
        WHERE id = @installmentId;
        
        -- تحديث رصيد العميل
        UPDATE c
        SET c.balance = c.balance - @amount,
            c.updatedAt = GETDATE()
        FROM Customers c
        INNER JOIN Installments i ON c.id = i.customerId
        WHERE i.id = @installmentId;
        
        COMMIT TRANSACTION;
        PRINT N'✅ تم تسجيل دفعة القسط بنجاح';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        RAISERROR(ERROR_MESSAGE(), 16, 1);
    END CATCH
END
GO

-- =============================================
-- SP: تحويل بين الصناديق
-- =============================================
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_TransferBetweenCashboxes')
    DROP PROCEDURE sp_TransferBetweenCashboxes;
GO

CREATE PROCEDURE sp_TransferBetweenCashboxes
    @voucherNumber NVARCHAR(50),
    @fromCashboxId INT,
    @toCashboxId INT,
    @amount DECIMAL(18, 2),
    @transferType NVARCHAR(50) = N'صندوق إلى صندوق',
    @notes NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- التحقق من الرصيد الكافي
        DECLARE @fromBalance DECIMAL(18, 2);
        SELECT @fromBalance = balance FROM Cashboxes WHERE id = @fromCashboxId;
        
        IF @fromBalance < @amount
        BEGIN
            RAISERROR(N'الرصيد غير كافٍ في الصندوق المصدر', 16, 1);
            RETURN;
        END
        
        -- تسجيل التحويل
        INSERT INTO TransferVouchers (voucherNumber, fromCashboxId, toCashboxId, amount, transferType, notes)
        VALUES (@voucherNumber, @fromCashboxId, @toCashboxId, @amount, @transferType, @notes);
        
        -- تحديث الصندوق المصدر (خصم)
        UPDATE Cashboxes
        SET balance = balance - @amount,
            updatedAt = GETDATE()
        WHERE id = @fromCashboxId;
        
        -- تحديث الصندوق الهدف (إضافة)
        UPDATE Cashboxes
        SET balance = balance + @amount,
            updatedAt = GETDATE()
        WHERE id = @toCashboxId;
        
        COMMIT TRANSACTION;
        PRINT N'✅ تم التحويل بنجاح';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        RAISERROR(ERROR_MESSAGE(), 16, 1);
    END CATCH
END
GO

-- =============================================
-- SP: إنشاء مرتجع مبيعات
-- =============================================
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_CreateSalesReturn')
    DROP PROCEDURE sp_CreateSalesReturn;
GO

CREATE PROCEDURE sp_CreateSalesReturn
    @returnNumber NVARCHAR(50),
    @saleId INT = NULL,
    @originalInvoiceNumber NVARCHAR(50) = NULL,
    @customerId INT = NULL,
    @customerName NVARCHAR(200) = NULL,
    @totalAmount DECIMAL(18, 2),
    @refundAmount DECIMAL(18, 2),
    @refundType NVARCHAR(50) = N'نقدي',
    @reason NVARCHAR(500) = NULL,
    @returnItems NVARCHAR(MAX), -- JSON array
    @newReturnId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- إنشاء المرتجع
        INSERT INTO SalesReturns (returnNumber, saleId, originalInvoiceNumber, customerId, 
                                 customerName, totalAmount, refundAmount, refundType, reason)
        VALUES (@returnNumber, @saleId, @originalInvoiceNumber, @customerId,
                @customerName, @totalAmount, @refundAmount, @refundType, @reason);
        
        SET @newReturnId = SCOPE_IDENTITY();
        
        -- إدراج تفاصيل المرتجع
        INSERT INTO SalesReturnItems (salesReturnId, productId, productName, quantity, unitPrice, totalPrice)
        SELECT 
            @newReturnId,
            JSON_VALUE(value, '$.productId'),
            JSON_VALUE(value, '$.productName'),
            JSON_VALUE(value, '$.quantity'),
            JSON_VALUE(value, '$.unitPrice'),
            JSON_VALUE(value, '$.totalPrice')
        FROM OPENJSON(@returnItems);
        
        -- إرجاع المنتجات للمخزون
        UPDATE p
        SET p.quantity = p.quantity + CAST(JSON_VALUE(items.value, '$.quantity') AS INT),
            p.updatedAt = GETDATE()
        FROM Products p
        INNER JOIN OPENJSON(@returnItems) items 
            ON p.id = CAST(JSON_VALUE(items.value, '$.productId') AS INT);
        
        -- تحديث رصيد العميل
        IF @customerId IS NOT NULL
        BEGIN
            UPDATE Customers
            SET balance = balance - @refundAmount,
                updatedAt = GETDATE()
            WHERE id = @customerId;
        END
        
        COMMIT TRANSACTION;
        PRINT N'✅ تم إنشاء مرتجع المبيعات بنجاح';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        RAISERROR(ERROR_MESSAGE(), 16, 1);
    END CATCH
END
GO

-- =============================================
-- SP: الحصول على تقرير المبيعات اليومية
-- =============================================
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_GetDailySalesReport')
    DROP PROCEDURE sp_GetDailySalesReport;
GO

CREATE PROCEDURE sp_GetDailySalesReport
    @reportDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @reportDate IS NULL
        SET @reportDate = CAST(GETDATE() AS DATE);
    
    SELECT 
        COUNT(*) AS totalInvoices,
        SUM(totalAmount) AS totalSales,
        SUM(discount) AS totalDiscount,
        SUM(netAmount) AS netSales,
        SUM(paidAmount) AS totalPaid,
        SUM(remainingAmount) AS totalRemaining,
        SUM(CASE WHEN paymentType = N'نقدي' THEN netAmount ELSE 0 END) AS cashSales,
        SUM(CASE WHEN paymentType = N'آجل' THEN netAmount ELSE 0 END) AS creditSales
    FROM Sales
    WHERE CAST(saleDate AS DATE) = @reportDate;
END
GO

-- =============================================
-- SP: الحصول على أفضل المنتجات مبيعاً
-- =============================================
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_GetTopSellingProducts')
    DROP PROCEDURE sp_GetTopSellingProducts;
GO

CREATE PROCEDURE sp_GetTopSellingProducts
    @topN INT = 10,
    @startDate DATE = NULL,
    @endDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @startDate IS NULL
        SET @startDate = DATEADD(MONTH, -1, GETDATE());
    
    IF @endDate IS NULL
        SET @endDate = GETDATE();
    
    SELECT TOP (@topN)
        si.productId,
        si.productName,
        SUM(si.quantity) AS totalQuantity,
        SUM(si.totalPrice) AS totalSales,
        COUNT(DISTINCT si.saleId) AS numberOfInvoices,
        AVG(si.unitPrice) AS avgPrice
    FROM SaleItems si
    INNER JOIN Sales s ON si.saleId = s.id
    WHERE CAST(s.saleDate AS DATE) BETWEEN @startDate AND @endDate
    GROUP BY si.productId, si.productName
    ORDER BY totalSales DESC;
END
GO

-- =============================================
-- SP: الحصول على العملاء الأكثر شراءً
-- =============================================
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_GetTopCustomers')
    DROP PROCEDURE sp_GetTopCustomers;
GO

CREATE PROCEDURE sp_GetTopCustomers
    @topN INT = 10,
    @startDate DATE = NULL,
    @endDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @startDate IS NULL
        SET @startDate = DATEADD(MONTH, -1, GETDATE());
    
    IF @endDate IS NULL
        SET @endDate = GETDATE();
    
    SELECT TOP (@topN)
        s.customerId,
        s.customerName,
        COUNT(*) AS numberOfPurchases,
        SUM(s.netAmount) AS totalPurchases,
        AVG(s.netAmount) AS avgPurchaseValue,
        MAX(c.balance) AS currentBalance
    FROM Sales s
    LEFT JOIN Customers c ON s.customerId = c.id
    WHERE CAST(s.saleDate AS DATE) BETWEEN @startDate AND @endDate
        AND s.customerId IS NOT NULL
    GROUP BY s.customerId, s.customerName
    ORDER BY totalPurchases DESC;
END
GO

-- =============================================
-- SP: حساب الأرباح
-- =============================================
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_CalculateProfit')
    DROP PROCEDURE sp_CalculateProfit;
GO

CREATE PROCEDURE sp_CalculateProfit
    @startDate DATE = NULL,
    @endDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @startDate IS NULL
        SET @startDate = DATEADD(MONTH, -1, GETDATE());
    
    IF @endDate IS NULL
        SET @endDate = GETDATE();
    
    SELECT 
        SUM(si.totalPrice) AS totalRevenue,
        SUM(si.quantity * p.purchasePrice) AS totalCost,
        SUM(si.totalPrice - (si.quantity * p.purchasePrice)) AS grossProfit,
        COUNT(DISTINCT s.id) AS numberOfSales
    FROM SaleItems si
    INNER JOIN Sales s ON si.saleId = s.id
    INNER JOIN Products p ON si.productId = p.id
    WHERE CAST(s.saleDate AS DATE) BETWEEN @startDate AND @endDate;
END
GO

PRINT N'';
PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
PRINT N'✅ تم إنشاء جميع الإجراءات المخزنة بنجاح!';
PRINT N'✅ All stored procedures created successfully!';
PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
GO

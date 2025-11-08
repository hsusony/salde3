-- إصلاح الفواتير الموجودة التي FinalAmount = NULL
-- تحديث FinalAmount بناءً على TotalAmount - Discount + Tax

USE SalesManagementDB;
GO

SET QUOTED_IDENTIFIER ON;
GO

-- عرض الفواتير التي تحتاج إصلاح
SELECT 
    SaleID, 
    InvoiceNumber,
    TotalAmount, 
    Discount, 
    Tax, 
    FinalAmount,
    (ISNULL(TotalAmount, 0) - ISNULL(Discount, 0) + ISNULL(Tax, 0)) AS CalculatedFinalAmount
FROM Sales
WHERE FinalAmount IS NULL OR InvoiceNumber IS NULL;

-- تحديث FinalAmount للفواتير التي القيمة NULL
UPDATE Sales
SET 
    FinalAmount = ISNULL(TotalAmount, 0) - ISNULL(Discount, 0) + ISNULL(Tax, 0),
    InvoiceNumber = CASE 
        WHEN InvoiceNumber IS NULL THEN 'INV-' + CAST(DATEPART(YEAR, GETDATE()) AS VARCHAR) + '-' + RIGHT('0000' + CAST(SaleID AS VARCHAR), 4)
        ELSE InvoiceNumber
    END,
    UpdatedAt = GETDATE()
WHERE FinalAmount IS NULL OR InvoiceNumber IS NULL;

-- عرض النتائج بعد التحديث
SELECT 
    SaleID, 
    InvoiceNumber,
    TotalAmount, 
    Discount, 
    Tax, 
    FinalAmount,
    Status
FROM Sales
ORDER BY SaleID DESC;

GO

PRINT 'تم إصلاح الفواتير بنجاح ✅';

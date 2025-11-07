USE SalesManagementDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- تحديث FinalAmount و RemainingAmount للفواتير الموجودة
UPDATE Sales 
SET 
    FinalAmount = TotalAmount - ISNULL(Discount, 0) + ISNULL(Tax, 0),
    RemainingAmount = (TotalAmount - ISNULL(Discount, 0) + ISNULL(Tax, 0)) - ISNULL(PaidAmount, 0)
WHERE FinalAmount IS NULL;

PRINT 'تم تحديث الفواتير بنجاح';
GO

-- عرض النتائج
SELECT TOP 10 
    SaleID, 
    TotalAmount, 
    Discount, 
    Tax, 
    FinalAmount,
    PaidAmount,
    RemainingAmount
FROM Sales 
ORDER BY SaleID DESC;

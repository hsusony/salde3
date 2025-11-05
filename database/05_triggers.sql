-- =============================================
-- Triggers for Sales Management System
-- المشغلات (Triggers) لنظام إدارة المبيعات
-- =============================================

USE SalesManagementDB;
GO

-- =============================================
-- Trigger: تحديث تاريخ التعديل تلقائياً للعملاء
-- =============================================
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_Customers_UpdatedAt')
    DROP TRIGGER trg_Customers_UpdatedAt;
GO

CREATE TRIGGER trg_Customers_UpdatedAt
ON Customers
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Customers
    SET updatedAt = GETDATE()
    WHERE id IN (SELECT id FROM inserted);
END
GO

-- =============================================
-- Trigger: تحديث تاريخ التعديل تلقائياً للمنتجات
-- =============================================
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_Products_UpdatedAt')
    DROP TRIGGER trg_Products_UpdatedAt;
GO

CREATE TRIGGER trg_Products_UpdatedAt
ON Products
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Products
    SET updatedAt = GETDATE()
    WHERE id IN (SELECT id FROM inserted);
END
GO

-- =============================================
-- Trigger: تحديث تاريخ التعديل تلقائياً للمخازن
-- =============================================
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_Warehouses_UpdatedAt')
    DROP TRIGGER trg_Warehouses_UpdatedAt;
GO

CREATE TRIGGER trg_Warehouses_UpdatedAt
ON Warehouses
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Warehouses
    SET updatedAt = GETDATE()
    WHERE id IN (SELECT id FROM inserted);
END
GO

-- =============================================
-- Trigger: تسجيل عملية في سجل التدقيق عند إنشاء/تعديل/حذف عميل
-- =============================================
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_Customers_Audit')
    DROP TRIGGER trg_Customers_Audit;
GO

CREATE TRIGGER trg_Customers_Audit
ON Customers
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @action NVARCHAR(200);
    DECLARE @oldValue NVARCHAR(MAX);
    DECLARE @newValue NVARCHAR(MAX);
    
    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        -- تحديث
        SET @action = N'تعديل عميل';
        SELECT @oldValue = (SELECT * FROM deleted FOR JSON PATH);
        SELECT @newValue = (SELECT * FROM inserted FOR JSON PATH);
    END
    ELSE IF EXISTS (SELECT * FROM inserted)
    BEGIN
        -- إدراج
        SET @action = N'إضافة عميل';
        SELECT @newValue = (SELECT * FROM inserted FOR JSON PATH);
    END
    ELSE
    BEGIN
        -- حذف
        SET @action = N'حذف عميل';
        SELECT @oldValue = (SELECT * FROM deleted FOR JSON PATH);
    END
    
    INSERT INTO AuditLogs (action, tableName, oldValue, newValue)
    VALUES (@action, 'Customers', @oldValue, @newValue);
END
GO

-- =============================================
-- Trigger: تسجيل عملية في سجل التدقيق عند إنشاء/تعديل/حذف منتج
-- =============================================
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_Products_Audit')
    DROP TRIGGER trg_Products_Audit;
GO

CREATE TRIGGER trg_Products_Audit
ON Products
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @action NVARCHAR(200);
    DECLARE @oldValue NVARCHAR(MAX);
    DECLARE @newValue NVARCHAR(MAX);
    
    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        SET @action = N'تعديل منتج';
        SELECT @oldValue = (SELECT * FROM deleted FOR JSON PATH);
        SELECT @newValue = (SELECT * FROM inserted FOR JSON PATH);
    END
    ELSE IF EXISTS (SELECT * FROM inserted)
    BEGIN
        SET @action = N'إضافة منتج';
        SELECT @newValue = (SELECT * FROM inserted FOR JSON PATH);
    END
    ELSE
    BEGIN
        SET @action = N'حذف منتج';
        SELECT @oldValue = (SELECT * FROM deleted FOR JSON PATH);
    END
    
    INSERT INTO AuditLogs (action, tableName, oldValue, newValue)
    VALUES (@action, 'Products', @oldValue, @newValue);
END
GO

-- =============================================
-- Trigger: تسجيل عملية في سجل التدقيق عند إنشاء فاتورة بيع
-- =============================================
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_Sales_Audit')
    DROP TRIGGER trg_Sales_Audit;
GO

CREATE TRIGGER trg_Sales_Audit
ON Sales
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO AuditLogs (action, tableName, recordId, newValue)
    SELECT 
        N'إنشاء فاتورة بيع',
        'Sales',
        i.id,
        (SELECT * FROM inserted i2 WHERE i2.id = i.id FOR JSON PATH)
    FROM inserted i;
END
GO

-- =============================================
-- Trigger: تحديث رصيد الصندوق عند إضافة سند قبض
-- =============================================
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_PaymentVouchers_UpdateCashbox')
    DROP TRIGGER trg_PaymentVouchers_UpdateCashbox;
GO

CREATE TRIGGER trg_PaymentVouchers_UpdateCashbox
ON PaymentVouchers
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- افترض أن الصندوق الافتراضي له id = 1
    -- في التطبيق الفعلي، يجب تحديد الصندوق من واجهة المستخدم
    DECLARE @defaultCashboxId INT = 1;
    
    IF EXISTS (SELECT * FROM Cashboxes WHERE id = @defaultCashboxId)
    BEGIN
        UPDATE Cashboxes
        SET balance = balance + i.amount,
            updatedAt = GETDATE()
        FROM Cashboxes cb
        CROSS JOIN inserted i
        WHERE cb.id = @defaultCashboxId;
    END
END
GO

-- =============================================
-- Trigger: تحديث رصيد الصندوق عند إضافة سند صرف
-- =============================================
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_CashVouchers_UpdateCashbox')
    DROP TRIGGER trg_CashVouchers_UpdateCashbox;
GO

CREATE TRIGGER trg_CashVouchers_UpdateCashbox
ON CashVouchers
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @defaultCashboxId INT = 1;
    
    IF EXISTS (SELECT * FROM Cashboxes WHERE id = @defaultCashboxId)
    BEGIN
        UPDATE Cashboxes
        SET balance = balance - i.amount,
            updatedAt = GETDATE()
        FROM Cashboxes cb
        CROSS JOIN inserted i
        WHERE cb.id = @defaultCashboxId;
    END
END
GO

-- =============================================
-- Trigger: التحقق من توازن القيد المحاسبي
-- =============================================
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_JournalEntries_CheckBalance')
    DROP TRIGGER trg_JournalEntries_CheckBalance;
GO

CREATE TRIGGER trg_JournalEntries_CheckBalance
ON JournalEntries
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- التحقق من أن المدين يساوي الدائن
    IF EXISTS (
        SELECT 1 
        FROM inserted 
        WHERE totalDebit <> totalCredit 
        AND isBalanced = 1
    )
    BEGIN
        RAISERROR(N'القيد المحاسبي غير متوازن! يجب أن يكون المدين مساوياً للدائن', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
    
    -- تحديث حالة التوازن تلقائياً
    UPDATE JournalEntries
    SET isBalanced = CASE 
        WHEN totalDebit = totalCredit THEN 1 
        ELSE 0 
    END
    WHERE id IN (SELECT id FROM inserted);
END
GO

-- =============================================
-- Trigger: تحديث إجمالي القيد المحاسبي عند إضافة/تعديل سطر
-- =============================================
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_JournalEntryLines_UpdateTotals')
    DROP TRIGGER trg_JournalEntryLines_UpdateTotals;
GO

CREATE TRIGGER trg_JournalEntryLines_UpdateTotals
ON JournalEntryLines
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- تحديث الإجماليات للقيود المتأثرة
    UPDATE je
    SET totalDebit = ISNULL((SELECT SUM(debit) FROM JournalEntryLines WHERE journalEntryId = je.id), 0),
        totalCredit = ISNULL((SELECT SUM(credit) FROM JournalEntryLines WHERE journalEntryId = je.id), 0),
        updatedAt = GETDATE()
    FROM JournalEntries je
    WHERE je.id IN (
        SELECT DISTINCT journalEntryId FROM inserted
        UNION
        SELECT DISTINCT journalEntryId FROM deleted
    );
END
GO

-- =============================================
-- Trigger: تحديث مخزون المستودع عند إضافة حركة مخزون
-- =============================================
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_InventoryTransactions_UpdateStock')
    DROP TRIGGER trg_InventoryTransactions_UpdateStock;
GO

CREATE TRIGGER trg_InventoryTransactions_UpdateStock
ON InventoryTransactions
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- تحديث مخزون المستودع حسب نوع الحركة
    UPDATE ws
    SET quantity = CASE 
        WHEN i.transactionType IN (N'شراء', N'إدخال', N'مرتجع مبيعات', N'تحويل وارد') 
        THEN ws.quantity + i.quantity
        WHEN i.transactionType IN (N'بيع', N'إخراج', N'مرتجع مشتريات', N'تحويل صادر') 
        THEN ws.quantity - i.quantity
        ELSE ws.quantity
    END,
    lastRestockDate = CASE 
        WHEN i.transactionType IN (N'شراء', N'إدخال', N'مرتجع مبيعات', N'تحويل وارد') 
        THEN GETDATE()
        ELSE ws.lastRestockDate
    END,
    updatedAt = GETDATE()
    FROM WarehouseStock ws
    INNER JOIN inserted i ON ws.warehouseId = i.warehouseId AND ws.productId = i.productId;
    
    -- إذا لم يكن المنتج موجوداً في المستودع، أضفه
    INSERT INTO WarehouseStock (warehouseId, productId, quantity, lastRestockDate)
    SELECT 
        i.warehouseId,
        i.productId,
        CASE 
            WHEN i.transactionType IN (N'شراء', N'إدخال', N'مرتجع مبيعات', N'تحويل وارد') 
            THEN i.quantity
            ELSE -i.quantity
        END,
        GETDATE()
    FROM inserted i
    WHERE NOT EXISTS (
        SELECT 1 FROM WarehouseStock ws
        WHERE ws.warehouseId = i.warehouseId AND ws.productId = i.productId
    );
END
GO

-- =============================================
-- Trigger: منع حذف منتج له حركات مخزون
-- =============================================
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_Products_PreventDelete')
    DROP TRIGGER trg_Products_PreventDelete;
GO

CREATE TRIGGER trg_Products_PreventDelete
ON Products
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (
        SELECT 1 
        FROM deleted d
        INNER JOIN InventoryTransactions it ON d.id = it.productId
    )
    BEGIN
        RAISERROR(N'لا يمكن حذف منتج له حركات مخزون. يمكنك تعطيل المنتج بدلاً من حذفه.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
    
    -- إذا لم يكن له حركات، اسمح بالحذف
    DELETE FROM Products WHERE id IN (SELECT id FROM deleted);
END
GO

-- =============================================
-- Trigger: تحديث حالة القسط عند الدفع الكامل
-- =============================================
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_InstallmentPayments_UpdateStatus')
    DROP TRIGGER trg_InstallmentPayments_UpdateStatus;
GO

CREATE TRIGGER trg_InstallmentPayments_UpdateStatus
ON InstallmentPayments
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE i
    SET status = CASE 
        WHEN i.remainingAmount <= 0 THEN N'مكتمل'
        ELSE i.status
    END,
    updatedAt = GETDATE()
    FROM Installments i
    INNER JOIN inserted ins ON i.id = ins.installmentId;
END
GO

-- =============================================
-- Trigger: تحديث رصيد الصندوق عند اعتماد قيد محاسبي
-- =============================================
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_JournalEntries_UpdateCashOnApproval')
    DROP TRIGGER trg_JournalEntries_UpdateCashOnApproval;
GO

CREATE TRIGGER trg_JournalEntries_UpdateCashOnApproval
ON JournalEntries
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- عند تغيير الحالة من مسودة إلى معتمد
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        INNER JOIN deleted d ON i.id = d.id
        WHERE i.status = N'معتمد' AND d.status = N'مسودة'
    )
    BEGIN
        -- هنا يمكن إضافة منطق لتحديث الصناديق أو الحسابات
        -- بناءً على تفاصيل القيد المحاسبي
        
        INSERT INTO AuditLogs (action, tableName, recordId, newValue)
        SELECT 
            N'اعتماد قيد محاسبي',
            'JournalEntries',
            i.id,
            CONCAT(N'القيد رقم: ', i.entryNumber)
        FROM inserted i
        INNER JOIN deleted d ON i.id = d.id
        WHERE i.status = N'معتمد' AND d.status = N'مسودة';
    END
END
GO

PRINT N'';
PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
PRINT N'✅ تم إنشاء جميع المشغلات (Triggers) بنجاح!';
PRINT N'✅ All triggers created successfully!';
PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
GO

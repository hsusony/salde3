-- =============================================
-- Complete Payment Voucher System
-- نظام سندات الدفع الكامل
-- =============================================

USE SalesManagementDB;
GO

PRINT N'';
PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
PRINT N'🔧 بدء إنشاء نظام سندات الدفع الكامل';
PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
PRINT N'';

-- =============================================
-- جدول سندات الدفع الرئيسي (PaymentVouchers)
-- =============================================
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'PaymentVouchers')
BEGIN
    PRINT N'⚠️ جدول PaymentVouchers موجود مسبقاً - سيتم حذفه وإعادة إنشائه';
    DROP TABLE IF EXISTS PaymentVouchers;
END
GO

CREATE TABLE PaymentVouchers (
    id INT IDENTITY(1,1) PRIMARY KEY,
    voucherNumber NVARCHAR(50) NOT NULL UNIQUE,
    voucherDate DATETIME2 NOT NULL DEFAULT GETDATE(),
    
    -- معلومات المستفيد
    accountName NVARCHAR(200) NOT NULL,
    cashAccount NVARCHAR(100) NOT NULL DEFAULT N'صندوق 181',
    
    -- معلومات المبلغ
    amount DECIMAL(18, 2) NOT NULL,
    discount DECIMAL(18, 2) NOT NULL DEFAULT 0,
    totalAmount AS (amount - discount) PERSISTED,
    amountInWords NVARCHAR(500),
    
    -- معلومات العملة
    currency NVARCHAR(50) NOT NULL DEFAULT N'دينار',
    exchangeRate DECIMAL(18, 4) NOT NULL DEFAULT 1.0,
    
    -- معلومات إضافية
    notes NVARCHAR(MAX),
    description NVARCHAR(MAX) DEFAULT N'دفع لحساب .. رأس المال المدفوع',
    
    -- معلومات الطلب
    previousOrder DECIMAL(18, 2) NOT NULL DEFAULT 0,
    currentOrder DECIMAL(18, 2) NOT NULL DEFAULT 0,
    
    -- الحالة والتتبع
    status NVARCHAR(50) NOT NULL DEFAULT N'مكتمل',
    isPrinted BIT NOT NULL DEFAULT 0,
    printCount INT NOT NULL DEFAULT 0,
    
    -- معلومات المستخدم
    createdBy INT,
    approvedBy INT,
    
    -- التواريخ
    createdAt DATETIME2 NOT NULL DEFAULT GETDATE(),
    updatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),
    approvedAt DATETIME2,
    
    -- Foreign Keys
    CONSTRAINT FK_PaymentVouchers_CreatedBy FOREIGN KEY (createdBy) 
        REFERENCES Users(id) ON DELETE SET NULL,
    CONSTRAINT FK_PaymentVouchers_ApprovedBy FOREIGN KEY (approvedBy) 
        REFERENCES Users(id) ON DELETE NO ACTION,
    
    -- Constraints
    CONSTRAINT CK_PaymentVouchers_Amount CHECK (amount >= 0),
    CONSTRAINT CK_PaymentVouchers_Discount CHECK (discount >= 0 AND discount <= amount),
    CONSTRAINT CK_PaymentVouchers_ExchangeRate CHECK (exchangeRate > 0)
);

CREATE NONCLUSTERED INDEX IX_PaymentVouchers_VoucherNumber ON PaymentVouchers(voucherNumber);
CREATE NONCLUSTERED INDEX IX_PaymentVouchers_VoucherDate ON PaymentVouchers(voucherDate);
CREATE NONCLUSTERED INDEX IX_PaymentVouchers_AccountName ON PaymentVouchers(accountName);
CREATE NONCLUSTERED INDEX IX_PaymentVouchers_Status ON PaymentVouchers(status);
CREATE NONCLUSTERED INDEX IX_PaymentVouchers_CreatedAt ON PaymentVouchers(createdAt);

PRINT N'✅ تم إنشاء جدول PaymentVouchers';
GO

-- =============================================
-- جدول سندات الدفع المتعددة (MultiplePaymentVouchers)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'MultiplePaymentVouchers')
BEGIN
    CREATE TABLE MultiplePaymentVouchers (
        id INT IDENTITY(1,1) PRIMARY KEY,
        voucherNumber NVARCHAR(50) NOT NULL UNIQUE,
        voucherDate DATETIME2 NOT NULL DEFAULT GETDATE(),
        
        -- معلومات المستفيد
        beneficiaryName NVARCHAR(200) NOT NULL,
        
        -- المبالغ الإجمالية
        totalAmount DECIMAL(18, 2) NOT NULL DEFAULT 0,
        
        -- معلومات إضافية
        notes NVARCHAR(MAX),
        
        -- الحالة
        status NVARCHAR(50) NOT NULL DEFAULT N'مكتمل',
        isPrinted BIT NOT NULL DEFAULT 0,
        
        -- التواريخ
        createdAt DATETIME2 NOT NULL DEFAULT GETDATE(),
        updatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),
        
        CONSTRAINT CK_MultiplePaymentVouchers_Amount CHECK (totalAmount >= 0)
    );
    
    CREATE NONCLUSTERED INDEX IX_MultiplePaymentVouchers_VoucherNumber 
        ON MultiplePaymentVouchers(voucherNumber);
    CREATE NONCLUSTERED INDEX IX_MultiplePaymentVouchers_VoucherDate 
        ON MultiplePaymentVouchers(voucherDate);
    
    PRINT N'✅ تم إنشاء جدول MultiplePaymentVouchers';
END
GO

-- =============================================
-- جدول تفاصيل سندات الدفع المتعددة (PaymentVoucherItems)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PaymentVoucherItems')
BEGIN
    CREATE TABLE PaymentVoucherItems (
        id INT IDENTITY(1,1) PRIMARY KEY,
        voucherId INT NOT NULL,
        
        -- معلومات البند
        accountName NVARCHAR(200) NOT NULL,
        currentAmount DECIMAL(18, 2) NOT NULL,
        previousAmount DECIMAL(18, 2) NOT NULL DEFAULT 0,
        totalAmount AS (currentAmount + previousAmount) PERSISTED,
        
        -- معلومات إضافية
        notes NVARCHAR(MAX),
        
        -- التاريخ
        createdAt DATETIME2 NOT NULL DEFAULT GETDATE(),
        
        FOREIGN KEY (voucherId) REFERENCES MultiplePaymentVouchers(id) ON DELETE CASCADE,
        
        CONSTRAINT CK_PaymentVoucherItems_CurrentAmount CHECK (currentAmount >= 0),
        CONSTRAINT CK_PaymentVoucherItems_PreviousAmount CHECK (previousAmount >= 0)
    );
    
    CREATE NONCLUSTERED INDEX IX_PaymentVoucherItems_VoucherId 
        ON PaymentVoucherItems(voucherId);
    
    PRINT N'✅ تم إنشاء جدول PaymentVoucherItems';
END
GO

-- =============================================
-- جدول سندات الدفع بعملتين (DualCurrencyPayments)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'DualCurrencyPayments')
BEGIN
    CREATE TABLE DualCurrencyPayments (
        id INT IDENTITY(1,1) PRIMARY KEY,
        voucherNumber NVARCHAR(50) NOT NULL UNIQUE,
        voucherDate DATETIME2 NOT NULL DEFAULT GETDATE(),
        
        -- معلومات المستفيد
        beneficiaryName NVARCHAR(200) NOT NULL,
        
        -- مبلغ الدينار العراقي
        amountIQD DECIMAL(18, 2) NOT NULL,
        paymentMethodIQD NVARCHAR(50) NOT NULL DEFAULT N'نقدي',
        checkNumberIQD NVARCHAR(50),
        checkDateIQD DATETIME2,
        bankNameIQD NVARCHAR(200),
        
        -- مبلغ الدولار
        amountUSD DECIMAL(18, 2) NOT NULL,
        paymentMethodUSD NVARCHAR(50) NOT NULL DEFAULT N'نقدي',
        checkNumberUSD NVARCHAR(50),
        checkDateUSD DATETIME2,
        bankNameUSD NVARCHAR(200),
        
        -- سعر الصرف
        exchangeRate DECIMAL(18, 4) NOT NULL,
        
        -- معلومات إضافية
        notes NVARCHAR(MAX),
        
        -- الحالة
        status NVARCHAR(50) NOT NULL DEFAULT N'مكتمل',
        isPrinted BIT NOT NULL DEFAULT 0,
        
        -- التواريخ
        createdAt DATETIME2 NOT NULL DEFAULT GETDATE(),
        updatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),
        
        CONSTRAINT CK_DualCurrencyPayments_AmountIQD CHECK (amountIQD >= 0),
        CONSTRAINT CK_DualCurrencyPayments_AmountUSD CHECK (amountUSD >= 0),
        CONSTRAINT CK_DualCurrencyPayments_ExchangeRate CHECK (exchangeRate > 0)
    );
    
    CREATE NONCLUSTERED INDEX IX_DualCurrencyPayments_VoucherNumber 
        ON DualCurrencyPayments(voucherNumber);
    CREATE NONCLUSTERED INDEX IX_DualCurrencyPayments_VoucherDate 
        ON DualCurrencyPayments(voucherDate);
    
    PRINT N'✅ تم إنشاء جدول DualCurrencyPayments';
END
GO

-- =============================================
-- جدول سندات الصرف (DisbursementVouchers)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'DisbursementVouchers')
BEGIN
    CREATE TABLE DisbursementVouchers (
        id INT IDENTITY(1,1) PRIMARY KEY,
        voucherNumber NVARCHAR(50) NOT NULL UNIQUE,
        voucherDate DATETIME2 NOT NULL DEFAULT GETDATE(),
        
        -- معلومات المستلم
        recipientName NVARCHAR(200) NOT NULL,
        recipientIdNumber NVARCHAR(50),
        
        -- معلومات المبلغ
        amount DECIMAL(18, 2) NOT NULL,
        amountInWords NVARCHAR(500),
        
        -- معلومات الصرف
        purpose NVARCHAR(200),
        category NVARCHAR(100) DEFAULT N'مصروفات عامة',
        
        -- معلومات إضافية
        notes NVARCHAR(MAX),
        
        -- الحالة
        status NVARCHAR(50) NOT NULL DEFAULT N'مكتمل',
        isPrinted BIT NOT NULL DEFAULT 0,
        
        -- التواريخ
        createdAt DATETIME2 NOT NULL DEFAULT GETDATE(),
        updatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),
        
        CONSTRAINT CK_DisbursementVouchers_Amount CHECK (amount >= 0)
    );
    
    CREATE NONCLUSTERED INDEX IX_DisbursementVouchers_VoucherNumber 
        ON DisbursementVouchers(voucherNumber);
    CREATE NONCLUSTERED INDEX IX_DisbursementVouchers_VoucherDate 
        ON DisbursementVouchers(voucherDate);
    CREATE NONCLUSTERED INDEX IX_DisbursementVouchers_RecipientName 
        ON DisbursementVouchers(recipientName);
    
    PRINT N'✅ تم إنشاء جدول DisbursementVouchers';
END
GO

-- =============================================
-- جدول رصيد العملات (CurrencyBalances)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CurrencyBalances')
BEGIN
    CREATE TABLE CurrencyBalances (
        id INT IDENTITY(1,1) PRIMARY KEY,
        currency NVARCHAR(50) NOT NULL UNIQUE,
        balance DECIMAL(18, 2) NOT NULL DEFAULT 0,
        lastUpdated DATETIME2 NOT NULL DEFAULT GETDATE(),
        
        -- التواريخ
        createdAt DATETIME2 NOT NULL DEFAULT GETDATE(),
        updatedAt DATETIME2 NOT NULL DEFAULT GETDATE()
    );
    
    -- إدراج العملات الافتراضية
    INSERT INTO CurrencyBalances (currency, balance) VALUES 
        (N'دينار عراقي', 0),
        (N'دولار أمريكي', 0),
        (N'يورو', 0);
    
    PRINT N'✅ تم إنشاء جدول CurrencyBalances';
END
GO

-- =============================================
-- Trigger: تحديث المجموع في سندات الدفع المتعددة
-- =============================================
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'TR_UpdateMultiplePaymentVoucherTotal')
    DROP TRIGGER TR_UpdateMultiplePaymentVoucherTotal;
GO

CREATE TRIGGER TR_UpdateMultiplePaymentVoucherTotal
ON PaymentVoucherItems
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- تحديث المجموع للسندات المتأثرة
    UPDATE mpv
    SET totalAmount = (
        SELECT ISNULL(SUM(currentAmount + previousAmount), 0)
        FROM PaymentVoucherItems
        WHERE voucherId = mpv.id
    ),
    updatedAt = GETDATE()
    FROM MultiplePaymentVouchers mpv
    WHERE mpv.id IN (
        SELECT DISTINCT voucherId FROM inserted
        UNION
        SELECT DISTINCT voucherId FROM deleted
    );
END;
GO
PRINT N'✅ تم إنشاء Trigger: TR_UpdateMultiplePaymentVoucherTotal';
GO

-- =============================================
-- Trigger: تحديث تاريخ التعديل في PaymentVouchers
-- =============================================
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'TR_UpdatePaymentVoucherTimestamp')
    DROP TRIGGER TR_UpdatePaymentVoucherTimestamp;
GO

CREATE TRIGGER TR_UpdatePaymentVoucherTimestamp
ON PaymentVouchers
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE PaymentVouchers
    SET updatedAt = GETDATE()
    WHERE id IN (SELECT id FROM inserted);
END;
GO
PRINT N'✅ تم إنشاء Trigger: TR_UpdatePaymentVoucherTimestamp';
GO

-- =============================================
-- Stored Procedure: إضافة سند دفع
-- =============================================
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_AddPaymentVoucher')
    DROP PROCEDURE sp_AddPaymentVoucher;
GO

CREATE PROCEDURE sp_AddPaymentVoucher
    @voucherNumber NVARCHAR(50),
    @voucherDate DATETIME2,
    @accountName NVARCHAR(200),
    @cashAccount NVARCHAR(100),
    @amount DECIMAL(18, 2),
    @discount DECIMAL(18, 2) = 0,
    @amountInWords NVARCHAR(500) = NULL,
    @currency NVARCHAR(50) = N'دينار',
    @exchangeRate DECIMAL(18, 4) = 1.0,
    @notes NVARCHAR(MAX) = NULL,
    @description NVARCHAR(MAX) = NULL,
    @previousOrder DECIMAL(18, 2) = 0,
    @currentOrder DECIMAL(18, 2) = 0,
    @createdBy INT = NULL,
    @newId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- إدراج السند
        INSERT INTO PaymentVouchers (
            voucherNumber, voucherDate, accountName, cashAccount,
            amount, discount, amountInWords, currency, exchangeRate,
            notes, description, previousOrder, currentOrder, createdBy
        )
        VALUES (
            @voucherNumber, @voucherDate, @accountName, @cashAccount,
            @amount, @discount, @amountInWords, @currency, @exchangeRate,
            @notes, @description, @previousOrder, @currentOrder, @createdBy
        );
        
        SET @newId = SCOPE_IDENTITY();
        
        COMMIT TRANSACTION;
        
        PRINT N'✅ تم إضافة سند الدفع: ' + @voucherNumber;
        RETURN 0;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT N'❌ خطأ في إضافة سند الدفع: ' + @ErrorMessage;
        THROW;
    END CATCH
END;
GO
PRINT N'✅ تم إنشاء Stored Procedure: sp_AddPaymentVoucher';
GO

-- =============================================
-- Stored Procedure: الحصول على سندات الدفع
-- =============================================
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_GetPaymentVouchers')
    DROP PROCEDURE sp_GetPaymentVouchers;
GO

CREATE PROCEDURE sp_GetPaymentVouchers
    @startDate DATETIME2 = NULL,
    @endDate DATETIME2 = NULL,
    @status NVARCHAR(50) = NULL,
    @accountName NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        pv.*,
        u.username as createdByUsername,
        a.username as approvedByUsername
    FROM PaymentVouchers pv
    LEFT JOIN Users u ON pv.createdBy = u.id
    LEFT JOIN Users a ON pv.approvedBy = a.id
    WHERE 
        (@startDate IS NULL OR pv.voucherDate >= @startDate)
        AND (@endDate IS NULL OR pv.voucherDate <= @endDate)
        AND (@status IS NULL OR pv.status = @status)
        AND (@accountName IS NULL OR pv.accountName LIKE '%' + @accountName + '%')
    ORDER BY pv.voucherDate DESC, pv.createdAt DESC;
END;
GO
PRINT N'✅ تم إنشاء Stored Procedure: sp_GetPaymentVouchers';
GO

-- =============================================
-- Stored Procedure: حذف سند دفع
-- =============================================
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_DeletePaymentVoucher')
    DROP PROCEDURE sp_DeletePaymentVoucher;
GO

CREATE PROCEDURE sp_DeletePaymentVoucher
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    BEGIN TRY
        DECLARE @voucherNumber NVARCHAR(50);
        
        SELECT @voucherNumber = voucherNumber 
        FROM PaymentVouchers 
        WHERE id = @id;
        
        IF @voucherNumber IS NULL
        BEGIN
            PRINT N'❌ سند الدفع غير موجود';
            ROLLBACK TRANSACTION;
            RETURN -1;
        END
        
        DELETE FROM PaymentVouchers WHERE id = @id;
        
        COMMIT TRANSACTION;
        
        PRINT N'✅ تم حذف سند الدفع: ' + @voucherNumber;
        RETURN 0;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT N'❌ خطأ في حذف سند الدفع: ' + @ErrorMessage;
        THROW;
    END CATCH
END;
GO
PRINT N'✅ تم إنشاء Stored Procedure: sp_DeletePaymentVoucher';
GO

-- =============================================
-- View: عرض سندات الدفع مع التفاصيل
-- =============================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_PaymentVouchersDetails')
    DROP VIEW vw_PaymentVouchersDetails;
GO

CREATE VIEW vw_PaymentVouchersDetails
AS
SELECT 
    pv.id,
    pv.voucherNumber,
    pv.voucherDate,
    pv.accountName,
    pv.cashAccount,
    pv.amount,
    pv.discount,
    pv.totalAmount,
    pv.amountInWords,
    pv.currency,
    pv.exchangeRate,
    pv.notes,
    pv.description,
    pv.previousOrder,
    pv.currentOrder,
    pv.status,
    pv.isPrinted,
    pv.printCount,
    pv.createdAt,
    pv.updatedAt,
    u.username as createdByUsername,
    a.username as approvedByUsername,
    YEAR(pv.voucherDate) as voucherYear,
    MONTH(pv.voucherDate) as voucherMonth,
    DAY(pv.voucherDate) as voucherDay
FROM PaymentVouchers pv
LEFT JOIN Users u ON pv.createdBy = u.id
LEFT JOIN Users a ON pv.approvedBy = a.id;
GO
PRINT N'✅ تم إنشاء View: vw_PaymentVouchersDetails';
GO

-- =============================================
-- View: إحصائيات سندات الدفع
-- =============================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_PaymentVouchersStats')
    DROP VIEW vw_PaymentVouchersStats;
GO

CREATE VIEW vw_PaymentVouchersStats
AS
SELECT 
    currency,
    COUNT(*) as voucherCount,
    SUM(totalAmount) as totalPaid,
    AVG(totalAmount) as averagePaid,
    MIN(totalAmount) as minPaid,
    MAX(totalAmount) as maxPaid
FROM PaymentVouchers
WHERE status = N'مكتمل'
GROUP BY currency;
GO
PRINT N'✅ تم إنشاء View: vw_PaymentVouchersStats';
GO

-- =============================================
-- Function: الحصول على المجموع حسب الفترة
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'fn_GetPaymentVoucherTotalByPeriod')
    DROP FUNCTION fn_GetPaymentVoucherTotalByPeriod;
GO

CREATE FUNCTION fn_GetPaymentVoucherTotalByPeriod
(
    @startDate DATETIME2,
    @endDate DATETIME2,
    @currency NVARCHAR(50) = NULL
)
RETURNS DECIMAL(18, 2)
AS
BEGIN
    DECLARE @total DECIMAL(18, 2);
    
    SELECT @total = ISNULL(SUM(totalAmount), 0)
    FROM PaymentVouchers
    WHERE voucherDate BETWEEN @startDate AND @endDate
        AND status = N'مكتمل'
        AND (@currency IS NULL OR currency = @currency);
    
    RETURN @total;
END;
GO
PRINT N'✅ تم إنشاء Function: fn_GetPaymentVoucherTotalByPeriod';
GO

-- =============================================
-- إضافة بيانات تجريبية (اختياري)
-- =============================================
PRINT N'';
PRINT N'📝 إضافة بيانات تجريبية...';

-- سند دفع تجريبي 1
DECLARE @testId INT;
EXEC sp_AddPaymentVoucher
    @voucherNumber = N'PAY-2025-001',
    @voucherDate = '2025-01-01',
    @accountName = N'محمد أحمد',
    @cashAccount = N'صندوق 181',
    @amount = 1000000,
    @discount = 50000,
    @amountInWords = N'تسعمائة وخمسون ألف دينار',
    @currency = N'دينار',
    @exchangeRate = 1.0,
    @notes = N'سند دفع تجريبي',
    @description = N'دفع لحساب رأس المال المدفوع',
    @previousOrder = 0,
    @currentOrder = 950000,
    @newId = @testId OUTPUT;

PRINT N'✅ تم إضافة سند دفع تجريبي برقم: PAY-2025-001';

-- سند دفع تجريبي 2
EXEC sp_AddPaymentVoucher
    @voucherNumber = N'PAY-2025-002',
    @voucherDate = '2025-01-02',
    @accountName = N'شركة النور التجارية',
    @cashAccount = N'صندوق 182',
    @amount = 500000,
    @discount = 0,
    @amountInWords = N'خمسمائة ألف دينار',
    @currency = N'دينار',
    @exchangeRate = 1.0,
    @notes = N'دفعة على حساب التوريدات',
    @description = N'دفع لحساب الموردين',
    @previousOrder = 0,
    @currentOrder = 500000,
    @newId = @testId OUTPUT;

PRINT N'✅ تم إضافة سند دفع تجريبي برقم: PAY-2025-002';

PRINT N'';
PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
PRINT N'✅ اكتمل إنشاء نظام سندات الدفع بنجاح!';
PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
PRINT N'';
PRINT N'📊 الجداول المُنشأة:';
PRINT N'   ✅ PaymentVouchers - سندات الدفع الرئيسية';
PRINT N'   ✅ MultiplePaymentVouchers - سندات الدفع المتعددة';
PRINT N'   ✅ PaymentVoucherItems - تفاصيل السندات المتعددة';
PRINT N'   ✅ DualCurrencyPayments - سندات الدفع بعملتين';
PRINT N'   ✅ DisbursementVouchers - سندات الصرف';
PRINT N'   ✅ CurrencyBalances - رصيد العملات';
PRINT N'';
PRINT N'⚙️ Stored Procedures:';
PRINT N'   ✅ sp_AddPaymentVoucher - إضافة سند دفع';
PRINT N'   ✅ sp_GetPaymentVouchers - عرض سندات الدفع';
PRINT N'   ✅ sp_DeletePaymentVoucher - حذف سند دفع';
PRINT N'';
PRINT N'📈 Views:';
PRINT N'   ✅ vw_PaymentVouchersDetails - تفاصيل السندات';
PRINT N'   ✅ vw_PaymentVouchersStats - إحصائيات السندات';
PRINT N'';
PRINT N'🔧 Functions:';
PRINT N'   ✅ fn_GetPaymentVoucherTotalByPeriod - المجموع حسب الفترة';
PRINT N'';
PRINT N'🔄 Triggers:';
PRINT N'   ✅ TR_UpdateMultiplePaymentVoucherTotal';
PRINT N'   ✅ TR_UpdatePaymentVoucherTimestamp';
PRINT N'';
PRINT N'📝 البيانات التجريبية:';
PRINT N'   ✅ تم إضافة 2 سند دفع تجريبي';
PRINT N'';
PRINT N'🎉 النظام جاهز للاستخدام!';
PRINT N'';

-- اختبار البيانات
SELECT 
    COUNT(*) as TotalVouchers,
    SUM(totalAmount) as TotalAmount,
    currency
FROM PaymentVouchers
GROUP BY currency;

GO

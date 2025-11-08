-- Create Users table for authentication
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Users')
BEGIN
    CREATE TABLE Users (
        UserID INT PRIMARY KEY IDENTITY(1,1),
        Username NVARCHAR(50) UNIQUE NOT NULL,
        Password NVARCHAR(255) NOT NULL,
        FullName NVARCHAR(100) NOT NULL,
        Email NVARCHAR(100),
        Phone NVARCHAR(20),
        Role NVARCHAR(20) DEFAULT 'user', -- admin, user, cashier
        IsActive BIT DEFAULT 1,
        CreatedAt DATETIME DEFAULT GETDATE(),
        LastLogin DATETIME,
        CONSTRAINT CHK_Role CHECK (Role IN ('admin', 'user', 'cashier'))
    );

    -- Create default admin user
    -- Username: admin
    -- Password: admin123 (hashed)
    INSERT INTO Users (Username, Password, FullName, Role)
    VALUES ('admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', N'المدير العام', 'admin');

    PRINT 'Users table created successfully with default admin user';
    PRINT 'Username: admin';
    PRINT 'Password: admin123';
END
GO

-- Create ActivityLog table for audit trail
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ActivityLog')
BEGIN
    CREATE TABLE ActivityLog (
        LogID INT PRIMARY KEY IDENTITY(1,1),
        UserID INT,
        Action NVARCHAR(100) NOT NULL,
        TableName NVARCHAR(50),
        RecordID INT,
        OldValue NVARCHAR(MAX),
        NewValue NVARCHAR(MAX),
        IPAddress NVARCHAR(50),
        CreatedAt DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (UserID) REFERENCES Users(UserID)
    );

    PRINT 'ActivityLog table created successfully';
END
GO

-- Create index for better performance
CREATE NONCLUSTERED INDEX IX_ActivityLog_UserID ON ActivityLog(UserID);
CREATE NONCLUSTERED INDEX IX_ActivityLog_CreatedAt ON ActivityLog(CreatedAt);
GO

PRINT 'Authentication system setup completed!';

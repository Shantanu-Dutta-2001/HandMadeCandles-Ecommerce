-- =============================================
-- Script: 02_CreateTables.sql
-- Description: Creates all tables for CandleFantasyDb
-- =============================================

USE [CandleFantasyDb]
GO

-- =============================================
-- Table: Users
-- Description: Stores user account information
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Users')
BEGIN
    CREATE TABLE Users (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        Name NVARCHAR(100) NOT NULL,
        Email NVARCHAR(100) UNIQUE NOT NULL,
        PasswordHash NVARCHAR(MAX) NOT NULL,
        Role NVARCHAR(20) DEFAULT 'User',
        CreatedAt DATETIME DEFAULT GETDATE(),
        CONSTRAINT CK_Users_Role CHECK (Role IN ('User', 'Admin'))
    )
    
    CREATE INDEX IX_Users_Email ON Users(Email)
    PRINT 'Table Users created successfully.'
END
ELSE
BEGIN
    PRINT 'Table Users already exists.'
END
GO

-- =============================================
-- Table: Products
-- Description: Stores candle product catalog
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Products')
BEGIN
    CREATE TABLE Products (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        Name NVARCHAR(200) NOT NULL,
        Description NVARCHAR(MAX),
        Price DECIMAL(18,2) NOT NULL,
        Image NVARCHAR(MAX),
        Category NVARCHAR(50),
        Rating DECIMAL(3,2) DEFAULT 0,
        CreatedAt DATETIME DEFAULT GETDATE(),
        CONSTRAINT CK_Products_Price CHECK (Price >= 0),
        CONSTRAINT CK_Products_Rating CHECK (Rating >= 0 AND Rating <= 5)
    )
    
    CREATE INDEX IX_Products_Category ON Products(Category)
    CREATE INDEX IX_Products_Rating ON Products(Rating DESC)
    PRINT 'Table Products created successfully.'
END
ELSE
BEGIN
    PRINT 'Table Products already exists.'
END
GO

-- =============================================
-- Table: Orders
-- Description: Stores customer orders
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Orders')
BEGIN
    CREATE TABLE Orders (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        UserId INT NOT NULL,
        Total DECIMAL(18,2) NOT NULL,
        Status NVARCHAR(50) DEFAULT 'Pending',
        Date DATETIME DEFAULT GETDATE(),
        PaymentMethod NVARCHAR(50),
        ShippingAddress NVARCHAR(MAX),
        CONSTRAINT FK_Orders_Users FOREIGN KEY (UserId) REFERENCES Users(Id),
        CONSTRAINT CK_Orders_Total CHECK (Total >= 0),
        CONSTRAINT CK_Orders_Status CHECK (Status IN ('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled'))
    )
    
    CREATE INDEX IX_Orders_UserId ON Orders(UserId)
    CREATE INDEX IX_Orders_Date ON Orders(Date DESC)
    CREATE INDEX IX_Orders_Status ON Orders(Status)
    PRINT 'Table Orders created successfully.'
END
ELSE
BEGIN
    PRINT 'Table Orders already exists.'
END
GO

-- =============================================
-- Table: OrderItems
-- Description: Stores line items for each order
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'OrderItems')
BEGIN
    CREATE TABLE OrderItems (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        OrderId INT NOT NULL,
        ProductId INT NOT NULL,
        Quantity INT NOT NULL,
        Price DECIMAL(18,2) NOT NULL,
        CONSTRAINT FK_OrderItems_Orders FOREIGN KEY (OrderId) REFERENCES Orders(Id) ON DELETE CASCADE,
        CONSTRAINT FK_OrderItems_Products FOREIGN KEY (ProductId) REFERENCES Products(Id),
        CONSTRAINT CK_OrderItems_Quantity CHECK (Quantity > 0),
        CONSTRAINT CK_OrderItems_Price CHECK (Price >= 0)
    )
    
    CREATE INDEX IX_OrderItems_OrderId ON OrderItems(OrderId)
    CREATE INDEX IX_OrderItems_ProductId ON OrderItems(ProductId)
    PRINT 'Table OrderItems created successfully.'
END
ELSE
BEGIN
    PRINT 'Table OrderItems already exists.'
END
GO

-- =============================================
-- Table: Reviews
-- Description: Stores customer testimonials
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Reviews')
BEGIN
    CREATE TABLE Reviews (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        UserName NVARCHAR(100) NOT NULL,
        Content NVARCHAR(MAX) NOT NULL,
        Rating INT NOT NULL,
        Date DATETIME DEFAULT GETDATE(),
        ProductId INT NULL,
        CONSTRAINT FK_Reviews_Products FOREIGN KEY (ProductId) REFERENCES Products(Id),
        CONSTRAINT CK_Reviews_Rating CHECK (Rating >= 1 AND Rating <= 5)
    )
    
    CREATE INDEX IX_Reviews_Date ON Reviews(Date DESC)
    CREATE INDEX IX_Reviews_ProductId ON Reviews(ProductId)
    PRINT 'Table Reviews created successfully.'
END
ELSE
BEGIN
    PRINT 'Table Reviews already exists.'
END
GO

-- =============================================
-- Table: Messages
-- Description: Stores contact form submissions
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Messages')
BEGIN
    CREATE TABLE Messages (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        Name NVARCHAR(100) NOT NULL,
        Email NVARCHAR(100) NOT NULL,
        Subject NVARCHAR(200) NOT NULL,
        Body NVARCHAR(MAX) NOT NULL,
        CreatedAt DATETIME DEFAULT GETDATE(),
        IsRead BIT DEFAULT 0
    )
    
    CREATE INDEX IX_Messages_CreatedAt ON Messages(CreatedAt DESC)
    CREATE INDEX IX_Messages_IsRead ON Messages(IsRead)
    PRINT 'Table Messages created successfully.'
END
ELSE
BEGIN
    PRINT 'Table Messages already exists.'
END
GO

PRINT 'All tables created successfully.'
GO

-- Database Initialization Script

-- 1. Users Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Users')
CREATE TABLE Users (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Email NVARCHAR(255) UNIQUE NOT NULL,
    PasswordHash NVARCHAR(MAX) NOT NULL,
    Role NVARCHAR(20) DEFAULT 'User'
);

-- 2. Products Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Products')
CREATE TABLE Products (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(255) NOT NULL,
    Description NVARCHAR(MAX),
    Price DECIMAL(18,2) NOT NULL,
    Image NVARCHAR(MAX),
    Category NVARCHAR(100),
    Rating DECIMAL(3,2) DEFAULT 0
);

-- 3. Addresses Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Addresses')
CREATE TABLE Addresses (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT FOREIGN KEY REFERENCES Users(Id),
    Name NVARCHAR(100),
    AddressLine NVARCHAR(255),
    City NVARCHAR(100),
    Zip NVARCHAR(20),
    Phone NVARCHAR(20),
    IsDefault BIT DEFAULT 0
);

-- 4. Orders Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Orders')
CREATE TABLE Orders (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT FOREIGN KEY REFERENCES Users(Id),
    Total DECIMAL(18,2) NOT NULL,
    Status NVARCHAR(50) DEFAULT 'Pending',
    Date DATETIME DEFAULT GETDATE(),
    PaymentMethod NVARCHAR(50),
    ShippingName NVARCHAR(100),
    ShippingAddress NVARCHAR(255),
    ShippingCity NVARCHAR(100),
    ShippingZip NVARCHAR(20),
    ShippingPhone NVARCHAR(20)
);

-- 5. OrderItems Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'OrderItems')
CREATE TABLE OrderItems (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    OrderId INT FOREIGN KEY REFERENCES Orders(Id),
    ProductId INT FOREIGN KEY REFERENCES Products(Id),
    Quantity INT NOT NULL,
    Price DECIMAL(18,2) NOT NULL
);

-- 6. OrderFeedbacks Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'OrderFeedbacks')
CREATE TABLE OrderFeedbacks (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    OrderId INT UNIQUE FOREIGN KEY REFERENCES Orders(Id),
    Rating INT NOT NULL CHECK (Rating BETWEEN 1 AND 5),
    Message NVARCHAR(MAX),
    Date DATETIME DEFAULT GETDATE()
);

-- 7. Messages (Queries) Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Messages')
CREATE TABLE Messages (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Email NVARCHAR(255) NOT NULL,
    Subject NVARCHAR(255) NOT NULL,
    Body NVARCHAR(MAX) NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- SEED DATA
-- 1. Base Products (Shared with DbInitializer)
IF NOT EXISTS (SELECT * FROM Products)
BEGIN
    INSERT INTO Products (Name, Description, Price, Image, Category, Rating) VALUES 
    ('Eternal Flame', 'A candle that never burns out.', 45.00, 'https://images.unsplash.com/photo-1603006905003-be475563bc59?q=80', 'Legendary', 5.0),
    ('Midnight Whisper', 'Contains the silence of the void.', 18.50, 'https://images.unsplash.com/photo-1547796068-067f082e0d3c?q=80', 'Stealth', 4.8),
    ('Forest Spirit', 'Essence of the ancient woods.', 22.00, 'https://images.unsplash.com/photo-1608181114410-db2bb411e527?q=80', 'Nature', 4.9);
END;

-- 2. Demo User (demo@user.com / User123!)
IF NOT EXISTS (SELECT * FROM Users WHERE Email = 'demo@user.com')
BEGIN
    INSERT INTO Users (Name, Email, PasswordHash, Role) 
    VALUES ('John Demo', 'demo@user.com', '$2a$11$q9nB7lXvL1... PLACEHOLDER', 'User');
END;

-- 3. Demo Data (Addresses, Orders, Messages) is usually handled by DbInitializer but scripts can have them too.
-- For conciseness, we primarily rely on DbInitializer for complex relational seeding.

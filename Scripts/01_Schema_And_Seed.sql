-- Database Initialization Script for CandleFantasyDb

-- 1. Create Database (If running manually, unsure if DB exists)
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'CandleFantasyDb')
BEGIN
    CREATE DATABASE [CandleFantasyDb]
END
GO

USE [CandleFantasyDb]
GO

-- 2. Create Tables
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Users')
CREATE TABLE Users (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    PasswordHash NVARCHAR(MAX) NOT NULL,
    Role NVARCHAR(20) DEFAULT 'User'
)
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Products')
CREATE TABLE Products (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(200) NOT NULL,
    Description NVARCHAR(MAX),
    Price DECIMAL(18,2) NOT NULL,
    Image NVARCHAR(MAX),
    Category NVARCHAR(50),
    Rating DECIMAL(3,2) DEFAULT 0
)
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Orders')
CREATE TABLE Orders (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT FOREIGN KEY REFERENCES Users(Id),
    Total DECIMAL(18,2) NOT NULL,
    Status NVARCHAR(50) DEFAULT 'Pending',
    Date DATETIME DEFAULT GETDATE(),
    PaymentMethod NVARCHAR(50)
)
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'OrderItems')
CREATE TABLE OrderItems (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    OrderId INT FOREIGN KEY REFERENCES Orders(Id),
    ProductId INT FOREIGN KEY REFERENCES Products(Id),
    Quantity INT NOT NULL,
    Price DECIMAL(18,2) NOT NULL
)
GO

-- 3. Seed Data (Fantasy Theme)
IF NOT EXISTS (SELECT * FROM Products)
BEGIN
    INSERT INTO Products (Name, Description, Price, Image, Category, Rating) VALUES 
    ('Eternal Flame', 'A candle that never burns out, forged in the depths of the Phoenix Nest. Emits a warm, undying light.', 45.00, 'https://images.unsplash.com/photo-1603006905003-be475563bc59?q=80', 'Legendary', 5.0),
    
    ('Midnight Whisper', 'Contains the silence of the void. Perfect for deep meditation or stealth missions. Smells like ozone and shadows.', 18.50, 'https://images.unsplash.com/photo-1547796068-067f082e0d3c?q=80', 'Stealth', 4.8),
    
    ('Forest Spirit', 'Essence of the ancient woods. Invokes the tranquility of an Elven Glade using moss, fern, and morning dew scents.', 22.00, 'https://images.unsplash.com/photo-1608181114410-db2bb411e527?q=80', 'Nature', 4.9),
    
    ('Dragon''s Breath', 'Spicy cinnamon and ember smoke. Captures the raw power of a fire drake. Warning: Glass may feel warm to the touch.', 30.00, 'https://images.unsplash.com/photo-1572016252981-d2f2cb6960ae?q=80', 'Elemental', 4.7),
    
    ('Wizard''s Study', 'The scent of old parchment, leather bindings, and pipe tobacco. Grants +2 Intelligence while burning.', 25.00, 'https://images.unsplash.com/photo-1596436034138-0283025215e9?q=80', 'Academic', 4.6),
    
    ('Siren''s Call', 'Sea salt, ocean breeze, and a hint of dangerous allure. Use with caution near open water.', 28.00, 'https://images.unsplash.com/photo-1602525963321-4d3756855877?q=80', 'Aquatic', 4.5),
    
    ('Dwarven Hearth', 'Roasted chestnuts, iron, and stout ale. Smells like home after a long mining expedition.', 20.00, 'https://images.unsplash.com/photo-1597588362688-64c8d1720d2d?q=80', 'Home', 4.8),
    
    ('Fae Trickery', 'A shifting scent that changes every hour. Lilac, then honey, then... sour milk? A gamble for the adventurous.', 15.00, 'https://images.unsplash.com/photo-1612152605332-959c25f48e35?q=80', 'Chaos', 4.2),
    
    ('Moonlight Serenade', 'Cool floral notes that bloom only at night. Crafted by the Lunar Priestess.', 35.00, 'https://images.unsplash.com/photo-1570701564993-e00652af8aa7?q=80', 'Celestial', 5.0),
    
    ('Alchemist''s Gold', 'Metallic tang mixed with honey and saffron. Designed to attract prosperity (results not guaranteed).', 50.00, 'https://images.unsplash.com/photo-1570703886561-3957813735a6?q=80', 'Luxury', 4.4)
END
GO

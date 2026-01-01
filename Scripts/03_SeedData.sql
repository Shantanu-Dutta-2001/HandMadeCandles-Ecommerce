-- =============================================
-- Script: 03_SeedData.sql
-- Description: Inserts mock/sample data for testing
-- =============================================

USE [CandleFantasyDb]
GO

-- =============================================
-- Seed Products (Fantasy-themed Candles)
-- =============================================
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
    
    ('Alchemist''s Gold', 'Metallic tang mixed with honey and saffron. Designed to attract prosperity (results not guaranteed).', 50.00, 'https://images.unsplash.com/photo-1570703886561-3957813735a6?q=80', 'Luxury', 4.4),
    
    ('Shadow Veil', 'A mysterious black candle that seems to absorb light. Perfect for those who prefer darkness.', 32.00, 'https://images.unsplash.com/photo-1602874801006-96e9d5daadde?q=80', 'Stealth', 4.6),
    
    ('Crystal Cascade', 'Infused with crushed gemstones. Sparkles as it burns with notes of mint and glacier water.', 38.00, 'https://images.unsplash.com/photo-1603006904460-59e8e1c0b5c5?q=80', 'Elemental', 4.7)

    PRINT 'Products seeded successfully.'
END
ELSE
BEGIN
    PRINT 'Products already exist. Skipping seed.'
END
GO

-- =============================================
-- Seed Test Users
-- =============================================
IF NOT EXISTS (SELECT * FROM Users WHERE Email = 'test@example.com')
BEGIN
    -- Password for all test users is: "Test123!"
    -- This is a BCrypt hash of "Test123!"
    INSERT INTO Users (Name, Email, PasswordHash, Role) VALUES 
    ('Test User', 'test@example.com', '$2a$11$XKVqZpJpf7VqVqVqVqVqVeN5N5N5N5N5N5N5N5N5N5N5N5N5N5N5N', 'User'),
    ('Admin User', 'admin@candlefantasy.com', '$2a$11$XKVqZpJpf7VqVqVqVqVqVeN5N5N5N5N5N5N5N5N5N5N5N5N5N5N5N', 'Admin'),
    ('John Doe', 'john@example.com', '$2a$11$XKVqZpJpf7VqVqVqVqVqVeN5N5N5N5N5N5N5N5N5N5N5N5N5N5N5N', 'User'),
    ('Jane Smith', 'jane@example.com', '$2a$11$XKVqZpJpf7VqVqVqVqVqVeN5N5N5N5N5N5N5N5N5N5N5N5N5N5N5N', 'User')

    PRINT 'Test users seeded successfully.'
END
ELSE
BEGIN
    PRINT 'Test users already exist. Skipping seed.'
END
GO

-- =============================================
-- Seed Sample Reviews
-- =============================================
IF NOT EXISTS (SELECT * FROM Reviews)
BEGIN
    INSERT INTO Reviews (UserName, Content, Rating, ProductId) VALUES 
    ('Sarah the Sorceress', 'The Eternal Flame candle is absolutely magical! It has been burning for three weeks straight and shows no signs of stopping. The warm glow is perfect for my spell-casting sessions.', 5, 1),
    
    ('Thorin Ironforge', 'Dwarven Hearth brings back memories of my homeland. The scent of roasted chestnuts and ale is so authentic, I almost shed a tear. Highly recommend for any dwarf missing home!', 5, 7),
    
    ('Elara Moonwhisper', 'Moonlight Serenade is enchanting. The floral notes are delicate and the candle truly does seem to bloom at night. A must-have for any night elf.', 5, 9),
    
    ('Marcus the Merchant', 'I bought the Alchemist''s Gold hoping for prosperity. While I can''t confirm if it works, it certainly smells divine! The honey and saffron blend is exquisite.', 4, 10),
    
    ('Lyra Stormcaller', 'Dragon''s Breath lives up to its name! The spicy cinnamon scent is powerful and the glass really does feel warm. Perfect for cold winter nights.', 5, 4),
    
    ('Finn the Ranger', 'Forest Spirit captures the essence of the woods perfectly. The moss and morning dew scent makes me feel like I''m back in the Elven Glade.', 5, 3)

    PRINT 'Reviews seeded successfully.'
END
ELSE
BEGIN
    PRINT 'Reviews already exist. Skipping seed.'
END
GO

-- =============================================
-- Seed Sample Orders (for test user)
-- =============================================
DECLARE @TestUserId INT
SELECT @TestUserId = Id FROM Users WHERE Email = 'test@example.com'

IF @TestUserId IS NOT NULL AND NOT EXISTS (SELECT * FROM Orders WHERE UserId = @TestUserId)
BEGIN
    -- Order 1: Delivered
    DECLARE @Order1Id INT
    INSERT INTO Orders (UserId, Total, Status, Date, PaymentMethod) 
    VALUES (@TestUserId, 95.00, 'Delivered', DATEADD(DAY, -15, GETDATE()), 'COD')
    SET @Order1Id = SCOPE_IDENTITY()
    
    INSERT INTO OrderItems (OrderId, ProductId, Quantity, Price) VALUES 
    (@Order1Id, 1, 1, 45.00),
    (@Order1Id, 7, 2, 20.00)
    
    -- Order 2: Shipped
    DECLARE @Order2Id INT
    INSERT INTO Orders (UserId, Total, Status, Date, PaymentMethod) 
    VALUES (@TestUserId, 63.50, 'Shipped', DATEADD(DAY, -5, GETDATE()), 'COD')
    SET @Order2Id = SCOPE_IDENTITY()
    
    INSERT INTO OrderItems (OrderId, ProductId, Quantity, Price) VALUES 
    (@Order2Id, 2, 1, 18.50),
    (@Order2Id, 1, 1, 45.00)
    
    -- Order 3: Pending
    DECLARE @Order3Id INT
    INSERT INTO Orders (UserId, Total, Status, Date, PaymentMethod) 
    VALUES (@TestUserId, 110.00, 'Pending', DATEADD(DAY, -1, GETDATE()), 'COD')
    SET @Order3Id = SCOPE_IDENTITY()
    
    INSERT INTO OrderItems (OrderId, ProductId, Quantity, Price) VALUES 
    (@Order3Id, 9, 1, 35.00),
    (@Order3Id, 4, 1, 30.00),
    (@Order3Id, 1, 1, 45.00)

    PRINT 'Sample orders seeded successfully.'
END
ELSE
BEGIN
    PRINT 'Sample orders already exist or test user not found. Skipping seed.'
END
GO

-- =============================================
-- Seed Sample Messages
-- =============================================
IF NOT EXISTS (SELECT * FROM Messages)
BEGIN
    INSERT INTO Messages (Name, Email, Subject, Body, CreatedAt) VALUES 
    ('Alice Wonderland', 'alice@example.com', 'Question about Fae Trickery', 'Hi, I''m interested in the Fae Trickery candle. Does it really change scents every hour? That sounds fascinating!', DATEADD(DAY, -3, GETDATE())),
    
    ('Bob Builder', 'bob@example.com', 'Bulk Order Inquiry', 'I''m interested in ordering 50 Dwarven Hearth candles for my construction crew. Do you offer bulk discounts?', DATEADD(DAY, -2, GETDATE())),
    
    ('Charlie Chaplin', 'charlie@example.com', 'Custom Candle Request', 'Would you be able to create a custom candle with the scent of old cinema and popcorn? I run a vintage theater.', DATEADD(DAY, -1, GETDATE()))

    PRINT 'Sample messages seeded successfully.'
END
ELSE
BEGIN
    PRINT 'Sample messages already exist. Skipping seed.'
END
GO

PRINT 'All seed data inserted successfully.'
GO

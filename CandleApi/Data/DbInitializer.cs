using Dapper;
using Microsoft.Data.SqlClient;
using BCrypt.Net;
using CandleApi.Models;

namespace CandleApi.Data
{
    public class DbInitializer
    {
        private readonly IConfiguration _configuration;

        public DbInitializer(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        public void Initialize()
        {
            var connectionString = _configuration.GetConnectionString("DefaultConnection");
            
            // Create database if not exists (Requires connection to master, simplified here to just assume DB exists or User runs script, 
            // but for "Fantasy" we can try to be smart. 
            // Better approach: Let's assume the DB needs to be created.
            // We need to parse the connection string to connect to 'master' first.
            
            try 
            {
                var builder = new SqlConnectionStringBuilder(connectionString);
                var databaseName = builder.InitialCatalog;
                builder.InitialCatalog = "master";
                
                using (var masterConnection = new SqlConnection(builder.ConnectionString))
                {
                    masterConnection.Open();
                    var checkDbQuery = $"SELECT * FROM sys.databases WHERE name = '{databaseName}'";
                    var exists = masterConnection.QueryFirstOrDefault(checkDbQuery) != null;

                    if (!exists)
                    {
                        masterConnection.Execute($"CREATE DATABASE [{databaseName}]");
                    }
                }
            }
            catch (Exception ex)
            {
                // On shared hosting like MonsterASP, we often don't have access to 'master'
                // This is fine as long as the DB already exists.
                Console.WriteLine($"Note: Could not check/create database from code (Normal on shared hosting): {ex.Message}");
            }

            // Now connect to the actual DB and create tables
            using (var connection = new SqlConnection(connectionString))
            {
                connection.Open();

                // Users Table
                connection.Execute(@"
                    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Users')
                    CREATE TABLE Users (
                        Id INT IDENTITY(1,1) PRIMARY KEY,
                        Name NVARCHAR(100) NOT NULL,
                        Email NVARCHAR(100) UNIQUE NOT NULL,
                        PasswordHash NVARCHAR(MAX) NOT NULL,
                        Role NVARCHAR(20) DEFAULT 'User'
                    )");

                // Products Table
                connection.Execute(@"
                    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Products')
                    CREATE TABLE Products (
                        Id INT IDENTITY(1,1) PRIMARY KEY,
                        Name NVARCHAR(200) NOT NULL,
                        Description NVARCHAR(MAX),
                        Price DECIMAL(18,2) NOT NULL,
                        Image NVARCHAR(MAX),
                        Category NVARCHAR(50),
                        Rating DECIMAL(3,2) DEFAULT 0
                    )");

                // Orders Table
                connection.Execute(@"
                    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Orders')
                    CREATE TABLE Orders (
                        Id INT IDENTITY(1,1) PRIMARY KEY,
                        UserId INT FOREIGN KEY REFERENCES Users(Id),
                        Total DECIMAL(18,2) NOT NULL,
                        Status NVARCHAR(50) DEFAULT 'Pending',
                        Date DATETIME DEFAULT GETDATE(),
                        PaymentMethod NVARCHAR(50)
                    )");

                // OrderItems Table
                connection.Execute(@"
                    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'OrderItems')
                    CREATE TABLE OrderItems (
                        Id INT IDENTITY(1,1) PRIMARY KEY,
                        OrderId INT FOREIGN KEY REFERENCES Orders(Id),
                        ProductId INT FOREIGN KEY REFERENCES Products(Id),
                        Quantity INT NOT NULL,
                        Price DECIMAL(18,2) NOT NULL
                    )");

                // Reviews Table
                connection.Execute(@"
                    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Reviews')
                    CREATE TABLE Reviews (
                        Id INT IDENTITY(1,1) PRIMARY KEY,
                        UserName NVARCHAR(100) NOT NULL,
                        Content NVARCHAR(MAX) NOT NULL,
                        Rating INT NOT NULL,
                        Date DATETIME DEFAULT GETDATE()
                    )");

                // Messages Table
                connection.Execute(@"
                    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Messages')
                    CREATE TABLE Messages (
                        Id INT IDENTITY(1,1) PRIMARY KEY,
                        Name NVARCHAR(100) NOT NULL,
                        Email NVARCHAR(100) NOT NULL,
                        Subject NVARCHAR(200),
                        Body NVARCHAR(MAX) NOT NULL,
                        CreatedAt DATETIME DEFAULT GETDATE()
                    )");

                // OrderFeedback Table
                connection.Execute(@"
                    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'OrderFeedbacks')
                    CREATE TABLE OrderFeedbacks (
                        Id INT IDENTITY(1,1) PRIMARY KEY,
                        OrderId INT FOREIGN KEY REFERENCES Orders(Id),
                        UserId INT FOREIGN KEY REFERENCES Users(Id),
                        Rating INT NOT NULL,
                        Message NVARCHAR(MAX),
                        Date DATETIME DEFAULT GETDATE()
                    )");

                // Address Table
                connection.Execute(@"
                    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Addresses')
                    CREATE TABLE Addresses (
                        Id INT IDENTITY(1,1) PRIMARY KEY,
                        UserId INT FOREIGN KEY REFERENCES Users(Id),
                        Name NVARCHAR(100) NOT NULL,
                        AddressLine NVARCHAR(200) NOT NULL,
                        City NVARCHAR(100) NOT NULL,
                        Zip NVARCHAR(20) NOT NULL,
                        Phone NVARCHAR(20) NOT NULL,
                        IsDefault BIT DEFAULT 0
                    )");

                 // Update Orders Table structure (Add columns if they don't exist)
                 var alterOrderSql = @"
                    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Orders') AND name = 'ShippingName')
                        ALTER TABLE Orders ADD ShippingName NVARCHAR(100) NOT NULL DEFAULT '';
                    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Orders') AND name = 'ShippingAddress')
                        ALTER TABLE Orders ADD ShippingAddress NVARCHAR(200) NOT NULL DEFAULT '';
                    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Orders') AND name = 'ShippingCity')
                        ALTER TABLE Orders ADD ShippingCity NVARCHAR(100) NOT NULL DEFAULT '';
                    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Orders') AND name = 'ShippingZip')
                        ALTER TABLE Orders ADD ShippingZip NVARCHAR(20) NOT NULL DEFAULT '';
                    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Orders') AND name = 'ShippingPhone')
                        ALTER TABLE Orders ADD ShippingPhone NVARCHAR(20) NOT NULL DEFAULT '';
                 ";
                 connection.Execute(alterOrderSql);

                 // Seed Initial Data (Fantasy Theme)
                 var productCount = connection.ExecuteScalar<int>("SELECT COUNT(*) FROM Products");
                 if (productCount == 0)
                 {
                     connection.Execute(@"
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
                     ");
                 }

                 var reviewCount = connection.ExecuteScalar<int>("SELECT COUNT(*) FROM Reviews");
                 if (reviewCount == 0)
                 {
                     connection.Execute(@"
                        INSERT INTO Reviews (UserName, Content, Rating, Date) VALUES 
                        ('Sarah M.', 'The Vanilla Dreams candle sends me straight to the Cloud District (figuratively). Absolutely divine.', 5, GETDATE()),
                        ('Gimli S.', 'Dwarven Hearth is proper stout! Reminds me of the glitter of gold in the deep.', 5, GETDATE()),
                        ('Elara Moonwhisper', 'Forest Spirit is... acceptable. A bit too much moss, not enough starlight.', 4, GETDATE())
                     ");
                 }
                // Seed Admin User
                var adminEmail = "admin@candle.com";
                var adminExists = connection.QueryFirstOrDefault<int>(
                    "SELECT COUNT(1) FROM Users WHERE Email = @Email", new { Email = adminEmail });
                
                if (adminExists > 0)
                {
                    // Force update admin password to ensure it matches seeded expectations
                    string hashedPassword = BCrypt.Net.BCrypt.HashPassword("Admin123!");
                    connection.Execute("UPDATE Users SET PasswordHash = @Hash, Role = 'Admin' WHERE Email = @Email", 
                        new { Email = adminEmail, Hash = hashedPassword });
                }
                else
                {
                    string hashedPassword = BCrypt.Net.BCrypt.HashPassword("Admin123!");
                    connection.Execute(@"
                        INSERT INTO Users (Name, Email, PasswordHash, Role) 
                        VALUES ('Admin', @Email, @Hash, 'Admin')", 
                        new { Email = adminEmail, Hash = hashedPassword });
                }

                // Seed Demo User
                var demoEmail = "demo@user.com";
                var demoUser = connection.QueryFirstOrDefault<User>(
                    "SELECT TOP 1 * FROM Users WHERE Email = @Email", new { Email = demoEmail });
                
                int demoUserId;
                if (demoUser == null)
                {
                    string hashedPassword = BCrypt.Net.BCrypt.HashPassword("User123!");
                    demoUserId = connection.ExecuteScalar<int>(@"
                        INSERT INTO Users (Name, Email, PasswordHash, Role) 
                        VALUES ('John Demo', @Email, @Hash, 'User');
                        SELECT CAST(SCOPE_IDENTITY() as int)", 
                        new { Email = demoEmail, Hash = hashedPassword });
                }
                else
                {
                    demoUserId = demoUser.Id;
                }

                // Seed Sample Addresses
                var addressCount = connection.ExecuteScalar<int>(
                    "SELECT COUNT(1) FROM Addresses WHERE UserId = @UserId", new { UserId = demoUserId });
                if (addressCount == 0)
                {
                    connection.Execute(@"
                        INSERT INTO Addresses (UserId, Name, AddressLine, City, Zip, Phone, IsDefault) VALUES 
                        (@UserId, 'Home', '123 Phoenix Nest Lane', 'Aurelia', '44102', '555-0101', 1),
                        (@UserId, 'Office', '77 Griffin Tower, Level 4', 'Skyreach', '99105', '555-0199', 0)",
                        new { UserId = demoUserId });
                }

                // Seed Sample Orders
                var orderCount = connection.ExecuteScalar<int>(
                    "SELECT COUNT(1) FROM Orders WHERE UserId = @UserId", new { UserId = demoUserId });
                if (orderCount == 0)
                {
                    // Order 1: Delivered
                    var orderId1 = connection.ExecuteScalar<int>(@"
                        INSERT INTO Orders (UserId, Total, Status, Date, PaymentMethod, ShippingName, ShippingAddress, ShippingCity, ShippingZip, ShippingPhone) 
                        VALUES (@UserId, 63.50, 'Delivered', DATEADD(day, -5, GETDATE()), 'COD', 'John Demo', '123 Phoenix Nest Lane', 'Aurelia', '44102', '555-0101');
                        SELECT CAST(SCOPE_IDENTITY() as int)", new { UserId = demoUserId });
                    
                    connection.Execute("INSERT INTO OrderItems (OrderId, ProductId, Quantity, Price) VALUES (@OrderId, 1, 1, 45.00), (@OrderId, 2, 1, 18.50)", new { OrderId = orderId1 });
                    connection.Execute("INSERT INTO OrderFeedbacks (OrderId, UserId, Rating, Message) VALUES (@OrderId, @UserId, 5, 'The Eternal Flame is breathtaking! Shipping was fast.')", new { OrderId = orderId1, UserId = demoUserId });

                    // Order 2: Shipped
                    var orderId2 = connection.ExecuteScalar<int>(@"
                        INSERT INTO Orders (UserId, Total, Status, Date, PaymentMethod, ShippingName, ShippingAddress, ShippingCity, ShippingZip, ShippingPhone) 
                        VALUES (@UserId, 52.00, 'Shipped', DATEADD(day, -2, GETDATE()), 'COD', 'John Demo', '123 Phoenix Nest Lane', 'Aurelia', '44102', '555-0101');
                        SELECT CAST(SCOPE_IDENTITY() as int)", new { UserId = demoUserId });
                    
                    connection.Execute("INSERT INTO OrderItems (OrderId, ProductId, Quantity, Price) VALUES (@OrderId, 3, 2, 22.00), (@OrderId, 8, 1, 15.00)", new { OrderId = orderId2 });

                    // Order 3: Pending
                    var orderId3 = connection.ExecuteScalar<int>(@"
                        INSERT INTO Orders (UserId, Total, Status, Date, PaymentMethod, ShippingName, ShippingAddress, ShippingCity, ShippingZip, ShippingPhone) 
                        VALUES (@UserId, 30.00, 'Pending', GETDATE(), 'COD', 'John Demo', '123 Phoenix Nest Lane', 'Aurelia', '44102', '555-0101');
                        SELECT CAST(SCOPE_IDENTITY() as int)", new { UserId = demoUserId });
                    
                    connection.Execute("INSERT INTO OrderItems (OrderId, ProductId, Quantity, Price) VALUES (@OrderId, 4, 1, 30.00)", new { OrderId = orderId3 });
                }

                // Seed Sample Messages (Queries)
                var messageCount = connection.ExecuteScalar<int>("SELECT COUNT(1) FROM Messages");
                if (messageCount <= 1) // Allow 1 from previous seeding if any
                {
                    connection.Execute(@"
                        INSERT INTO Messages (Name, Email, Subject, Body) VALUES 
                        ('Gandalf the Grey', 'gandalf@istari.com', 'Bulk Order for Hobbyon', 'Do you offer discounts for bulk orders of Eternal Flame candles? We have a long night ahead.'),
                        ('Legolas Greenleaf', 'legolas@mirkwood.org', 'Scent Query', 'The Forest Spirit candle is missing the sharp note of Mallorn leaves. Can you customize a batch?'),
                        ('Thorin Oakenshield', 'thorin@erebor.com', 'Shipping to Lonely Mountain', 'Is your courier willing to travel through Mirkwood? The dragon is currently sleeping.')");
                }
            }
        }
    }
}

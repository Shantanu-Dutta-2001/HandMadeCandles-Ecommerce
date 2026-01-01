-- =============================================
-- Script: 04_StoredProcedures.sql
-- Description: Creates all stored procedures for API operations
-- =============================================

USE [CandleFantasyDb]
GO

-- =============================================
-- AUTHENTICATION PROCEDURES
-- =============================================

-- =============================================
-- Procedure: sp_RegisterUser
-- Description: Registers a new user
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_RegisterUser')
    DROP PROCEDURE sp_RegisterUser
GO

CREATE PROCEDURE sp_RegisterUser
    @Name NVARCHAR(100),
    @Email NVARCHAR(100),
    @PasswordHash NVARCHAR(MAX),
    @UserId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Check if user already exists
        IF EXISTS (SELECT 1 FROM Users WHERE Email = @Email)
        BEGIN
            RAISERROR('User with this email already exists.', 16, 1)
            RETURN
        END
        
        -- Insert new user
        INSERT INTO Users (Name, Email, PasswordHash, Role)
        VALUES (@Name, @Email, @PasswordHash, 'User')
        
        SET @UserId = SCOPE_IDENTITY()
        
        SELECT @UserId AS Id, 'User registered successfully.' AS Message
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

-- =============================================
-- Procedure: sp_GetUserByEmail
-- Description: Retrieves user by email for login
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetUserByEmail')
    DROP PROCEDURE sp_GetUserByEmail
GO

CREATE PROCEDURE sp_GetUserByEmail
    @Email NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT Id, Name, Email, PasswordHash, Role, CreatedAt
    FROM Users
    WHERE Email = @Email
END
GO

-- =============================================
-- Procedure: sp_GetUserById
-- Description: Retrieves user by ID
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetUserById')
    DROP PROCEDURE sp_GetUserById
GO

CREATE PROCEDURE sp_GetUserById
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT Id, Name, Email, Role, CreatedAt
    FROM Users
    WHERE Id = @UserId
END
GO

-- =============================================
-- PRODUCT PROCEDURES
-- =============================================

-- =============================================
-- Procedure: sp_GetAllProducts
-- Description: Retrieves all products
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetAllProducts')
    DROP PROCEDURE sp_GetAllProducts
GO

CREATE PROCEDURE sp_GetAllProducts
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT Id, Name, Description, Price, Image, Category, Rating, CreatedAt
    FROM Products
    ORDER BY Rating DESC, Name
END
GO

-- =============================================
-- Procedure: sp_GetProductById
-- Description: Retrieves a single product by ID
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetProductById')
    DROP PROCEDURE sp_GetProductById
GO

CREATE PROCEDURE sp_GetProductById
    @ProductId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT Id, Name, Description, Price, Image, Category, Rating, CreatedAt
    FROM Products
    WHERE Id = @ProductId
END
GO

-- =============================================
-- Procedure: sp_GetProductsByCategory
-- Description: Retrieves products by category
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetProductsByCategory')
    DROP PROCEDURE sp_GetProductsByCategory
GO

CREATE PROCEDURE sp_GetProductsByCategory
    @Category NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT Id, Name, Description, Price, Image, Category, Rating, CreatedAt
    FROM Products
    WHERE Category = @Category
    ORDER BY Rating DESC, Name
END
GO

-- =============================================
-- ORDER PROCEDURES
-- =============================================

-- =============================================
-- Procedure: sp_CreateOrder
-- Description: Creates a new order with items
-- Parameters: @OrderItems is a JSON array of items
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_CreateOrder')
    DROP PROCEDURE sp_CreateOrder
GO

CREATE PROCEDURE sp_CreateOrder
    @UserId INT,
    @Total DECIMAL(18,2),
    @PaymentMethod NVARCHAR(50),
    @ShippingAddress NVARCHAR(MAX) = NULL,
    @OrderItems NVARCHAR(MAX), -- JSON array: [{"ProductId":1,"Quantity":2,"Price":45.00}]
    @OrderId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION
        
        -- Create the order
        INSERT INTO Orders (UserId, Total, Status, Date, PaymentMethod, ShippingAddress)
        VALUES (@UserId, @Total, 'Pending', GETDATE(), @PaymentMethod, @ShippingAddress)
        
        SET @OrderId = SCOPE_IDENTITY()
        
        -- Insert order items from JSON
        INSERT INTO OrderItems (OrderId, ProductId, Quantity, Price)
        SELECT 
            @OrderId,
            JSON_VALUE(value, '$.ProductId'),
            JSON_VALUE(value, '$.Quantity'),
            JSON_VALUE(value, '$.Price')
        FROM OPENJSON(@OrderItems)
        
        COMMIT TRANSACTION
        
        SELECT @OrderId AS OrderId, 'Order created successfully.' AS Message
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION
        THROW;
    END CATCH
END
GO

-- =============================================
-- Procedure: sp_GetUserOrders
-- Description: Retrieves all orders for a user
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetUserOrders')
    DROP PROCEDURE sp_GetUserOrders
GO

CREATE PROCEDURE sp_GetUserOrders
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        o.Id,
        o.UserId,
        o.Total,
        o.Status,
        o.Date,
        o.PaymentMethod,
        o.ShippingAddress
    FROM Orders o
    WHERE o.UserId = @UserId
    ORDER BY o.Date DESC
END
GO

-- =============================================
-- Procedure: sp_GetOrderById
-- Description: Retrieves order details with items
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetOrderById')
    DROP PROCEDURE sp_GetOrderById
GO

CREATE PROCEDURE sp_GetOrderById
    @OrderId INT,
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Get order details
    SELECT 
        o.Id,
        o.UserId,
        o.Total,
        o.Status,
        o.Date,
        o.PaymentMethod,
        o.ShippingAddress
    FROM Orders o
    WHERE o.Id = @OrderId AND o.UserId = @UserId
    
    -- Get order items
    SELECT 
        oi.Id,
        oi.OrderId,
        oi.ProductId,
        oi.Quantity,
        oi.Price,
        p.Name AS ProductName,
        p.Image AS ProductImage
    FROM OrderItems oi
    INNER JOIN Products p ON oi.ProductId = p.Id
    WHERE oi.OrderId = @OrderId
END
GO

-- =============================================
-- Procedure: sp_UpdateOrderStatus
-- Description: Updates order status
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_UpdateOrderStatus')
    DROP PROCEDURE sp_UpdateOrderStatus
GO

CREATE PROCEDURE sp_UpdateOrderStatus
    @OrderId INT,
    @Status NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        UPDATE Orders
        SET Status = @Status
        WHERE Id = @OrderId
        
        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR('Order not found.', 16, 1)
            RETURN
        END
        
        SELECT 'Order status updated successfully.' AS Message
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

-- =============================================
-- Procedure: sp_GetOrderItemsByOrderId
-- Description: Retrieves all items for an order
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetOrderItemsByOrderId')
    DROP PROCEDURE sp_GetOrderItemsByOrderId
GO

CREATE PROCEDURE sp_GetOrderItemsByOrderId
    @OrderId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        oi.Id,
        oi.OrderId,
        oi.ProductId,
        oi.Quantity,
        oi.Price,
        p.Name AS ProductName,
        p.Image AS ProductImage,
        p.Category AS ProductCategory
    FROM OrderItems oi
    INNER JOIN Products p ON oi.ProductId = p.Id
    WHERE oi.OrderId = @OrderId
END
GO

-- =============================================
-- REVIEW PROCEDURES
-- =============================================

-- =============================================
-- Procedure: sp_GetLatestReviews
-- Description: Retrieves latest reviews
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetLatestReviews')
    DROP PROCEDURE sp_GetLatestReviews
GO

CREATE PROCEDURE sp_GetLatestReviews
    @TopCount INT = 3
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT TOP (@TopCount)
        r.Id,
        r.UserName,
        r.Content,
        r.Rating,
        r.Date,
        r.ProductId,
        p.Name AS ProductName
    FROM Reviews r
    LEFT JOIN Products p ON r.ProductId = p.Id
    ORDER BY r.Date DESC
END
GO

-- =============================================
-- Procedure: sp_GetReviewsByProduct
-- Description: Retrieves reviews for a specific product
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetReviewsByProduct')
    DROP PROCEDURE sp_GetReviewsByProduct
GO

CREATE PROCEDURE sp_GetReviewsByProduct
    @ProductId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        Id,
        UserName,
        Content,
        Rating,
        Date,
        ProductId
    FROM Reviews
    WHERE ProductId = @ProductId
    ORDER BY Date DESC
END
GO

-- =============================================
-- Procedure: sp_CreateReview
-- Description: Creates a new review
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_CreateReview')
    DROP PROCEDURE sp_CreateReview
GO

CREATE PROCEDURE sp_CreateReview
    @UserName NVARCHAR(100),
    @Content NVARCHAR(MAX),
    @Rating INT,
    @ProductId INT = NULL,
    @ReviewId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Validate rating
        IF @Rating < 1 OR @Rating > 5
        BEGIN
            RAISERROR('Rating must be between 1 and 5.', 16, 1)
            RETURN
        END
        
        -- Insert review
        INSERT INTO Reviews (UserName, Content, Rating, Date, ProductId)
        VALUES (@UserName, @Content, @Rating, GETDATE(), @ProductId)
        
        SET @ReviewId = SCOPE_IDENTITY()
        
        -- Update product rating if ProductId is provided
        IF @ProductId IS NOT NULL
        BEGIN
            UPDATE Products
            SET Rating = (
                SELECT AVG(CAST(Rating AS DECIMAL(3,2)))
                FROM Reviews
                WHERE ProductId = @ProductId
            )
            WHERE Id = @ProductId
        END
        
        SELECT @ReviewId AS ReviewId, 'Review created successfully.' AS Message
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

-- =============================================
-- MESSAGE PROCEDURES
-- =============================================

-- =============================================
-- Procedure: sp_CreateMessage
-- Description: Creates a new contact message
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_CreateMessage')
    DROP PROCEDURE sp_CreateMessage
GO

CREATE PROCEDURE sp_CreateMessage
    @Name NVARCHAR(100),
    @Email NVARCHAR(100),
    @Subject NVARCHAR(200),
    @Body NVARCHAR(MAX),
    @MessageId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        INSERT INTO Messages (Name, Email, Subject, Body, CreatedAt, IsRead)
        VALUES (@Name, @Email, @Subject, @Body, GETDATE(), 0)
        
        SET @MessageId = SCOPE_IDENTITY()
        
        SELECT @MessageId AS MessageId, 'Message sent successfully.' AS Message
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

-- =============================================
-- Procedure: sp_GetAllMessages
-- Description: Retrieves all messages (for admin)
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetAllMessages')
    DROP PROCEDURE sp_GetAllMessages
GO

CREATE PROCEDURE sp_GetAllMessages
    @OnlyUnread BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        Id,
        Name,
        Email,
        Subject,
        Body,
        CreatedAt,
        IsRead
    FROM Messages
    WHERE (@OnlyUnread = 0 OR IsRead = 0)
    ORDER BY CreatedAt DESC
END
GO

-- =============================================
-- Procedure: sp_MarkMessageAsRead
-- Description: Marks a message as read
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_MarkMessageAsRead')
    DROP PROCEDURE sp_MarkMessageAsRead
GO

CREATE PROCEDURE sp_MarkMessageAsRead
    @MessageId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE Messages
    SET IsRead = 1
    WHERE Id = @MessageId
    
    SELECT 'Message marked as read.' AS Message
END
GO

-- =============================================
-- ANALYTICS & REPORTING PROCEDURES
-- =============================================

-- =============================================
-- Procedure: sp_GetOrderStatistics
-- Description: Gets order statistics for dashboard
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetOrderStatistics')
    DROP PROCEDURE sp_GetOrderStatistics
GO

CREATE PROCEDURE sp_GetOrderStatistics
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Default to last 30 days if not specified
    IF @StartDate IS NULL
        SET @StartDate = DATEADD(DAY, -30, GETDATE())
    IF @EndDate IS NULL
        SET @EndDate = GETDATE()
    
    SELECT 
        COUNT(*) AS TotalOrders,
        SUM(Total) AS TotalRevenue,
        AVG(Total) AS AverageOrderValue,
        COUNT(CASE WHEN Status = 'Pending' THEN 1 END) AS PendingOrders,
        COUNT(CASE WHEN Status = 'Processing' THEN 1 END) AS ProcessingOrders,
        COUNT(CASE WHEN Status = 'Shipped' THEN 1 END) AS ShippedOrders,
        COUNT(CASE WHEN Status = 'Delivered' THEN 1 END) AS DeliveredOrders,
        COUNT(CASE WHEN Status = 'Cancelled' THEN 1 END) AS CancelledOrders
    FROM Orders
    WHERE Date BETWEEN @StartDate AND @EndDate
END
GO

-- =============================================
-- Procedure: sp_GetTopSellingProducts
-- Description: Gets top selling products
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetTopSellingProducts')
    DROP PROCEDURE sp_GetTopSellingProducts
GO

CREATE PROCEDURE sp_GetTopSellingProducts
    @TopCount INT = 10
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT TOP (@TopCount)
        p.Id,
        p.Name,
        p.Category,
        p.Price,
        p.Rating,
        SUM(oi.Quantity) AS TotalQuantitySold,
        SUM(oi.Quantity * oi.Price) AS TotalRevenue
    FROM Products p
    INNER JOIN OrderItems oi ON p.Id = oi.ProductId
    GROUP BY p.Id, p.Name, p.Category, p.Price, p.Rating
    ORDER BY TotalQuantitySold DESC
END
GO

PRINT 'All stored procedures created successfully.'
GO

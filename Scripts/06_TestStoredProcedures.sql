-- =============================================
-- Script: 06_TestStoredProcedures.sql
-- Description: Test scripts for all stored procedures
-- =============================================

USE [CandleFantasyDb]
GO

PRINT '=========================================='
PRINT 'Testing Stored Procedures'
PRINT '=========================================='
PRINT ''

-- =============================================
-- Test Authentication Procedures
-- =============================================
PRINT 'Testing Authentication Procedures...'
PRINT ''

-- Test: Register User
DECLARE @NewUserId INT
EXEC sp_RegisterUser 
    @Name = 'Test Registration',
    @Email = 'testreg@example.com',
    @PasswordHash = '$2a$11$TestHashValue',
    @UserId = @NewUserId OUTPUT
PRINT 'New User ID: ' + CAST(@NewUserId AS NVARCHAR(10))
PRINT ''

-- Test: Get User By Email
EXEC sp_GetUserByEmail @Email = 'test@example.com'
PRINT ''

-- Test: Get User By ID
EXEC sp_GetUserById @UserId = 1
PRINT ''

-- =============================================
-- Test Product Procedures
-- =============================================
PRINT 'Testing Product Procedures...'
PRINT ''

-- Test: Get All Products
EXEC sp_GetAllProducts
PRINT ''

-- Test: Get Product By ID
EXEC sp_GetProductById @ProductId = 1
PRINT ''

-- Test: Get Products By Category
EXEC sp_GetProductsByCategory @Category = 'Legendary'
PRINT ''

-- =============================================
-- Test Order Procedures
-- =============================================
PRINT 'Testing Order Procedures...'
PRINT ''

-- Test: Create Order
DECLARE @NewOrderId INT
DECLARE @OrderItemsJson NVARCHAR(MAX) = '[
    {"ProductId": 1, "Quantity": 2, "Price": 45.00},
    {"ProductId": 3, "Quantity": 1, "Price": 22.00}
]'

EXEC sp_CreateOrder
    @UserId = 1,
    @Total = 112.00,
    @PaymentMethod = 'COD',
    @ShippingAddress = '123 Test Street, Test City',
    @OrderItems = @OrderItemsJson,
    @OrderId = @NewOrderId OUTPUT
PRINT 'New Order ID: ' + CAST(@NewOrderId AS NVARCHAR(10))
PRINT ''

-- Test: Get User Orders
EXEC sp_GetUserOrders @UserId = 1
PRINT ''

-- Test: Get Order By ID
EXEC sp_GetOrderById @OrderId = 1, @UserId = 1
PRINT ''

-- Test: Get Order Items
EXEC sp_GetOrderItemsByOrderId @OrderId = 1
PRINT ''

-- Test: Update Order Status
EXEC sp_UpdateOrderStatus @OrderId = @NewOrderId, @Status = 'Processing'
PRINT ''

-- =============================================
-- Test Review Procedures
-- =============================================
PRINT 'Testing Review Procedures...'
PRINT ''

-- Test: Get Latest Reviews
EXEC sp_GetLatestReviews @TopCount = 5
PRINT ''

-- Test: Get Reviews By Product
EXEC sp_GetReviewsByProduct @ProductId = 1
PRINT ''

-- Test: Create Review
DECLARE @NewReviewId INT
EXEC sp_CreateReview
    @UserName = 'Test Reviewer',
    @Content = 'This is a test review. The product is amazing!',
    @Rating = 5,
    @ProductId = 1,
    @ReviewId = @NewReviewId OUTPUT
PRINT 'New Review ID: ' + CAST(@NewReviewId AS NVARCHAR(10))
PRINT ''

-- =============================================
-- Test Message Procedures
-- =============================================
PRINT 'Testing Message Procedures...'
PRINT ''

-- Test: Create Message
DECLARE @NewMessageId INT
EXEC sp_CreateMessage
    @Name = 'Test Contact',
    @Email = 'testcontact@example.com',
    @Subject = 'Test Subject',
    @Body = 'This is a test message body.',
    @MessageId = @NewMessageId OUTPUT
PRINT 'New Message ID: ' + CAST(@NewMessageId AS NVARCHAR(10))
PRINT ''

-- Test: Get All Messages
EXEC sp_GetAllMessages @OnlyUnread = 0
PRINT ''

-- Test: Mark Message As Read
EXEC sp_MarkMessageAsRead @MessageId = @NewMessageId
PRINT ''

-- =============================================
-- Test Analytics Procedures
-- =============================================
PRINT 'Testing Analytics Procedures...'
PRINT ''

-- Test: Get Order Statistics
EXEC sp_GetOrderStatistics
PRINT ''

-- Test: Get Top Selling Products
EXEC sp_GetTopSellingProducts @TopCount = 5
PRINT ''

PRINT '=========================================='
PRINT 'All Stored Procedure Tests Complete!'
PRINT '=========================================='
GO

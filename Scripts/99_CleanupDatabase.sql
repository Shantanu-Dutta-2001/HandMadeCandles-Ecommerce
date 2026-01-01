-- =============================================
-- Script: 99_CleanupDatabase.sql
-- Description: Drops all tables and stored procedures
-- WARNING: This will delete ALL data!
-- =============================================

USE [CandleFantasyDb]
GO

PRINT '=========================================='
PRINT 'WARNING: This will delete ALL data!'
PRINT '=========================================='
PRINT ''

-- Drop Stored Procedures
PRINT 'Dropping Stored Procedures...'

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_RegisterUser')
    DROP PROCEDURE sp_RegisterUser
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetUserByEmail')
    DROP PROCEDURE sp_GetUserByEmail
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetUserById')
    DROP PROCEDURE sp_GetUserById
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetAllProducts')
    DROP PROCEDURE sp_GetAllProducts
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetProductById')
    DROP PROCEDURE sp_GetProductById
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetProductsByCategory')
    DROP PROCEDURE sp_GetProductsByCategory
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_CreateOrder')
    DROP PROCEDURE sp_CreateOrder
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetUserOrders')
    DROP PROCEDURE sp_GetUserOrders
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetOrderById')
    DROP PROCEDURE sp_GetOrderById
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_UpdateOrderStatus')
    DROP PROCEDURE sp_UpdateOrderStatus
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetOrderItemsByOrderId')
    DROP PROCEDURE sp_GetOrderItemsByOrderId
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetLatestReviews')
    DROP PROCEDURE sp_GetLatestReviews
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetReviewsByProduct')
    DROP PROCEDURE sp_GetReviewsByProduct
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_CreateReview')
    DROP PROCEDURE sp_CreateReview
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_CreateMessage')
    DROP PROCEDURE sp_CreateMessage
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetAllMessages')
    DROP PROCEDURE sp_GetAllMessages
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_MarkMessageAsRead')
    DROP PROCEDURE sp_MarkMessageAsRead
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetOrderStatistics')
    DROP PROCEDURE sp_GetOrderStatistics
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetTopSellingProducts')
    DROP PROCEDURE sp_GetTopSellingProducts

PRINT 'Stored Procedures dropped.'
PRINT ''

-- Drop Tables (in reverse order of dependencies)
PRINT 'Dropping Tables...'

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'OrderItems')
    DROP TABLE OrderItems
    
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Orders')
    DROP TABLE Orders
    
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Reviews')
    DROP TABLE Reviews
    
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Messages')
    DROP TABLE Messages
    
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Products')
    DROP TABLE Products
    
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Users')
    DROP TABLE Users

PRINT 'Tables dropped.'
PRINT ''

PRINT '=========================================='
PRINT 'Database cleanup complete!'
PRINT 'All tables and stored procedures removed.'
PRINT '=========================================='
GO

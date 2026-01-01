-- =============================================
-- Script: 05_UtilityQueries.sql
-- Description: Useful queries for database management and testing
-- =============================================

USE [CandleFantasyDb]
GO

-- =============================================
-- VIEW ALL DATA (for testing/verification)
-- =============================================

-- View all users
SELECT * FROM Users
GO

-- View all products
SELECT * FROM Products ORDER BY Category, Name
GO

-- View all orders with user info
SELECT 
    o.Id AS OrderId,
    u.Name AS CustomerName,
    u.Email,
    o.Total,
    o.Status,
    o.Date,
    o.PaymentMethod
FROM Orders o
INNER JOIN Users u ON o.UserId = u.Id
ORDER BY o.Date DESC
GO

-- View order details with items
SELECT 
    o.Id AS OrderId,
    o.Date,
    o.Status,
    o.Total,
    p.Name AS ProductName,
    oi.Quantity,
    oi.Price,
    (oi.Quantity * oi.Price) AS LineTotal
FROM Orders o
INNER JOIN OrderItems oi ON o.Id = oi.OrderId
INNER JOIN Products p ON oi.ProductId = p.Id
ORDER BY o.Date DESC, o.Id, p.Name
GO

-- View all reviews
SELECT * FROM Reviews ORDER BY Date DESC
GO

-- View all messages
SELECT * FROM Messages ORDER BY CreatedAt DESC
GO

-- =============================================
-- STATISTICS QUERIES
-- =============================================

-- Product sales summary
SELECT 
    p.Name,
    p.Category,
    p.Price,
    COUNT(DISTINCT oi.OrderId) AS NumberOfOrders,
    SUM(oi.Quantity) AS TotalQuantitySold,
    SUM(oi.Quantity * oi.Price) AS TotalRevenue
FROM Products p
LEFT JOIN OrderItems oi ON p.Id = oi.ProductId
GROUP BY p.Id, p.Name, p.Category, p.Price
ORDER BY TotalRevenue DESC
GO

-- Order status summary
SELECT 
    Status,
    COUNT(*) AS OrderCount,
    SUM(Total) AS TotalValue
FROM Orders
GROUP BY Status
ORDER BY OrderCount DESC
GO

-- Revenue by date
SELECT 
    CAST(Date AS DATE) AS OrderDate,
    COUNT(*) AS OrderCount,
    SUM(Total) AS DailyRevenue
FROM Orders
GROUP BY CAST(Date AS DATE)
ORDER BY OrderDate DESC
GO

-- Customer order summary
SELECT 
    u.Name,
    u.Email,
    COUNT(o.Id) AS TotalOrders,
    SUM(o.Total) AS TotalSpent,
    MAX(o.Date) AS LastOrderDate
FROM Users u
LEFT JOIN Orders o ON u.Id = o.UserId
GROUP BY u.Id, u.Name, u.Email
ORDER BY TotalSpent DESC
GO

-- =============================================
-- TESTING QUERIES
-- =============================================

-- Check table row counts
SELECT 'Users' AS TableName, COUNT(*) AS RowCount FROM Users
UNION ALL
SELECT 'Products', COUNT(*) FROM Products
UNION ALL
SELECT 'Orders', COUNT(*) FROM Orders
UNION ALL
SELECT 'OrderItems', COUNT(*) FROM OrderItems
UNION ALL
SELECT 'Reviews', COUNT(*) FROM Reviews
UNION ALL
SELECT 'Messages', COUNT(*) FROM Messages
GO

-- Check for orphaned records
SELECT 'Orphaned OrderItems' AS Issue, COUNT(*) AS Count
FROM OrderItems oi
LEFT JOIN Orders o ON oi.OrderId = o.Id
WHERE o.Id IS NULL
UNION ALL
SELECT 'Orphaned Orders', COUNT(*)
FROM Orders o
LEFT JOIN Users u ON o.UserId = u.Id
WHERE u.Id IS NULL
GO

-- =============================================
-- DATA VALIDATION QUERIES
-- =============================================

-- Check for invalid prices
SELECT 'Products with invalid prices' AS Issue, COUNT(*) AS Count
FROM Products
WHERE Price < 0
GO

-- Check for invalid ratings
SELECT 'Products with invalid ratings' AS Issue, COUNT(*) AS Count
FROM Products
WHERE Rating < 0 OR Rating > 5
GO

-- Check for orders with mismatched totals
SELECT 
    o.Id AS OrderId,
    o.Total AS OrderTotal,
    SUM(oi.Quantity * oi.Price) AS CalculatedTotal,
    ABS(o.Total - SUM(oi.Quantity * oi.Price)) AS Difference
FROM Orders o
INNER JOIN OrderItems oi ON o.Id = oi.OrderId
GROUP BY o.Id, o.Total
HAVING ABS(o.Total - SUM(oi.Quantity * oi.Price)) > 0.01
GO

-- =============================================
-- Script: 01_CreateDatabase.sql
-- Description: Creates the CandleFantasyDb database
-- =============================================

-- Check if database exists and create if it doesn't
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'CandleFantasyDb')
BEGIN
    CREATE DATABASE [CandleFantasyDb]
    PRINT 'Database CandleFantasyDb created successfully.'
END
ELSE
BEGIN
    PRINT 'Database CandleFantasyDb already exists.'
END
GO

-- Switch to the database
USE [CandleFantasyDb]
GO

PRINT 'Switched to CandleFantasyDb database.'
GO

-- =============================================
-- Script: 00_MasterSetup.sql
-- Description: Master script to run all setup scripts in order
-- Usage: Execute this script to set up the entire database
-- =============================================

PRINT '=========================================='
PRINT 'Starting CandleFantasyDb Setup'
PRINT '=========================================='
PRINT ''

-- Step 1: Create Database
PRINT 'Step 1/4: Creating Database...'
:r 01_CreateDatabase.sql
PRINT ''

-- Step 2: Create Tables
PRINT 'Step 2/4: Creating Tables...'
:r 02_CreateTables.sql
PRINT ''

-- Step 3: Seed Data
PRINT 'Step 3/4: Seeding Data...'
:r 03_SeedData.sql
PRINT ''

-- Step 4: Create Stored Procedures
PRINT 'Step 4/4: Creating Stored Procedures...'
:r 04_StoredProcedures.sql
PRINT ''

PRINT '=========================================='
PRINT 'CandleFantasyDb Setup Complete!'
PRINT '=========================================='
PRINT ''
PRINT 'Database: CandleFantasyDb'
PRINT 'Tables: Users, Products, Orders, OrderItems, Reviews, Messages'
PRINT 'Stored Procedures: 20+ procedures for all API operations'
PRINT ''
PRINT 'You can now run the CandleApi application.'
PRINT '=========================================='

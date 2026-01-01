@echo off
REM =============================================
REM Script: SetupDatabase.bat
REM Description: Batch file to setup the database
REM =============================================

echo ==========================================
echo CandleFantasyDb Database Setup
echo ==========================================
echo.

REM Check if sqlcmd is available
where sqlcmd >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: sqlcmd not found. Please install SQL Server Command Line Utilities.
    echo Download from: https://docs.microsoft.com/en-us/sql/tools/sqlcmd-utility
    pause
    exit /b 1
)

echo This will create/update the CandleFantasyDb database.
echo.
set /p CONFIRM="Continue? (Y/N): "
if /i not "%CONFIRM%"=="Y" (
    echo Setup cancelled.
    pause
    exit /b 0
)

echo.
echo Executing setup scripts...
echo.

REM Execute the master setup script
sqlcmd -S localhost -E -i "00_MasterSetup.sql"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ==========================================
    echo Database setup completed successfully!
    echo ==========================================
) else (
    echo.
    echo ==========================================
    echo ERROR: Database setup failed!
    echo ==========================================
)

echo.
pause

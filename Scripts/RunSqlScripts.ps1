# =============================================
# Script: RunSqlScripts.ps1
# Description: PowerShell script to execute SQL scripts
# Usage: .\RunSqlScripts.ps1 -ScriptName "00_MasterSetup.sql"
# =============================================

param(
    [Parameter(Mandatory=$false)]
    [string]$ScriptName = "00_MasterSetup.sql",
    
    [Parameter(Mandatory=$false)]
    [string]$ServerName = "localhost",
    
    [Parameter(Mandatory=$false)]
    [string]$DatabaseName = "CandleFantasyDb",
    
    [Parameter(Mandatory=$false)]
    [switch]$UseWindowsAuth = $true
)

# Get the script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SqlScriptPath = Join-Path $ScriptDir $ScriptName

# Check if script exists
if (-not (Test-Path $SqlScriptPath)) {
    Write-Host "Error: Script file not found: $SqlScriptPath" -ForegroundColor Red
    exit 1
}

Write-Host "=========================================="
Write-Host "SQL Script Executor"
Write-Host "=========================================="
Write-Host "Server: $ServerName"
Write-Host "Database: $DatabaseName"
Write-Host "Script: $ScriptName"
Write-Host "Authentication: $(if ($UseWindowsAuth) { 'Windows' } else { 'SQL Server' })"
Write-Host "=========================================="
Write-Host ""

# Build sqlcmd command
$sqlcmdArgs = @(
    "-S", $ServerName,
    "-i", "`"$SqlScriptPath`""
)

if ($UseWindowsAuth) {
    $sqlcmdArgs += "-E"
} else {
    $username = Read-Host "Enter SQL Server username"
    $password = Read-Host "Enter SQL Server password" -AsSecureString
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
    $plainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    $sqlcmdArgs += @("-U", $username, "-P", $plainPassword)
}

# Execute the script
try {
    Write-Host "Executing script..." -ForegroundColor Yellow
    Write-Host ""
    
    & sqlcmd @sqlcmdArgs
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "=========================================="
        Write-Host "Script executed successfully!" -ForegroundColor Green
        Write-Host "=========================================="
    } else {
        Write-Host ""
        Write-Host "=========================================="
        Write-Host "Script execution failed with exit code: $LASTEXITCODE" -ForegroundColor Red
        Write-Host "=========================================="
        exit $LASTEXITCODE
    }
} catch {
    Write-Host ""
    Write-Host "=========================================="
    Write-Host "Error executing script: $_" -ForegroundColor Red
    Write-Host "=========================================="
    exit 1
}

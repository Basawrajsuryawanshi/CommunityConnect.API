# ============================================
# User Database Setup Script
# This script automates the database initialization
# ============================================

param(
	[string]$ServerInstance = "(localdb)\MSSQLLocalDB",
	[switch]$Force
)

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "User Database Setup" -ForegroundColor Cyan
Write-Host "============================================`n" -ForegroundColor Cyan

# Function to check if LocalDB is running
function Test-LocalDBRunning {
	try {
		$info = & SqlLocalDB.exe info MSSQLLocalDB 2>&1
		return $info -match "State:\s+Running"
	}
	catch {
		return $false
	}
}

# Function to start LocalDB
function Start-LocalDBInstance {
	Write-Host "Starting LocalDB instance..." -ForegroundColor Yellow
	try {
		& SqlLocalDB.exe start MSSQLLocalDB | Out-Null
		Start-Sleep -Seconds 3

		if (Test-LocalDBRunning) {
			Write-Host "✓ LocalDB started successfully" -ForegroundColor Green
			return $true
		}
		else {
			Write-Host "✗ Failed to start LocalDB" -ForegroundColor Red
			return $false
		}
	}
	catch {
		Write-Host "✗ Error starting LocalDB: $_" -ForegroundColor Red
		return $false
	}
}

# Check if LocalDB is installed
Write-Host "Checking LocalDB installation..." -ForegroundColor Yellow
try {
	$localDBInfo = & SqlLocalDB.exe v 2>&1
	if ($LASTEXITCODE -eq 0) {
		Write-Host "✓ LocalDB is installed" -ForegroundColor Green
	}
	else {
		Write-Host "✗ LocalDB is not installed. Please install SQL Server LocalDB." -ForegroundColor Red
		exit 1
	}
}
catch {
	Write-Host "✗ LocalDB is not installed or not in PATH" -ForegroundColor Red
	exit 1
}

# Check if LocalDB is running
Write-Host "Checking LocalDB status..." -ForegroundColor Yellow
if (Test-LocalDBRunning) {
	Write-Host "✓ LocalDB is running" -ForegroundColor Green
}
else {
	Write-Host "LocalDB is not running" -ForegroundColor Yellow
	if (-not (Start-LocalDBInstance)) {
		exit 1
	}
}

# Set script paths
$scriptRoot = $PSScriptRoot
$projectRoot = Split-Path (Split-Path $scriptRoot -Parent) -Parent
$initScript = Join-Path $scriptRoot "InitializeDatabase.sql"

# Verify script files exist
Write-Host "`nVerifying script files..." -ForegroundColor Yellow
if (-not (Test-Path $initScript)) {
	Write-Host "✗ InitializeDatabase.sql not found at: $initScript" -ForegroundColor Red
	exit 1
}
Write-Host "✓ Script files found" -ForegroundColor Green

# Check if database exists
Write-Host "`nChecking if database exists..." -ForegroundColor Yellow
$dbCheckQuery = "SELECT DB_ID('UserDB') AS DbId"
try {
	$result = Invoke-Sqlcmd -ServerInstance $ServerInstance -Query $dbCheckQuery -ErrorAction Stop
	$dbExists = $null -ne $result.DbId

	if ($dbExists) {
		Write-Host "✓ Database UserDB exists" -ForegroundColor Green

		if ($Force) {
			Write-Host "`nForce flag is set. Dropping existing database..." -ForegroundColor Yellow
			$dropQuery = @"
ALTER DATABASE UserDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE UserDB;
"@
			Invoke-Sqlcmd -ServerInstance $ServerInstance -Query $dropQuery -ErrorAction Stop
			Write-Host "✓ Database dropped successfully" -ForegroundColor Green
			$dbExists = $false
		}
		else {
			Write-Host "Database already exists. Use -Force to recreate it." -ForegroundColor Yellow
		}
	}
	else {
		Write-Host "Database does not exist. Creating..." -ForegroundColor Yellow
	}
}
catch {
	Write-Host "✗ Error checking database: $_" -ForegroundColor Red
	exit 1
}

# Execute initialization script
if (-not $dbExists -or $Force) {
	Write-Host "`nExecuting InitializeDatabase.sql..." -ForegroundColor Yellow
	try {
		Invoke-Sqlcmd -ServerInstance $ServerInstance -InputFile $initScript -ErrorAction Stop
		Write-Host "✓ Database initialized successfully" -ForegroundColor Green
	}
	catch {
		Write-Host "✗ Error initializing database: $_" -ForegroundColor Red
		Write-Host $_.Exception.Message -ForegroundColor Red
		exit 1
	}
}

# Deploy stored procedures
Write-Host "`nDeploying stored procedures..." -ForegroundColor Yellow
$spScriptPath = Join-Path $scriptRoot "DeployStoredProcedures.ps1"
if (Test-Path $spScriptPath) {
	try {
		& $spScriptPath -ServerName $ServerInstance -DatabaseName "UserDB"
		Write-Host "✓ Stored procedures deployed successfully" -ForegroundColor Green
	}
	catch {
		Write-Host "✗ Error deploying stored procedures: $_" -ForegroundColor Red
		Write-Host $_.Exception.Message -ForegroundColor Red
		exit 1
	}
}
else {
	Write-Host "⚠ DeployStoredProcedures.ps1 not found. Skipping stored procedure deployment." -ForegroundColor Yellow
}

# Summary
Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "Setup completed successfully!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Database: UserDB" -ForegroundColor Gray
Write-Host "Server: $ServerInstance" -ForegroundColor Gray
Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "1. Update connection string in appsettings.json" -ForegroundColor Gray
Write-Host "   `"UserDb`": `"Server=$ServerInstance;Database=UserDB;Integrated Security=True;TrustServerCertificate=True;`"" -ForegroundColor Gray
Write-Host "2. Run the User.API project" -ForegroundColor Gray
Write-Host "============================================`n" -ForegroundColor Cyan

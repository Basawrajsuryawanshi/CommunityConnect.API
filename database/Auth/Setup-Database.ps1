# ============================================
# Auth Database Setup Script
# This script automates the database initialization
# ============================================

param(
	[string]$ServerInstance = "(localdb)\MSSQLLocalDB",
	[switch]$Force
)

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Auth Database Setup" -ForegroundColor Cyan
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
$spScript = Join-Path $scriptRoot "StoredProcedures.sql"

# Verify script files exist
Write-Host "`nVerifying script files..." -ForegroundColor Yellow
if (-not (Test-Path $initScript)) {
	Write-Host "✗ InitializeDatabase.sql not found at: $initScript" -ForegroundColor Red
	exit 1
}
if (-not (Test-Path $spScript)) {
	Write-Host "✗ StoredProcedures.sql not found at: $spScript" -ForegroundColor Red
	exit 1
}
Write-Host "✓ Script files found" -ForegroundColor Green

# Check if database exists
Write-Host "`nChecking if database exists..." -ForegroundColor Yellow
$dbCheckQuery = "SELECT DB_ID('CommunityConnect_AuthDB') AS DbId"
try {
	$result = Invoke-Sqlcmd -ServerInstance $ServerInstance -Query $dbCheckQuery -ErrorAction Stop
	$dbExists = $null -ne $result.DbId

	if ($dbExists) {
		if ($Force) {
			Write-Host "Database exists. Force flag set - will drop and recreate." -ForegroundColor Yellow
			$dropQuery = "USE master; ALTER DATABASE CommunityConnect_AuthDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE CommunityConnect_AuthDB;"
			Invoke-Sqlcmd -ServerInstance $ServerInstance -Query $dropQuery -ErrorAction Stop
			Write-Host "✓ Existing database dropped" -ForegroundColor Green
		}
		else {
			Write-Host "✗ Database already exists. Use -Force to drop and recreate." -ForegroundColor Red
			Write-Host "Or run the scripts manually if you want to update existing database." -ForegroundColor Yellow
			exit 1
		}
	}
	else {
		Write-Host "Database does not exist - will create new one." -ForegroundColor Yellow
	}
}
catch {
	Write-Host "Could not check database existence: $_" -ForegroundColor Yellow
	Write-Host "Proceeding with database creation..." -ForegroundColor Yellow
}

# Execute InitializeDatabase.sql
Write-Host "`nCreating database and tables..." -ForegroundColor Yellow
try {
	Invoke-Sqlcmd -ServerInstance $ServerInstance -InputFile $initScript -ErrorAction Stop
	Write-Host "✓ Database and tables created successfully" -ForegroundColor Green
}
catch {
	Write-Host "✗ Error creating database: $_" -ForegroundColor Red
	exit 1
}

# Execute StoredProcedures.sql
Write-Host "`nCreating stored procedures..." -ForegroundColor Yellow
try {
	Invoke-Sqlcmd -ServerInstance $ServerInstance -InputFile $spScript -ErrorAction Stop
	Write-Host "✓ Stored procedures created successfully" -ForegroundColor Green
}
catch {
	Write-Host "✗ Error creating stored procedures: $_" -ForegroundColor Red
	exit 1
}

# Verify installation
Write-Host "`nVerifying installation..." -ForegroundColor Yellow
try {
	$tableQuery = "USE CommunityConnect_AuthDB; SELECT COUNT(*) AS TableCount FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';"
	$spQuery = "USE CommunityConnect_AuthDB; SELECT COUNT(*) AS SPCount FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE';"

	$tableCount = (Invoke-Sqlcmd -ServerInstance $ServerInstance -Query $tableQuery -ErrorAction Stop).TableCount
	$spCount = (Invoke-Sqlcmd -ServerInstance $ServerInstance -Query $spQuery -ErrorAction Stop).SPCount

	Write-Host "  Tables created: $tableCount (expected: 3)" -ForegroundColor Cyan
	Write-Host "  Stored procedures created: $spCount (expected: 15)" -ForegroundColor Cyan

	if ($tableCount -eq 3 -and $spCount -eq 15) {
		Write-Host "[OK] Installation verified successfully" -ForegroundColor Green
	}
	else {
		Write-Host "[Warning] Expected counts dont match. Please verify manually." -ForegroundColor Yellow
	}
}
catch {
	Write-Host "[Error] Error verifying installation: $_" -ForegroundColor Red
}

# Display connection string
Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "Setup completed successfully!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "`nConnection String:" -ForegroundColor Yellow
Write-Host "Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=CommunityConnect_AuthDB;Integrated Security=True;Persist Security Info=False;Pooling=False;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Command Timeout=0" -ForegroundColor White

Write-Host "`nNext Steps:" -ForegroundColor Yellow
Write-Host "1. Open the Auth.API project in Visual Studio" -ForegroundColor White
Write-Host "2. Ensure the connection string in appsettings.json matches the one above" -ForegroundColor White
Write-Host "3. Run the Auth.API project (F5)" -ForegroundColor White
Write-Host "4. Navigate to https://localhost:5001/swagger" -ForegroundColor White
Write-Host "5. Test the /api/auth/register endpoint" -ForegroundColor White

Write-Host "`nTest Registration:" -ForegroundColor Yellow
Write-Host "POST /api/auth/register" -ForegroundColor White
Write-Host '{' -ForegroundColor White
Write-Host '  "email": "test@example.com",' -ForegroundColor White
Write-Host '  "password": "Test@1234"' -ForegroundColor White
Write-Host '}' -ForegroundColor White

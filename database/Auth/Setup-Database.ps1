# ============================================
# Auth Database Setup Script
# This script automates the complete database setup including:
# - Database creation
# - Tables deployment (8 tables)
# - Stored procedures deployment (34 procedures)
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
$tablesFolder = Join-Path $scriptRoot "Tables"
$spDeployScript = Join-Path $scriptRoot "DeployStoredProcedures.ps1"

# Verify script files exist
Write-Host "`nVerifying script files..." -ForegroundColor Yellow
if (-not (Test-Path $initScript)) {
	Write-Host "✗ InitializeDatabase.sql not found at: $initScript" -ForegroundColor Red
	exit 1
}
if (-not (Test-Path $tablesFolder)) {
	Write-Host "✗ Tables folder not found at: $tablesFolder" -ForegroundColor Red
	exit 1
}
if (-not (Test-Path $spDeployScript)) {
	Write-Host "✗ DeployStoredProcedures.ps1 not found at: $spDeployScript" -ForegroundColor Red
	exit 1
}
Write-Host "✓ Script files found" -ForegroundColor Green

# Check if database exists
Write-Host "`nChecking if database exists..." -ForegroundColor Yellow
$dbCheckQuery = "SELECT DB_ID('AuthDB') AS DbId"
try {
	$result = Invoke-Sqlcmd -ServerInstance $ServerInstance -Query $dbCheckQuery -ErrorAction Stop
	$dbExists = $null -ne $result.DbId

	if ($dbExists) {
		if ($Force) {
			Write-Host "Database exists. Force flag set - will drop and recreate." -ForegroundColor Yellow
			$dropQuery = "USE master; ALTER DATABASE AuthDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE AuthDB;"
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
Write-Host "`nCreating database..." -ForegroundColor Yellow
try {
	Invoke-Sqlcmd -ServerInstance $ServerInstance -InputFile $initScript -ErrorAction Stop
	Write-Host "✓ Database created successfully" -ForegroundColor Green
}
catch {
	Write-Host "✗ Error creating database: $_" -ForegroundColor Red
	exit 1
}

# Deploy tables in order
Write-Host "`nDeploying tables..." -ForegroundColor Yellow
$tableOrder = @(
	'Users.sql',
	'RefreshTokens.sql',
	'OAuthProviders.sql',
	'UserProfiles.sql',
	'Roles.sql',
	'UserRoleAssignments.sql',
	'UserPreferences.sql',
	'UserConnections.sql'
)

$tableSuccess = 0
$tableFailed = 0

foreach ($tableName in $tableOrder) {
	$tablePath = Join-Path $tablesFolder $tableName
	try {
		Invoke-Sqlcmd -ServerInstance $ServerInstance -InputFile $tablePath -ErrorAction Stop
		Write-Host "  ✓ $tableName deployed" -ForegroundColor Green
		$tableSuccess++
	}
	catch {
		Write-Host "  ✗ $tableName failed: $_" -ForegroundColor Red
		$tableFailed++
	}
}

if ($tableFailed -gt 0) {
	Write-Host "✗ Some tables failed to deploy" -ForegroundColor Red
	exit 1
}
Write-Host "✓ All tables deployed successfully ($tableSuccess tables)" -ForegroundColor Green

# Execute DeployStoredProcedures.ps1
Write-Host "`nDeploying stored procedures..." -ForegroundColor Yellow
try {
	& $spDeployScript -ServerInstance $ServerInstance -Database "AuthDB"
	Write-Host "✓ Stored procedures deployment completed" -ForegroundColor Green
}
catch {
	Write-Host "✗ Error deploying stored procedures: $_" -ForegroundColor Red
	exit 1
}

# Verify installation
Write-Host "`nVerifying installation..." -ForegroundColor Yellow
try {
	$tableQuery = "SELECT COUNT(*) AS TableCount FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';"
	$spQuery = "SELECT COUNT(*) AS SPCount FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE';"

	$tableCount = (Invoke-Sqlcmd -ServerInstance $ServerInstance -Database "AuthDB" -Query $tableQuery -ErrorAction Stop).TableCount
	$spCount = (Invoke-Sqlcmd -ServerInstance $ServerInstance -Database "AuthDB" -Query $spQuery -ErrorAction Stop).SPCount

	Write-Host "  Tables created: $tableCount (expected: 8)" -ForegroundColor Cyan
	Write-Host "  Stored procedures created: $spCount (expected: 37)" -ForegroundColor Cyan

	if ($tableCount -eq 8 -and $spCount -eq 37) {
		Write-Host "✓ Installation verified successfully" -ForegroundColor Green
	}
	else {
		Write-Host "⚠ Expected counts don't match. Please verify manually." -ForegroundColor Yellow
	}
}
catch {
	Write-Host "✗ Error verifying installation: $_" -ForegroundColor Red
}

# Display connection string
Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "Setup completed successfully!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "`nConnection String:" -ForegroundColor Yellow
Write-Host "Data Source=$ServerInstance;Initial Catalog=AuthDB;Integrated Security=True;TrustServerCertificate=True" -ForegroundColor White

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

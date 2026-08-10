# Deploy User Database Stored Procedures
# Usage: .\DeployStoredProcedures.ps1 -ServerName "localhost" -DatabaseName "UserDB"

param(
	[Parameter(Mandatory=$false)]
	[string]$ServerName = "localhost",

	[Parameter(Mandatory=$false)]
	[string]$DatabaseName = "UserDB",

	[Parameter(Mandatory=$false)]
	[bool]$IntegratedSecurity = $true
)

$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$StoredProceduresPath = Join-Path $ScriptPath "StoredProcedures"

# Connection string
if ($IntegratedSecurity) {
	$ConnectionString = "Server=$ServerName;Database=$DatabaseName;Integrated Security=True;TrustServerCertificate=True;"
} else {
	$ConnectionString = "Server=$ServerName;Database=$DatabaseName;User Id=$Username;Password=$Password;TrustServerCertificate=True;"
}

Write-Host "Deploying User DB Stored Procedures..." -ForegroundColor Green
Write-Host "Server: $ServerName" -ForegroundColor Gray
Write-Host "Database: $DatabaseName" -ForegroundColor Gray
Write-Host ""

# Function to execute SQL file
function Execute-SqlFile {
	param (
		[string]$FilePath
	)

	$FileName = Split-Path $FilePath -Leaf
	Write-Host "  Executing: $FileName" -ForegroundColor Cyan

	try {
		$SqlContent = Get-Content $FilePath -Raw
		Invoke-Sqlcmd -ConnectionString $ConnectionString -Query $SqlContent -ErrorAction Stop
		Write-Host "  ✓ Success" -ForegroundColor Green
	}
	catch {
		Write-Host "  ✗ Error: $_" -ForegroundColor Red
		throw
	}
}

# Deploy UserProfiles stored procedures
Write-Host "Deploying UserProfiles procedures..." -ForegroundColor Yellow
$UserProfilesPath = Join-Path $StoredProceduresPath "UserProfiles"
Get-ChildItem -Path $UserProfilesPath -Filter "*.sql" | ForEach-Object {
	Execute-SqlFile $_.FullName
}

# Deploy Roles stored procedures
Write-Host "`nDeploying Roles procedures..." -ForegroundColor Yellow
$RolesPath = Join-Path $StoredProceduresPath "Roles"
Get-ChildItem -Path $RolesPath -Filter "*.sql" | ForEach-Object {
	Execute-SqlFile $_.FullName
}

# Deploy UserPreferences stored procedures
Write-Host "`nDeploying UserPreferences procedures..." -ForegroundColor Yellow
$PreferencesPath = Join-Path $StoredProceduresPath "UserPreferences"
Get-ChildItem -Path $PreferencesPath -Filter "*.sql" | ForEach-Object {
	Execute-SqlFile $_.FullName
}

# Deploy UserConnections stored procedures
Write-Host "`nDeploying UserConnections procedures..." -ForegroundColor Yellow
$ConnectionsPath = Join-Path $StoredProceduresPath "UserConnections"
Get-ChildItem -Path $ConnectionsPath -Filter "*.sql" | ForEach-Object {
	Execute-SqlFile $_.FullName
}

Write-Host "`n✓ All stored procedures deployed successfully!" -ForegroundColor Green

# ============================================
# CommunityConnect Auth Database - Stored Procedures Deployment Script
# PowerShell script to deploy all stored procedures from individual files
# ============================================

param(
	[Parameter(Mandatory=$false)]
	[string]$ServerInstance = "localhost",

	[Parameter(Mandatory=$false)]
	[string]$Database = "AuthDB",

	[Parameter(Mandatory=$false)]
	[switch]$UseTrustedConnection = $true
)

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Auth Database Stored Procedures Deployment" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Server: $ServerInstance" -ForegroundColor Yellow
Write-Host "Database: $Database" -ForegroundColor Yellow
Write-Host ""

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$errorCount = 0
$successCount = 0

function Execute-SqlFile {
	param(
		[string]$FilePath,
		[string]$ProcedureName
	)

	try {
		$fullPath = Join-Path $scriptPath $FilePath

		if (-not (Test-Path $fullPath)) {
			Write-Host "  ✗ $ProcedureName - File not found: $fullPath" -ForegroundColor Red
			return $false
		}

		$sqlContent = Get-Content $fullPath -Raw

		if ($UseTrustedConnection) {
			Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $Database -Query $sqlContent -ErrorAction Stop
		} else {
			Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $Database -Query $sqlContent -ErrorAction Stop
		}

		Write-Host "  ✓ $ProcedureName deployed" -ForegroundColor Green
		return $true
	}
	catch {
		Write-Host "  ✗ $ProcedureName - Error: $($_.Exception.Message)" -ForegroundColor Red
		return $false
	}
}

# ============================================
# USER STORED PROCEDURES (8 procedures)
# ============================================
Write-Host "Deploying User stored procedures..." -ForegroundColor Cyan

$userProcs = @(
	@{Path="StoredProcedures\Users\sp_CreateUser.sql"; Name="sp_CreateUser"},
	@{Path="StoredProcedures\Users\sp_GetUserByEmail.sql"; Name="sp_GetUserByEmail"},
	@{Path="StoredProcedures\Users\sp_GetUserById.sql"; Name="sp_GetUserById"},
	@{Path="StoredProcedures\Users\sp_UpdateLastLogin.sql"; Name="sp_UpdateLastLogin"},
	@{Path="StoredProcedures\Users\sp_VerifyEmail.sql"; Name="sp_VerifyEmail"},
	@{Path="StoredProcedures\Users\sp_UpdatePassword.sql"; Name="sp_UpdatePassword"},
	@{Path="StoredProcedures\Users\sp_SetPasswordResetToken.sql"; Name="sp_SetPasswordResetToken"},
	@{Path="StoredProcedures\Users\sp_DeleteUser.sql"; Name="sp_DeleteUser"}
)

foreach ($proc in $userProcs) {
	if (Execute-SqlFile -FilePath $proc.Path -ProcedureName $proc.Name) {
		$successCount++
	} else {
		$errorCount++
	}
}

Write-Host ""

# ============================================
# REFRESH TOKEN STORED PROCEDURES (4 procedures)
# ============================================
Write-Host "Deploying RefreshToken stored procedures..." -ForegroundColor Cyan

$tokenProcs = @(
	@{Path="StoredProcedures\RefreshTokens\sp_CreateRefreshToken.sql"; Name="sp_CreateRefreshToken"},
	@{Path="StoredProcedures\RefreshTokens\sp_GetRefreshToken.sql"; Name="sp_GetRefreshToken"},
	@{Path="StoredProcedures\RefreshTokens\sp_RevokeRefreshToken.sql"; Name="sp_RevokeRefreshToken"},
	@{Path="StoredProcedures\RefreshTokens\sp_RevokeAllUserTokens.sql"; Name="sp_RevokeAllUserTokens"}
)

foreach ($proc in $tokenProcs) {
	if (Execute-SqlFile -FilePath $proc.Path -ProcedureName $proc.Name) {
		$successCount++
	} else {
		$errorCount++
	}
}

Write-Host ""

# ============================================
# OAUTH PROVIDER STORED PROCEDURES (3 procedures)
# ============================================
Write-Host "Deploying OAuth stored procedures..." -ForegroundColor Cyan

$oauthProcs = @(
	@{Path="StoredProcedures\OAuth\sp_UpsertOAuthProvider.sql"; Name="sp_UpsertOAuthProvider"},
	@{Path="StoredProcedures\OAuth\sp_GetOAuthProvider.sql"; Name="sp_GetOAuthProvider"},
	@{Path="StoredProcedures\OAuth\sp_GetUserByOAuthProvider.sql"; Name="sp_GetUserByOAuthProvider"}
)

foreach ($proc in $oauthProcs) {
	if (Execute-SqlFile -FilePath $proc.Path -ProcedureName $proc.Name) {
		$successCount++
	} else {
		$errorCount++
	}
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Deployment Summary" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Total procedures: 15" -ForegroundColor Yellow
Write-Host "Successfully deployed: $successCount" -ForegroundColor Green
Write-Host "Failed: $errorCount" -ForegroundColor $(if ($errorCount -gt 0) { "Red" } else { "Green" })
Write-Host "============================================" -ForegroundColor Cyan

if ($errorCount -gt 0) {
	Write-Host ""
	Write-Host "⚠ Some procedures failed to deploy. Please review the errors above." -ForegroundColor Yellow
	exit 1
} else {
	Write-Host ""
	Write-Host "✓ All stored procedures deployed successfully!" -ForegroundColor Green
	exit 0
}

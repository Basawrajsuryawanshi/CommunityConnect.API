# Auth Database Stored Procedures

This directory contains all stored procedures for the Auth service, organized by functional category.

## Directory Structure

```
StoredProcedures/
├── Users/                  # User management stored procedures (8 files)
│   ├── sp_CreateUser.sql
│   ├── sp_GetUserByEmail.sql
│   ├── sp_GetUserById.sql
│   ├── sp_UpdateLastLogin.sql
│   ├── sp_VerifyEmail.sql
│   ├── sp_UpdatePassword.sql
│   ├── sp_SetPasswordResetToken.sql
│   └── sp_DeleteUser.sql
│
├── RefreshTokens/          # Refresh token management stored procedures (4 files)
│   ├── sp_CreateRefreshToken.sql
│   ├── sp_GetRefreshToken.sql
│   ├── sp_RevokeRefreshToken.sql
│   └── sp_RevokeAllUserTokens.sql
│
└── OAuth/                  # OAuth provider stored procedures (3 files)
	├── sp_UpsertOAuthProvider.sql
	├── sp_GetOAuthProvider.sql
	└── sp_GetUserByOAuthProvider.sql
```

## Deployment

### Option 1: PowerShell Script (Recommended for Visual Studio)
Use the PowerShell deployment script from the `database\Auth\` directory:

```powershell
# Deploy to local SQL Server with default settings
.\DeployStoredProcedures.ps1

# Deploy to specific server
.\DeployStoredProcedures.ps1 -ServerInstance "your-server" -Database "AuthDB"
```

**Note:** Requires `SqlServer` PowerShell module. Install with:
```powershell
Install-Module -Name SqlServer -Scope CurrentUser
```

### Option 2: SQLCMD Mode (SQL Server Management Studio)
Use the SQL deployment script in SQLCMD mode:

1. Open `DeployStoredProcedures.sql` in SSMS
2. Enable **Query Menu → SQLCMD Mode**
3. Execute the script

Or via command line:
```bash
sqlcmd -S <server> -d AuthDB -i DeployStoredProcedures.sql
```

### Option 3: Deploy Individual Stored Procedure
Navigate to the specific category folder and run individual files:

```powershell
# Using PowerShell with Invoke-Sqlcmd
Invoke-Sqlcmd -ServerInstance "localhost" -Database "AuthDB" -InputFile "StoredProcedures\Users\sp_CreateUser.sql"

# Using sqlcmd
sqlcmd -S localhost -d AuthDB -i StoredProcedures\Users\sp_CreateUser.sql
```

### Option 4: Deploy by Category
Deploy all stored procedures in a specific category:

```powershell
# PowerShell - Deploy all User procedures
Get-ChildItem "StoredProcedures\Users\*.sql" | ForEach-Object {
    Invoke-Sqlcmd -ServerInstance "localhost" -Database "AuthDB" -InputFile $_.FullName
}

# PowerShell - Deploy all RefreshToken procedures
Get-ChildItem "StoredProcedures\RefreshTokens\*.sql" | ForEach-Object {
    Invoke-Sqlcmd -ServerInstance "localhost" -Database "AuthDB" -InputFile $_.FullName
}

# PowerShell - Deploy all OAuth procedures
Get-ChildItem "StoredProcedures\OAuth\*.sql" | ForEach-Object {
    Invoke-Sqlcmd -ServerInstance "localhost" -Database "AuthDB" -InputFile $_.FullName
}
```

## Stored Procedures Overview

### User Stored Procedures
- **sp_CreateUser** - Creates a new user with email and password
- **sp_GetUserByEmail** - Retrieves user information by email address
- **sp_GetUserById** - Retrieves user information by user ID
- **sp_UpdateLastLogin** - Updates the last login timestamp for a user
- **sp_VerifyEmail** - Verifies a user's email using verification token
- **sp_UpdatePassword** - Updates user password and clears reset tokens
- **sp_SetPasswordResetToken** - Sets a password reset token with expiry
- **sp_DeleteUser** - Soft deletes a user (sets IsDeleted flag)

### Refresh Token Stored Procedures
- **sp_CreateRefreshToken** - Creates a new refresh token for a user
- **sp_GetRefreshToken** - Retrieves refresh token information by token value
- **sp_RevokeRefreshToken** - Revokes a specific refresh token
- **sp_RevokeAllUserTokens** - Revokes all refresh tokens for a specific user

### OAuth Stored Procedures
- **sp_UpsertOAuthProvider** - Creates or updates an OAuth provider connection
- **sp_GetOAuthProvider** - Retrieves OAuth provider by provider name and provider user ID
- **sp_GetUserByOAuthProvider** - Retrieves user information via OAuth provider credentials

## Benefits of Individual Files

1. **Version Control** - Each stored procedure change is tracked independently
2. **Easier Code Review** - Smaller, focused files are easier to review
3. **Selective Deployment** - Deploy only the procedures that changed
4. **Better Organization** - Logical grouping by functionality
5. **Reduced Merge Conflicts** - Multiple developers can work on different procedures simultaneously
6. **Clear Ownership** - Easy to see what each file does from its name

## Maintenance

When modifying a stored procedure:
1. Edit the individual .sql file in the appropriate category folder
2. Test the changes thoroughly
3. Deploy using the master script or individual file
4. Commit only the changed file(s) to version control

## Migration Note

The original monolithic `StoredProcedures.sql` file has been split into individual files. If you need to reference the original file, it is still available but should no longer be used for deployments.

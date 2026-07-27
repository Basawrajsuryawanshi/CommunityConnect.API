# Auth Database Setup Guide

## Overview
This guide will help you set up the CommunityConnect Auth database with LocalDB and stored procedures.

## Prerequisites
- SQL Server LocalDB installed (comes with Visual Studio)
- SQL Server Management Studio (SSMS) or Azure Data Studio (optional but recommended)

## Connection String
```
Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=CommunityConnect_AuthDB;Integrated Security=True;Persist Security Info=False;Pooling=False;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Command Timeout=0
```

## Setup Instructions

### Step 1: Verify LocalDB Installation

Open PowerShell and run:
```powershell
SqlLocalDB.exe info
```

If LocalDB is not running, start it:
```powershell
SqlLocalDB.exe start MSSQLLocalDB
```

### Step 2: Initialize Database

#### Option A: Using SQL Server Management Studio (SSMS)
1. Open SSMS
2. Connect to: `(localdb)\MSSQLLocalDB`
3. Open file: `database/Auth/InitializeDatabase.sql`
4. Click **Execute** (F5)

#### Option B: Using sqlcmd (Command Line)
```powershell
sqlcmd -S "(localdb)\MSSQLLocalDB" -i "database\Auth\InitializeDatabase.sql"
```

#### Option C: Using PowerShell
```powershell
cd "C:\S\Apps\CommunityConnect.API\CommunityConnect.API"

Invoke-Sqlcmd -ServerInstance "(localdb)\MSSQLLocalDB" `
			  -InputFile "database\Auth\InitializeDatabase.sql"
```

### Step 3: Create Stored Procedures

#### Option A: Using SSMS
1. In SSMS, ensure you're connected to `(localdb)\MSSQLLocalDB`
2. Open file: `database/Auth/StoredProcedures.sql`
3. Click **Execute** (F5)

#### Option B: Using sqlcmd
```powershell
sqlcmd -S "(localdb)\MSSQLLocalDB" -i "database\Auth\StoredProcedures.sql"
```

#### Option C: Using PowerShell
```powershell
Invoke-Sqlcmd -ServerInstance "(localdb)\MSSQLLocalDB" `
			  -InputFile "database\Auth\StoredProcedures.sql"
```

### Step 4: Verify Installation

Run this query to verify tables and stored procedures:
```sql
USE CommunityConnect_AuthDB;
GO

-- Check tables
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';

-- Check stored procedures
SELECT ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE';
```

Expected tables:
- Users
- RefreshTokens
- OAuthProviders

Expected stored procedures (15 total):
- sp_CreateUser
- sp_GetUserByEmail
- sp_GetUserById
- sp_UpdateLastLogin
- sp_VerifyEmail
- sp_UpdatePassword
- sp_SetPasswordResetToken
- sp_DeleteUser
- sp_CreateRefreshToken
- sp_GetRefreshToken
- sp_RevokeRefreshToken
- sp_RevokeAllUserTokens
- sp_UpsertOAuthProvider
- sp_GetOAuthProvider
- sp_GetUserByOAuthProvider

## Quick Setup Script (PowerShell)

Save this as `setup-database.ps1` and run it:

```powershell
# Start LocalDB
SqlLocalDB.exe start MSSQLLocalDB

# Wait for LocalDB to start
Start-Sleep -Seconds 2

# Set paths
$projectRoot = "C:\S\Apps\CommunityConnect.API\CommunityConnect.API"
$initScript = Join-Path $projectRoot "database\Auth\InitializeDatabase.sql"
$spScript = Join-Path $projectRoot "database\Auth\StoredProcedures.sql"

# Run initialization script
Write-Host "Creating database and tables..." -ForegroundColor Green
sqlcmd -S "(localdb)\MSSQLLocalDB" -i $initScript

# Run stored procedures script
Write-Host "Creating stored procedures..." -ForegroundColor Green
sqlcmd -S "(localdb)\MSSQLLocalDB" -i $spScript

Write-Host "Database setup completed!" -ForegroundColor Green
```

## Testing the Connection

### Test with .NET Application
1. Open the Auth.API project
2. Set it as startup project
3. Run the application (F5)
4. Navigate to Swagger: `https://localhost:5001/swagger`
5. Test the `/api/auth/register` endpoint

### Test Register Endpoint

**POST** `http://localhost:5001/api/register`

Request Body:
```json
{
  "email": "test@example.com",
  "password": "Test@1234"
}
```

Expected Response:
```json
{
  "userId": "guid-here",
  "email": "test@example.com",
  "accessToken": "jwt-token-here",
  "refreshToken": "refresh-token-here",
  "refreshTokenExpiry": "2024-01-15T10:30:00Z"
}
```

## Troubleshooting

### Error: Cannot connect to (localdb)\MSSQLLocalDB
```powershell
# Stop and restart LocalDB
SqlLocalDB.exe stop MSSQLLocalDB
SqlLocalDB.exe delete MSSQLLocalDB
SqlLocalDB.exe create MSSQLLocalDB
SqlLocalDB.exe start MSSQLLocalDB
```

### Error: Database already exists
If you need to recreate the database:
```sql
USE master;
GO
DROP DATABASE CommunityConnect_AuthDB;
GO
-- Then run InitializeDatabase.sql again
```

### Error: Stored procedure not found
Ensure you ran both scripts in order:
1. InitializeDatabase.sql (creates database and tables)
2. StoredProcedures.sql (creates stored procedures)

### View Data
To check if registration worked:
```sql
USE CommunityConnect_AuthDB;
GO

SELECT * FROM Users;
SELECT * FROM RefreshTokens;
```

## Architecture Overview

### Database Interface Pattern
- **IAuthDatabase**: Interface defining all database operations
- **AuthDatabaseService**: Implementation using ADO.NET and stored procedures
- **AuthService**: Business logic layer that uses IAuthDatabase

### Benefits
✅ Direct stored procedure execution
✅ Better performance (no ORM overhead)
✅ Explicit SQL control
✅ Easy to maintain and optimize
✅ One interface per database (clean separation)

### Stored Procedure Flow
```
Registration Request
	↓
AuthController.Register()
	↓
AuthService.RegisterAsync()
	↓
IAuthDatabase.CreateUserAsync()
	↓
AuthDatabaseService.CreateUserAsync()
	↓
SqlCommand → sp_CreateUser
	↓
SQL Server executes stored procedure
	↓
User record created in database
```

## Next Steps

After successful setup:
1. Test register endpoint via Swagger
2. Test login endpoint
3. Verify data in database
4. Add more stored procedures as needed
5. Implement similar pattern for other services (User, Event, etc.)

## Additional Notes

- All stored procedures include error handling
- Email uniqueness is enforced at database level
- Timestamps are stored in UTC
- Soft delete is implemented (IsDeleted flag)
- Refresh tokens support IP tracking
- OAuth providers support multiple platforms

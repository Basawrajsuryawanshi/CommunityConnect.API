# Auth Database Tables

This folder contains all table definitions for the Auth database.

## Tables

### Authentication Tables
1. **Users.sql** - Core user authentication table
   - Stores user credentials and verification tokens
   - Fields: Email, PasswordHash, EmailVerified, etc.

2. **RefreshTokens.sql** - JWT refresh token management
   - Tracks refresh tokens for user sessions
   - Handles token revocation and replacement

3. **OAuthProviders.sql** - OAuth integration
   - Stores OAuth provider connections (Google, Facebook, etc.)
   - Links external provider IDs to internal user accounts

### User Profile & Social Tables
4. **UserProfiles.sql** - User profile information
   - Stores personal details, JNV info, address, and social links
   - Fields: FirstName, LastName, JNV, Batch, etc.
   - References Users(Id)

5. **UserPreferences.sql** - User notification and theme preferences
   - Stores user settings for notifications and UI preferences
   - Fields: EmailNotifications, Theme, Language, etc.

6. **UserConnections.sql** - User connection/friendship management
   - Manages connection requests and relationships between users
   - Supports Pending, Accepted, and Blocked statuses

### Authorization Tables
7. **Roles.sql** - Role definitions
   - Defines available user roles (Admin, Moderator, Member, EventOrganizer)
   - Includes default role seeding

8. **UserRoleAssignments.sql** - User-to-role mapping
   - Links users to their assigned roles
   - Supports role expiration

## Deployment Order

When creating tables, they must be deployed in this order to satisfy foreign key dependencies:

1. Users
2. RefreshTokens
3. OAuthProviders
4. UserProfiles
5. Roles
6. UserRoleAssignments
7. UserPreferences
8. UserConnections

## Usage

To deploy all tables in order:
```powershell
# Run from database\Auth directory
$tableOrder = @('Users.sql', 'RefreshTokens.sql', 'OAuthProviders.sql', 'UserProfiles.sql', 'Roles.sql', 'UserRoleAssignments.sql', 'UserPreferences.sql', 'UserConnections.sql')
foreach ($table in $tableOrder) {
	sqlcmd -S .\SQLEXPRESS -i "Tables\$table"
	Write-Host "Deployed: $table"
}
```

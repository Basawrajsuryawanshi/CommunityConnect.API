# User Database

This folder contains all database scripts for the User service, including table definitions, stored procedures, and setup automation.

## 📁 Folder Structure

```
database/User/
├── InitializeDatabase.sql        # Creates database and tables
├── Setup-Database.ps1             # Automated setup script
├── DeployStoredProcedures.ps1     # Deploy all stored procedures
├── StoredProcedures/
│   ├── UserProfiles/
│   │   ├── sp_CreateUserProfile.sql
│   │   ├── sp_GetUserProfileById.sql
│   │   ├── sp_UpdateUserProfile.sql
│   │   ├── sp_DeleteUserProfile.sql
│   │   ├── sp_SearchUserProfiles.sql
│   │   ├── sp_GetUserProfilesByJNV.sql
│   │   └── sp_GetUserProfilesByBatch.sql
│   ├── Roles/
│   │   ├── sp_GetAllRoles.sql
│   │   ├── sp_AssignUserRole.sql
│   │   ├── sp_RemoveUserRole.sql
│   │   └── sp_GetUserRoles.sql
│   ├── UserPreferences/
│   │   ├── sp_GetUserPreferences.sql
│   │   └── sp_UpsertUserPreferences.sql
│   └── UserConnections/
│       ├── sp_CreateConnectionRequest.sql
│       ├── sp_AcceptConnectionRequest.sql
│       ├── sp_RejectConnectionRequest.sql
│       ├── sp_BlockUserConnection.sql
│       ├── sp_GetUserConnections.sql
│       └── sp_GetPendingConnectionRequests.sql
└── README.md                      # This file
```

## 🗄️ Database Schema

### Tables

#### 1. **UserProfiles**
Stores user profile information and JNV-specific data.

| Column | Type | Description |
|--------|------|-------------|
| Id | UNIQUEIDENTIFIER | Primary key (same as AuthDB Users.Id) |
| FirstName | NVARCHAR(100) | User's first name |
| LastName | NVARCHAR(100) | User's last name |
| DisplayName | NVARCHAR(200) | Display name |
| AvatarUrl | NVARCHAR(500) | Profile picture URL |
| Bio | NVARCHAR(MAX) | Biography |
| DateOfBirth | DATE | Date of birth |
| Gender | NVARCHAR(20) | Gender |
| PhoneNumber | NVARCHAR(20) | Phone number |
| JNV | NVARCHAR(200) | Jawahar Navodaya Vidyalaya name |
| Batch | NVARCHAR(10) | Batch year (e.g., "2015", "2020") |
| StudentId | NVARCHAR(50) | Student ID |
| AddressLine1 | NVARCHAR(255) | Address line 1 |
| AddressLine2 | NVARCHAR(255) | Address line 2 |
| City | NVARCHAR(100) | City |
| State | NVARCHAR(100) | State |
| Country | NVARCHAR(100) | Country |
| PostalCode | NVARCHAR(20) | Postal code |
| LinkedInUrl | NVARCHAR(500) | LinkedIn profile URL |
| TwitterHandle | NVARCHAR(100) | Twitter handle |
| GitHubUsername | NVARCHAR(100) | GitHub username |
| IsProfileComplete | BIT | Profile completion status |
| IsPublic | BIT | Public visibility flag |
| CreatedAt | DATETIME2 | Creation timestamp |
| UpdatedAt | DATETIME2 | Last update timestamp |

**Indexes:**
- IX_UserProfiles_JNV
- IX_UserProfiles_Batch
- IX_UserProfiles_DisplayName

#### 2. **Roles**
Defines available user roles.

| Column | Type | Description |
|--------|------|-------------|
| Id | INT IDENTITY | Primary key |
| Name | NVARCHAR(50) | Role name (unique) |
| Description | NVARCHAR(MAX) | Role description |
| CreatedAt | DATETIME2 | Creation timestamp |

**Default Roles:**
- Admin
- Moderator
- Member
- EventOrganizer

#### 3. **UserRoleAssignments**
Maps users to their assigned roles.

| Column | Type | Description |
|--------|------|-------------|
| Id | INT IDENTITY | Primary key |
| UserId | UNIQUEIDENTIFIER | User ID (FK to UserProfiles) |
| RoleId | INT | Role ID (FK to Roles) |
| AssignedAt | DATETIME2 | Assignment timestamp |
| AssignedBy | UNIQUEIDENTIFIER | User who assigned the role |
| ExpiresAt | DATETIME2 | Expiration date (nullable) |

**Constraints:**
- FK to UserProfiles (CASCADE DELETE)
- FK to Roles (CASCADE DELETE)
- UNIQUE (UserId, RoleId)

#### 4. **UserPreferences**
Stores user notification and UI preferences.

| Column | Type | Description |
|--------|------|-------------|
| Id | INT IDENTITY | Primary key |
| UserId | UNIQUEIDENTIFIER | User ID (FK to UserProfiles, UNIQUE) |
| EmailNotifications | BIT | Email notifications enabled |
| PushNotifications | BIT | Push notifications enabled |
| SmsNotifications | BIT | SMS notifications enabled |
| EventReminders | BIT | Event reminders enabled |
| AnnouncementAlerts | BIT | Announcement alerts enabled |
| DiscussionUpdates | BIT | Discussion updates enabled |
| Theme | NVARCHAR(20) | UI theme (light/dark) |
| Language | NVARCHAR(10) | Language preference |
| CreatedAt | DATETIME2 | Creation timestamp |
| UpdatedAt | DATETIME2 | Last update timestamp |

**Constraints:**
- FK to UserProfiles (CASCADE DELETE)
- UNIQUE (UserId)

#### 5. **UserConnections**
Manages user-to-user connections and friend requests.

| Column | Type | Description |
|--------|------|-------------|
| Id | INT IDENTITY | Primary key |
| UserId | UNIQUEIDENTIFIER | Requesting user ID (FK to UserProfiles) |
| ConnectedUserId | UNIQUEIDENTIFIER | Target user ID (FK to UserProfiles) |
| Status | NVARCHAR(20) | Status: Pending, Accepted, Blocked |
| RequestedAt | DATETIME2 | Request timestamp |
| AcceptedAt | DATETIME2 | Acceptance timestamp (nullable) |

**Constraints:**
- FK to UserProfiles.UserId (CASCADE DELETE)
- FK to UserProfiles.ConnectedUserId (NO ACTION)
- CHECK (UserId != ConnectedUserId)
- UNIQUE (UserId, ConnectedUserId)

**Indexes:**
- IX_UserConnections_UserId
- IX_UserConnections_Status

## 🚀 Quick Setup

### Option 1: Automated Setup (Recommended)

Run the automated setup script:

```powershell
cd C:\S\Apps\CommunityConnect.API\CommunityConnect.API\database\User
.\Setup-Database.ps1
```

**With custom server:**
```powershell
.\Setup-Database.ps1 -ServerInstance "localhost"
```

**Force recreate database:**
```powershell
.\Setup-Database.ps1 -Force
```

This script will:
1. ✓ Check LocalDB installation
2. ✓ Start LocalDB if not running
3. ✓ Create UserDB database
4. ✓ Create all tables with indexes
5. ✓ Insert default roles
6. ✓ Deploy all stored procedures

### Option 2: Manual Setup

1. **Create database and tables:**
```powershell
sqlcmd -S (localdb)\MSSQLLocalDB -i InitializeDatabase.sql
```

2. **Deploy stored procedures:**
```powershell
.\DeployStoredProcedures.ps1
```

## 🔧 Configuration

After setup, update your `appsettings.json`:

```json
{
  "ConnectionStrings": {
	"UserDb": "Server=(localdb)\\MSSQLLocalDB;Database=UserDB;Integrated Security=True;TrustServerCertificate=True;"
  }
}
```

## 📝 Stored Procedures

### UserProfiles (7 procedures)
- **sp_CreateUserProfile** - Create new profile
- **sp_GetUserProfileById** - Get profile by ID
- **sp_UpdateUserProfile** - Update profile
- **sp_DeleteUserProfile** - Delete profile
- **sp_SearchUserProfiles** - Search profiles by name, JNV, or batch
- **sp_GetUserProfilesByJNV** - Get profiles by JNV
- **sp_GetUserProfilesByBatch** - Get profiles by batch year

### Roles (4 procedures)
- **sp_GetAllRoles** - Get all available roles
- **sp_AssignUserRole** - Assign role to user
- **sp_RemoveUserRole** - Remove role from user
- **sp_GetUserRoles** - Get user's roles with expiration info

### UserPreferences (2 procedures)
- **sp_GetUserPreferences** - Get user preferences
- **sp_UpsertUserPreferences** - Create or update preferences

### UserConnections (6 procedures)
- **sp_CreateConnectionRequest** - Send connection request
- **sp_AcceptConnectionRequest** - Accept request
- **sp_RejectConnectionRequest** - Reject/delete request
- **sp_BlockUserConnection** - Block user
- **sp_GetUserConnections** - Get user's connections (with optional status filter)
- **sp_GetPendingConnectionRequests** - Get pending requests for a user

## 🔄 Update Procedures

To update stored procedures after changes:

```powershell
.\DeployStoredProcedures.ps1 -ServerName "(localdb)\MSSQLLocalDB" -DatabaseName "UserDB"
```

## ⚠️ Important Notes

1. **Foreign Key Relationship**: UserProfiles.Id should match AuthDB.Users.Id
2. **Self-referential FK**: UserConnections has special handling to prevent cascade delete issues
3. **Default Values**: Tables have sensible defaults (IsPublic=1, EmailNotifications=1, etc.)
4. **Indexes**: Optimized for common queries (JNV, Batch, DisplayName, Status)

## 🧪 Testing

After setup, verify the database:

```sql
USE UserDB;
GO

-- Check tables
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES;

-- Check stored procedures
SELECT name FROM sys.procedures ORDER BY name;

-- Verify default roles
SELECT * FROM Roles;
```

## 🐛 Troubleshooting

**LocalDB not running:**
```powershell
SqlLocalDB.exe start MSSQLLocalDB
```

**Connection issues:**
- Verify LocalDB is installed: `SqlLocalDB.exe v`
- Check connection string in appsettings.json
- Ensure SQL Server LocalDB is in PATH

**Permission errors:**
- Run PowerShell as Administrator
- Check SQL Server authentication mode

## 📚 Related Documentation

- [User.API Documentation](../../src/Services/User/CommunityConnect.User.API/USER_API_DOCUMENTATION.md)
- [Auth Database Setup](../Auth/README.md)
- [Overall Architecture](../../README.md)

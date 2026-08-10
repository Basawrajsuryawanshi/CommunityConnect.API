-- ============================================
-- User Database Initialization Script
-- This script creates the database and tables for the User service
-- ============================================

USE master;
GO

-- Create database if it doesn't exist
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'UserDB')
BEGIN
	CREATE DATABASE UserDB;
	PRINT 'Database UserDB created successfully.';
END
ELSE
BEGIN
	PRINT 'Database UserDB already exists.';
END
GO

USE UserDB;
GO

-- ============================================
-- USER PROFILES TABLE
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'UserProfiles')
BEGIN
	CREATE TABLE UserProfiles (
		Id UNIQUEIDENTIFIER PRIMARY KEY,
		FirstName NVARCHAR(100) NOT NULL,
		LastName NVARCHAR(100) NOT NULL,
		DisplayName NVARCHAR(200) NULL,
		AvatarUrl NVARCHAR(500) NULL,
		Bio NVARCHAR(MAX) NULL,
		DateOfBirth DATE NULL,
		Gender NVARCHAR(20) NULL,
		PhoneNumber NVARCHAR(20) NULL,

		-- JNV Specific
		JNV NVARCHAR(200) NULL,
		Batch NVARCHAR(10) NULL,
		StudentId NVARCHAR(50) NULL,

		-- Address
		AddressLine1 NVARCHAR(255) NULL,
		AddressLine2 NVARCHAR(255) NULL,
		City NVARCHAR(100) NULL,
		State NVARCHAR(100) NULL,
		Country NVARCHAR(100) NULL,
		PostalCode NVARCHAR(20) NULL,

		-- Social
		LinkedInUrl NVARCHAR(500) NULL,
		TwitterHandle NVARCHAR(100) NULL,
		GitHubUsername NVARCHAR(100) NULL,

		IsProfileComplete BIT NOT NULL DEFAULT 0,
		IsPublic BIT NOT NULL DEFAULT 1,
		CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
		UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE()
	);

	CREATE INDEX IX_UserProfiles_JNV ON UserProfiles(JNV);
	CREATE INDEX IX_UserProfiles_Batch ON UserProfiles(Batch);
	CREATE INDEX IX_UserProfiles_DisplayName ON UserProfiles(DisplayName);

	PRINT 'UserProfiles table created successfully.';
END
ELSE
BEGIN
	PRINT 'UserProfiles table already exists.';
END
GO

-- ============================================
-- ROLES TABLE
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Roles')
BEGIN
	CREATE TABLE Roles (
		Id INT IDENTITY(1,1) PRIMARY KEY,
		Name NVARCHAR(50) NOT NULL UNIQUE,
		Description NVARCHAR(MAX) NULL,
		CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE()
	);

	PRINT 'Roles table created successfully.';
END
ELSE
BEGIN
	PRINT 'Roles table already exists.';
END
GO

-- ============================================
-- USER ROLE ASSIGNMENTS TABLE
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'UserRoleAssignments')
BEGIN
	CREATE TABLE UserRoleAssignments (
		Id INT IDENTITY(1,1) PRIMARY KEY,
		UserId UNIQUEIDENTIFIER NOT NULL,
		RoleId INT NOT NULL,
		AssignedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
		AssignedBy UNIQUEIDENTIFIER NULL,
		ExpiresAt DATETIME2 NULL,

		CONSTRAINT FK_UserRoleAssignments_Users FOREIGN KEY (UserId) 
			REFERENCES UserProfiles(Id) ON DELETE CASCADE,
		CONSTRAINT FK_UserRoleAssignments_Roles FOREIGN KEY (RoleId) 
			REFERENCES Roles(Id) ON DELETE CASCADE,
		CONSTRAINT UQ_UserRoleAssignments_User_Role UNIQUE (UserId, RoleId)
	);

	CREATE INDEX IX_UserRoleAssignments_UserId ON UserRoleAssignments(UserId);

	PRINT 'UserRoleAssignments table created successfully.';
END
ELSE
BEGIN
	PRINT 'UserRoleAssignments table already exists.';
END
GO

-- ============================================
-- USER PREFERENCES TABLE
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'UserPreferences')
BEGIN
	CREATE TABLE UserPreferences (
		Id INT IDENTITY(1,1) PRIMARY KEY,
		UserId UNIQUEIDENTIFIER NOT NULL UNIQUE,
		EmailNotifications BIT NOT NULL DEFAULT 1,
		PushNotifications BIT NOT NULL DEFAULT 1,
		SmsNotifications BIT NOT NULL DEFAULT 0,
		EventReminders BIT NOT NULL DEFAULT 1,
		AnnouncementAlerts BIT NOT NULL DEFAULT 1,
		DiscussionUpdates BIT NOT NULL DEFAULT 1,
		Theme NVARCHAR(20) NOT NULL DEFAULT 'light',
		Language NVARCHAR(10) NOT NULL DEFAULT 'en',
		CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
		UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),

		CONSTRAINT FK_UserPreferences_Users FOREIGN KEY (UserId) 
			REFERENCES UserProfiles(Id) ON DELETE CASCADE
	);

	PRINT 'UserPreferences table created successfully.';
END
ELSE
BEGIN
	PRINT 'UserPreferences table already exists.';
END
GO

-- ============================================
-- USER CONNECTIONS TABLE
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'UserConnections')
BEGIN
	CREATE TABLE UserConnections (
		Id INT IDENTITY(1,1) PRIMARY KEY,
		UserId UNIQUEIDENTIFIER NOT NULL,
		ConnectedUserId UNIQUEIDENTIFIER NOT NULL,
		Status NVARCHAR(20) NOT NULL, -- 'Pending', 'Accepted', 'Blocked'
		RequestedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
		AcceptedAt DATETIME2 NULL,

		CONSTRAINT FK_UserConnections_User FOREIGN KEY (UserId) 
			REFERENCES UserProfiles(Id) ON DELETE CASCADE,
		CONSTRAINT FK_UserConnections_Connected FOREIGN KEY (ConnectedUserId) 
			REFERENCES UserProfiles(Id) ON DELETE NO ACTION,
		CONSTRAINT CHK_UserConnections_NotSelf CHECK (UserId != ConnectedUserId),
		CONSTRAINT UQ_UserConnections_User_Connected UNIQUE (UserId, ConnectedUserId)
	);

	CREATE INDEX IX_UserConnections_UserId ON UserConnections(UserId);
	CREATE INDEX IX_UserConnections_Status ON UserConnections(Status);

	PRINT 'UserConnections table created successfully.';
END
ELSE
BEGIN
	PRINT 'UserConnections table already exists.';
END
GO

-- ============================================
-- INSERT DEFAULT ROLES
-- ============================================
IF NOT EXISTS (SELECT * FROM Roles WHERE Name = 'Admin')
BEGIN
	INSERT INTO Roles (Name, Description) VALUES
		('Admin', 'Administrator with full access'),
		('Moderator', 'Community moderator'),
		('Member', 'Regular community member'),
		('EventOrganizer', 'Can create and manage events');

	PRINT 'Default roles inserted successfully.';
END
ELSE
BEGIN
	PRINT 'Default roles already exist.';
END
GO

PRINT '============================================';
PRINT 'Database initialization completed successfully!';
PRINT 'Database: UserDB';
PRINT 'Tables created: UserProfiles, Roles, UserRoleAssignments, UserPreferences, UserConnections';
PRINT '============================================';
GO

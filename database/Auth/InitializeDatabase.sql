-- ============================================
-- Auth Database Initialization Script
-- This script creates the database and tables for the Auth service
-- ============================================

USE master;
GO

-- Create database if it doesn't exist
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'AuthDB')
BEGIN
	CREATE DATABASE AuthDB;
	PRINT 'Database AuthDB created successfully.';
END
ELSE
BEGIN
	PRINT 'Database AuthDB already exists.';
END
GO

USE AuthDB;
GO

-- ============================================
-- USERS TABLE
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Users')
BEGIN
	CREATE TABLE Users (
		Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
		Email NVARCHAR(255) NOT NULL UNIQUE,
		PasswordHash NVARCHAR(500) NULL,
		EmailVerified BIT NOT NULL DEFAULT 0,
		EmailVerificationToken NVARCHAR(500) NULL,
		EmailVerificationExpiry DATETIME2 NULL,
		PasswordResetToken NVARCHAR(500) NULL,
		PasswordResetExpiry DATETIME2 NULL,
		IsActive BIT NOT NULL DEFAULT 1,
		IsDeleted BIT NOT NULL DEFAULT 0,
		CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
		UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
		LastLoginAt DATETIME2 NULL
	);

	CREATE INDEX IX_Users_Email ON Users(Email);
	CREATE INDEX IX_Users_EmailVerificationToken ON Users(EmailVerificationToken);
	CREATE INDEX IX_Users_PasswordResetToken ON Users(PasswordResetToken);

	PRINT 'Users table created successfully.';
END
ELSE
BEGIN
	PRINT 'Users table already exists.';
END
GO

-- ============================================
-- REFRESH TOKENS TABLE
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'RefreshTokens')
BEGIN
	CREATE TABLE RefreshTokens (
		Id INT IDENTITY(1,1) PRIMARY KEY,
		UserId UNIQUEIDENTIFIER NOT NULL,
		Token NVARCHAR(500) NOT NULL UNIQUE,
		ExpiresAt DATETIME2 NOT NULL,
		CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
		RevokedAt DATETIME2 NULL,
		ReplacedByToken NVARCHAR(500) NULL,
		IsRevoked BIT NOT NULL DEFAULT 0,
		CreatedByIp NVARCHAR(50) NULL,
		RevokedByIp NVARCHAR(50) NULL,

		CONSTRAINT FK_RefreshTokens_Users FOREIGN KEY (UserId) 
			REFERENCES Users(Id) ON DELETE CASCADE
	);

	CREATE INDEX IX_RefreshTokens_Token ON RefreshTokens(Token);
	CREATE INDEX IX_RefreshTokens_UserId ON RefreshTokens(UserId);

	PRINT 'RefreshTokens table created successfully.';
END
ELSE
BEGIN
	PRINT 'RefreshTokens table already exists.';
END
GO

-- ============================================
-- OAUTH PROVIDERS TABLE
-- ============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'OAuthProviders')
BEGIN
	CREATE TABLE OAuthProviders (
		Id INT IDENTITY(1,1) PRIMARY KEY,
		UserId UNIQUEIDENTIFIER NOT NULL,
		Provider NVARCHAR(50) NOT NULL,
		ProviderUserId NVARCHAR(255) NOT NULL,
		AccessToken NVARCHAR(MAX) NULL,
		RefreshToken NVARCHAR(MAX) NULL,
		TokenExpiresAt DATETIME2 NULL,
		CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
		UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),

		CONSTRAINT FK_OAuthProviders_Users FOREIGN KEY (UserId) 
			REFERENCES Users(Id) ON DELETE CASCADE,
		CONSTRAINT UQ_OAuthProviders_Provider_ProviderUserId 
			UNIQUE (Provider, ProviderUserId)
	);

	CREATE INDEX IX_OAuthProviders_Provider_ProviderUserId 
		ON OAuthProviders(Provider, ProviderUserId);
	CREATE INDEX IX_OAuthProviders_UserId ON OAuthProviders(UserId);

	PRINT 'OAuthProviders table created successfully.';
END
ELSE
BEGIN
	PRINT 'OAuthProviders table already exists.';
END
GO

PRINT '============================================';
PRINT 'Database initialization completed successfully!';
PRINT 'Database: AuthDB';
PRINT 'Tables created: Users, RefreshTokens, OAuthProviders';
PRINT '============================================';
GO

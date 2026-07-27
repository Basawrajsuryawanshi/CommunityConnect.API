-- ============================================
-- CommunityConnect Auth Database - Stored Procedures
-- This script creates all stored procedures for the Auth service
-- ============================================

USE AuthDB;
GO

-- Set required options for indexed tables
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- ============================================
-- USER STORED PROCEDURES
-- ============================================

-- sp_CreateUser: Creates a new user
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_CreateUser')
	DROP PROCEDURE sp_CreateUser;
GO

SET QUOTED_IDENTIFIER ON;
GO

CREATE PROCEDURE sp_CreateUser
	@Email NVARCHAR(255),
	@PasswordHash NVARCHAR(500),
	@EmailVerified BIT = 0,
	@EmailVerificationToken NVARCHAR(500) = NULL,
	@EmailVerificationExpiry DATETIME2 = NULL
AS
BEGIN
	SET NOCOUNT ON;
	SET QUOTED_IDENTIFIER ON;

	DECLARE @UserId UNIQUEIDENTIFIER = NEWID();
	DECLARE @Now DATETIME2 = GETUTCDATE();

	-- Check if email already exists
	IF EXISTS (SELECT 1 FROM Users WHERE Email = @Email AND IsDeleted = 0)
	BEGIN
		RAISERROR('Email already exists', 16, 1);
RETURN;
	END

	INSERT INTO Users (
		Id, Email, PasswordHash, EmailVerified, 
		EmailVerificationToken, EmailVerificationExpiry,
		IsActive, IsDeleted, CreatedAt, UpdatedAt
	)
	VALUES (
		@UserId, @Email, @PasswordHash, @EmailVerified,
		@EmailVerificationToken, @EmailVerificationExpiry,
		1, 0, @Now, @Now
	);

	-- Return the created user
	SELECT 
		Id, Email, PasswordHash, EmailVerified,
		EmailVerificationToken, EmailVerificationExpiry,
		PasswordResetToken, PasswordResetExpiry,
		IsActive, IsDeleted, CreatedAt, UpdatedAt, LastLoginAt
	FROM Users
	WHERE Id = @UserId;
END
GO

-- sp_GetUserByEmail: Retrieves user by email
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetUserByEmail')
	DROP PROCEDURE sp_GetUserByEmail;
GO

CREATE PROCEDURE sp_GetUserByEmail
	@Email NVARCHAR(255)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		Id, Email, PasswordHash, EmailVerified,
		EmailVerificationToken, EmailVerificationExpiry,
		PasswordResetToken, PasswordResetExpiry,
		IsActive, IsDeleted, CreatedAt, UpdatedAt, LastLoginAt
	FROM Users
	WHERE Email = @Email AND IsDeleted = 0;
END
GO

-- sp_GetUserById: Retrieves user by ID
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetUserById')
	DROP PROCEDURE sp_GetUserById;
GO

CREATE PROCEDURE sp_GetUserById
	@UserId UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		Id, Email, PasswordHash, EmailVerified,
		EmailVerificationToken, EmailVerificationExpiry,
		PasswordResetToken, PasswordResetExpiry,
		IsActive, IsDeleted, CreatedAt, UpdatedAt, LastLoginAt
	FROM Users
	WHERE Id = @UserId AND IsDeleted = 0;
END
GO

-- sp_UpdateLastLogin: Updates user's last login timestamp
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_UpdateLastLogin')
	DROP PROCEDURE sp_UpdateLastLogin;
GO

CREATE PROCEDURE sp_UpdateLastLogin
	@UserId UNIQUEIDENTIFIER,
	@LastLoginAt DATETIME2
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Users
	SET LastLoginAt = @LastLoginAt,
		UpdatedAt = GETUTCDATE()
	WHERE Id = @UserId AND IsDeleted = 0;
END
GO

-- sp_VerifyEmail: Verifies user email
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_VerifyEmail')
	DROP PROCEDURE sp_VerifyEmail;
GO

CREATE PROCEDURE sp_VerifyEmail
	@Email NVARCHAR(255),
	@VerificationToken NVARCHAR(500)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Users
	SET EmailVerified = 1,
		EmailVerificationToken = NULL,
		EmailVerificationExpiry = NULL,
		UpdatedAt = GETUTCDATE()
	WHERE Email = @Email 
		AND EmailVerificationToken = @VerificationToken
		AND EmailVerificationExpiry > GETUTCDATE()
		AND IsDeleted = 0;

	-- Return number of rows affected
	RETURN @@ROWCOUNT;
END
GO

-- sp_UpdatePassword: Updates user password
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_UpdatePassword')
	DROP PROCEDURE sp_UpdatePassword;
GO

CREATE PROCEDURE sp_UpdatePassword
	@UserId UNIQUEIDENTIFIER,
	@NewPasswordHash NVARCHAR(500)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Users
	SET PasswordHash = @NewPasswordHash,
		PasswordResetToken = NULL,
		PasswordResetExpiry = NULL,
		UpdatedAt = GETUTCDATE()
	WHERE Id = @UserId AND IsDeleted = 0;

	RETURN @@ROWCOUNT;
END
GO

-- sp_SetPasswordResetToken: Sets password reset token
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_SetPasswordResetToken')
	DROP PROCEDURE sp_SetPasswordResetToken;
GO

CREATE PROCEDURE sp_SetPasswordResetToken
	@UserId UNIQUEIDENTIFIER,
	@ResetToken NVARCHAR(500),
	@Expiry DATETIME2
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Users
	SET PasswordResetToken = @ResetToken,
		PasswordResetExpiry = @Expiry,
		UpdatedAt = GETUTCDATE()
	WHERE Id = @UserId AND IsDeleted = 0;

	RETURN @@ROWCOUNT;
END
GO

-- sp_DeleteUser: Soft deletes a user
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_DeleteUser')
	DROP PROCEDURE sp_DeleteUser;
GO

CREATE PROCEDURE sp_DeleteUser
	@UserId UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Users
	SET IsDeleted = 1,
		IsActive = 0,
		UpdatedAt = GETUTCDATE()
	WHERE Id = @UserId;

	RETURN @@ROWCOUNT;
END
GO

-- ============================================
-- REFRESH TOKEN STORED PROCEDURES
-- ============================================

-- sp_CreateRefreshToken: Creates a new refresh token
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_CreateRefreshToken')
	DROP PROCEDURE sp_CreateRefreshToken;
GO

CREATE PROCEDURE sp_CreateRefreshToken
	@UserId UNIQUEIDENTIFIER,
	@Token NVARCHAR(500),
	@ExpiresAt DATETIME2,
	@CreatedByIp NVARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @TokenId INT;
	DECLARE @Now DATETIME2 = GETUTCDATE();

	INSERT INTO RefreshTokens (
		UserId, Token, ExpiresAt, CreatedAt, IsRevoked, CreatedByIp
	)
	VALUES (
		@UserId, @Token, @ExpiresAt, @Now, 0, @CreatedByIp
	);

	SET @TokenId = SCOPE_IDENTITY();

	-- Return the created refresh token
	SELECT 
		Id, UserId, Token, ExpiresAt, CreatedAt,
		RevokedAt, ReplacedByToken, IsRevoked,
		CreatedByIp, RevokedByIp
	FROM RefreshTokens
	WHERE Id = @TokenId;
END
GO

-- sp_GetRefreshToken: Gets refresh token by token value
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetRefreshToken')
	DROP PROCEDURE sp_GetRefreshToken;
GO

CREATE PROCEDURE sp_GetRefreshToken
	@Token NVARCHAR(500)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		Id, UserId, Token, ExpiresAt, CreatedAt,
		RevokedAt, ReplacedByToken, IsRevoked,
		CreatedByIp, RevokedByIp
	FROM RefreshTokens
	WHERE Token = @Token;
END
GO

-- sp_RevokeRefreshToken: Revokes a refresh token
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_RevokeRefreshToken')
	DROP PROCEDURE sp_RevokeRefreshToken;
GO

CREATE PROCEDURE sp_RevokeRefreshToken
	@Token NVARCHAR(500),
	@RevokedByIp NVARCHAR(50) = NULL,
	@ReplacedByToken NVARCHAR(500) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE RefreshTokens
	SET IsRevoked = 1,
		RevokedAt = GETUTCDATE(),
		RevokedByIp = @RevokedByIp,
		ReplacedByToken = @ReplacedByToken
	WHERE Token = @Token AND IsRevoked = 0;

	RETURN @@ROWCOUNT;
END
GO

-- sp_RevokeAllUserTokens: Revokes all refresh tokens for a user
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_RevokeAllUserTokens')
	DROP PROCEDURE sp_RevokeAllUserTokens;
GO

CREATE PROCEDURE sp_RevokeAllUserTokens
	@UserId UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE RefreshTokens
	SET IsRevoked = 1,
		RevokedAt = GETUTCDATE()
	WHERE UserId = @UserId AND IsRevoked = 0;

	RETURN @@ROWCOUNT;
END
GO

-- ============================================
-- OAUTH PROVIDER STORED PROCEDURES
-- ============================================

-- sp_UpsertOAuthProvider: Creates or updates OAuth provider
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_UpsertOAuthProvider')
	DROP PROCEDURE sp_UpsertOAuthProvider;
GO

CREATE PROCEDURE sp_UpsertOAuthProvider
	@UserId UNIQUEIDENTIFIER,
	@Provider NVARCHAR(50),
	@ProviderUserId NVARCHAR(255),
	@AccessToken NVARCHAR(MAX) = NULL,
	@RefreshToken NVARCHAR(MAX) = NULL,
	@TokenExpiresAt DATETIME2 = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Now DATETIME2 = GETUTCDATE();
	DECLARE @OAuthId INT;

	-- Check if OAuth provider already exists
	IF EXISTS (
		SELECT 1 FROM OAuthProviders 
		WHERE Provider = @Provider AND ProviderUserId = @ProviderUserId
	)
	BEGIN
		-- Update existing
		UPDATE OAuthProviders
		SET UserId = @UserId,
			AccessToken = @AccessToken,
			RefreshToken = @RefreshToken,
			TokenExpiresAt = @TokenExpiresAt,
			UpdatedAt = @Now
		WHERE Provider = @Provider AND ProviderUserId = @ProviderUserId;

		SELECT @OAuthId = Id FROM OAuthProviders 
		WHERE Provider = @Provider AND ProviderUserId = @ProviderUserId;
	END
	ELSE
	BEGIN
		-- Insert new
		INSERT INTO OAuthProviders (
			UserId, Provider, ProviderUserId, AccessToken,
			RefreshToken, TokenExpiresAt, CreatedAt, UpdatedAt
		)
		VALUES (
			@UserId, @Provider, @ProviderUserId, @AccessToken,
			@RefreshToken, @TokenExpiresAt, @Now, @Now
		);

		SET @OAuthId = SCOPE_IDENTITY();
	END

	-- Return the OAuth provider
	SELECT 
		Id, UserId, Provider, ProviderUserId,
		AccessToken, RefreshToken, TokenExpiresAt,
		CreatedAt, UpdatedAt
	FROM OAuthProviders
	WHERE Id = @OAuthId;
END
GO

-- sp_GetOAuthProvider: Gets OAuth provider by provider and provider user ID
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetOAuthProvider')
	DROP PROCEDURE sp_GetOAuthProvider;
GO

CREATE PROCEDURE sp_GetOAuthProvider
	@Provider NVARCHAR(50),
	@ProviderUserId NVARCHAR(255)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		Id, UserId, Provider, ProviderUserId,
		AccessToken, RefreshToken, TokenExpiresAt,
		CreatedAt, UpdatedAt
	FROM OAuthProviders
	WHERE Provider = @Provider AND ProviderUserId = @ProviderUserId;
END
GO

-- sp_GetUserByOAuthProvider: Gets user by OAuth provider
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetUserByOAuthProvider')
	DROP PROCEDURE sp_GetUserByOAuthProvider;
GO

CREATE PROCEDURE sp_GetUserByOAuthProvider
	@Provider NVARCHAR(50),
	@ProviderUserId NVARCHAR(255)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		u.Id, u.Email, u.PasswordHash, u.EmailVerified,
		u.EmailVerificationToken, u.EmailVerificationExpiry,
		u.PasswordResetToken, u.PasswordResetExpiry,
		u.IsActive, u.IsDeleted, u.CreatedAt, u.UpdatedAt, u.LastLoginAt
	FROM Users u
	INNER JOIN OAuthProviders op ON u.Id = op.UserId
	WHERE op.Provider = @Provider 
		AND op.ProviderUserId = @ProviderUserId
		AND u.IsDeleted = 0;
END
GO

PRINT '============================================';
PRINT 'All stored procedures created successfully!';
PRINT 'User SPs: sp_CreateUser, sp_GetUserByEmail, sp_GetUserById, sp_UpdateLastLogin, sp_VerifyEmail, sp_UpdatePassword, sp_SetPasswordResetToken, sp_DeleteUser';
PRINT 'RefreshToken SPs: sp_CreateRefreshToken, sp_GetRefreshToken, sp_RevokeRefreshToken, sp_RevokeAllUserTokens';
PRINT 'OAuth SPs: sp_UpsertOAuthProvider, sp_GetOAuthProvider, sp_GetUserByOAuthProvider';
PRINT '============================================';
GO

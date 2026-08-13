-- ============================================
-- sp_CreateUser: Creates a new user
-- ============================================

USE Communityconnect;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

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

	DECLARE @UserId INT;
	DECLARE @Now DATETIME2 = GETUTCDATE();

	-- Check if email already exists
	IF EXISTS (SELECT 1 FROM Users WHERE Email = @Email AND IsDeleted = 0)
	BEGIN
		RAISERROR('Email already exists', 16, 1);
		RETURN;
	END

	INSERT INTO Users (
		Email, PasswordHash, EmailVerified, 
		EmailVerificationToken, EmailVerificationExpiry,
		IsActive, IsDeleted, CreatedAt, UpdatedAt
	)
	VALUES (
		@Email, @PasswordHash, @EmailVerified,
		@EmailVerificationToken, @EmailVerificationExpiry,
		1, 0, @Now, @Now
	);

	SET @UserId = SCOPE_IDENTITY();

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



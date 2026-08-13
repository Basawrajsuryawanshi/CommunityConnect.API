-- ============================================
-- sp_GetUserByEmail: Retrieves user by email
-- ============================================

USE Communityconnect;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

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


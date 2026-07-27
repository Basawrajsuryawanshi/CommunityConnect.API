-- ============================================
-- sp_VerifyEmail: Verifies user email
-- ============================================

USE AuthDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

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

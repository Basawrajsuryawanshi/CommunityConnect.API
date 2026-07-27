-- ============================================
-- sp_SetPasswordResetToken: Sets password reset token
-- ============================================

USE AuthDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

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

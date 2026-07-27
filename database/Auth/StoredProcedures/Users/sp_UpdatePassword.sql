-- ============================================
-- sp_UpdatePassword: Updates user password
-- ============================================

USE AuthDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

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

-- ============================================
-- sp_UpdateLastLogin: Updates user's last login timestamp
-- ============================================

USE AuthDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

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

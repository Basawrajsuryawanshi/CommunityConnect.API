-- ============================================
-- sp_DeleteUser: Soft deletes a user
-- ============================================

USE Communityconnect;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_DeleteUser')
	DROP PROCEDURE sp_DeleteUser;
GO

CREATE PROCEDURE sp_DeleteUser
	@UserId INT
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



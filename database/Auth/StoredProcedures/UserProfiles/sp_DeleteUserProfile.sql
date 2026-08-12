-- ============================================
-- sp_DeleteUserProfile: Deletes a user profile
-- ============================================

USE AuthDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_DeleteUserProfile')
	DROP PROCEDURE sp_DeleteUserProfile;
GO

CREATE PROCEDURE sp_DeleteUserProfile
	@Id UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	DELETE FROM UserProfiles
	WHERE Id = @Id;

	SELECT CAST(@@ROWCOUNT AS BIT) AS Success;
END
GO



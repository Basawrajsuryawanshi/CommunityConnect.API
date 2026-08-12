-- ============================================
-- sp_RemoveUserRole: Removes a role from a user
-- ============================================

USE AuthDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_RemoveUserRole')
	DROP PROCEDURE sp_RemoveUserRole;
GO

CREATE PROCEDURE sp_RemoveUserRole
	@UserId UNIQUEIDENTIFIER,
	@RoleId INT
AS
BEGIN
	SET NOCOUNT ON;

	DELETE FROM UserRoleAssignments
	WHERE UserId = @UserId AND RoleId = @RoleId;

	SELECT CAST(@@ROWCOUNT AS BIT) AS Success;
END
GO



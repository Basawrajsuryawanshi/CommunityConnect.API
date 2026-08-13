-- ============================================
-- sp_GetUserRoles: Gets all roles assigned to a user
-- ============================================

USE Communityconnect;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetUserRoles')
	DROP PROCEDURE sp_GetUserRoles;
GO

CREATE PROCEDURE sp_GetUserRoles
	@UserId INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		ura.Id,
		ura.RoleId,
		r.Name AS RoleName,
		r.Description AS RoleDescription,
		ura.AssignedAt,
		ura.ExpiresAt,
		CASE 
			WHEN ura.ExpiresAt IS NOT NULL AND ura.ExpiresAt < GETUTCDATE() 
			THEN CAST(1 AS BIT)
			ELSE CAST(0 AS BIT)
		END AS IsExpired
	FROM UserRoleAssignments ura
	INNER JOIN Roles r ON ura.RoleId = r.Id
	WHERE ura.UserId = @UserId
	ORDER BY ura.AssignedAt DESC;
END
GO





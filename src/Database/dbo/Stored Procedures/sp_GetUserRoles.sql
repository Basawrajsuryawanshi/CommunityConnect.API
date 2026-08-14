
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

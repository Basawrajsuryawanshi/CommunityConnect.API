
CREATE PROCEDURE sp_RemoveUserRole
	@UserId INT,
	@RoleId INT
AS
BEGIN
	SET NOCOUNT ON;

	DELETE FROM UserRoleAssignments
	WHERE UserId = @UserId AND RoleId = @RoleId;

	SELECT CAST(@@ROWCOUNT AS BIT) AS Success;
END

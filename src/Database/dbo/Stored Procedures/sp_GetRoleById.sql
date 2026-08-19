
CREATE PROCEDURE sp_GetRoleById
	@RoleId INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		Id, Name, Description, CreatedAt
	FROM Roles
	WHERE Id = @RoleId;
END

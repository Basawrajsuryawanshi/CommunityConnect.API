
CREATE PROCEDURE sp_GetAllRoles
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		Id, Name, Description, CreatedAt
	FROM Roles
	ORDER BY Name;
END

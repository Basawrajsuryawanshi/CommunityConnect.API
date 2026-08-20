
CREATE PROCEDURE sp_UpdateRole
	@RoleId INT,
	@Name NVARCHAR(50),
	@Description NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	SET QUOTED_IDENTIFIER ON;

	-- Check if role exists
	IF NOT EXISTS (SELECT 1 FROM Roles WHERE Id = @RoleId)
	BEGIN
		RAISERROR('Role not found', 16, 1);
		RETURN;
	END

	-- Check if the new name conflicts with another role
	IF EXISTS (SELECT 1 FROM Roles WHERE Name = @Name AND Id != @RoleId)
	BEGIN
		RAISERROR('Role name already exists', 16, 1);
		RETURN;
	END

	UPDATE Roles
	SET Name = @Name,
		Description = @Description
	WHERE Id = @RoleId;

	-- Return the updated role
	SELECT 
		Id, Name, Description, CreatedAt
	FROM Roles
	WHERE Id = @RoleId;
END

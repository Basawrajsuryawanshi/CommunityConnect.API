
CREATE PROCEDURE sp_CreateRole
	@Name NVARCHAR(50),
	@Description NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	SET QUOTED_IDENTIFIER ON;

	DECLARE @RoleId INT;
	DECLARE @Now DATETIME2 = GETUTCDATE();

	-- Check if role name already exists
	IF EXISTS (SELECT 1 FROM Roles WHERE Name = @Name)
	BEGIN
		RAISERROR('Role name already exists', 16, 1);
		RETURN;
	END

	INSERT INTO Roles (
		Name, Description, CreatedAt
	)
	VALUES (
		@Name, @Description, @Now
	);

	SET @RoleId = SCOPE_IDENTITY();

	-- Return the created role
	SELECT 
		Id, Name, Description, CreatedAt
	FROM Roles
	WHERE Id = @RoleId;
END

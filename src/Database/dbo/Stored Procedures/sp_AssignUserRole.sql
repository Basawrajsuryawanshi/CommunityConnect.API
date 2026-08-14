
CREATE PROCEDURE sp_AssignUserRole
	@UserId INT,
	@RoleId INT,
	@AssignedBy INT = NULL,
	@ExpiresAt DATETIME2 = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Now DATETIME2 = GETUTCDATE();
	DECLARE @AssignmentId INT;

	-- Check if already exists
	IF EXISTS (SELECT 1 FROM UserRoleAssignments WHERE UserId = @UserId AND RoleId = @RoleId)
	BEGIN
		-- Update existing
		UPDATE UserRoleAssignments
		SET ExpiresAt = @ExpiresAt
		WHERE UserId = @UserId AND RoleId = @RoleId;

		SELECT @AssignmentId = Id FROM UserRoleAssignments WHERE UserId = @UserId AND RoleId = @RoleId;
	END
	ELSE
	BEGIN
		-- Insert new
		INSERT INTO UserRoleAssignments (UserId, RoleId, AssignedBy, AssignedAt, ExpiresAt)
		VALUES (@UserId, @RoleId, @AssignedBy, @Now, @ExpiresAt);

		SET @AssignmentId = SCOPE_IDENTITY();
	END

	-- Return assignment details
	SELECT 
		ura.Id,
		ura.UserId,
		ura.RoleId,
		r.Name AS RoleName,
		ura.AssignedAt,
		ura.ExpiresAt
	FROM UserRoleAssignments ura
	INNER JOIN Roles r ON ura.RoleId = r.Id
	WHERE ura.Id = @AssignmentId;
END

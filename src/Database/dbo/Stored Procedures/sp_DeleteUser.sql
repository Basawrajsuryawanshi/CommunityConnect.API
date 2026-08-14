
CREATE PROCEDURE sp_DeleteUser
	@UserId INT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Users
	SET IsDeleted = 1,
		IsActive = 0,
		UpdatedAt = GETUTCDATE()
	WHERE Id = @UserId;

	RETURN @@ROWCOUNT;
END

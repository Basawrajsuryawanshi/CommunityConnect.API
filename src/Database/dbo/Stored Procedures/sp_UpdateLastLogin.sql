
CREATE PROCEDURE sp_UpdateLastLogin
	@UserId INT,
	@LastLoginAt DATETIME2
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Users
	SET LastLoginAt = @LastLoginAt,
		UpdatedAt = GETUTCDATE()
	WHERE Id = @UserId AND IsDeleted = 0;
END

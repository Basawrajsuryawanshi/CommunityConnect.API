
CREATE PROCEDURE sp_UpdatePassword
	@UserId INT,
	@NewPasswordHash NVARCHAR(500)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Users
	SET PasswordHash = @NewPasswordHash,
		PasswordResetToken = NULL,
		PasswordResetExpiry = NULL,
		UpdatedAt = GETUTCDATE()
	WHERE Id = @UserId AND IsDeleted = 0;

	RETURN @@ROWCOUNT;
END

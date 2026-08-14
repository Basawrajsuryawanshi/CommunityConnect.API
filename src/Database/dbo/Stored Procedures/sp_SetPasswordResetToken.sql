
CREATE PROCEDURE sp_SetPasswordResetToken
	@UserId INT,
	@ResetToken NVARCHAR(500),
	@Expiry DATETIME2
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Users
	SET PasswordResetToken = @ResetToken,
		PasswordResetExpiry = @Expiry,
		UpdatedAt = GETUTCDATE()
	WHERE Id = @UserId AND IsDeleted = 0;

	RETURN @@ROWCOUNT;
END

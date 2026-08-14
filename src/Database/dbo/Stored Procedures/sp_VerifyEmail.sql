
CREATE PROCEDURE sp_VerifyEmail
	@Email NVARCHAR(255),
	@VerificationToken NVARCHAR(500)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Users
	SET EmailVerified = 1,
		EmailVerificationToken = NULL,
		EmailVerificationExpiry = NULL,
		UpdatedAt = GETUTCDATE()
	WHERE Email = @Email 
		AND EmailVerificationToken = @VerificationToken
		AND EmailVerificationExpiry > GETUTCDATE()
		AND IsDeleted = 0;

	-- Return number of rows affected
	RETURN @@ROWCOUNT;
END

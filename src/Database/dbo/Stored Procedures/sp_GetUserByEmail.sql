
CREATE PROCEDURE sp_GetUserByEmail
	@Email NVARCHAR(255)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		Id, Email, PasswordHash, EmailVerified,
		EmailVerificationToken, EmailVerificationExpiry,
		PasswordResetToken, PasswordResetExpiry,
		IsActive, IsDeleted, CreatedAt, UpdatedAt, LastLoginAt
	FROM Users
	WHERE Email = @Email AND IsDeleted = 0;
END

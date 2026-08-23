
CREATE PROCEDURE sp_GetUserByEmail
	@Email NVARCHAR(255)
AS
BEGIN
	SET NOCOUNT ON;

	SET @Email = NULLIF(LOWER(LTRIM(RTRIM(@Email))), N'');

	SELECT 
		Id, Email, PasswordHash, EmailVerified,
		EmailVerificationToken, EmailVerificationExpiry,
		PasswordResetToken, PasswordResetExpiry,
		IsActive, IsDeleted, CreatedAt, UpdatedAt, LastLoginAt
	FROM Users
	WHERE LOWER(LTRIM(RTRIM(Email))) = @Email
		AND IsDeleted = 0;
END

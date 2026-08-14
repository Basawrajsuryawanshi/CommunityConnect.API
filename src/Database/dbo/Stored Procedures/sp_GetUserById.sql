
CREATE PROCEDURE sp_GetUserById
	@UserId INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		Id, Email, PasswordHash, EmailVerified,
		EmailVerificationToken, EmailVerificationExpiry,
		PasswordResetToken, PasswordResetExpiry,
		IsActive, IsDeleted, CreatedAt, UpdatedAt, LastLoginAt
	FROM Users
	WHERE Id = @UserId AND IsDeleted = 0;
END

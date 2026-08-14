
CREATE PROCEDURE sp_GetUserByOAuthProvider
	@Provider NVARCHAR(50),
	@ProviderUserId NVARCHAR(255)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		u.Id, u.Email, u.PasswordHash, u.EmailVerified,
		u.EmailVerificationToken, u.EmailVerificationExpiry,
		u.PasswordResetToken, u.PasswordResetExpiry,
		u.IsActive, u.IsDeleted, u.CreatedAt, u.UpdatedAt, u.LastLoginAt
	FROM Users u
	INNER JOIN OAuthProviders op ON u.Id = op.UserId
	WHERE op.Provider = @Provider 
		AND op.ProviderUserId = @ProviderUserId
		AND u.IsDeleted = 0;
END

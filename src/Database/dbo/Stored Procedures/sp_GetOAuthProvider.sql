
CREATE PROCEDURE sp_GetOAuthProvider
	@Provider NVARCHAR(50),
	@ProviderUserId NVARCHAR(255)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		Id, UserId, Provider, ProviderUserId,
		AccessToken, RefreshToken, TokenExpiresAt,
		CreatedAt, UpdatedAt
	FROM OAuthProviders
	WHERE Provider = @Provider AND ProviderUserId = @ProviderUserId;
END

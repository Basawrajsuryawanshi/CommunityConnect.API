
CREATE PROCEDURE sp_GetRefreshToken
	@Token NVARCHAR(500)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		Id, UserId, Token, ExpiresAt, CreatedAt,
		RevokedAt, ReplacedByToken, IsRevoked,
		CreatedByIp, RevokedByIp
	FROM RefreshTokens
	WHERE Token = @Token;
END

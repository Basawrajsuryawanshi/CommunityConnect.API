
CREATE PROCEDURE sp_RevokeRefreshToken
	@Token NVARCHAR(500),
	@RevokedByIp NVARCHAR(50) = NULL,
	@ReplacedByToken NVARCHAR(500) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE RefreshTokens
	SET IsRevoked = 1,
		RevokedAt = GETUTCDATE(),
		RevokedByIp = @RevokedByIp,
		ReplacedByToken = @ReplacedByToken
	WHERE Token = @Token;

	RETURN @@ROWCOUNT;
END

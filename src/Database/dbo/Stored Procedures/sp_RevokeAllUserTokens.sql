
CREATE PROCEDURE sp_RevokeAllUserTokens
	@UserId INT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE RefreshTokens
	SET IsRevoked = 1,
		RevokedAt = GETUTCDATE()
	WHERE UserId = @UserId AND IsRevoked = 0;

	RETURN @@ROWCOUNT;
END

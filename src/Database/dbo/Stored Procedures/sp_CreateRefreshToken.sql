
CREATE PROCEDURE sp_CreateRefreshToken
	@UserId INT,
	@Token NVARCHAR(500),
	@ExpiresAt DATETIME2,
	@CreatedByIp NVARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @TokenId INT;
	DECLARE @Now DATETIME2 = GETUTCDATE();

	INSERT INTO RefreshTokens (
		UserId, Token, ExpiresAt, CreatedAt, IsRevoked, CreatedByIp
	)
	VALUES (
		@UserId, @Token, @ExpiresAt, @Now, 0, @CreatedByIp
	);

	SET @TokenId = SCOPE_IDENTITY();

	-- Return the created refresh token
	SELECT 
		Id, UserId, Token, ExpiresAt, CreatedAt,
		RevokedAt, ReplacedByToken, IsRevoked,
		CreatedByIp, RevokedByIp
	FROM RefreshTokens
	WHERE Id = @TokenId;
END

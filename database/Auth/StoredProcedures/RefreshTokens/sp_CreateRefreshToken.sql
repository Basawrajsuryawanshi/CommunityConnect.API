-- ============================================
-- sp_CreateRefreshToken: Creates a new refresh token
-- ============================================

USE AuthDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_CreateRefreshToken')
	DROP PROCEDURE sp_CreateRefreshToken;
GO

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
GO


-- ============================================
-- sp_GetRefreshToken: Gets refresh token by token value
-- ============================================

USE AuthDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetRefreshToken')
	DROP PROCEDURE sp_GetRefreshToken;
GO

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
GO

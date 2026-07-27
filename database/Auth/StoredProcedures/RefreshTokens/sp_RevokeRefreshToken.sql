-- ============================================
-- sp_RevokeRefreshToken: Revokes a refresh token
-- ============================================

USE AuthDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_RevokeRefreshToken')
	DROP PROCEDURE sp_RevokeRefreshToken;
GO

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
GO

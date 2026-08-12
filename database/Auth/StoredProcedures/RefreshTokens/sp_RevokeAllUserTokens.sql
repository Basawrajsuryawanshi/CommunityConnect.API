-- ============================================
-- sp_RevokeAllUserTokens: Revokes all refresh tokens for a user
-- ============================================

USE AuthDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_RevokeAllUserTokens')
	DROP PROCEDURE sp_RevokeAllUserTokens;
GO

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
GO


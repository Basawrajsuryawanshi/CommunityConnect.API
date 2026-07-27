-- ============================================
-- sp_GetOAuthProvider: Gets OAuth provider by provider and provider user ID
-- ============================================

USE AuthDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetOAuthProvider')
	DROP PROCEDURE sp_GetOAuthProvider;
GO

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
GO

-- ============================================
-- sp_GetUserByOAuthProvider: Gets user by OAuth provider
-- ============================================

USE AuthDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetUserByOAuthProvider')
	DROP PROCEDURE sp_GetUserByOAuthProvider;
GO

CREATE PROCEDURE sp_GetUserByOAuthProvider
	@Provider NVARCHAR(50),
	@ProviderUserId NVARCHAR(255)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		u.Id, u.Email, u.PasswordHash, u.EmailVerified,
		u.EmailVerificationToken, u.EmailVerificationExpiry,
		u.PasswordResetToken, u.PasswordResetExpiry,
		u.IsActive, u.IsDeleted, u.CreatedAt, u.UpdatedAt, u.LastLoginAt
	FROM Users u
	INNER JOIN OAuthProviders op ON u.Id = op.UserId
	WHERE op.Provider = @Provider 
		AND op.ProviderUserId = @ProviderUserId
		AND u.IsDeleted = 0;
END
GO

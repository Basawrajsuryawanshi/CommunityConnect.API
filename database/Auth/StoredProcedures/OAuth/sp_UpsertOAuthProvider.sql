-- ============================================
-- sp_UpsertOAuthProvider: Creates or updates OAuth provider
-- ============================================

USE AuthDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_UpsertOAuthProvider')
	DROP PROCEDURE sp_UpsertOAuthProvider;
GO

CREATE PROCEDURE sp_UpsertOAuthProvider
	@UserId UNIQUEIDENTIFIER,
	@Provider NVARCHAR(50),
	@ProviderUserId NVARCHAR(255),
	@AccessToken NVARCHAR(MAX) = NULL,
	@RefreshToken NVARCHAR(MAX) = NULL,
	@TokenExpiresAt DATETIME2 = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Now DATETIME2 = GETUTCDATE();
	DECLARE @OAuthId INT;

	-- Check if OAuth provider already exists
	IF EXISTS (
		SELECT 1 FROM OAuthProviders 
		WHERE Provider = @Provider AND ProviderUserId = @ProviderUserId
	)
	BEGIN
		-- Update existing
		UPDATE OAuthProviders
		SET UserId = @UserId,
			AccessToken = @AccessToken,
			RefreshToken = @RefreshToken,
			TokenExpiresAt = @TokenExpiresAt,
			UpdatedAt = @Now
		WHERE Provider = @Provider AND ProviderUserId = @ProviderUserId;

		SELECT @OAuthId = Id FROM OAuthProviders 
		WHERE Provider = @Provider AND ProviderUserId = @ProviderUserId;
	END
	ELSE
	BEGIN
		-- Insert new
		INSERT INTO OAuthProviders (
			UserId, Provider, ProviderUserId, AccessToken,
			RefreshToken, TokenExpiresAt, CreatedAt, UpdatedAt
		)
		VALUES (
			@UserId, @Provider, @ProviderUserId, @AccessToken,
			@RefreshToken, @TokenExpiresAt, @Now, @Now
		);

		SET @OAuthId = SCOPE_IDENTITY();
	END

	-- Return the OAuth provider
	SELECT 
		Id, UserId, Provider, ProviderUserId,
		AccessToken, RefreshToken, TokenExpiresAt,
		CreatedAt, UpdatedAt
	FROM OAuthProviders
	WHERE Id = @OAuthId;
END
GO

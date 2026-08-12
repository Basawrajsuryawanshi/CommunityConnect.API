-- ============================================
-- OAUTH PROVIDERS TABLE
-- ============================================
USE AuthDB;
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'OAuthProviders')
BEGIN
	CREATE TABLE OAuthProviders (
		Id INT IDENTITY(1,1) PRIMARY KEY,
		UserId INT NOT NULL,
		Provider NVARCHAR(50) NOT NULL,
		ProviderUserId NVARCHAR(255) NOT NULL,
		AccessToken NVARCHAR(MAX) NULL,
		RefreshToken NVARCHAR(MAX) NULL,
		TokenExpiresAt DATETIME2 NULL,
		CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
		UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),

		CONSTRAINT FK_OAuthProviders_Users FOREIGN KEY (UserId) 
			REFERENCES Users(Id) ON DELETE CASCADE,
		CONSTRAINT UQ_OAuthProviders_Provider_ProviderUserId 
			UNIQUE (Provider, ProviderUserId)
	);

	CREATE INDEX IX_OAuthProviders_Provider_ProviderUserId 
		ON OAuthProviders(Provider, ProviderUserId);
	CREATE INDEX IX_OAuthProviders_UserId ON OAuthProviders(UserId);

	PRINT 'OAuthProviders table created successfully.';
END
ELSE
BEGIN
	PRINT 'OAuthProviders table already exists.';
END
GO

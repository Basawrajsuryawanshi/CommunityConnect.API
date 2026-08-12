-- ============================================
-- REFRESH TOKENS TABLE
-- ============================================
USE AuthDB;
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'RefreshTokens')
BEGIN
	CREATE TABLE RefreshTokens (
		Id INT IDENTITY(1,1) PRIMARY KEY,
		UserId UNIQUEIDENTIFIER NOT NULL,
		Token NVARCHAR(500) NOT NULL UNIQUE,
		ExpiresAt DATETIME2 NOT NULL,
		CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
		RevokedAt DATETIME2 NULL,
		ReplacedByToken NVARCHAR(500) NULL,
		IsRevoked BIT NOT NULL DEFAULT 0,
		CreatedByIp NVARCHAR(50) NULL,
		RevokedByIp NVARCHAR(50) NULL,

		CONSTRAINT FK_RefreshTokens_Users FOREIGN KEY (UserId) 
			REFERENCES Users(Id) ON DELETE CASCADE
	);

	CREATE INDEX IX_RefreshTokens_Token ON RefreshTokens(Token);
	CREATE INDEX IX_RefreshTokens_UserId ON RefreshTokens(UserId);

	PRINT 'RefreshTokens table created successfully.';
END
ELSE
BEGIN
	PRINT 'RefreshTokens table already exists.';
END
GO

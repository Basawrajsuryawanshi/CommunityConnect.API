-- ============================================
-- USERS TABLE
-- ============================================
USE AuthDB;
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Users')
BEGIN
	CREATE TABLE Users (
		Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
		Email NVARCHAR(255) NOT NULL UNIQUE,
		PasswordHash NVARCHAR(500) NULL,
		EmailVerified BIT NOT NULL DEFAULT 0,
		EmailVerificationToken NVARCHAR(500) NULL,
		EmailVerificationExpiry DATETIME2 NULL,
		PasswordResetToken NVARCHAR(500) NULL,
		PasswordResetExpiry DATETIME2 NULL,
		IsActive BIT NOT NULL DEFAULT 1,
		IsDeleted BIT NOT NULL DEFAULT 0,
		CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
		UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
		LastLoginAt DATETIME2 NULL
	);

	CREATE INDEX IX_Users_Email ON Users(Email);
	CREATE INDEX IX_Users_EmailVerificationToken ON Users(EmailVerificationToken);
	CREATE INDEX IX_Users_PasswordResetToken ON Users(PasswordResetToken);

	PRINT 'Users table created successfully.';
END
ELSE
BEGIN
	PRINT 'Users table already exists.';
END
GO

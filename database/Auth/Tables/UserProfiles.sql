-- ============================================
-- USER PROFILES TABLE
-- ============================================
USE AuthDB;
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'UserProfiles')
BEGIN
	CREATE TABLE UserProfiles (
		Id UNIQUEIDENTIFIER PRIMARY KEY,
		FirstName NVARCHAR(100) NOT NULL,
		LastName NVARCHAR(100) NOT NULL,
		DisplayName NVARCHAR(200) NULL,
		AvatarUrl NVARCHAR(500) NULL,
		Bio NVARCHAR(MAX) NULL,
		DateOfBirth DATE NULL,
		Gender NVARCHAR(20) NULL,
		PhoneNumber NVARCHAR(20) NULL,

		-- JNV Specific
		JNV NVARCHAR(200) NULL,
		Batch NVARCHAR(10) NULL,
		StudentId NVARCHAR(50) NULL,

		-- Address
		AddressLine1 NVARCHAR(255) NULL,
		AddressLine2 NVARCHAR(255) NULL,
		City NVARCHAR(100) NULL,
		State NVARCHAR(100) NULL,
		Country NVARCHAR(100) NULL,
		PostalCode NVARCHAR(20) NULL,

		-- Social
		LinkedInUrl NVARCHAR(500) NULL,
		TwitterHandle NVARCHAR(100) NULL,
		GitHubUsername NVARCHAR(100) NULL,

		IsProfileComplete BIT NOT NULL DEFAULT 0,
		IsPublic BIT NOT NULL DEFAULT 1,
		CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
		UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE()
	);

	CREATE INDEX IX_UserProfiles_JNV ON UserProfiles(JNV);
	CREATE INDEX IX_UserProfiles_Batch ON UserProfiles(Batch);
	CREATE INDEX IX_UserProfiles_DisplayName ON UserProfiles(DisplayName);

	PRINT 'UserProfiles table created successfully.';
END
ELSE
BEGIN
	PRINT 'UserProfiles table already exists.';
END
GO

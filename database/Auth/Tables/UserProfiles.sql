-- ============================================
-- USER PROFILES TABLE
-- ============================================
USE AuthDB;
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'UserProfiles')
BEGIN
	CREATE TABLE UserProfiles (
		Id UNIQUEIDENTIFIER PRIMARY KEY,

		-- Personal Information
		FullName NVARCHAR(255) NOT NULL,
		EmailID NVARCHAR(255) NULL,
		MobileNumber NVARCHAR(10) NOT NULL,

		-- School Information
		SchoolName NVARCHAR(255) NOT NULL,
		State NVARCHAR(100) NOT NULL,
		SchoolRegion NVARCHAR(100) NOT NULL,
		PassoutYear INT NOT NULL,

		-- Current Information
		Role NVARCHAR(50) NOT NULL,
		University NVARCHAR(255) NOT NULL,
		CurrentState NVARCHAR(100) NOT NULL,
		CurrentDistrict NVARCHAR(100) NOT NULL,

		-- Additional Information
		BloodGroup NVARCHAR(5) NOT NULL,

		-- Timestamps
		CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
		UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE()
	);

	CREATE INDEX IX_UserProfiles_SchoolName ON UserProfiles(SchoolName);
	CREATE INDEX IX_UserProfiles_PassoutYear ON UserProfiles(PassoutYear);
	CREATE INDEX IX_UserProfiles_EmailID ON UserProfiles(EmailID);

	PRINT 'UserProfiles table created successfully.';
END
ELSE
BEGIN
	PRINT 'UserProfiles table already exists.';
END
GO

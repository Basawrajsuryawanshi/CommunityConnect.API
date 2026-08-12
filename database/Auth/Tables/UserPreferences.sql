-- ============================================
-- USER PREFERENCES TABLE
-- ============================================
USE AuthDB;
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'UserPreferences')
BEGIN
	CREATE TABLE UserPreferences (
		Id INT IDENTITY(1,1) PRIMARY KEY,
		UserId INT NOT NULL UNIQUE,
		EmailNotifications BIT NOT NULL DEFAULT 1,
		PushNotifications BIT NOT NULL DEFAULT 1,
		SmsNotifications BIT NOT NULL DEFAULT 0,
		EventReminders BIT NOT NULL DEFAULT 1,
		AnnouncementAlerts BIT NOT NULL DEFAULT 1,
		DiscussionUpdates BIT NOT NULL DEFAULT 1,
		Theme NVARCHAR(20) NOT NULL DEFAULT 'light',
		Language NVARCHAR(10) NOT NULL DEFAULT 'en',
		CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
		UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),

		CONSTRAINT FK_UserPreferences_Users FOREIGN KEY (UserId) 
			REFERENCES UserProfiles(Id) ON DELETE CASCADE
	);

	PRINT 'UserPreferences table created successfully.';
END
ELSE
BEGIN
	PRINT 'UserPreferences table already exists.';
END
GO

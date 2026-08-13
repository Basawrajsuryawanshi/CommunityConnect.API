-- ============================================
-- USER CONNECTIONS TABLE
-- ============================================
USE Communityconnect;
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'UserConnections')
BEGIN
	CREATE TABLE UserConnections (
		Id INT IDENTITY(1,1) PRIMARY KEY,
		UserId INT NOT NULL,
		ConnectedUserId INT NOT NULL,
		Status NVARCHAR(20) NOT NULL, -- 'Pending', 'Accepted', 'Blocked'
		RequestedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
		AcceptedAt DATETIME2 NULL,

		CONSTRAINT FK_UserConnections_User FOREIGN KEY (UserId) 
			REFERENCES UserProfiles(Id) ON DELETE CASCADE,
		CONSTRAINT FK_UserConnections_Connected FOREIGN KEY (ConnectedUserId) 
			REFERENCES UserProfiles(Id) ON DELETE NO ACTION,
		CONSTRAINT CHK_UserConnections_NotSelf CHECK (UserId != ConnectedUserId),
		CONSTRAINT UQ_UserConnections_User_Connected UNIQUE (UserId, ConnectedUserId)
	);

	CREATE INDEX IX_UserConnections_UserId ON UserConnections(UserId);
	CREATE INDEX IX_UserConnections_Status ON UserConnections(Status);

	PRINT 'UserConnections table created successfully.';
END
ELSE
BEGIN
	PRINT 'UserConnections table already exists.';
END
GO


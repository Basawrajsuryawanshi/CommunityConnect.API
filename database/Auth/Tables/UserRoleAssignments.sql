-- ============================================
-- USER ROLE ASSIGNMENTS TABLE
-- ============================================
USE AuthDB;
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'UserRoleAssignments')
BEGIN
	CREATE TABLE UserRoleAssignments (
		Id INT IDENTITY(1,1) PRIMARY KEY,
		UserId UNIQUEIDENTIFIER NOT NULL,
		RoleId INT NOT NULL,
		AssignedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
		AssignedBy UNIQUEIDENTIFIER NULL,
		ExpiresAt DATETIME2 NULL,

		CONSTRAINT FK_UserRoleAssignments_Users FOREIGN KEY (UserId) 
			REFERENCES UserProfiles(Id) ON DELETE CASCADE,
		CONSTRAINT FK_UserRoleAssignments_Roles FOREIGN KEY (RoleId) 
			REFERENCES Roles(Id) ON DELETE CASCADE,
		CONSTRAINT UQ_UserRoleAssignments_User_Role UNIQUE (UserId, RoleId)
	);

	CREATE INDEX IX_UserRoleAssignments_UserId ON UserRoleAssignments(UserId);

	PRINT 'UserRoleAssignments table created successfully.';
END
ELSE
BEGIN
	PRINT 'UserRoleAssignments table already exists.';
END
GO

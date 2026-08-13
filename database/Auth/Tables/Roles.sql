-- ============================================
-- ROLES TABLE
-- ============================================
USE Communityconnect;
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Roles')
BEGIN
	CREATE TABLE Roles (
		Id INT IDENTITY(1,1) PRIMARY KEY,
		Name NVARCHAR(50) NOT NULL UNIQUE,
		Description NVARCHAR(MAX) NULL,
		CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE()
	);

	PRINT 'Roles table created successfully.';
END
ELSE
BEGIN
	PRINT 'Roles table already exists.';
END
GO

-- ============================================
-- INSERT DEFAULT ROLES
-- ============================================
IF NOT EXISTS (SELECT * FROM Roles WHERE Name = 'Admin')
BEGIN
	INSERT INTO Roles (Name, Description) VALUES
		('Admin', 'Administrator with full access'),
		('Moderator', 'Community moderator'),
		('Member', 'Regular community member'),
		('EventOrganizer', 'Can create and manage events');

	PRINT 'Default roles inserted successfully.';
END
ELSE
BEGIN
	PRINT 'Default roles already exist.';
END
GO


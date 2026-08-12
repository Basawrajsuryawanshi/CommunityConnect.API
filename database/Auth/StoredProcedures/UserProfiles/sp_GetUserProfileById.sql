-- ============================================
-- sp_GetUserProfileById: Gets a user profile by ID
-- ============================================

USE AuthDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetUserProfileById')
	DROP PROCEDURE sp_GetUserProfileById;
GO

CREATE PROCEDURE sp_GetUserProfileById
	@Id UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		Id, FirstName, LastName, DisplayName, AvatarUrl, Bio,
		DateOfBirth, Gender, PhoneNumber, JNV, Batch, StudentId,
		AddressLine1, AddressLine2, City, State, Country, PostalCode,
		LinkedInUrl, TwitterHandle, GitHubUsername,
		IsProfileComplete, IsPublic, CreatedAt, UpdatedAt
	FROM UserProfiles
	WHERE Id = @Id;
END
GO


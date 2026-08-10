-- ============================================
-- sp_UpdateUserProfile: Updates a user profile
-- ============================================

USE UserDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_UpdateUserProfile')
	DROP PROCEDURE sp_UpdateUserProfile;
GO

CREATE PROCEDURE sp_UpdateUserProfile
	@Id UNIQUEIDENTIFIER,
	@FirstName NVARCHAR(100) = NULL,
	@LastName NVARCHAR(100) = NULL,
	@DisplayName NVARCHAR(200) = NULL,
	@AvatarUrl NVARCHAR(500) = NULL,
	@Bio NVARCHAR(MAX) = NULL,
	@DateOfBirth DATE = NULL,
	@Gender NVARCHAR(20) = NULL,
	@PhoneNumber NVARCHAR(20) = NULL,
	@JNV NVARCHAR(200) = NULL,
	@Batch NVARCHAR(10) = NULL,
	@StudentId NVARCHAR(50) = NULL,
	@AddressLine1 NVARCHAR(255) = NULL,
	@AddressLine2 NVARCHAR(255) = NULL,
	@City NVARCHAR(100) = NULL,
	@State NVARCHAR(100) = NULL,
	@Country NVARCHAR(100) = NULL,
	@PostalCode NVARCHAR(20) = NULL,
	@LinkedInUrl NVARCHAR(500) = NULL,
	@TwitterHandle NVARCHAR(100) = NULL,
	@GitHubUsername NVARCHAR(100) = NULL,
	@IsProfileComplete BIT = NULL,
	@IsPublic BIT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Now DATETIME2 = GETUTCDATE();

	UPDATE UserProfiles
	SET 
		FirstName = COALESCE(@FirstName, FirstName),
		LastName = COALESCE(@LastName, LastName),
		DisplayName = COALESCE(@DisplayName, DisplayName),
		AvatarUrl = COALESCE(@AvatarUrl, AvatarUrl),
		Bio = COALESCE(@Bio, Bio),
		DateOfBirth = COALESCE(@DateOfBirth, DateOfBirth),
		Gender = COALESCE(@Gender, Gender),
		PhoneNumber = COALESCE(@PhoneNumber, PhoneNumber),
		JNV = COALESCE(@JNV, JNV),
		Batch = COALESCE(@Batch, Batch),
		StudentId = COALESCE(@StudentId, StudentId),
		AddressLine1 = COALESCE(@AddressLine1, AddressLine1),
		AddressLine2 = COALESCE(@AddressLine2, AddressLine2),
		City = COALESCE(@City, City),
		State = COALESCE(@State, State),
		Country = COALESCE(@Country, Country),
		PostalCode = COALESCE(@PostalCode, PostalCode),
		LinkedInUrl = COALESCE(@LinkedInUrl, LinkedInUrl),
		TwitterHandle = COALESCE(@TwitterHandle, TwitterHandle),
		GitHubUsername = COALESCE(@GitHubUsername, GitHubUsername),
		IsProfileComplete = COALESCE(@IsProfileComplete, IsProfileComplete),
		IsPublic = COALESCE(@IsPublic, IsPublic),
		UpdatedAt = @Now
	WHERE Id = @Id;

	-- Return updated profile
	SELECT 
		Id, FirstName, LastName, DisplayName, UpdatedAt
	FROM UserProfiles
	WHERE Id = @Id;
END
GO


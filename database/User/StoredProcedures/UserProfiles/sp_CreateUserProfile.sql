-- ============================================
-- sp_CreateUserProfile: Creates a new user profile
-- ============================================

USE UserDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_CreateUserProfile')
	DROP PROCEDURE sp_CreateUserProfile;
GO

CREATE PROCEDURE sp_CreateUserProfile
	@Id UNIQUEIDENTIFIER,
	@FirstName NVARCHAR(100),
	@LastName NVARCHAR(100),
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
	@GitHubUsername NVARCHAR(100) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Now DATETIME2 = GETUTCDATE();
	DECLARE @ComputedDisplayName NVARCHAR(200);

	SET @ComputedDisplayName = COALESCE(@DisplayName, @FirstName + ' ' + @LastName);

	INSERT INTO UserProfiles (
		Id, FirstName, LastName, DisplayName, AvatarUrl, Bio,
		DateOfBirth, Gender, PhoneNumber, JNV, Batch, StudentId,
		AddressLine1, AddressLine2, City, State, Country, PostalCode,
		LinkedInUrl, TwitterHandle, GitHubUsername,
		IsProfileComplete, IsPublic, CreatedAt, UpdatedAt
	)
	VALUES (
		@Id, @FirstName, @LastName, @ComputedDisplayName,
		@AvatarUrl, @Bio, @DateOfBirth, @Gender, @PhoneNumber,
		@JNV, @Batch, @StudentId, @AddressLine1, @AddressLine2,
		@City, @State, @Country, @PostalCode, @LinkedInUrl,
		@TwitterHandle, @GitHubUsername,
		0, 1, @Now, @Now
	);

	-- Return the created profile
	SELECT 
		Id, FirstName, LastName, DisplayName, CreatedAt
	FROM UserProfiles
	WHERE Id = @Id;
END
GO

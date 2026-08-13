-- ============================================
-- sp_UpdateUserProfile: Updates a user profile
-- ============================================

USE Communityconnect;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_UpdateUserProfile')
	DROP PROCEDURE sp_UpdateUserProfile;
GO

CREATE PROCEDURE sp_UpdateUserProfile
	@Id INT,
	@FullName NVARCHAR(255) = NULL,
	@Email NVARCHAR(255) = NULL,
	@MobileNumber NVARCHAR(10) = NULL,
	@SchoolName NVARCHAR(255) = NULL,
	@State NVARCHAR(100) = NULL,
	@SchoolRegion NVARCHAR(100) = NULL,
	@PassoutYear INT = NULL,
	@Role NVARCHAR(50) = NULL,
	@University NVARCHAR(255) = NULL,
	@CurrentState NVARCHAR(100) = NULL,
	@CurrentDistrict NVARCHAR(100) = NULL,
	@BloodGroup NVARCHAR(5) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Now DATETIME2 = GETUTCDATE();

	UPDATE UserProfiles
	SET 
		FullName = COALESCE(@FullName, FullName),
		Email = COALESCE(@Email, Email),
		MobileNumber = COALESCE(@MobileNumber, MobileNumber),
		SchoolName = COALESCE(@SchoolName, SchoolName),
		State = COALESCE(@State, State),
		SchoolRegion = COALESCE(@SchoolRegion, SchoolRegion),
		PassoutYear = COALESCE(@PassoutYear, PassoutYear),
		Role = COALESCE(@Role, Role),
		University = COALESCE(@University, University),
		CurrentState = COALESCE(@CurrentState, CurrentState),
		CurrentDistrict = COALESCE(@CurrentDistrict, CurrentDistrict),
		BloodGroup = COALESCE(@BloodGroup, BloodGroup),
		UpdatedAt = @Now
	WHERE Id = @Id;

	-- Return updated profile
	SELECT 
		Id, FullName, Email, MobileNumber, SchoolName,
		PassoutYear, Role, University, UpdatedAt
	FROM UserProfiles
	WHERE Id = @Id;
END
GO





-- ============================================
-- sp_CreateUserProfile: Creates a new user profile
-- ============================================

USE AuthDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_CreateUserProfile')
	DROP PROCEDURE sp_CreateUserProfile;
GO

CREATE PROCEDURE sp_CreateUserProfile
	@Id UNIQUEIDENTIFIER,
	@FullName NVARCHAR(255),
	@EmailID NVARCHAR(255) = NULL,
	@MobileNumber NVARCHAR(10),
	@SchoolName NVARCHAR(255),
	@State NVARCHAR(100),
	@SchoolRegion NVARCHAR(100),
	@PassoutYear INT,
	@Role NVARCHAR(50),
	@University NVARCHAR(255),
	@CurrentState NVARCHAR(100),
	@CurrentDistrict NVARCHAR(100),
	@BloodGroup NVARCHAR(5)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Now DATETIME2 = GETUTCDATE();

	INSERT INTO UserProfiles (
		Id, FullName, EmailID, MobileNumber,
		SchoolName, State, SchoolRegion, PassoutYear,
		Role, University, CurrentState, CurrentDistrict,
		BloodGroup, CreatedAt, UpdatedAt
	)
	VALUES (
		@Id, @FullName, @EmailID, @MobileNumber,
		@SchoolName, @State, @SchoolRegion, @PassoutYear,
		@Role, @University, @CurrentState, @CurrentDistrict,
		@BloodGroup, @Now, @Now
	);

	-- Return the created profile
	SELECT 
		Id, FullName, EmailID, MobileNumber, SchoolName, 
		PassoutYear, Role, University, CreatedAt
	FROM UserProfiles
	WHERE Id = @Id;
END
GO


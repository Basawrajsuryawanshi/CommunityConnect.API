-- ============================================
-- sp_GetUserProfileById: Gets a user profile by ID
-- ============================================

USE Communityconnect;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetUserProfileById')
	DROP PROCEDURE sp_GetUserProfileById;
GO

CREATE PROCEDURE sp_GetUserProfileById
	@Id INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		Id, FullName, Email, MobileNumber,
		SchoolName, State, SchoolRegion, PassoutYear,
		Role, University, CurrentState, CurrentDistrict,
		BloodGroup, CreatedAt, UpdatedAt
	FROM UserProfiles
	WHERE Id = @Id;
END
GO




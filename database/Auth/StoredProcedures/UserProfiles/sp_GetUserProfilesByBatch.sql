-- ============================================
-- sp_GetUserProfilesByPassoutYear: Gets user profiles by passout year
-- ============================================

USE AuthDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetUserProfilesByBatch')
	DROP PROCEDURE sp_GetUserProfilesByBatch;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetUserProfilesByPassoutYear')
	DROP PROCEDURE sp_GetUserProfilesByPassoutYear;
GO

CREATE PROCEDURE sp_GetUserProfilesByPassoutYear
	@PassoutYear INT,
	@Limit INT = 50,
	@Offset INT = 0
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		Id, FullName, EmailID, MobileNumber,
		SchoolName, State, SchoolRegion, PassoutYear,
		Role, University, CurrentState, CurrentDistrict,
		BloodGroup, CreatedAt, UpdatedAt
	FROM UserProfiles
	WHERE 
		PassoutYear = @PassoutYear
	ORDER BY SchoolName, FullName
	OFFSET @Offset ROWS
	FETCH NEXT @Limit ROWS ONLY;
END
GO



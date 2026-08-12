-- ============================================
-- sp_GetAllUserProfiles: Gets all user profiles with optional pagination
-- ============================================

USE AuthDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetAllUserProfiles')
	DROP PROCEDURE sp_GetAllUserProfiles;
GO

CREATE PROCEDURE sp_GetAllUserProfiles
	@PageNumber INT = 1,
	@PageSize INT = 50
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

	-- Get total count
	DECLARE @TotalCount INT;
	SELECT @TotalCount = COUNT(*) FROM UserProfiles;

	-- Get paginated results
	SELECT 
		Id, FullName, EmailID, MobileNumber,
		SchoolName, State, SchoolRegion, PassoutYear,
		Role, University, CurrentState, CurrentDistrict,
		BloodGroup, CreatedAt, UpdatedAt
	FROM UserProfiles
	ORDER BY CreatedAt DESC
	OFFSET @Offset ROWS
	FETCH NEXT @PageSize ROWS ONLY;

	-- Return total count as separate result set
	SELECT @TotalCount AS TotalCount;
END
GO


-- ============================================
-- sp_SearchUserProfiles: Searches user profiles
-- ============================================

USE AuthDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_SearchUserProfiles')
	DROP PROCEDURE sp_SearchUserProfiles;
GO

CREATE PROCEDURE sp_SearchUserProfiles
	@SearchTerm NVARCHAR(200),
	@SchoolName NVARCHAR(255) = NULL,
	@PassoutYear INT = NULL,
	@Role NVARCHAR(50) = NULL,
	@Limit INT = 50,
	@Offset INT = 0
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		Id, FullName, Email, MobileNumber,
		SchoolName, State, SchoolRegion, PassoutYear,
		Role, University, CurrentState, CurrentDistrict,
		BloodGroup, CreatedAt, UpdatedAt
	FROM UserProfiles
	WHERE 
		(
			@SearchTerm IS NULL OR @SearchTerm = '' OR
			FullName LIKE '%' + @SearchTerm + '%'
			OR SchoolName LIKE '%' + @SearchTerm + '%'
			OR Role LIKE '%' + @SearchTerm + '%'
			OR University LIKE '%' + @SearchTerm + '%'
			OR CAST(PassoutYear AS NVARCHAR) LIKE '%' + @SearchTerm + '%'
		)
		AND (@SchoolName IS NULL OR SchoolName = @SchoolName)
		AND (@PassoutYear IS NULL OR PassoutYear = @PassoutYear)
		AND (@Role IS NULL OR Role = @Role)
	ORDER BY FullName
	OFFSET @Offset ROWS
	FETCH NEXT @Limit ROWS ONLY;
END
GO



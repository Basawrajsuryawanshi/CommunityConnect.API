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
	@Limit INT = 50,
	@Offset INT = 0
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		Id, FirstName, LastName, DisplayName, AvatarUrl,
		JNV, Batch, City, State, IsPublic
	FROM UserProfiles
	WHERE 
		IsPublic = 1
		AND (
			DisplayName LIKE '%' + @SearchTerm + '%'
			OR FirstName LIKE '%' + @SearchTerm + '%'
			OR LastName LIKE '%' + @SearchTerm + '%'
			OR JNV LIKE '%' + @SearchTerm + '%'
			OR Batch LIKE '%' + @SearchTerm + '%'
		)
	ORDER BY DisplayName
	OFFSET @Offset ROWS
	FETCH NEXT @Limit ROWS ONLY;
END
GO



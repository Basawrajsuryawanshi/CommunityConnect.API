-- ============================================
-- sp_GetUserProfilesByJNV: Gets user profiles by JNV
-- ============================================

USE AuthDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetUserProfilesByJNV')
	DROP PROCEDURE sp_GetUserProfilesByJNV;
GO

CREATE PROCEDURE sp_GetUserProfilesByJNV
	@JNV NVARCHAR(200),
	@Limit INT = 50,
	@Offset INT = 0
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		Id, FirstName, LastName, DisplayName, AvatarUrl,
		JNV, Batch, City, State
	FROM UserProfiles
	WHERE 
		IsPublic = 1
		AND JNV = @JNV
	ORDER BY Batch DESC, DisplayName
	OFFSET @Offset ROWS
	FETCH NEXT @Limit ROWS ONLY;
END
GO



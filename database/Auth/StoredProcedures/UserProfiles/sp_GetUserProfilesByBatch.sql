-- ============================================
-- sp_GetUserProfilesByBatch: Gets user profiles by batch
-- ============================================

USE AuthDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetUserProfilesByBatch')
	DROP PROCEDURE sp_GetUserProfilesByBatch;
GO

CREATE PROCEDURE sp_GetUserProfilesByBatch
	@Batch NVARCHAR(10),
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
		AND Batch = @Batch
	ORDER BY JNV, DisplayName
	OFFSET @Offset ROWS
	FETCH NEXT @Limit ROWS ONLY;
END
GO



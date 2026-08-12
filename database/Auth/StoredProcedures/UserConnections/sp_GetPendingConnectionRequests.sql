-- ============================================
-- sp_GetPendingConnectionRequests: Gets pending connection requests
-- ============================================

USE AuthDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetPendingConnectionRequests')
	DROP PROCEDURE sp_GetPendingConnectionRequests;
GO

CREATE PROCEDURE sp_GetPendingConnectionRequests
	@UserId UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		uc.Id,
		uc.ConnectedUserId AS UserId,
		uc.UserId AS RequestingUserId,
		up.DisplayName AS RequestingUserName,
		up.AvatarUrl AS RequestingUserAvatar,
		up.JNV AS RequestingUserJNV,
		up.Batch AS RequestingUserBatch,
		uc.Status,
		uc.RequestedAt
	FROM UserConnections uc
	INNER JOIN UserProfiles up ON uc.UserId = up.Id
	WHERE 
		uc.ConnectedUserId = @UserId
		AND uc.Status = 'Pending'
	ORDER BY uc.RequestedAt DESC;
END
GO



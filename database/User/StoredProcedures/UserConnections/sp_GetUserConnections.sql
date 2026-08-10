-- ============================================
-- sp_GetUserConnections: Gets all connections for a user
-- ============================================

USE UserDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetUserConnections')
	DROP PROCEDURE sp_GetUserConnections;
GO

CREATE PROCEDURE sp_GetUserConnections
	@UserId UNIQUEIDENTIFIER,
	@Status NVARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		uc.Id,
		uc.UserId,
		uc.ConnectedUserId,
		up.DisplayName AS ConnectedUserName,
		up.AvatarUrl AS ConnectedUserAvatar,
		uc.Status,
		uc.RequestedAt,
		uc.AcceptedAt
	FROM UserConnections uc
	INNER JOIN UserProfiles up ON uc.ConnectedUserId = up.Id
	WHERE 
		uc.UserId = @UserId
		AND (@Status IS NULL OR uc.Status = @Status)
	ORDER BY uc.RequestedAt DESC;
END
GO


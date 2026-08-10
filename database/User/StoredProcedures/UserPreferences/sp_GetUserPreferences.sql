-- ============================================
-- sp_GetUserPreferences: Gets user preferences
-- ============================================

USE UserDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetUserPreferences')
	DROP PROCEDURE sp_GetUserPreferences;
GO

CREATE PROCEDURE sp_GetUserPreferences
	@UserId UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		Id, UserId, EmailNotifications, PushNotifications, SmsNotifications,
		EventReminders, AnnouncementAlerts, DiscussionUpdates,
		Theme, Language, CreatedAt, UpdatedAt
	FROM UserPreferences
	WHERE UserId = @UserId;
END
GO


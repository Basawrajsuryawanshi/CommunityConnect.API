
CREATE PROCEDURE sp_GetUserPreferences
	@UserId INT
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

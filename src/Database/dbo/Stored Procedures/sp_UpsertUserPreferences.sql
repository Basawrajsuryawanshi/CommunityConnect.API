
CREATE PROCEDURE sp_UpsertUserPreferences
	@UserId INT,
	@EmailNotifications BIT = 1,
	@PushNotifications BIT = 1,
	@SmsNotifications BIT = 0,
	@EventReminders BIT = 1,
	@AnnouncementAlerts BIT = 1,
	@DiscussionUpdates BIT = 1,
	@Theme NVARCHAR(20) = 'light',
	@Language NVARCHAR(10) = 'en'
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Now DATETIME2 = GETUTCDATE();
	DECLARE @PreferenceId INT;

	-- Check if preferences exist
	IF EXISTS (SELECT 1 FROM UserPreferences WHERE UserId = @UserId)
	BEGIN
		-- Update existing
		UPDATE UserPreferences
		SET 
			EmailNotifications = @EmailNotifications,
			PushNotifications = @PushNotifications,
			SmsNotifications = @SmsNotifications,
			EventReminders = @EventReminders,
			AnnouncementAlerts = @AnnouncementAlerts,
			DiscussionUpdates = @DiscussionUpdates,
			Theme = @Theme,
			Language = @Language,
			UpdatedAt = @Now
		WHERE UserId = @UserId;

		SELECT @PreferenceId = Id FROM UserPreferences WHERE UserId = @UserId;
	END
	ELSE
	BEGIN
		-- Insert new
		INSERT INTO UserPreferences (
			UserId, EmailNotifications, PushNotifications, SmsNotifications,
			EventReminders, AnnouncementAlerts, DiscussionUpdates,
			Theme, Language, CreatedAt, UpdatedAt
		)
		VALUES (
			@UserId, @EmailNotifications, @PushNotifications, @SmsNotifications,
			@EventReminders, @AnnouncementAlerts, @DiscussionUpdates,
			@Theme, @Language, @Now, @Now
		);

		SET @PreferenceId = SCOPE_IDENTITY();
	END

	-- Return preferences
	SELECT 
		Id, UserId, EmailNotifications, PushNotifications, SmsNotifications,
		EventReminders, AnnouncementAlerts, DiscussionUpdates,
		Theme, Language, UpdatedAt
	FROM UserPreferences
	WHERE Id = @PreferenceId;
END

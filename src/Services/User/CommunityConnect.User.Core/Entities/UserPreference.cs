using System;

namespace CommunityConnect.User.Core.Entities
{
    public class UserPreference
    {
        public int Id { get; set; }
        public Guid UserId { get; set; }
        public bool EmailNotifications { get; set; } = true;
        public bool PushNotifications { get; set; } = true;
        public bool SmsNotifications { get; set; } = false;
        public bool EventReminders { get; set; } = true;
        public bool AnnouncementAlerts { get; set; } = true;
        public bool DiscussionUpdates { get; set; } = true;
        public string Theme { get; set; } = "light";
        public string Language { get; set; } = "en";
        public string TimeZone { get; set; } = "UTC";
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        // Navigation properties
        public UserProfile User { get; set; } = null!;
    }
}

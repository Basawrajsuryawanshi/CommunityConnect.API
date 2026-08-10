using System;

namespace CommunityConnect.User.Core.Entities
{
    public class UserConnection
    {
        public int Id { get; set; }
        public Guid UserId { get; set; }
        public Guid ConnectedUserId { get; set; }
        public string Status { get; set; } = string.Empty; // Pending, Accepted, Blocked
        public DateTime RequestedAt { get; set; } = DateTime.UtcNow;
        public DateTime? AcceptedAt { get; set; }

        // Navigation properties
        public UserProfile User { get; set; } = null!;
        public UserProfile ConnectedUser { get; set; } = null!;

        // Computed properties
        public bool IsPending => Status == "Pending";
        public bool IsAccepted => Status == "Accepted";
        public bool IsBlocked => Status == "Blocked";
    }
}

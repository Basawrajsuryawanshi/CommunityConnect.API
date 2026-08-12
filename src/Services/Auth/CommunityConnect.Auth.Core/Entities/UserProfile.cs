namespace CommunityConnect.Auth.Core.Entities
{
    /// <summary>
    /// User profile entity
    /// </summary>
    public class UserProfile
    {
        public int Id { get; set; }

        // Personal Information
        public string FullName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string MobileNumber { get; set; } = string.Empty;

        // School Information
        public string SchoolName { get; set; } = string.Empty;
        public string State { get; set; } = string.Empty;
        public string SchoolRegion { get; set; } = string.Empty;
        public int PassoutYear { get; set; }

        // Current Information
        public string Role { get; set; } = string.Empty;
        public string University { get; set; } = string.Empty;
        public string CurrentState { get; set; } = string.Empty;
        public string CurrentDistrict { get; set; } = string.Empty;

        // Additional Information
        public string BloodGroup { get; set; } = string.Empty;

        // Timestamps
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
    }
}

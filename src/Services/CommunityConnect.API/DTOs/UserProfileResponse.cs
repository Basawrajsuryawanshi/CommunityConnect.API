namespace CommunityConnect.API.DTOs
{
    /// <summary>
    /// Response DTO for user profile data
    /// Excludes sensitive information like password
    /// </summary>
    public class UserProfileResponse
    {
        public Guid Id { get; set; }

        // Personal Information
        public string FullName { get; set; } = string.Empty;
        public string? EmailID { get; set; }
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

        /// <summary>
        /// Maps a UserProfile domain model to a response DTO
        /// </summary>
        public static UserProfileResponse FromUserProfile(Models.UserProfile profile)
        {
            return new UserProfileResponse
            {
                Id = profile.Id,
                FullName = profile.FullName,
                EmailID = profile.EmailID,
                MobileNumber = profile.MobileNumber,
                SchoolName = profile.SchoolName,
                State = profile.State,
                SchoolRegion = profile.SchoolRegion,
                PassoutYear = profile.PassoutYear,
                Role = profile.Role,
                University = profile.University,
                CurrentState = profile.CurrentState,
                CurrentDistrict = profile.CurrentDistrict,
                BloodGroup = profile.BloodGroup,
                CreatedAt = profile.CreatedAt,
                UpdatedAt = profile.UpdatedAt
            };
        }
    }
}

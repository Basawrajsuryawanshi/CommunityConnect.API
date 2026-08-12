using System.ComponentModel.DataAnnotations;

namespace CommunityConnect.Auth.API.Models
{
    /// <summary>
    /// User profile domain model
    /// </summary>
    public class UserProfile
    {
        public Guid Id { get; set; }

        // Personal Information
        [Required]
        [MaxLength(255)]
        public string FullName { get; set; } = string.Empty;

        [MaxLength(255)]
        [EmailAddress]
        public string? EmailID { get; set; }

        [Required]
        [MaxLength(10)]
        [Phone]
        public string MobileNumber { get; set; } = string.Empty;

        // School Information
        [Required]
        [MaxLength(255)]
        public string SchoolName { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        public string State { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        public string SchoolRegion { get; set; } = string.Empty;

        [Required]
        public int PassoutYear { get; set; }

        // Current Information
        [Required]
        [MaxLength(50)]
        public string Role { get; set; } = string.Empty;

        [Required]
        [MaxLength(255)]
        public string University { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        public string CurrentState { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        public string CurrentDistrict { get; set; } = string.Empty;

        // Additional Information
        [Required]
        [MaxLength(5)]
        public string BloodGroup { get; set; } = string.Empty;

        // Timestamps
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
    }
}

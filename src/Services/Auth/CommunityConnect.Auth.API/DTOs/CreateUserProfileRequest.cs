using System.ComponentModel.DataAnnotations;

namespace CommunityConnect.Auth.API.DTOs
{
    /// <summary>
    /// Request DTO for creating a new user profile
    /// </summary>
    public class CreateUserProfileRequest
    {
        // Personal Information
        [Required(ErrorMessage = "Full name is required")]
        [MaxLength(255)]
        public string FullName { get; set; } = string.Empty;

        [MaxLength(255)]
        [EmailAddress(ErrorMessage = "Invalid email format")]
        public string? EmailID { get; set; }

        [Required(ErrorMessage = "Mobile number is required")]
        [MaxLength(10)]
        [RegularExpression(@"^\d{10}$", ErrorMessage = "Mobile number must be 10 digits")]
        public string MobileNumber { get; set; } = string.Empty;

        // School Information
        [Required(ErrorMessage = "School name is required")]
        [MaxLength(255)]
        public string SchoolName { get; set; } = string.Empty;

        [Required(ErrorMessage = "State is required")]
        [MaxLength(100)]
        public string State { get; set; } = string.Empty;

        [Required(ErrorMessage = "School region is required")]
        [MaxLength(100)]
        public string SchoolRegion { get; set; } = string.Empty;

        [Required(ErrorMessage = "Passout year is required")]
        [Range(1950, 2100, ErrorMessage = "Passout year must be between 1950 and 2100")]
        public int PassoutYear { get; set; }

        // Current Information
        [Required(ErrorMessage = "Role is required")]
        [MaxLength(50)]
        public string Role { get; set; } = string.Empty;

        [Required(ErrorMessage = "University is required")]
        [MaxLength(255)]
        public string University { get; set; } = string.Empty;

        [Required(ErrorMessage = "Current state is required")]
        [MaxLength(100)]
        public string CurrentState { get; set; } = string.Empty;

        [Required(ErrorMessage = "Current district is required")]
        [MaxLength(100)]
        public string CurrentDistrict { get; set; } = string.Empty;

        // Additional Information
        [Required(ErrorMessage = "Blood group is required")]
        [MaxLength(5)]
        [RegularExpression(@"^(A|B|AB|O)[+-]$", ErrorMessage = "Invalid blood group format (e.g., A+, B-, AB+, O-)")]
        public string BloodGroup { get; set; } = string.Empty;
    }
}

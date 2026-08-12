using System.ComponentModel.DataAnnotations;

namespace CommunityConnect.Auth.API.DTOs
{
    /// <summary>
    /// Request DTO for updating an existing user profile
    /// All fields are optional to support partial updates
    /// </summary>
    public class UpdateUserProfileRequest
    {
        // Personal Information
        [MaxLength(255)]
        public string? FullName { get; set; }

        [MaxLength(255)]
        [EmailAddress(ErrorMessage = "Invalid email format")]
        public string? EmailID { get; set; }

        [MaxLength(10)]
        [RegularExpression(@"^\d{10}$", ErrorMessage = "Mobile number must be 10 digits")]
        public string? MobileNumber { get; set; }

        // School Information
        [MaxLength(255)]
        public string? SchoolName { get; set; }

        [MaxLength(100)]
        public string? State { get; set; }

        [MaxLength(100)]
        public string? SchoolRegion { get; set; }

        [Range(1950, 2100, ErrorMessage = "Passout year must be between 1950 and 2100")]
        public int? PassoutYear { get; set; }

        // Current Information
        [MaxLength(50)]
        public string? Role { get; set; }

        [MaxLength(255)]
        public string? University { get; set; }

        [MaxLength(100)]
        public string? CurrentState { get; set; }

        [MaxLength(100)]
        public string? CurrentDistrict { get; set; }

        // Additional Information
        [MaxLength(5)]
        [RegularExpression(@"^(A|B|AB|O)[+-]$", ErrorMessage = "Invalid blood group format (e.g., A+, B-, AB+, O-)")]
        public string? BloodGroup { get; set; }
    }
}

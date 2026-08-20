using System.ComponentModel.DataAnnotations;

namespace CommunityConnect.API.DTOs
{
    /// <summary>
    /// Request DTO for updating an existing role
    /// </summary>
    public class UpdateRoleRequest
    {
        /// <summary>
        /// Role name (e.g., Student, Alumni, Faculty)
        /// </summary>
        [Required(ErrorMessage = "Role name is required")]
        [StringLength(50, MinimumLength = 2, ErrorMessage = "Role name must be between 2 and 50 characters")]
        public string Name { get; set; } = string.Empty;

        /// <summary>
        /// Role description
        /// </summary>
        [Required(ErrorMessage = "Role description is required")]
        [StringLength(200, MinimumLength = 5, ErrorMessage = "Role description must be between 5 and 200 characters")]
        public string Description { get; set; } = string.Empty;
    }
}

namespace CommunityConnect.API.DTOs
{
    /// <summary>
    /// Response DTO for role data
    /// </summary>
    public class RoleDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }

        /// <summary>
        /// Maps a Role entity to a RoleDto
        /// </summary>
        public static RoleDto FromRole(Core.Entities.Role role)
        {
            return new RoleDto
            {
                Id = role.Id,
                Name = role.Name,
                Description = role.Description,
                CreatedAt = role.CreatedAt
            };
        }
    }
}

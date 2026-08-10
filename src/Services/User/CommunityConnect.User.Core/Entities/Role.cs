using System;

namespace CommunityConnect.User.Core.Entities
{
    public class Role
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // Navigation properties
        public ICollection<UserRoleAssignment> UserAssignments { get; set; } = new List<UserRoleAssignment>();
    }

    public class UserRoleAssignment
    {
        public int Id { get; set; }
        public Guid UserId { get; set; }
        public int RoleId { get; set; }
        public DateTime AssignedAt { get; set; } = DateTime.UtcNow;
        public Guid? AssignedBy { get; set; }
        public DateTime? ExpiresAt { get; set; }

        // Navigation properties
        public UserProfile User { get; set; } = null!;
        public Role Role { get; set; } = null!;

        // Computed property
        public bool IsExpired => ExpiresAt.HasValue && ExpiresAt.Value < DateTime.UtcNow;
    }
}

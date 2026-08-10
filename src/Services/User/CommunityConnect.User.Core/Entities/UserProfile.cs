using System;

namespace CommunityConnect.User.Core.Entities
{
    public class UserProfile
    {
        public Guid Id { get; set; }
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string? DisplayName { get; set; }
        public string? AvatarUrl { get; set; }
        public string? Bio { get; set; }
        public DateTime? DateOfBirth { get; set; }
        public string? Gender { get; set; }
        public string? PhoneNumber { get; set; }

        // JNV Specific
        public string? JNV { get; set; }
        public string? Batch { get; set; }
        public string? StudentId { get; set; }

        // Address
        public string? AddressLine1 { get; set; }
        public string? AddressLine2 { get; set; }
        public string? City { get; set; }
        public string? State { get; set; }
        public string? Country { get; set; }
        public string? PostalCode { get; set; }

        // Social
        public string? LinkedInUrl { get; set; }
        public string? TwitterHandle { get; set; }
        public string? GitHubUsername { get; set; }

        public bool IsProfileComplete { get; set; }
        public bool IsPublic { get; set; } = true;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        // Navigation properties
        public ICollection<UserRoleAssignment> RoleAssignments { get; set; } = new List<UserRoleAssignment>();
        public UserPreference? Preferences { get; set; }
        public ICollection<UserConnection> Connections { get; set; } = new List<UserConnection>();
    }
}

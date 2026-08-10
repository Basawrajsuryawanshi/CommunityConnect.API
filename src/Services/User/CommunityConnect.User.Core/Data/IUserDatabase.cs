using CommunityConnect.User.Core.Entities;

namespace CommunityConnect.User.Core.Data
{
    /// <summary>
    /// Interface for User database operations using stored procedures
    /// One interface per database - contains all methods related to User DB
    /// </summary>
    public interface IUserDatabase
    {
        // ============================================
        // USER PROFILE OPERATIONS
        // ============================================

        /// <summary>
        /// Creates a new user profile using sp_CreateUserProfile stored procedure
        /// </summary>
        Task<UserProfile> CreateUserProfileAsync(
            Guid id,
            string firstName,
            string lastName,
            string email,
            string? displayName = null,
            string? avatarUrl = null,
            string? bio = null,
            DateTime? dateOfBirth = null,
            string? gender = null,
            string? phoneNumber = null,
            string? jnv = null,
            string? batch = null,
            string? studentId = null,
            string? addressLine1 = null,
            string? addressLine2 = null,
            string? city = null,
            string? state = null,
            string? country = null,
            string? postalCode = null,
            string? linkedInUrl = null,
            string? twitterHandle = null,
            string? gitHubUsername = null);

        /// <summary>
        /// Gets user profile by ID using sp_GetUserProfileById stored procedure
        /// </summary>
        Task<UserProfile?> GetUserProfileByIdAsync(Guid userId);

        /// <summary>
        /// Updates user profile using sp_UpdateUserProfile stored procedure
        /// </summary>
        Task<UserProfile?> UpdateUserProfileAsync(
            Guid id,
            string? firstName = null,
            string? lastName = null,
            string? displayName = null,
            string? avatarUrl = null,
            string? bio = null,
            DateTime? dateOfBirth = null,
            string? gender = null,
            string? phoneNumber = null,
            string? jnv = null,
            string? batch = null,
            string? studentId = null,
            string? addressLine1 = null,
            string? addressLine2 = null,
            string? city = null,
            string? state = null,
            string? country = null,
            string? postalCode = null,
            string? linkedInUrl = null,
            string? twitterHandle = null,
            string? gitHubUsername = null,
            bool? isProfileComplete = null,
            bool? isPublic = null);

        /// <summary>
        /// Deletes a user profile using sp_DeleteUserProfile stored procedure
        /// </summary>
        Task<bool> DeleteUserProfileAsync(Guid userId);

        /// <summary>
        /// Searches user profiles using sp_SearchUserProfiles stored procedure
        /// </summary>
        Task<IEnumerable<UserProfile>> SearchUserProfilesAsync(string searchTerm, int limit = 50, int offset = 0);

        /// <summary>
        /// Gets user profiles by JNV using sp_GetUserProfilesByJNV stored procedure
        /// </summary>
        Task<IEnumerable<UserProfile>> GetUserProfilesByJNVAsync(string jnv, int limit = 50, int offset = 0);

        /// <summary>
        /// Gets user profiles by batch using sp_GetUserProfilesByBatch stored procedure
        /// </summary>
        Task<IEnumerable<UserProfile>> GetUserProfilesByBatchAsync(string batch, int limit = 50, int offset = 0);

        // ============================================
        // ROLE OPERATIONS
        // ============================================

        /// <summary>
        /// Gets all available roles using sp_GetAllRoles stored procedure
        /// </summary>
        Task<IEnumerable<Role>> GetAllRolesAsync();

        /// <summary>
        /// Assigns a role to a user using sp_AssignUserRole stored procedure
        /// </summary>
        Task<UserRoleAssignment> AssignUserRoleAsync(
            Guid userId,
            int roleId,
            Guid? assignedBy = null,
            DateTime? expiresAt = null);

        /// <summary>
        /// Removes a role from a user using sp_RemoveUserRole stored procedure
        /// </summary>
        Task<bool> RemoveUserRoleAsync(Guid userId, int roleId);

        /// <summary>
        /// Gets all roles assigned to a user using sp_GetUserRoles stored procedure
        /// </summary>
        Task<IEnumerable<UserRoleAssignment>> GetUserRolesAsync(Guid userId);

        // ============================================
        // USER PREFERENCES OPERATIONS
        // ============================================

        /// <summary>
        /// Gets user preferences using sp_GetUserPreferences stored procedure
        /// </summary>
        Task<UserPreference?> GetUserPreferencesAsync(Guid userId);

        /// <summary>
        /// Creates or updates user preferences using sp_UpsertUserPreferences stored procedure
        /// </summary>
        Task<UserPreference> UpsertUserPreferencesAsync(
            Guid userId,
            bool emailNotifications = true,
            bool pushNotifications = true,
            bool smsNotifications = false,
            bool eventReminders = true,
            bool announcementAlerts = true,
            bool discussionUpdates = true,
            string theme = "light",
            string language = "en");

        // ============================================
        // USER CONNECTIONS OPERATIONS
        // ============================================

        /// <summary>
        /// Creates a connection request using sp_CreateConnectionRequest stored procedure
        /// </summary>
        Task<UserConnection> CreateConnectionRequestAsync(Guid userId, Guid connectedUserId);

        /// <summary>
        /// Accepts a connection request using sp_AcceptConnectionRequest stored procedure
        /// </summary>
        Task<UserConnection?> AcceptConnectionRequestAsync(int connectionId, Guid connectedUserId);

        /// <summary>
        /// Rejects a connection request using sp_RejectConnectionRequest stored procedure
        /// </summary>
        Task<bool> RejectConnectionRequestAsync(int connectionId, Guid connectedUserId);

        /// <summary>
        /// Blocks a user connection using sp_BlockUserConnection stored procedure
        /// </summary>
        Task<UserConnection> BlockUserConnectionAsync(Guid userId, Guid connectedUserId);

        /// <summary>
        /// Gets user connections using sp_GetUserConnections stored procedure
        /// </summary>
        Task<IEnumerable<UserConnection>> GetUserConnectionsAsync(Guid userId, string? status = null);

        /// <summary>
        /// Gets pending connection requests using sp_GetPendingConnectionRequests stored procedure
        /// </summary>
        Task<IEnumerable<UserConnection>> GetPendingConnectionRequestsAsync(Guid userId);
    }
}

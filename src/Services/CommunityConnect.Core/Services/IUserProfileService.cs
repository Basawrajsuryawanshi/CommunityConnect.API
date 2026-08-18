using CommunityConnect.Core.Entities;

namespace CommunityConnect.Core.Services
{
    /// <summary>
    /// Service interface for user profile operations
    /// </summary>
    public interface IUserProfileService
    {
        /// <summary>
        /// Get user profile by ID
        /// </summary>
        /// <param name="id">User profile ID</param>
        /// <returns>User profile or null if not found</returns>
        Task<UserProfile?> GetUserProfileByIdAsync(int id);

        /// <summary>
        /// Create a new user profile
        /// </summary>
        /// <param name="id">User ID</param>
        /// <param name="fullName">Full name</param>
        /// <param name="email">Email address</param>
        /// <param name="mobileNumber">Mobile number</param>
        /// <param name="schoolName">School name</param>
        /// <param name="state">State</param>
        /// <param name="schoolRegion">School region</param>
        /// <param name="passoutYear">Passout year</param>
        /// <param name="role">Role</param>
        /// <param name="university">University</param>
        /// <param name="currentState">Current state</param>
        /// <param name="currentDistrict">Current district</param>
        /// <param name="bloodGroup">Blood group</param>
        /// <returns>Created user profile</returns>
        Task<UserProfile> CreateUserProfileAsync(
            int id,
            string fullName,
            string email,
            string mobileNumber,
            string schoolName,
            string state,
            string schoolRegion,
            int passoutYear,
            string role,
            string university,
            string currentState,
            string currentDistrict,
            string bloodGroup);

        /// <summary>
        /// Update an existing user profile
        /// </summary>
        /// <param name="id">User profile ID</param>
        /// <param name="fullName">Full name</param>
        /// <param name="mobileNumber">Mobile number</param>
        /// <param name="schoolName">School name</param>
        /// <param name="state">State</param>
        /// <param name="schoolRegion">School region</param>
        /// <param name="passoutYear">Passout year</param>
        /// <param name="role">Role</param>
        /// <param name="university">University</param>
        /// <param name="currentState">Current state</param>
        /// <param name="currentDistrict">Current district</param>
        /// <param name="bloodGroup">Blood group</param>
        /// <returns>Updated user profile or null if not found</returns>
        Task<UserProfile?> UpdateUserProfileAsync(
            int id,
            string fullName,
            string mobileNumber,
            string schoolName,
            string state,
            string schoolRegion,
            int passoutYear,
            string role,
            string university,
            string currentState,
            string currentDistrict,
            string bloodGroup);

        /// <summary>
        /// Delete a user profile
        /// </summary>
        /// <param name="id">User profile ID</param>
        /// <returns>True if deleted successfully, false otherwise</returns>
        Task<bool> DeleteUserProfileAsync(int id);

        /// <summary>
        /// Get all user profiles with pagination
        /// </summary>
        /// <param name="pageNumber">Page number (1-based)</param>
        /// <param name="pageSize">Number of records per page</param>
        /// <param name="role">Optional role filter</param>
        /// <returns>Tuple containing list of user profiles and total count</returns>
        Task<(List<UserProfile> Profiles, int TotalCount)> GetAllUserProfilesAsync(int pageNumber = 1, int pageSize = 50, string? role = null);

        /// <summary>
        /// Get all roles
        /// </summary>
        /// <returns>List of all roles</returns>
        Task<List<Role>> GetAllRolesAsync();
    }
}

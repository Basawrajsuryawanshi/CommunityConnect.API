using CommunityConnect.Core.Data;
using CommunityConnect.Core.Entities;
using CommunityConnect.Core.Services;
using Microsoft.Extensions.Logging;

namespace CommunityConnect.Infrastructure.Services
{
    /// <summary>
    /// Service implementation for user profile operations
    /// </summary>
    public class UserProfileService : IUserProfileService
    {
        private readonly IAuthDatabase _authDatabase;
        private readonly ILogger<UserProfileService> _logger;

        public UserProfileService(IAuthDatabase authDatabase, ILogger<UserProfileService> logger)
        {
            _authDatabase = authDatabase;
            _logger = logger;
        }

        public async Task<UserProfile?> GetUserProfileByIdAsync(int id)
        {
            try
            {
                _logger.LogInformation("Retrieving user profile for ID: {UserId}", id);
                var profile = await _authDatabase.GetUserProfileByIdAsync(id);

                if (profile == null)
                {
                    _logger.LogWarning("User profile not found for ID: {UserId}", id);
                }

                return profile;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving user profile for ID: {UserId}", id);
                throw;
            }
        }

        public async Task<UserProfile> CreateUserProfileAsync(
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
            string bloodGroup)
        {
            try
            {
                _logger.LogInformation("Creating user profile for user ID: {UserId}", id);

                var profile = await _authDatabase.CreateUserProfileAsync(
                    id,
                    fullName,
                    email,
                    mobileNumber,
                    schoolName,
                    state,
                    schoolRegion,
                    passoutYear,
                    role,
                    university,
                    currentState,
                    currentDistrict,
                    bloodGroup);

                _logger.LogInformation("User profile created successfully for user ID: {UserId}", id);
                return profile;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating user profile for user ID: {UserId}", id);
                throw;
            }
        }

        public async Task<UserProfile?> UpdateUserProfileAsync(
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
            string bloodGroup)
        {
            try
            {
                _logger.LogInformation("Updating user profile for ID: {UserId}", id);

                // First check if the profile exists
                var existingProfile = await _authDatabase.GetUserProfileByIdAsync(id);
                if (existingProfile == null)
                {
                    _logger.LogWarning("User profile not found for ID: {UserId}", id);
                    return null;
                }

                // TODO: Implement sp_UpdateUserProfile stored procedure in database
                // For now, return null indicating update needs to be implemented
                _logger.LogWarning("Update user profile not yet implemented");
                throw new NotImplementedException("Update user profile functionality requires sp_UpdateUserProfile stored procedure to be created in the database");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating user profile for ID: {UserId}", id);
                throw;
            }
        }

        public async Task<bool> DeleteUserProfileAsync(int id)
        {
            try
            {
                _logger.LogInformation("Deleting user profile for ID: {UserId}", id);

                // First check if the profile exists
                var existingProfile = await _authDatabase.GetUserProfileByIdAsync(id);
                if (existingProfile == null)
                {
                    _logger.LogWarning("User profile not found for ID: {UserId}", id);
                    return false;
                }

                // TODO: Implement sp_DeleteUserProfile stored procedure in database
                // For now, return false indicating delete needs to be implemented
                _logger.LogWarning("Delete user profile not yet implemented");
                throw new NotImplementedException("Delete user profile functionality requires sp_DeleteUserProfile stored procedure to be created in the database");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting user profile for ID: {UserId}", id);
                throw;
            }
        }

        public async Task<(List<UserProfile> Profiles, int TotalCount)> GetAllUserProfilesAsync(int pageNumber = 1, int pageSize = 50, string? role = null)
        {
            try
            {
                _logger.LogInformation("Retrieving all user profiles - Page: {PageNumber}, PageSize: {PageSize}, Role: {Role}", 
                    pageNumber, pageSize, role ?? "All");

                var (profiles, totalCount) = await _authDatabase.GetAllUserProfilesAsync(pageNumber, pageSize);

                // Apply role filter if specified
                if (!string.IsNullOrWhiteSpace(role))
                {
                    profiles = profiles.Where(p => p.Role.Equals(role, StringComparison.OrdinalIgnoreCase)).ToList();
                    totalCount = profiles.Count; // Update total count after filtering
                }

                _logger.LogInformation("Retrieved {Count} user profiles out of {TotalCount} total", 
                    profiles.Count, totalCount);

                return (profiles, totalCount);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving all user profiles");
                throw;
            }
        }

        public async Task<List<Role>> GetAllRolesAsync()
        {
            try
            {
                _logger.LogInformation("Retrieving all roles");

                var roles = await _authDatabase.GetAllRolesAsync();

                _logger.LogInformation("Retrieved {Count} roles", roles.Count);

                return roles;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving all roles");
                throw;
            }
        }
    }
}

using CommunityConnect.Contracts.User;
using CommunityConnect.User.Core.Data;
using CommunityConnect.User.Core.Entities;
using CommunityConnect.User.Core.Services;

namespace CommunityConnect.User.Infrastructure.Services
{
    public class UserService : IUserService
    {
        private readonly IUserDatabase _database;

        public UserService(IUserDatabase database)
        {
            _database = database;
        }

        // Profile Management
        public async Task<UserProfileResponse?> GetUserProfileAsync(Guid userId)
        {
            var profile = await _database.GetUserProfileByIdAsync(userId);
            return profile == null ? null : MapToProfileResponse(profile);
        }

        public async Task<UserProfileResponse> CreateUserProfileAsync(CreateUserProfileRequest request)
        {
            // Check if profile already exists
            var existingProfile = await _database.GetUserProfileByIdAsync(request.UserId);

            if (existingProfile != null)
            {
                throw new InvalidOperationException($"User profile already exists for user {request.UserId}");
            }

            // Create new user profile using stored procedure
            var profile = await _database.CreateUserProfileAsync(
                id: request.UserId,
                firstName: request.FirstName,
                lastName: request.LastName,
                email: "", // Email should come from Auth service
                displayName: request.DisplayName,
                bio: request.Bio,
                dateOfBirth: request.DateOfBirth,
                gender: request.Gender,
                phoneNumber: request.PhoneNumber,
                jnv: request.JNV,
                batch: request.Batch,
                studentId: request.StudentId
            );

            // Create default preferences
            await _database.UpsertUserPreferencesAsync(request.UserId);

            // Assign default User role
            var roles = await _database.GetAllRolesAsync();
            var userRole = roles.FirstOrDefault(r => r.Name == "User");
            if (userRole != null)
            {
                await _database.AssignUserRoleAsync(request.UserId, userRole.Id);
            }

            return MapToProfileResponse(profile);
        }

        public async Task<UserProfileResponse> UpdateUserProfileAsync(Guid userId, UpdateUserProfileRequest request)
        {
            // Get existing profile
            var existingProfile = await _database.GetUserProfileByIdAsync(userId);

            if (existingProfile == null)
            {
                throw new KeyNotFoundException($"User profile not found for user {userId}");
            }

            // Check if profile is complete
            var isProfileComplete = !string.IsNullOrWhiteSpace(request.FirstName ?? existingProfile.FirstName) &&
                                   !string.IsNullOrWhiteSpace(request.LastName ?? existingProfile.LastName) &&
                                   !string.IsNullOrWhiteSpace(request.JNV ?? existingProfile.JNV) &&
                                   !string.IsNullOrWhiteSpace(request.Batch ?? existingProfile.Batch);

            // Update profile using stored procedure
            var profile = await _database.UpdateUserProfileAsync(
                id: userId,
                firstName: request.FirstName,
                lastName: request.LastName,
                displayName: request.DisplayName,
                avatarUrl: request.AvatarUrl,
                bio: request.Bio,
                dateOfBirth: request.DateOfBirth,
                gender: request.Gender,
                phoneNumber: request.PhoneNumber,
                jnv: request.JNV,
                batch: request.Batch,
                studentId: request.StudentId,
                addressLine1: request.AddressLine1,
                addressLine2: request.AddressLine2,
                city: request.City,
                state: request.State,
                country: request.Country,
                postalCode: request.PostalCode,
                linkedInUrl: request.LinkedInUrl,
                twitterHandle: request.TwitterHandle,
                gitHubUsername: request.GitHubUsername,
                isProfileComplete: isProfileComplete,
                isPublic: request.IsPublic
            );

            return profile == null 
                ? throw new InvalidOperationException("Failed to update user profile")
                : MapToProfileResponse(profile);
        }

        public async Task DeleteUserProfileAsync(Guid userId)
        {
            var deleted = await _database.DeleteUserProfileAsync(userId);

            if (!deleted)
            {
                throw new KeyNotFoundException($"User profile not found for user {userId}");
            }
        }

        // User Search
        public async Task<SearchUsersResponse> SearchUsersAsync(SearchUsersRequest request)
        {
            IEnumerable<UserProfile> profiles;

            // If searching by JNV and batch
            if (!string.IsNullOrWhiteSpace(request.JNV) && !string.IsNullOrWhiteSpace(request.Batch))
            {
                var allByJNV = await _database.GetUserProfilesByJNVAsync(request.JNV);
                profiles = allByJNV.Where(p => p.Batch == request.Batch);
            }
            // If searching by JNV only
            else if (!string.IsNullOrWhiteSpace(request.JNV))
            {
                profiles = await _database.GetUserProfilesByJNVAsync(request.JNV);
            }
            // If searching by batch only
            else if (!string.IsNullOrWhiteSpace(request.Batch))
            {
                profiles = await _database.GetUserProfilesByBatchAsync(request.Batch);
            }
            // If searching by  term
            else if (!string.IsNullOrWhiteSpace(request.SearchTerm))
            {
                profiles = await _database.SearchUserProfilesAsync(request.SearchTerm);
            }
            // Get all public profiles
            else
            {
                profiles = await _database.SearchUserProfilesAsync("");
            }

            var profilesList = profiles.ToList();
            var totalCount = profilesList.Count;

            // Apply pagination
            var paginatedProfiles = profilesList
                .Skip((request.Page - 1) * request.PageSize)
                .Take(request.PageSize)
                .Select(MapToBasicInfo)
                .ToList();

            var totalPages = (int)Math.Ceiling(totalCount / (double)request.PageSize);

            return new SearchUsersResponse(
                paginatedProfiles,
                totalCount,
                request.Page,
                request.PageSize,
                totalPages
            );
        }

        public async Task<List<UserBasicInfoResponse>> GetUsersByJNVAndBatchAsync(string jnv, string batch)
        {
            var profiles = await _database.GetUserProfilesByJNVAsync(jnv);
            var filteredProfiles = profiles.Where(p => p.Batch == batch);

            return filteredProfiles.Select(MapToBasicInfo).ToList();
        }

        // Preferences
        public async Task<UserPreferencesResponse?> GetUserPreferencesAsync(Guid userId)
        {
            var preferences = await _database.GetUserPreferencesAsync(userId);
            return preferences == null ? null : MapToPreferencesResponse(preferences);
        }

        public async Task<UserPreferencesResponse> UpdateUserPreferencesAsync(Guid userId, UpdateUserPreferencesRequest request)
        {
            // Get existing preferences
            var existing = await _database.GetUserPreferencesAsync(userId);

            // Upsert preferences
            var preferences = await _database.UpsertUserPreferencesAsync(
                userId: userId,
                emailNotifications: request.EmailNotifications ?? existing?.EmailNotifications ?? true,
                pushNotifications: request.PushNotifications ?? existing?.PushNotifications ?? true,
                smsNotifications: request.SmsNotifications ?? existing?.SmsNotifications ?? false,
                eventReminders: existing?.EventReminders ?? true,
                announcementAlerts: existing?.AnnouncementAlerts ?? true,
                discussionUpdates: existing?.DiscussionUpdates ?? true,
                theme: request.Theme ?? existing?.Theme ?? "light",
                language: request.Language ?? existing?.Language ?? "en"
            );

            return MapToPreferencesResponse(preferences);
        }

        // Connections
        public async Task<List<UserConnectionResponse>> GetUserConnectionsAsync(Guid userId)
        {
            var connections = await _database.GetUserConnectionsAsync(userId, "Accepted");

            // We need to fetch connected user profiles for each connection
            var result = new List<UserConnectionResponse>();

            foreach (var connection in connections)
            {
                var connectedUser = await _database.GetUserProfileByIdAsync(connection.ConnectedUserId);
                if (connectedUser != null)
                {
                    result.Add(new UserConnectionResponse(
                        connection.Id,
                        connection.UserId,
                        connection.ConnectedUserId,
                        "Friend",
                        connection.Status,
                        connection.RequestedAt,
                        MapToBasicInfo(connectedUser)
                    ));
                }
            }

            return result;
        }

        public async Task<UserConnectionResponse> CreateConnectionAsync(Guid userId, CreateConnectionRequest request)
        {
            // Check if connected user exists
            var connectedUser = await _database.GetUserProfileByIdAsync(request.ConnectedUserId);
            if (connectedUser == null)
            {
                throw new KeyNotFoundException($"User not found: {request.ConnectedUserId}");
            }

            // Check if connection already exists
            var existingConnections = await _database.GetUserConnectionsAsync(userId);
            if (existingConnections.Any(c => c.ConnectedUserId == request.ConnectedUserId))
            {
                throw new InvalidOperationException("Connection already exists");
            }

            // Create connection request
            var connection = await _database.CreateConnectionRequestAsync(userId, request.ConnectedUserId);

            return new UserConnectionResponse(
                connection.Id,
                connection.UserId,
                connection.ConnectedUserId,
                request.ConnectionType,
                connection.Status,
                connection.RequestedAt,
                MapToBasicInfo(connectedUser)
            );
        }

        public async Task RemoveConnectionAsync(Guid userId, int connectionId)
        {
            var connections = await _database.GetUserConnectionsAsync(userId);
            var connection = connections.FirstOrDefault(c => c.Id == connectionId);

            if (connection == null)
            {
                throw new KeyNotFoundException($"Connection not found: {connectionId}");
            }

            // For now, we'll use reject to remove. In production, add sp_delete_connection
            var rejected = await _database.RejectConnectionRequestAsync(connectionId, connection.ConnectedUserId);

            if (!rejected)
            {
                throw new InvalidOperationException("Failed to remove connection");
            }
        }

        public async Task<bool> CheckConnectionExistsAsync(Guid userId, Guid connectedUserId)
        {
            var connections = await _database.GetUserConnectionsAsync(userId, "Accepted");
            return connections.Any(c => c.ConnectedUserId == connectedUserId);
        }

        // Mapping helpers
        private static UserProfileResponse MapToProfileResponse(UserProfile profile)
        {
            return new UserProfileResponse(
                profile.Id,
                profile.FirstName,
                profile.LastName,
                profile.DisplayName,
                profile.AvatarUrl,
                profile.Bio,
                profile.DateOfBirth,
                profile.Gender,
                profile.PhoneNumber,
                profile.JNV,
                profile.Batch,
                profile.StudentId,
                profile.AddressLine1,
                profile.AddressLine2,
                profile.City,
                profile.State,
                profile.Country,
                profile.PostalCode,
                profile.LinkedInUrl,
                profile.TwitterHandle,
                profile.GitHubUsername,
                profile.IsProfileComplete,
                profile.IsPublic,
                profile.CreatedAt,
                profile.UpdatedAt
            );
        }

        private static UserBasicInfoResponse MapToBasicInfo(UserProfile profile)
        {
            return new UserBasicInfoResponse(
                profile.Id,
                profile.FirstName,
                profile.LastName,
                profile.DisplayName,
                profile.AvatarUrl,
                profile.JNV,
                profile.Batch
            );
        }

        private static UserPreferencesResponse MapToPreferencesResponse(UserPreference preferences)
        {
            return new UserPreferencesResponse(
                preferences.UserId,
                preferences.EmailNotifications,
                preferences.PushNotifications,
                preferences.SmsNotifications,
                preferences.Theme,
                preferences.Language,
                preferences.TimeZone
            );
        }
    }
}

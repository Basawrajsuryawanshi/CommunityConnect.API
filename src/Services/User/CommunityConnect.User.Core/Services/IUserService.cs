using CommunityConnect.Contracts.User;

namespace CommunityConnect.User.Core.Services
{
    public interface IUserService
    {
        // Profile Management
        Task<UserProfileResponse?> GetUserProfileAsync(Guid userId);
        Task<UserProfileResponse> CreateUserProfileAsync(CreateUserProfileRequest request);
        Task<UserProfileResponse> UpdateUserProfileAsync(Guid userId, UpdateUserProfileRequest request);
        Task DeleteUserProfileAsync(Guid userId);

        // User Search
        Task<SearchUsersResponse> SearchUsersAsync(SearchUsersRequest request);
        Task<List<UserBasicInfoResponse>> GetUsersByJNVAndBatchAsync(string jnv, string batch);

        // Preferences
        Task<UserPreferencesResponse?> GetUserPreferencesAsync(Guid userId);
        Task<UserPreferencesResponse> UpdateUserPreferencesAsync(Guid userId, UpdateUserPreferencesRequest request);

        // Connections
        Task<List<UserConnectionResponse>> GetUserConnectionsAsync(Guid userId);
        Task<UserConnectionResponse> CreateConnectionAsync(Guid userId, CreateConnectionRequest request);
        Task RemoveConnectionAsync(Guid userId, int connectionId);
        Task<bool> CheckConnectionExistsAsync(Guid userId, Guid connectedUserId);
    }
}

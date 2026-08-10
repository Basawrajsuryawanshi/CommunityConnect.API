using CommunityConnect.User.Core.Data;
using CommunityConnect.User.Core.Entities;
using Microsoft.Extensions.Configuration;
using Microsoft.Data.SqlClient;
using System.Data;

namespace CommunityConnect.User.Infrastructure.Data
{
    /// <summary>
    /// Implementation of IUserDatabase using ADO.NET and stored procedures
    /// Executes stored procedures directly against SQL Server (UserDB)
    /// </summary>
    public class UserDatabaseService : IUserDatabase
    {
        private readonly string _connectionString;

        public UserDatabaseService(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("DefaultConnection connection string is not configured");
        }

        // ============================================
        // HELPER METHODS
        // ============================================

        private SqlConnection GetConnection()
        {
            return new SqlConnection(_connectionString);
        }

        private async Task SetConnectionOptionsAsync(SqlConnection connection)
        {
            using var command = new SqlCommand("SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;", connection);
            await command.ExecuteNonQueryAsync();
        }

        private async Task<T?> ExecuteScalarAsync<T>(string storedProcedure, params SqlParameter[] parameters)
        {
            using var connection = GetConnection();
            await connection.OpenAsync();
            await SetConnectionOptionsAsync(connection);

            using var command = new SqlCommand(storedProcedure, connection)
            {
                CommandType = CommandType.StoredProcedure
            };

            command.Parameters.AddRange(parameters);
            var result = await command.ExecuteScalarAsync();

            return result == null || result == DBNull.Value ? default : (T)result;
        }

        private async Task<int> ExecuteNonQueryAsync(string storedProcedure, params SqlParameter[] parameters)
        {
            using var connection = GetConnection();
            await connection.OpenAsync();
            await SetConnectionOptionsAsync(connection);

            using var command = new SqlCommand(storedProcedure, connection)
            {
                CommandType = CommandType.StoredProcedure
            };

            command.Parameters.AddRange(parameters);
            return await command.ExecuteNonQueryAsync();
        }

        private async Task<T?> ExecuteReaderSingleAsync<T>(string storedProcedure, Func<SqlDataReader, T> mapper, params SqlParameter[] parameters)
        {
            using var connection = GetConnection();
            await connection.OpenAsync();
            await SetConnectionOptionsAsync(connection);

            using var command = new SqlCommand(storedProcedure, connection)
            {
                CommandType = CommandType.StoredProcedure
            };

            command.Parameters.AddRange(parameters);

            using var reader = await command.ExecuteReaderAsync();

            if (await reader.ReadAsync())
            {
                return mapper(reader);
            }

            return default;
        }

        private async Task<List<T>> ExecuteReaderListAsync<T>(string storedProcedure, Func<SqlDataReader, T> mapper, params SqlParameter[] parameters)
        {
            var results = new List<T>();

            using var connection = GetConnection();
            await connection.OpenAsync();
            await SetConnectionOptionsAsync(connection);

            using var command = new SqlCommand(storedProcedure, connection)
            {
                CommandType = CommandType.StoredProcedure
            };

            command.Parameters.AddRange(parameters);

            using var reader = await command.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                results.Add(mapper(reader));
            }

            return results;
        }

        // ============================================
        // MAPPERS
        // ============================================

        private UserProfile MapUserProfile(SqlDataReader reader)
        {
            return new UserProfile
            {
                Id = reader.GetGuid(reader.GetOrdinal("Id")),
                FirstName = reader.GetString(reader.GetOrdinal("FirstName")),
                LastName = reader.GetString(reader.GetOrdinal("LastName")),
                DisplayName = reader.IsDBNull(reader.GetOrdinal("DisplayName")) ? null : reader.GetString(reader.GetOrdinal("DisplayName")),
                AvatarUrl = reader.IsDBNull(reader.GetOrdinal("AvatarUrl")) ? null : reader.GetString(reader.GetOrdinal("AvatarUrl")),
                Bio = reader.IsDBNull(reader.GetOrdinal("Bio")) ? null : reader.GetString(reader.GetOrdinal("Bio")),
                DateOfBirth = reader.IsDBNull(reader.GetOrdinal("DateOfBirth")) ? null : reader.GetDateTime(reader.GetOrdinal("DateOfBirth")),
                Gender = reader.IsDBNull(reader.GetOrdinal("Gender")) ? null : reader.GetString(reader.GetOrdinal("Gender")),
                PhoneNumber = reader.IsDBNull(reader.GetOrdinal("PhoneNumber")) ? null : reader.GetString(reader.GetOrdinal("PhoneNumber")),
                JNV = reader.IsDBNull(reader.GetOrdinal("JNV")) ? null : reader.GetString(reader.GetOrdinal("JNV")),
                Batch = reader.IsDBNull(reader.GetOrdinal("Batch")) ? null : reader.GetString(reader.GetOrdinal("Batch")),
                StudentId = reader.IsDBNull(reader.GetOrdinal("StudentId")) ? null : reader.GetString(reader.GetOrdinal("StudentId")),
                AddressLine1 = reader.IsDBNull(reader.GetOrdinal("AddressLine1")) ? null : reader.GetString(reader.GetOrdinal("AddressLine1")),
                AddressLine2 = reader.IsDBNull(reader.GetOrdinal("AddressLine2")) ? null : reader.GetString(reader.GetOrdinal("AddressLine2")),
                City = reader.IsDBNull(reader.GetOrdinal("City")) ? null : reader.GetString(reader.GetOrdinal("City")),
                State = reader.IsDBNull(reader.GetOrdinal("State")) ? null : reader.GetString(reader.GetOrdinal("State")),
                Country = reader.IsDBNull(reader.GetOrdinal("Country")) ? null : reader.GetString(reader.GetOrdinal("Country")),
                PostalCode = reader.IsDBNull(reader.GetOrdinal("PostalCode")) ? null : reader.GetString(reader.GetOrdinal("PostalCode")),
                LinkedInUrl = reader.IsDBNull(reader.GetOrdinal("LinkedInUrl")) ? null : reader.GetString(reader.GetOrdinal("LinkedInUrl")),
                TwitterHandle = reader.IsDBNull(reader.GetOrdinal("TwitterHandle")) ? null : reader.GetString(reader.GetOrdinal("TwitterHandle")),
                GitHubUsername = reader.IsDBNull(reader.GetOrdinal("GitHubUsername")) ? null : reader.GetString(reader.GetOrdinal("GitHubUsername")),
                IsProfileComplete = reader.GetBoolean(reader.GetOrdinal("IsProfileComplete")),
                IsPublic = reader.GetBoolean(reader.GetOrdinal("IsPublic")),
                CreatedAt = reader.GetDateTime(reader.GetOrdinal("CreatedAt")),
                UpdatedAt = reader.GetDateTime(reader.GetOrdinal("UpdatedAt"))
            };
        }

        private Role MapRole(SqlDataReader reader)
        {
            return new Role
            {
                Id = reader.GetInt32(reader.GetOrdinal("Id")),
                Name = reader.GetString(reader.GetOrdinal("Name")),
                Description = reader.IsDBNull(reader.GetOrdinal("Description")) ? null : reader.GetString(reader.GetOrdinal("Description")),
                CreatedAt = reader.GetDateTime(reader.GetOrdinal("CreatedAt"))
            };
        }

        private UserRoleAssignment MapUserRoleAssignment(SqlDataReader reader)
        {
            return new UserRoleAssignment
            {
                Id = reader.GetInt32(reader.GetOrdinal("Id")),
                UserId = reader.GetGuid(reader.GetOrdinal("UserId")),
                RoleId = reader.GetInt32(reader.GetOrdinal("RoleId")),
                AssignedAt = reader.GetDateTime(reader.GetOrdinal("AssignedAt")),
                AssignedBy = reader.IsDBNull(reader.GetOrdinal("AssignedBy")) ? null : reader.GetGuid(reader.GetOrdinal("AssignedBy")),
                ExpiresAt = reader.IsDBNull(reader.GetOrdinal("ExpiresAt")) ? null : reader.GetDateTime(reader.GetOrdinal("ExpiresAt"))
            };
        }

        private UserPreference MapUserPreference(SqlDataReader reader)
        {
            return new UserPreference
            {
                Id = reader.GetInt32(reader.GetOrdinal("Id")),
                UserId = reader.GetGuid(reader.GetOrdinal("UserId")),
                EmailNotifications = reader.GetBoolean(reader.GetOrdinal("EmailNotifications")),
                PushNotifications = reader.GetBoolean(reader.GetOrdinal("PushNotifications")),
                SmsNotifications = reader.GetBoolean(reader.GetOrdinal("SmsNotifications")),
                EventReminders = reader.GetBoolean(reader.GetOrdinal("EventReminders")),
                AnnouncementAlerts = reader.GetBoolean(reader.GetOrdinal("AnnouncementAlerts")),
                DiscussionUpdates = reader.GetBoolean(reader.GetOrdinal("DiscussionUpdates")),
                Theme = reader.GetString(reader.GetOrdinal("Theme")),
                Language = reader.GetString(reader.GetOrdinal("Language")),
                TimeZone = reader.GetString(reader.GetOrdinal("TimeZone")),
                CreatedAt = reader.GetDateTime(reader.GetOrdinal("CreatedAt")),
                UpdatedAt = reader.GetDateTime(reader.GetOrdinal("UpdatedAt"))
            };
        }

        private UserConnection MapUserConnection(SqlDataReader reader)
        {
            return new UserConnection
            {
                Id = reader.GetInt32(reader.GetOrdinal("Id")),
                UserId = reader.GetGuid(reader.GetOrdinal("UserId")),
                ConnectedUserId = reader.GetGuid(reader.GetOrdinal("ConnectedUserId")),
                Status = reader.GetString(reader.GetOrdinal("Status")),
                RequestedAt = reader.GetDateTime(reader.GetOrdinal("RequestedAt")),
                AcceptedAt = reader.IsDBNull(reader.GetOrdinal("AcceptedAt")) ? null : reader.GetDateTime(reader.GetOrdinal("AcceptedAt"))
            };
        }

        // ============================================
        // USER PROFILE OPERATIONS
        // ============================================

        public async Task<UserProfile> CreateUserProfileAsync(
            Guid id, string firstName, string lastName, string email,
            string? displayName = null, string? avatarUrl = null, string? bio = null,
            DateTime? dateOfBirth = null, string? gender = null, string? phoneNumber = null,
            string? jnv = null, string? batch = null, string? studentId = null,
            string? addressLine1 = null, string? addressLine2 = null, string? city = null,
            string? state = null, string? country = null, string? postalCode = null,
            string? linkedInUrl = null, string? twitterHandle = null, string? gitHubUsername = null)
        {
            var parameters = new[]
            {
                new SqlParameter("@Id", id),
                new SqlParameter("@FirstName", firstName),
                new SqlParameter("@LastName", lastName),
                new SqlParameter("@DisplayName", (object?)displayName ?? DBNull.Value),
                new SqlParameter("@AvatarUrl", (object?)avatarUrl ?? DBNull.Value),
                new SqlParameter("@Bio", (object?)bio ?? DBNull.Value),
                new SqlParameter("@DateOfBirth", (object?)dateOfBirth ?? DBNull.Value),
                new SqlParameter("@Gender", (object?)gender ?? DBNull.Value),
                new SqlParameter("@PhoneNumber", (object?)phoneNumber ?? DBNull.Value),
                new SqlParameter("@JNV", (object?)jnv ?? DBNull.Value),
                new SqlParameter("@Batch", (object?)batch ?? DBNull.Value),
                new SqlParameter("@StudentId", (object?)studentId ?? DBNull.Value),
                new SqlParameter("@AddressLine1", (object?)addressLine1 ?? DBNull.Value),
                new SqlParameter("@AddressLine2", (object?)addressLine2 ?? DBNull.Value),
                new SqlParameter("@City", (object?)city ?? DBNull.Value),
                new SqlParameter("@State", (object?)state ?? DBNull.Value),
                new SqlParameter("@Country", (object?)country ?? DBNull.Value),
                new SqlParameter("@PostalCode", (object?)postalCode ?? DBNull.Value),
                new SqlParameter("@LinkedInUrl", (object?)linkedInUrl ?? DBNull.Value),
                new SqlParameter("@TwitterHandle", (object?)twitterHandle ?? DBNull.Value),
                new SqlParameter("@GitHubUsername", (object?)gitHubUsername ?? DBNull.Value)
            };

            var profile = await ExecuteReaderSingleAsync("sp_CreateUserProfile", MapUserProfile, parameters);
            return profile ?? throw new InvalidOperationException("Failed to create user profile");
        }

        public async Task<UserProfile?> GetUserProfileByIdAsync(Guid userId)
        {
            var parameters = new[]
            {
                new SqlParameter("@Id", userId)
            };

            return await ExecuteReaderSingleAsync("sp_GetUserProfileById", MapUserProfile, parameters);
        }

        public async Task<UserProfile?> UpdateUserProfileAsync(
            Guid id, string? firstName = null, string? lastName = null, string? displayName = null,
            string? avatarUrl = null, string? bio = null, DateTime? dateOfBirth = null,
            string? gender = null, string? phoneNumber = null, string? jnv = null,
            string? batch = null, string? studentId = null, string? addressLine1 = null,
            string? addressLine2 = null, string? city = null, string? state = null,
            string? country = null, string? postalCode = null, string? linkedInUrl = null,
            string? twitterHandle = null, string? gitHubUsername = null,
            bool? isProfileComplete = null, bool? isPublic = null)
        {
            var parameters = new[]
            {
                new SqlParameter("@Id", id),
                new SqlParameter("@FirstName", (object?)firstName ?? DBNull.Value),
                new SqlParameter("@LastName", (object?)lastName ?? DBNull.Value),
                new SqlParameter("@DisplayName", (object?)displayName ?? DBNull.Value),
                new SqlParameter("@AvatarUrl", (object?)avatarUrl ?? DBNull.Value),
                new SqlParameter("@Bio", (object?)bio ?? DBNull.Value),
                new SqlParameter("@DateOfBirth", (object?)dateOfBirth ?? DBNull.Value),
                new SqlParameter("@Gender", (object?)gender ?? DBNull.Value),
                new SqlParameter("@PhoneNumber", (object?)phoneNumber ?? DBNull.Value),
                new SqlParameter("@JNV", (object?)jnv ?? DBNull.Value),
                new SqlParameter("@Batch", (object?)batch ?? DBNull.Value),
                new SqlParameter("@StudentId", (object?)studentId ?? DBNull.Value),
                new SqlParameter("@AddressLine1", (object?)addressLine1 ?? DBNull.Value),
                new SqlParameter("@AddressLine2", (object?)addressLine2 ?? DBNull.Value),
                new SqlParameter("@City", (object?)city ?? DBNull.Value),
                new SqlParameter("@State", (object?)state ?? DBNull.Value),
                new SqlParameter("@Country", (object?)country ?? DBNull.Value),
                new SqlParameter("@PostalCode", (object?)postalCode ?? DBNull.Value),
                new SqlParameter("@LinkedInUrl", (object?)linkedInUrl ?? DBNull.Value),
                new SqlParameter("@TwitterHandle", (object?)twitterHandle ?? DBNull.Value),
                new SqlParameter("@GitHubUsername", (object?)gitHubUsername ?? DBNull.Value),
                new SqlParameter("@IsProfileComplete", (object?)isProfileComplete ?? DBNull.Value),
                new SqlParameter("@IsPublic", (object?)isPublic ?? DBNull.Value)
            };

            return await ExecuteReaderSingleAsync("sp_UpdateUserProfile", MapUserProfile, parameters);
        }

        public async Task<bool> DeleteUserProfileAsync(Guid userId)
        {
            var parameters = new[]
            {
                new SqlParameter("@Id", userId)
            };

            var affectedRows = await ExecuteNonQueryAsync("sp_DeleteUserProfile", parameters);
            return affectedRows > 0;
        }

        public async Task<IEnumerable<UserProfile>> SearchUserProfilesAsync(string searchTerm, int limit = 50, int offset = 0)
        {
            var parameters = new[]
            {
                new SqlParameter("@SearchTerm", searchTerm),
                new SqlParameter("@Limit", limit),
                new SqlParameter("@Offset", offset)
            };

            return await ExecuteReaderListAsync("sp_SearchUserProfiles", MapUserProfile, parameters);
        }

        public async Task<IEnumerable<UserProfile>> GetUserProfilesByJNVAsync(string jnv, int limit = 50, int offset = 0)
        {
            var parameters = new[]
            {
                new SqlParameter("@JNV", jnv),
                new SqlParameter("@Limit", limit),
                new SqlParameter("@Offset", offset)
            };

            return await ExecuteReaderListAsync("sp_GetUserProfilesByJNV", MapUserProfile, parameters);
        }

        public async Task<IEnumerable<UserProfile>> GetUserProfilesByBatchAsync(string batch, int limit = 50, int offset = 0)
        {
            var parameters = new[]
            {
                new SqlParameter("@Batch", batch),
                new SqlParameter("@Limit", limit),
                new SqlParameter("@Offset", offset)
            };

            return await ExecuteReaderListAsync("sp_GetUserProfilesByBatch", MapUserProfile, parameters);
        }

        // ============================================
        // ROLE OPERATIONS
        // ============================================

        public async Task<IEnumerable<Role>> GetAllRolesAsync()
        {
            return await ExecuteReaderListAsync("sp_GetAllRoles", MapRole);
        }

        public async Task<UserRoleAssignment> AssignUserRoleAsync(Guid userId, int roleId, Guid? assignedBy = null, DateTime? expiresAt = null)
        {
            var parameters = new[]
            {
                new SqlParameter("@UserId", userId),
                new SqlParameter("@RoleId", roleId),
                new SqlParameter("@AssignedBy", (object?)assignedBy ?? DBNull.Value),
                new SqlParameter("@ExpiresAt", (object?)expiresAt ?? DBNull.Value)
            };

            var assignment = await ExecuteReaderSingleAsync("sp_AssignUserRole", MapUserRoleAssignment, parameters);
            return assignment ?? throw new InvalidOperationException("Failed to assign role");
        }

        public async Task<bool> RemoveUserRoleAsync(Guid userId, int roleId)
        {
            var parameters = new[]
            {
                new SqlParameter("@UserId", userId),
                new SqlParameter("@RoleId", roleId)
            };

            var affectedRows = await ExecuteNonQueryAsync("sp_RemoveUserRole", parameters);
            return affectedRows > 0;
        }

        public async Task<IEnumerable<UserRoleAssignment>> GetUserRolesAsync(Guid userId)
        {
            var parameters = new[]
            {
                new SqlParameter("@UserId", userId)
            };

            return await ExecuteReaderListAsync("sp_GetUserRoles", MapUserRoleAssignment, parameters);
        }

        // ============================================
        // USER PREFERENCES OPERATIONS
        // ============================================

        public async Task<UserPreference?> GetUserPreferencesAsync(Guid userId)
        {
            var parameters = new[]
            {
                new SqlParameter("@UserId", userId)
            };

            return await ExecuteReaderSingleAsync("sp_GetUserPreferences", MapUserPreference, parameters);
        }

        public async Task<UserPreference> UpsertUserPreferencesAsync(
            Guid userId, bool emailNotifications = true, bool pushNotifications = true,
            bool smsNotifications = false, bool eventReminders = true,
            bool announcementAlerts = true, bool discussionUpdates = true,
            string theme = "light", string language = "en")
        {
            var parameters = new[]
            {
                new SqlParameter("@UserId", userId),
                new SqlParameter("@EmailNotifications", emailNotifications),
                new SqlParameter("@PushNotifications", pushNotifications),
                new SqlParameter("@SmsNotifications", smsNotifications),
                new SqlParameter("@EventReminders", eventReminders),
                new SqlParameter("@AnnouncementAlerts", announcementAlerts),
                new SqlParameter("@DiscussionUpdates", discussionUpdates),
                new SqlParameter("@Theme", theme),
                new SqlParameter("@Language", language)
            };

            var preference = await ExecuteReaderSingleAsync("sp_UpsertUserPreferences", MapUserPreference, parameters);
            return preference ?? throw new InvalidOperationException("Failed to upsert user preferences");
        }

        // ============================================
        // USER CONNECTIONS OPERATIONS
        // ============================================

        public async Task<UserConnection> CreateConnectionRequestAsync(Guid userId, Guid connectedUserId)
        {
            var parameters = new[]
            {
                new SqlParameter("@UserId", userId),
                new SqlParameter("@ConnectedUserId", connectedUserId)
            };

            var connection = await ExecuteReaderSingleAsync("sp_CreateConnectionRequest", MapUserConnection, parameters);
            return connection ?? throw new InvalidOperationException("Failed to create connection request");
        }

        public async Task<UserConnection?> AcceptConnectionRequestAsync(int connectionId, Guid connectedUserId)
        {
            var parameters = new[]
            {
                new SqlParameter("@ConnectionId", connectionId),
                new SqlParameter("@ConnectedUserId", connectedUserId)
            };

            return await ExecuteReaderSingleAsync("sp_AcceptConnectionRequest", MapUserConnection, parameters);
        }

        public async Task<bool> RejectConnectionRequestAsync(int connectionId, Guid connectedUserId)
        {
            var parameters = new[]
            {
                new SqlParameter("@ConnectionId", connectionId),
                new SqlParameter("@ConnectedUserId", connectedUserId)
            };

            var affectedRows = await ExecuteNonQueryAsync("sp_RejectConnectionRequest", parameters);
            return affectedRows > 0;
        }

        public async Task<UserConnection> BlockUserConnectionAsync(Guid userId, Guid connectedUserId)
        {
            var parameters = new[]
            {
                new SqlParameter("@UserId", userId),
                new SqlParameter("@ConnectedUserId", connectedUserId)
            };

            var connection = await ExecuteReaderSingleAsync("sp_BlockUserConnection", MapUserConnection, parameters);
            return connection ?? throw new InvalidOperationException("Failed to block user connection");
        }

        public async Task<IEnumerable<UserConnection>> GetUserConnectionsAsync(Guid userId, string? status = null)
        {
            var parameters = new[]
            {
                new SqlParameter("@UserId", userId),
                new SqlParameter("@Status", (object?)status ?? DBNull.Value)
            };

            return await ExecuteReaderListAsync("sp_GetUserConnections", MapUserConnection, parameters);
        }

        public async Task<IEnumerable<UserConnection>> GetPendingConnectionRequestsAsync(Guid userId)
        {
            var parameters = new[]
            {
                new SqlParameter("@UserId", userId)
            };

            return await ExecuteReaderListAsync("sp_GetPendingConnectionRequests", MapUserConnection, parameters);
        }
    }
}

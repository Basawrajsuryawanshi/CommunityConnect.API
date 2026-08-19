using CommunityConnect.Core.Data;
using CommunityConnect.Core.Entities;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using System.Data;

namespace CommunityConnect.Infrastructure.Data
{
    /// <summary>
    /// Implementation of IAuthDatabase using ADO.NET and stored procedures
    /// Executes stored procedures directly against SQL Server
    /// </summary>
    public class AuthDatabaseService : IAuthDatabase
    {
        private readonly string _connectionString;

        public AuthDatabaseService(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("AuthDb")
                ?? throw new InvalidOperationException("AuthDb connection string is not configured");
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

        private User MapUser(SqlDataReader reader)
        {
            return new User
            {
                Id = reader.GetInt32(reader.GetOrdinal("Id")),
                Email = reader.GetString(reader.GetOrdinal("Email")),
                PasswordHash = reader.IsDBNull(reader.GetOrdinal("PasswordHash")) ? null : reader.GetString(reader.GetOrdinal("PasswordHash")),
                EmailVerified = reader.GetBoolean(reader.GetOrdinal("EmailVerified")),
                EmailVerificationToken = reader.IsDBNull(reader.GetOrdinal("EmailVerificationToken")) ? null : reader.GetString(reader.GetOrdinal("EmailVerificationToken")),
                EmailVerificationExpiry = reader.IsDBNull(reader.GetOrdinal("EmailVerificationExpiry")) ? null : reader.GetDateTime(reader.GetOrdinal("EmailVerificationExpiry")),
                PasswordResetToken = reader.IsDBNull(reader.GetOrdinal("PasswordResetToken")) ? null : reader.GetString(reader.GetOrdinal("PasswordResetToken")),
                PasswordResetExpiry = reader.IsDBNull(reader.GetOrdinal("PasswordResetExpiry")) ? null : reader.GetDateTime(reader.GetOrdinal("PasswordResetExpiry")),
                IsActive = reader.GetBoolean(reader.GetOrdinal("IsActive")),
                IsDeleted = reader.GetBoolean(reader.GetOrdinal("IsDeleted")),
                CreatedAt = reader.GetDateTime(reader.GetOrdinal("CreatedAt")),
                UpdatedAt = reader.GetDateTime(reader.GetOrdinal("UpdatedAt")),
                LastLoginAt = reader.IsDBNull(reader.GetOrdinal("LastLoginAt")) ? null : reader.GetDateTime(reader.GetOrdinal("LastLoginAt"))
            };
        }

        private RefreshToken MapRefreshToken(SqlDataReader reader)
        {
            return new RefreshToken
            {
                Id = reader.GetInt32(reader.GetOrdinal("Id")),
                UserId = reader.GetInt32(reader.GetOrdinal("UserId")),
                Token = reader.GetString(reader.GetOrdinal("Token")),
                ExpiresAt = reader.GetDateTime(reader.GetOrdinal("ExpiresAt")),
                CreatedAt = reader.GetDateTime(reader.GetOrdinal("CreatedAt")),
                RevokedAt = reader.IsDBNull(reader.GetOrdinal("RevokedAt")) ? null : reader.GetDateTime(reader.GetOrdinal("RevokedAt")),
                ReplacedByToken = reader.IsDBNull(reader.GetOrdinal("ReplacedByToken")) ? null : reader.GetString(reader.GetOrdinal("ReplacedByToken")),
                IsRevoked = reader.GetBoolean(reader.GetOrdinal("IsRevoked")),
                CreatedByIp = reader.IsDBNull(reader.GetOrdinal("CreatedByIp")) ? null : reader.GetString(reader.GetOrdinal("CreatedByIp")),
                RevokedByIp = reader.IsDBNull(reader.GetOrdinal("RevokedByIp")) ? null : reader.GetString(reader.GetOrdinal("RevokedByIp"))
            };
        }

        private OAuthProvider MapOAuthProvider(SqlDataReader reader)
        {
            return new OAuthProvider
            {
                Id = reader.GetInt32(reader.GetOrdinal("Id")),
                UserId = reader.GetInt32(reader.GetOrdinal("UserId")),
                Provider = reader.GetString(reader.GetOrdinal("Provider")),
                ProviderUserId = reader.GetString(reader.GetOrdinal("ProviderUserId")),
                AccessToken = reader.IsDBNull(reader.GetOrdinal("AccessToken")) ? null : reader.GetString(reader.GetOrdinal("AccessToken")),
                RefreshToken = reader.IsDBNull(reader.GetOrdinal("RefreshToken")) ? null : reader.GetString(reader.GetOrdinal("RefreshToken")),
                TokenExpiresAt = reader.IsDBNull(reader.GetOrdinal("TokenExpiresAt")) ? null : reader.GetDateTime(reader.GetOrdinal("TokenExpiresAt")),
                CreatedAt = reader.GetDateTime(reader.GetOrdinal("CreatedAt")),
                UpdatedAt = reader.GetDateTime(reader.GetOrdinal("UpdatedAt"))
            };
        }

        private UserProfile MapUserProfile(SqlDataReader reader)
        {
            return new UserProfile
            {
                Id = reader.GetInt32(reader.GetOrdinal("Id")),
                FullName = reader.GetString(reader.GetOrdinal("FullName")),
                Email = reader.GetString(reader.GetOrdinal("Email")),
                MobileNumber = reader.GetString(reader.GetOrdinal("MobileNumber")),
                SchoolName = reader.GetString(reader.GetOrdinal("SchoolName")),
                State = reader.IsDBNull(reader.GetOrdinal("State")) ? string.Empty : reader.GetString(reader.GetOrdinal("State")),
                SchoolRegion = reader.IsDBNull(reader.GetOrdinal("SchoolRegion")) ? string.Empty : reader.GetString(reader.GetOrdinal("SchoolRegion")),
                PassoutYear = reader.GetInt32(reader.GetOrdinal("PassoutYear")),
                Role = reader.GetString(reader.GetOrdinal("Role")),
                University = reader.IsDBNull(reader.GetOrdinal("University")) ? string.Empty : reader.GetString(reader.GetOrdinal("University")),
                CurrentState = reader.IsDBNull(reader.GetOrdinal("CurrentState")) ? string.Empty : reader.GetString(reader.GetOrdinal("CurrentState")),
                CurrentDistrict = reader.IsDBNull(reader.GetOrdinal("CurrentDistrict")) ? string.Empty : reader.GetString(reader.GetOrdinal("CurrentDistrict")),
                BloodGroup = reader.IsDBNull(reader.GetOrdinal("BloodGroup")) ? string.Empty : reader.GetString(reader.GetOrdinal("BloodGroup")),
                CreatedAt = reader.GetDateTime(reader.GetOrdinal("CreatedAt")),
                UpdatedAt = reader.IsDBNull(reader.GetOrdinal("UpdatedAt")) ? DateTime.UtcNow : reader.GetDateTime(reader.GetOrdinal("UpdatedAt"))
            };
        }

        // ============================================
        // USER OPERATIONS
        // ============================================

        public async Task<User> CreateUserAsync(
            string email,
            string passwordHash,
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
            string bloodGroup,
            bool emailVerified = false,
            string? emailVerificationToken = null,
            DateTime? emailVerificationExpiry = null)
        {
            var parameters = new[]
            {
                new SqlParameter("@Email", email),
                new SqlParameter("@PasswordHash", passwordHash),
                new SqlParameter("@EmailVerified", emailVerified),
                new SqlParameter("@EmailVerificationToken", (object?)emailVerificationToken ?? DBNull.Value),
                new SqlParameter("@EmailVerificationExpiry", (object?)emailVerificationExpiry ?? DBNull.Value)
            };

            var user = await ExecuteReaderSingleAsync("sp_CreateUser", MapUser, parameters);

            if (user == null)
            {
                throw new InvalidOperationException("Failed to create user");
            }

            // Create user profile after user creation
            await CreateUserProfileAsync(
                user.Id,
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

            return user;
        }

        public async Task<User?> GetUserByEmailAsync(string email)
        {
            var parameters = new[]
            {
                new SqlParameter("@Email", email)
            };

            return await ExecuteReaderSingleAsync("sp_GetUserByEmail", MapUser, parameters);
        }

        public async Task<User?> GetUserByIdAsync(int userId)
        {
            var parameters = new[]
            {
                new SqlParameter("@UserId", userId)
            };

            return await ExecuteReaderSingleAsync("sp_GetUserById", MapUser, parameters);
        }

        public async Task UpdateLastLoginAsync(int userId, DateTime lastLoginAt)
        {
            var parameters = new[]
            {
                new SqlParameter("@UserId", userId),
                new SqlParameter("@LastLoginAt", lastLoginAt)
            };

            await ExecuteNonQueryAsync("sp_UpdateLastLogin", parameters);
        }

        public async Task<bool> VerifyEmailAsync(string email, string verificationToken)
        {
            var parameters = new[]
            {
                new SqlParameter("@Email", email),
                new SqlParameter("@VerificationToken", verificationToken)
            };

            var rowsAffected = await ExecuteNonQueryAsync("sp_VerifyEmail", parameters);
            return rowsAffected > 0;
        }

        public async Task<bool> UpdatePasswordAsync(int userId, string newPasswordHash)
        {
            var parameters = new[]
            {
                new SqlParameter("@UserId", userId),
                new SqlParameter("@NewPasswordHash", newPasswordHash)
            };

            var rowsAffected = await ExecuteNonQueryAsync("sp_UpdatePassword", parameters);
            return rowsAffected > 0;
        }

        public async Task<bool> SetPasswordResetTokenAsync(int userId, string resetToken, DateTime expiry)
        {
            var parameters = new[]
            {
                new SqlParameter("@UserId", userId),
                new SqlParameter("@ResetToken", resetToken),
                new SqlParameter("@Expiry", expiry)
            };

            var rowsAffected = await ExecuteNonQueryAsync("sp_SetPasswordResetToken", parameters);
            return rowsAffected > 0;
        }

        public async Task<bool> DeleteUserAsync(int userId)
        {
            var parameters = new[]
            {
                new SqlParameter("@UserId", userId)
            };

            var rowsAffected = await ExecuteNonQueryAsync("sp_DeleteUser", parameters);
            return rowsAffected > 0;
        }

        // ============================================
        // REFRESH TOKEN OPERATIONS
        // ============================================

        public async Task<RefreshToken> CreateRefreshTokenAsync(int userId, string token, DateTime expiresAt, string? createdByIp = null)
        {
            var parameters = new[]
            {
                new SqlParameter("@UserId", userId),
                new SqlParameter("@Token", token),
                new SqlParameter("@ExpiresAt", expiresAt),
                new SqlParameter("@CreatedByIp", (object?)createdByIp ?? DBNull.Value)
            };

            var refreshToken = await ExecuteReaderSingleAsync("sp_CreateRefreshToken", MapRefreshToken, parameters);

            return refreshToken ?? throw new InvalidOperationException("Failed to create refresh token");
        }

        public async Task<RefreshToken?> GetRefreshTokenAsync(string token)
        {
            var parameters = new[]
            {
                new SqlParameter("@Token", token)
            };

            return await ExecuteReaderSingleAsync("sp_GetRefreshToken", MapRefreshToken, parameters);
        }

        public async Task<bool> RevokeRefreshTokenAsync(string token, string? revokedByIp = null, string? replacedByToken = null)
        {
            var parameters = new[]
            {
                new SqlParameter("@Token", token),
                new SqlParameter("@RevokedByIp", (object?)revokedByIp ?? DBNull.Value),
                new SqlParameter("@ReplacedByToken", (object?)replacedByToken ?? DBNull.Value)
            };

            var rowsAffected = await ExecuteNonQueryAsync("sp_RevokeRefreshToken", parameters);
            return rowsAffected > 0;
        }

        public async Task<int> RevokeAllUserTokensAsync(int userId)
        {
            var parameters = new[]
            {
                new SqlParameter("@UserId", userId)
            };

            return await ExecuteNonQueryAsync("sp_RevokeAllUserTokens", parameters);
        }

        // ============================================
        // OAUTH PROVIDER OPERATIONS
        // ============================================

        public async Task<OAuthProvider> UpsertOAuthProviderAsync(int userId, string provider, string providerUserId,
            string? accessToken = null, string? refreshToken = null, DateTime? tokenExpiresAt = null)
        {
            var parameters = new[]
            {
                new SqlParameter("@UserId", userId),
                new SqlParameter("@Provider", provider),
                new SqlParameter("@ProviderUserId", providerUserId),
                new SqlParameter("@AccessToken", (object?)accessToken ?? DBNull.Value),
                new SqlParameter("@RefreshToken", (object?)refreshToken ?? DBNull.Value),
                new SqlParameter("@TokenExpiresAt", (object?)tokenExpiresAt ?? DBNull.Value)
            };

            var oauthProvider = await ExecuteReaderSingleAsync("sp_UpsertOAuthProvider", MapOAuthProvider, parameters);

            return oauthProvider ?? throw new InvalidOperationException("Failed to upsert OAuth provider");
        }

        public async Task<OAuthProvider?> GetOAuthProviderAsync(string provider, string providerUserId)
        {
            var parameters = new[]
            {
                new SqlParameter("@Provider", provider),
                new SqlParameter("@ProviderUserId", providerUserId)
            };

            return await ExecuteReaderSingleAsync("sp_GetOAuthProvider", MapOAuthProvider, parameters);
        }

        public async Task<User?> GetUserByOAuthProviderAsync(string provider, string providerUserId)
        {
            var parameters = new[]
            {
                new SqlParameter("@Provider", provider),
                new SqlParameter("@ProviderUserId", providerUserId)
            };

            return await ExecuteReaderSingleAsync("sp_GetUserByOAuthProvider", MapUser, parameters);
        }

        // ============================================
        // USER PROFILE OPERATIONS
        // ============================================

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
            var parameters = new[]
            {
                new SqlParameter("@Id", id),
                new SqlParameter("@FullName", fullName),
                new SqlParameter("@Email", email),
                new SqlParameter("@MobileNumber", mobileNumber),
                new SqlParameter("@SchoolName", schoolName),
                new SqlParameter("@State", state),
                new SqlParameter("@SchoolRegion", schoolRegion),
                new SqlParameter("@PassoutYear", passoutYear),
                new SqlParameter("@Role", role),
                new SqlParameter("@University", university),
                new SqlParameter("@CurrentState", currentState),
                new SqlParameter("@CurrentDistrict", currentDistrict),
                new SqlParameter("@BloodGroup", bloodGroup)
            };

            var userProfile = await ExecuteReaderSingleAsync("sp_CreateUserProfile", MapUserProfile, parameters);

            return userProfile ?? throw new InvalidOperationException("Failed to create user profile");
        }

        public async Task<UserProfile?> GetUserProfileByIdAsync(int id)
        {
            var parameters = new[]
            {
                new SqlParameter("@Id", id)
            };

            return await ExecuteReaderSingleAsync("sp_GetUserProfileById", MapUserProfile, parameters);
        }

        public async Task<(List<UserProfile> Profiles, int TotalCount)> GetAllUserProfilesAsync(int pageNumber = 1, int pageSize = 50)
        {
            var profiles = new List<UserProfile>();
            int totalCount = 0;

            using var connection = GetConnection();
            await connection.OpenAsync();
            await SetConnectionOptionsAsync(connection);

            using var command = new SqlCommand("sp_GetAllUserProfiles", connection)
            {
                CommandType = CommandType.StoredProcedure
            };

            command.Parameters.Add(new SqlParameter("@PageNumber", pageNumber));
            command.Parameters.Add(new SqlParameter("@PageSize", pageSize));

            using var reader = await command.ExecuteReaderAsync();

            // First result set: User profiles
            while (await reader.ReadAsync())
            {
                profiles.Add(MapUserProfile(reader));
            }

            // Second result set: Total count
            if (await reader.NextResultAsync())
            {
                if (await reader.ReadAsync())
                {
                    totalCount = reader.GetInt32(reader.GetOrdinal("TotalCount"));
                }
            }

            return (profiles, totalCount);
        }

        // ============================================
        // ROLE OPERATIONS
        // ============================================

        private Role MapRole(SqlDataReader reader)
        {
            return new Role
            {
                Id = reader.GetInt32(reader.GetOrdinal("Id")),
                Name = reader.GetString(reader.GetOrdinal("Name")),
                Description = reader.IsDBNull(reader.GetOrdinal("Description")) 
                    ? string.Empty 
                    : reader.GetString(reader.GetOrdinal("Description")),
                CreatedAt = reader.GetDateTime(reader.GetOrdinal("CreatedAt"))
            };
        }

        public async Task<List<Role>> GetAllRolesAsync()
        {
            return await ExecuteReaderListAsync("sp_GetAllRoles", MapRole);
        }

        public async Task<Role?> GetRoleByIdAsync(int id)
        {
            var parameters = new[]
            {
                new SqlParameter("@RoleId", id)
            };

            var roles = await ExecuteReaderListAsync("sp_GetRoleById", MapRole, parameters);
            return roles.FirstOrDefault();
        }

        public async Task<Role> CreateRoleAsync(string name, string description)
        {
            var parameters = new[]
            {
                new SqlParameter("@Name", name),
                new SqlParameter("@Description", description)
            };

            var roles = await ExecuteReaderListAsync("sp_CreateRole", MapRole, parameters);
            return roles.First();
        }

        public async Task<Role?> UpdateRoleAsync(int id, string name, string description)
        {
            var parameters = new[]
            {
                new SqlParameter("@RoleId", id),
                new SqlParameter("@Name", name),
                new SqlParameter("@Description", description)
            };

            var roles = await ExecuteReaderListAsync("sp_UpdateRole", MapRole, parameters);
            return roles.FirstOrDefault();
        }

        public async Task<bool> DeleteRoleAsync(int id)
        {
            var parameters = new[]
            {
                new SqlParameter("@RoleId", id)
            };

            try
            {
                var result = await ExecuteNonQueryAsync("sp_DeleteRole", parameters);

                // Temporary debug logging - you can remove this after debugging
                Console.WriteLine($"[DEBUG] DeleteRoleAsync: RoleId={id}, RowsAffected={result}");

                return result > 0;
            }
            catch (Exception ex)
            {
                // Temporary debug logging
                Console.WriteLine($"[DEBUG] DeleteRoleAsync ERROR: RoleId={id}, Exception={ex.Message}");
                throw;
            }
        }
    }
}

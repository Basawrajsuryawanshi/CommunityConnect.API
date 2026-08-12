using CommunityConnect.Auth.Core.Entities;

namespace CommunityConnect.Auth.Core.Data
{
    /// <summary>
    /// Interface for Auth database operations using stored procedures
    /// One interface per database - contains all methods related to Auth DB
    /// </summary>
    public interface IAuthDatabase
    {
        // ============================================
        // USER OPERATIONS
        // ============================================

        /// <summary>
        /// Creates a new user using sp_CreateUser stored procedure and user profile using sp_CreateUserProfile
        /// </summary>
        Task<User> CreateUserAsync(
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
            DateTime? emailVerificationExpiry = null);

        /// <summary>
        /// Gets user by email using sp_GetUserByEmail stored procedure
        /// </summary>
        Task<User?> GetUserByEmailAsync(string email);

        /// <summary>
        /// Gets user by ID using sp_GetUserById stored procedure
        /// </summary>
        Task<User?> GetUserByIdAsync(int userId);

        /// <summary>
        /// Updates user's last login timestamp using sp_UpdateLastLogin stored procedure
        /// </summary>
        Task UpdateLastLoginAsync(int userId, DateTime lastLoginAt);

        /// <summary>
        /// Updates user's email verification status using sp_VerifyEmail stored procedure
        /// </summary>
        Task<bool> VerifyEmailAsync(string email, string verificationToken);

        /// <summary>
        /// Updates user's password using sp_UpdatePassword stored procedure
        /// </summary>
        Task<bool> UpdatePasswordAsync(int userId, string newPasswordHash);

        /// <summary>
        /// Sets password reset token using sp_SetPasswordResetToken stored procedure
        /// </summary>
        Task<bool> SetPasswordResetTokenAsync(int userId, string resetToken, DateTime expiry);

        /// <summary>
        /// Soft delete user using sp_DeleteUser stored procedure
        /// </summary>
        Task<bool> DeleteUserAsync(int userId);

        // ============================================
        // REFRESH TOKEN OPERATIONS
        // ============================================

        /// <summary>
        /// Creates a refresh token using sp_CreateRefreshToken stored procedure
        /// </summary>
        Task<RefreshToken> CreateRefreshTokenAsync(
            int userId,
            string token,
            DateTime expiresAt,
            string? createdByIp = null);

        /// <summary>
        /// Gets refresh token by token value using sp_GetRefreshToken stored procedure
        /// </summary>
        Task<RefreshToken?> GetRefreshTokenAsync(string token);

        /// <summary>
        /// Revokes a refresh token using sp_RevokeRefreshToken stored procedure
        /// </summary>
        Task<bool> RevokeRefreshTokenAsync(string token, string? revokedByIp = null, string? replacedByToken = null);

        /// <summary>
        /// Revokes all refresh tokens for a user using sp_RevokeAllUserTokens stored procedure
        /// </summary>
        Task<int> RevokeAllUserTokensAsync(int userId);

        // ============================================
        // OAUTH PROVIDER OPERATIONS
        // ============================================

        /// <summary>
        /// Creates or updates OAuth provider using sp_UpsertOAuthProvider stored procedure
        /// </summary>
        Task<OAuthProvider> UpsertOAuthProviderAsync(
            int userId,
            string provider,
            string providerUserId,
            string? accessToken = null,
            string? refreshToken = null,
            DateTime? tokenExpiresAt = null);

        /// <summary>
        /// Gets OAuth provider by provider name and provider user ID using sp_GetOAuthProvider stored procedure
        /// </summary>
        Task<OAuthProvider?> GetOAuthProviderAsync(string provider, string providerUserId);

        /// <summary>
        /// Gets user by OAuth provider using sp_GetUserByOAuthProvider stored procedure
        /// </summary>
        Task<User?> GetUserByOAuthProviderAsync(string provider, string providerUserId);

        // ============================================
        // USER PROFILE OPERATIONS
        // ============================================

        /// <summary>
        /// Creates a new user profile using sp_CreateUserProfile stored procedure
        /// </summary>
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
    }
}

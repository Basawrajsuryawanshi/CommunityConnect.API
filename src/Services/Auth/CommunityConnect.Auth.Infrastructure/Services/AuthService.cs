using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using CommunityConnect.Auth.Core.Data;
using CommunityConnect.Auth.Core.Entities;
using CommunityConnect.Auth.Core.Services;
using CommunityConnect.Contracts.Auth;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;

namespace CommunityConnect.Auth.Infrastructure.Services
{
    public class AuthService : IAuthService
    {
        private readonly IAuthDatabase _authDatabase;
        private readonly IConfiguration _configuration;

        public AuthService(IAuthDatabase authDatabase, IConfiguration configuration)
        {
            _authDatabase = authDatabase;
            _configuration = configuration;
        }

        public async Task<AuthResponse> RegisterAsync(RegisterRequest request)
        {
            // Check if user exists using stored procedure
            var existingUser = await _authDatabase.GetUserByEmailAsync(request.Email);
            if (existingUser != null)
            {
                throw new Exception("User with this email already exists");
            }

            // Create user and user profile using stored procedure
            var user = await _authDatabase.CreateUserAsync(
                email: request.Email,
                passwordHash: HashPassword(request.Password),
                fullName: request.FullName,
                mobileNumber: request.MobileNumber,
                schoolName: request.SchoolName,
                state: request.State,
                schoolRegion: request.SchoolRegion,
                passoutYear: request.PassoutYear,
                role: request.Role,
                university: request.University,
                currentState: request.CurrentState,
                currentDistrict: request.CurrentDistrict,
                bloodGroup: request.BloodGroup,
                emailVerified: false
            );

            // Generate tokens
            var accessToken = GenerateAccessToken(user);
            var refreshToken = await GenerateRefreshTokenAsync(user.Id, "");

            return new AuthResponse(
                user.Id,
                user.Email,
                accessToken,
                refreshToken.Token,
                refreshToken.ExpiresAt
            );
        }

        public async Task<AuthResponse> LoginAsync(LoginRequest request)
        {
            // Get user using stored procedure
            var user = await _authDatabase.GetUserByEmailAsync(request.Email);

            if (user == null || !VerifyPassword(request.Password, user.PasswordHash!))
            {
                throw new Exception("Invalid email or password");
            }

            if (!user.IsActive)
            {
                throw new Exception("Account is deactivated");
            }

            // Update last login using stored procedure
            await _authDatabase.UpdateLastLoginAsync(user.Id, DateTime.UtcNow);

            // Generate tokens
            var accessToken = GenerateAccessToken(user);
            var refreshToken = await GenerateRefreshTokenAsync(user.Id, "");

            return new AuthResponse(
                user.Id,
                user.Email,
                accessToken,
                refreshToken.Token,
                refreshToken.ExpiresAt
            );
        }

        public async Task<AuthResponse> GoogleLoginAsync(GoogleLoginRequest request)
        {
            // TODO: Verify Google ID token
            // For now, simplified version

            throw new NotImplementedException("Google login not implemented yet");
        }

        public async Task<AuthResponse> RefreshTokenAsync(RefreshTokenRequest request)
        {
            // Get refresh token using stored procedure
            var refreshToken = await _authDatabase.GetRefreshTokenAsync(request.RefreshToken);

            if (refreshToken == null || refreshToken.IsRevoked || refreshToken.ExpiresAt < DateTime.UtcNow)
            {
                throw new Exception("Invalid or expired refresh token");
            }

            // Get user using stored procedure
            var user = await _authDatabase.GetUserByIdAsync(refreshToken.UserId);
            if (user == null)
            {
                throw new Exception("User not found");
            }

            // Revoke old token using stored procedure
            await _authDatabase.RevokeRefreshTokenAsync(refreshToken.Token);

            // Generate new tokens
            var accessToken = GenerateAccessToken(user);
            var newRefreshToken = await GenerateRefreshTokenAsync(user.Id, "");

            return new AuthResponse(
                user.Id,
                user.Email,
                accessToken,
                newRefreshToken.Token,
                newRefreshToken.ExpiresAt
            );
        }

        public async Task LogoutAsync(int userId)
        {
            // Revoke all user tokens using stored procedure
            await _authDatabase.RevokeAllUserTokensAsync(userId);
        }

        public Task<bool> ValidateTokenAsync(string token)
        {
            // Implement token validation logic
            throw new NotImplementedException();
        }

        private string GenerateAccessToken(User user)
        {
            var key = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(_configuration["Jwt:SecretKey"]!)
            );
            var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var claims = new[]
            {
                new Claim(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
                new Claim(JwtRegisteredClaimNames.Email, user.Email),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
            };

            var token = new JwtSecurityToken(
                issuer: _configuration["Jwt:Issuer"],
                audience: _configuration["Jwt:Audience"],
                claims: claims,
                expires: DateTime.UtcNow.AddMinutes(15),
                signingCredentials: credentials
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }

        private async Task<RefreshToken> GenerateRefreshTokenAsync(int userId, string ipAddress)
        {
            var tokenValue = Convert.ToBase64String(RandomNumberGenerator.GetBytes(64));
            var expiresAt = DateTime.UtcNow.AddDays(7);

            // Create refresh token using stored procedure
            var refreshToken = await _authDatabase.CreateRefreshTokenAsync(
                userId: userId,
                token: tokenValue,
                expiresAt: expiresAt,
                createdByIp: ipAddress
            );

            return refreshToken;
        }

        private string HashPassword(string password)
        {
            return BCrypt.Net.BCrypt.HashPassword(password);
        }

        private bool VerifyPassword(string password, string hash)
        {
            return BCrypt.Net.BCrypt.Verify(password, hash);
        }
    }
}

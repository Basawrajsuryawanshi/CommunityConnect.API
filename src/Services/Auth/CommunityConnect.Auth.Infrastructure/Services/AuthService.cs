using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using CommunityConnect.Auth.Core.Entities;
using CommunityConnect.Auth.Core.Services;
using CommunityConnect.Auth.Infrastructure.Data;
using CommunityConnect.Contracts.Auth;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;

namespace CommunityConnect.Auth.Infrastructure.Services
{
    public class AuthService : IAuthService
    {
        private readonly AuthDbContext _context;
        private readonly IConfiguration _configuration;

        public AuthService(AuthDbContext context, IConfiguration configuration)
        {
            _context = context;
            _configuration = configuration;
        }

        public async Task<AuthResponse> RegisterAsync(RegisterRequest request)
        {
            // Check if user exists
            if (await _context.Users.AnyAsync(u => u.Email == request.Email))
            {
                throw new Exception("User with this email already exists");
            }

            // Create user
            var user = new User
            {
                Email = request.Email,
                PasswordHash = HashPassword(request.Password),
                EmailVerified = false
            };

            _context.Users.Add(user);
            await _context.SaveChangesAsync();

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
            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Email == request.Email);

            if (user == null || !VerifyPassword(request.Password, user.PasswordHash!))
            {
                throw new Exception("Invalid email or password");
            }

            if (!user.IsActive)
            {
                throw new Exception("Account is deactivated");
            }

            // Update last login
            user.LastLoginAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

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
            var refreshToken = await _context.RefreshTokens
                .Include(rt => rt.User)
                .FirstOrDefaultAsync(rt => rt.Token == request.RefreshToken);

            if (refreshToken == null || refreshToken.IsRevoked || refreshToken.ExpiresAt < DateTime.UtcNow)
            {
                throw new Exception("Invalid or expired refresh token");
            }

            // Revoke old token
            refreshToken.IsRevoked = true;
            refreshToken.RevokedAt = DateTime.UtcNow;

            // Generate new tokens
            var accessToken = GenerateAccessToken(refreshToken.User);
            var newRefreshToken = await GenerateRefreshTokenAsync(refreshToken.UserId, "");

            await _context.SaveChangesAsync();

            return new AuthResponse(
                refreshToken.User.Id,
                refreshToken.User.Email,
                accessToken,
                newRefreshToken.Token,
                newRefreshToken.ExpiresAt
            );
        }

        public async Task LogoutAsync(Guid userId)
        {
            var refreshTokens = await _context.RefreshTokens
                .Where(rt => rt.UserId == userId && !rt.IsRevoked)
                .ToListAsync();

            foreach (var token in refreshTokens)
            {
                token.IsRevoked = true;
                token.RevokedAt = DateTime.UtcNow;
            }

            await _context.SaveChangesAsync();
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

        private async Task<RefreshToken> GenerateRefreshTokenAsync(Guid userId, string ipAddress)
        {
            var refreshToken = new RefreshToken
            {
                UserId = userId,
                Token = Convert.ToBase64String(RandomNumberGenerator.GetBytes(64)),
                ExpiresAt = DateTime.UtcNow.AddDays(7),
                CreatedByIp = ipAddress
            };

            _context.RefreshTokens.Add(refreshToken);
            await _context.SaveChangesAsync();

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

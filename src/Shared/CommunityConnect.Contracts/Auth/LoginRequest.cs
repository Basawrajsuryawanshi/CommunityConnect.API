namespace CommunityConnect.Contracts.Auth
{
    public record LoginRequest(string Email, string Password);

    public record RegisterRequest(
        string Email,
        string Password
    );

    public record GoogleLoginRequest(string IdToken);

    public record RefreshTokenRequest(string RefreshToken);

    public record AuthResponse(
        Guid UserId,
        string Email,
        string AccessToken,
        string RefreshToken,
        DateTime ExpiresAt
    );
}

namespace CommunityConnect.Contracts.Auth
{
    public record LoginRequest(string Email, string Password);

    public record RegisterRequest(
        string Email,
        string Password,
        string FullName,
        string MobileNumber,
        string SchoolName,
        string State,
        string SchoolRegion,
        int PassoutYear,
        string Role,
        string University,
        string CurrentState,
        string CurrentDistrict,
        string BloodGroup
    );

    public record GoogleLoginRequest(string IdToken);

    public record RefreshTokenRequest(string RefreshToken);

    public record AuthResponse(
        int UserId,
        string Email,
        string AccessToken,
        string RefreshToken,
        DateTime ExpiresAt
    );
}

namespace CommunityConnect.Contracts.User
{
    // Request models
    public record CreateUserProfileRequest(
        Guid UserId,
        string FirstName,
        string LastName,
        string? DisplayName = null,
        string? Bio = null,
        DateTime? DateOfBirth = null,
        string? Gender = null,
        string? PhoneNumber = null,
        string? JNV = null,
        string? Batch = null,
        string? StudentId = null
    );

    public record UpdateUserProfileRequest(
        string? FirstName = null,
        string? LastName = null,
        string? DisplayName = null,
        string? AvatarUrl = null,
        string? Bio = null,
        DateTime? DateOfBirth = null,
        string? Gender = null,
        string? PhoneNumber = null,
        string? JNV = null,
        string? Batch = null,
        string? StudentId = null,
        string? AddressLine1 = null,
        string? AddressLine2 = null,
        string? City = null,
        string? State = null,
        string? Country = null,
        string? PostalCode = null,
        string? LinkedInUrl = null,
        string? TwitterHandle = null,
        string? GitHubUsername = null,
        bool? IsPublic = null
    );

    public record UpdateUserPreferencesRequest(
        bool? EmailNotifications = null,
        bool? PushNotifications = null,
        bool? SmsNotifications = null,
        string? Theme = null,
        string? Language = null,
        string? TimeZone = null
    );

    public record CreateConnectionRequest(
        Guid ConnectedUserId,
        string ConnectionType
    );

    public record SearchUsersRequest(
        string? SearchTerm = null,
        string? JNV = null,
        string? Batch = null,
        int Page = 1,
        int PageSize = 20
    );

    // Response models
    public record UserProfileResponse(
        Guid Id,
        string FirstName,
        string LastName,
        string? DisplayName,
        string? AvatarUrl,
        string? Bio,
        DateTime? DateOfBirth,
        string? Gender,
        string? PhoneNumber,
        string? JNV,
        string? Batch,
        string? StudentId,
        string? AddressLine1,
        string? AddressLine2,
        string? City,
        string? State,
        string? Country,
        string? PostalCode,
        string? LinkedInUrl,
        string? TwitterHandle,
        string? GitHubUsername,
        bool IsProfileComplete,
        bool IsPublic,
        DateTime CreatedAt,
        DateTime UpdatedAt
    );

    public record UserPreferencesResponse(
        Guid UserId,
        bool EmailNotifications,
        bool PushNotifications,
        bool SmsNotifications,
        string Theme,
        string Language,
        string TimeZone
    );

    public record UserConnectionResponse(
        int Id,
        Guid UserId,
        Guid ConnectedUserId,
        string ConnectionType,
        string Status,
        DateTime CreatedAt,
        UserBasicInfoResponse ConnectedUser
    );

    public record UserBasicInfoResponse(
        Guid Id,
        string FirstName,
        string LastName,
        string? DisplayName,
        string? AvatarUrl,
        string? JNV,
        string? Batch
    );

    public record SearchUsersResponse(
        List<UserBasicInfoResponse> Users,
        int TotalCount,
        int Page,
        int PageSize,
        int TotalPages
    );
}

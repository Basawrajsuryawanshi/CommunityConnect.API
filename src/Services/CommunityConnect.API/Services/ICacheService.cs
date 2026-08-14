namespace CommunityConnect.API.Services;

/// <summary>
/// Defines caching operations for the API
/// </summary>
public interface ICacheService
{
    /// <summary>
    /// Get cached value by key
    /// </summary>
    Task<string?> GetAsync(string key);

    /// <summary>
    /// Set cache value with expiration time
    /// </summary>
    Task SetAsync(string key, string value, TimeSpan? expiration = null);

    /// <summary>
    /// Remove cached value by key
    /// </summary>
    Task RemoveAsync(string key);

    /// <summary>
    /// Remove multiple cached values by pattern
    /// </summary>
    Task RemoveByPatternAsync(string pattern);

    /// <summary>
    /// Check if key exists in cache
    /// </summary>
    Task<bool> ExistsAsync(string key);
}

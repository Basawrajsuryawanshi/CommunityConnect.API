using StackExchange.Redis;

namespace CommunityConnect.API.Services;

/// <summary>
/// Redis implementation of cache service with TTL support
/// </summary>
public class RedisCacheService : ICacheService
{
    private readonly IConnectionMultiplexer _redis;
    private readonly IDatabase _database;
    private readonly ILogger<RedisCacheService> _logger;

    public RedisCacheService(
        IConnectionMultiplexer redis,
        ILogger<RedisCacheService> logger)
    {
        _redis = redis;
        _database = redis.GetDatabase();
        _logger = logger;
    }

    public async Task<string?> GetAsync(string key)
    {
        try
        {
            var value = await _database.StringGetAsync(key);

            if (value.HasValue)
            {
                _logger.LogInformation("Cache HIT for key: {Key}", key);
                return value.ToString();
            }

            _logger.LogInformation("Cache MISS for key: {Key}", key);
            return null;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting cache key: {Key}", key);
            return null;
        }
    }

    public async Task SetAsync(string key, string value, TimeSpan? expiration = null)
    {
        try
        {
            if (expiration.HasValue)
            {
                await _database.StringSetAsync(key, value, expiration.Value);
                _logger.LogInformation("Cache SET for key: {Key} with TTL: {TTL}s", key, expiration.Value.TotalSeconds);
            }
            else
            {
                await _database.StringSetAsync(key, value);
                _logger.LogInformation("Cache SET for key: {Key} (no expiration)", key);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error setting cache key: {Key}", key);
        }
    }

    public async Task RemoveAsync(string key)
    {
        try
        {
            await _database.KeyDeleteAsync(key);
            _logger.LogInformation("Cache REMOVED for key: {Key}", key);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error removing cache key: {Key}", key);
        }
    }

    public async Task RemoveByPatternAsync(string pattern)
    {
        try
        {
            var endpoints = _redis.GetEndPoints();
            var server = _redis.GetServer(endpoints.First());

            var keys = server.Keys(pattern: pattern);
            foreach (var key in keys)
            {
                await _database.KeyDeleteAsync(key);
            }

            _logger.LogInformation("Cache REMOVED for pattern: {Pattern}", pattern);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error removing cache by pattern: {Pattern}", pattern);
        }
    }

    public async Task<bool> ExistsAsync(string key)
    {
        try
        {
            return await _database.KeyExistsAsync(key);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error checking cache key existence: {Key}", key);
            return false;
        }
    }
}

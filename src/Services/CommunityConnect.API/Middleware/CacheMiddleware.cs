using System.Text;

namespace CommunityConnect.API.Middleware;

/// <summary>
/// Middleware for caching GET requests with intelligent TTL based on resource type
/// </summary>
public class CacheMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<CacheMiddleware> _logger;

    public CacheMiddleware(RequestDelegate next, ILogger<CacheMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context, Services.ICacheService cacheService)
    {
        // Only cache GET requests
        if (context.Request.Method != HttpMethods.Get)
        {
            await _next(context);
            return;
        }

        // Skip caching for health and swagger endpoints
        var path = context.Request.Path.Value?.ToLower() ?? string.Empty;
        if (path.Contains("/health") || path.Contains("/swagger"))
        {
            await _next(context);
            return;
        }

        var cacheKey = GenerateCacheKey(context.Request);

        try
        {
            // Try to get from cache
            var cachedResponse = await cacheService.GetAsync(cacheKey);

            if (!string.IsNullOrEmpty(cachedResponse))
            {
                // Cache HIT - return cached response
                context.Response.ContentType = "application/json";
                context.Response.Headers.Append("X-Cache-Status", "HIT");
                await context.Response.WriteAsync(cachedResponse);
                return;
            }

            // Cache MISS - capture response and cache it
            context.Response.Headers.Append("X-Cache-Status", "MISS");
        }
        catch (Exception ex)
        {
            // Redis unavailable - continue without caching
            _logger.LogWarning(ex, "Cache service unavailable, continuing without cache for {Path}", context.Request.Path);
            context.Response.Headers.Append("X-Cache-Status", "UNAVAILABLE");
            await _next(context);
            return;
        }

        var originalBodyStream = context.Response.Body;
        using var responseBody = new MemoryStream();
        context.Response.Body = responseBody;

        await _next(context);

        // Only cache successful responses
        if (context.Response.StatusCode == StatusCodes.Status200OK)
        {
            responseBody.Seek(0, SeekOrigin.Begin);
            var responseText = await new StreamReader(responseBody).ReadToEndAsync();

            try
            {
                // Determine TTL based on endpoint
                var ttl = DetermineTTL(context.Request.Path);

                // Store in cache
                await cacheService.SetAsync(cacheKey, responseText, ttl);

                _logger.LogInformation("Cached response for {Path} with TTL {TTL}s", 
                    context.Request.Path, ttl.TotalSeconds);
            }
            catch (Exception ex)
            {
                // Failed to cache - log but continue
                _logger.LogWarning(ex, "Failed to cache response for {Path}", context.Request.Path);
            }
        }

        responseBody.Seek(0, SeekOrigin.Begin);
        await responseBody.CopyToAsync(originalBodyStream);
    }

    private string GenerateCacheKey(HttpRequest request)
    {
        var keyBuilder = new StringBuilder();
        keyBuilder.Append($"{request.Path}");

        if (request.QueryString.HasValue)
        {
            keyBuilder.Append(request.QueryString.Value);
        }

        // Include user ID if authenticated for user-specific caching
        if (request.Headers.ContainsKey("Authorization"))
        {
            var userId = request.HttpContext.User?.FindFirst("sub")?.Value 
                         ?? request.HttpContext.User?.FindFirst("userId")?.Value;
            if (!string.IsNullOrEmpty(userId))
            {
                keyBuilder.Append($":user:{userId}");
            }
        }

        return keyBuilder.ToString();
    }

    private TimeSpan DetermineTTL(PathString path)
    {
        var pathValue = path.Value?.ToLower() ?? string.Empty;

        // User profiles - 5 minutes
        if (pathValue.Contains("/user") && (pathValue.Contains("/profile") || pathValue.Contains("/users/")))
        {
            return TimeSpan.FromMinutes(5);
        }

        // Events - 1 minute (frequently updated)
        if (pathValue.Contains("/event"))
        {
            return TimeSpan.FromMinutes(1);
        }

        // Analytics - 10 minutes (less frequently changing)
        if (pathValue.Contains("/analytics"))
        {
            return TimeSpan.FromMinutes(10);
        }

        // Announcements - 3 minutes
        if (pathValue.Contains("/announcement"))
        {
            return TimeSpan.FromMinutes(3);
        }

        // Discussions - 2 minutes
        if (pathValue.Contains("/discussion"))
        {
            return TimeSpan.FromMinutes(2);
        }

        // Media metadata - 5 minutes
        if (pathValue.Contains("/media"))
        {
            return TimeSpan.FromMinutes(5);
        }

        // Notifications - 30 seconds (real-time nature)
        if (pathValue.Contains("/notification"))
        {
            return TimeSpan.FromSeconds(30);
        }

        // Default - 2 minutes
        return TimeSpan.FromMinutes(2);
    }
}

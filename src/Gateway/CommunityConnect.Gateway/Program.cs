using Ocelot.DependencyInjection;
using Ocelot.Middleware;
using Ocelot.Cache.CacheManager;
using Ocelot.Provider.Polly;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using Serilog;
using StackExchange.Redis;
using CommunityConnect.Gateway.Services;
using CommunityConnect.Gateway.Middleware;
using AspNetCoreRateLimit;

// ============================================
// SERILOG CONFIGURATION
// ============================================
Log.Logger = new LoggerConfiguration()
    .ReadFrom.Configuration(new ConfigurationBuilder()
        .AddJsonFile("appsettings.json")
        .Build())
    .CreateLogger();

try
{
    Log.Information("Starting CommunityConnect API Gateway");

    var builder = WebApplication.CreateBuilder(args);

    // Add Serilog
    builder.Host.UseSerilog();

    // ============================================
    // SERVICE CONFIGURATION
    // ============================================

    // Add Configuration
    builder.Configuration
        .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
        .AddJsonFile($"appsettings.{builder.Environment.EnvironmentName}.json", optional: true, reloadOnChange: true)
        .AddJsonFile("ocelot.json", optional: false, reloadOnChange: true)
        .AddEnvironmentVariables();

    // Add Redis Connection
    var redisConnectionString = builder.Configuration["Redis:ConnectionString"] ?? "localhost:6379";
    builder.Services.AddSingleton<IConnectionMultiplexer>(sp =>
    {
        try
        {
            var configuration = ConfigurationOptions.Parse(redisConnectionString);
            configuration.AbortOnConnectFail = false;
            configuration.ConnectRetry = 3;
            configuration.ConnectTimeout = 5000;
            configuration.AsyncTimeout = 5000;
            configuration.SyncTimeout = 5000;

            var multiplexer = ConnectionMultiplexer.Connect(configuration);

            multiplexer.ConnectionFailed += (sender, args) =>
            {
                Log.Warning("Redis connection failed: {EndPoint} - {FailureType}", 
                    args.EndPoint, args.FailureType);
            };

            multiplexer.ConnectionRestored += (sender, args) =>
            {
                Log.Information("Redis connection restored: {EndPoint}", args.EndPoint);
            };

            Log.Information("Redis connection established successfully");
            return multiplexer;
        }
        catch (Exception ex)
        {
            Log.Warning(ex, "Failed to connect to Redis at {ConnectionString}. Gateway will run without caching.", 
                redisConnectionString);

            // Return a disconnected multiplexer - service will handle gracefully
            var configuration = ConfigurationOptions.Parse(redisConnectionString);
            configuration.AbortOnConnectFail = false;
            return ConnectionMultiplexer.Connect(configuration);
        }
    });

    // Add Redis Distributed Cache
    builder.Services.AddStackExchangeRedisCache(options =>
    {
        options.Configuration = redisConnectionString;
        options.InstanceName = builder.Configuration["Redis:InstanceName"] ?? "CommunityConnect_Gateway_";
    });

    // Register Cache Service
    builder.Services.AddSingleton<ICacheService, RedisCacheService>();

    // ============================================
    // JWT AUTHENTICATION
    // ============================================
    var jwtSettings = builder.Configuration.GetSection("Jwt");
    var secretKey = jwtSettings["SecretKey"] ?? throw new InvalidOperationException("JWT SecretKey is not configured");

    builder.Services.AddAuthentication(options =>
    {
        options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
        options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
    })
    .AddJwtBearer("Bearer", options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = jwtSettings["Issuer"],
            ValidAudience = jwtSettings["Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey)),
            ClockSkew = TimeSpan.Zero
        };

        options.Events = new JwtBearerEvents
        {
            OnAuthenticationFailed = context =>
            {
                Log.Warning("JWT Authentication failed: {Error}", context.Exception.Message);
                return Task.CompletedTask;
            },
            OnTokenValidated = context =>
            {
                Log.Information("JWT Token validated successfully for user: {User}", 
                    context.Principal?.Identity?.Name ?? "Unknown");
                return Task.CompletedTask;
            }
        };
    });

    builder.Services.AddAuthorization();

    // ============================================
    // CORS CONFIGURATION
    // ============================================
    var corsSettings = builder.Configuration.GetSection("Cors");
    var allowedOrigins = corsSettings.GetSection("AllowedOrigins").Get<string[]>() ?? Array.Empty<string>();

    builder.Services.AddCors(options =>
    {
        options.AddPolicy("CommunityConnectCorsPolicy", policy =>
        {
            policy.WithOrigins(allowedOrigins)
                  .AllowAnyMethod()
                  .AllowAnyHeader()
                  .AllowCredentials()
                  .WithExposedHeaders("X-Cache-Status", "X-RateLimit-Limit", "X-RateLimit-Remaining");
        });
    });

    // ============================================
    // RATE LIMITING
    // ============================================
    builder.Services.AddMemoryCache();
    builder.Services.Configure<IpRateLimitOptions>(builder.Configuration.GetSection("IpRateLimiting"));
    builder.Services.AddInMemoryRateLimiting();
    builder.Services.AddSingleton<IRateLimitConfiguration, RateLimitConfiguration>();

    // ============================================
    // OCELOT WITH CACHE MANAGER AND POLLY (QOS)
    // ============================================
    builder.Services
        .AddOcelot(builder.Configuration)
        .AddCacheManager(x =>
        {
            x.WithDictionaryHandle();
        })
        .AddPolly();

    // ============================================
    // HEALTH CHECKS
    // ============================================
    builder.Services.AddHealthChecks()
        .AddCheck("gateway", () => 
            Microsoft.Extensions.Diagnostics.HealthChecks.HealthCheckResult.Healthy("Gateway is operational"))
        .AddRedis(redisConnectionString, 
            name: "redis-cache", 
            failureStatus: Microsoft.Extensions.Diagnostics.HealthChecks.HealthStatus.Degraded,
            tags: new[] { "cache", "optional" });

    // Add Controllers for health endpoint
    builder.Services.AddControllers();

    var app = builder.Build();

    // ============================================
    // MIDDLEWARE PIPELINE
    // ============================================

    // Use Serilog Request Logging
    app.UseSerilogRequestLogging(options =>
    {
        options.MessageTemplate = "HTTP {RequestMethod} {RequestPath} responded {StatusCode} in {Elapsed:0.0000} ms";
        options.EnrichDiagnosticContext = (diagnosticContext, httpContext) =>
        {
            diagnosticContext.Set("RequestHost", httpContext.Request.Host.Value);
            diagnosticContext.Set("UserAgent", httpContext.Request.Headers["User-Agent"].ToString());
            diagnosticContext.Set("ClientIP", httpContext.Connection.RemoteIpAddress?.ToString());
        };
    });

    // Use CORS
    app.UseCors("CommunityConnectCorsPolicy");

    // Use IP Rate Limiting
    app.UseIpRateLimiting();

    // Use Authentication & Authorization
    app.UseAuthentication();
    app.UseAuthorization();

    // ============================================
    // HANDLE NON-API ROUTES BEFORE OCELOT
    // ============================================
    // Intercept /swagger requests and return helpful message
    app.Use(async (context, next) =>
    {
        var path = context.Request.Path.Value?.ToLower() ?? string.Empty;

        // Handle Swagger requests
        if (path.StartsWith("/swagger") || path.StartsWith("/openapi"))
        {
            context.Response.StatusCode = 404;
            context.Response.ContentType = "application/json";
            await context.Response.WriteAsJsonAsync(new
            {
                error = "Swagger UI not available",
                message = "This is an API Gateway. Use /health for health checks or /api/* for service routes.",
                endpoints = new[]
                {
                    "GET /health - Health check",
                    "GET /health/ready - Readiness check",
                    "POST /api/auth/login - Authentication service",
                    "GET /api/user/profile - User service (requires JWT)",
                    "// ... see ocelot.json for all routes"
                }
            });
            return;
        }

        await next(context);
    });

    // ============================================
    // CONDITIONAL ROUTING - Gateway endpoints bypass Ocelot
    // ============================================

    // Health Check Endpoints (handled by gateway, not Ocelot)
    // Must be mapped BEFORE Ocelot

    // Basic health check - Always returns healthy if gateway is running
    app.MapHealthChecks("/health", new Microsoft.AspNetCore.Diagnostics.HealthChecks.HealthCheckOptions
    {
        Predicate = (check) => check.Name == "gateway",
        ResponseWriter = async (context, report) =>
        {
            context.Response.ContentType = "application/json";
            await context.Response.WriteAsJsonAsync(new
            {
                status = report.Status.ToString(),
                message = "Gateway is operational"
            });
        }
    });

    // Detailed health check - Shows all components including Redis
    app.MapHealthChecks("/health/detailed", new Microsoft.AspNetCore.Diagnostics.HealthChecks.HealthCheckOptions
    {
        ResponseWriter = async (context, report) =>
        {
            context.Response.ContentType = "application/json";
            var result = new
            {
                status = report.Status.ToString(),
                duration = report.TotalDuration.TotalMilliseconds,
                checks = report.Entries.Select(e => new
                {
                    name = e.Key,
                    status = e.Value.Status.ToString(),
                    duration = e.Value.Duration.TotalMilliseconds,
                    description = e.Value.Description,
                    data = e.Value.Data
                })
            };
            await context.Response.WriteAsJsonAsync(result);
        }
    });

    // Ready check - Same as basic health
    app.MapHealthChecks("/health/ready", new Microsoft.AspNetCore.Diagnostics.HealthChecks.HealthCheckOptions
    {
        Predicate = (check) => check.Name == "gateway"
    });

    app.MapControllers();

    // Apply Cache Middleware and Ocelot ONLY to /api/* routes
    app.MapWhen(
        context => context.Request.Path.StartsWithSegments("/api"),
        appBuilder =>
        {
            appBuilder.UseMiddleware<CacheMiddleware>();
            appBuilder.UseOcelot().Wait();
        });

    Log.Information("CommunityConnect API Gateway started successfully on {BaseUrl}", 
        builder.Configuration["Gateway:BaseUrl"] ?? "http://localhost:5000");

    await app.RunAsync();
}
catch (Exception ex)
{
    Log.Fatal(ex, "Gateway terminated unexpectedly");
}
finally
{
    Log.CloseAndFlush();
}


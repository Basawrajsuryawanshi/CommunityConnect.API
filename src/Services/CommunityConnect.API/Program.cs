using CommunityConnect.API.Middleware;
using CommunityConnect.API.Services;
using CommunityConnect.Core.Data;
using CommunityConnect.Core.Services;
using CommunityConnect.Infrastructure.Data;
using CommunityConnect.Infrastructure.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using StackExchange.Redis;
using System.Text;
using Serilog;
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
    Log.Information("Starting CommunityConnect API");

    var builder = WebApplication.CreateBuilder(args);

    // Add Serilog
    builder.Host.UseSerilog();

    // ============================================
    // SERVICE CONFIGURATION
    // ============================================

    // Add controllers and API explorer
    builder.Services.AddControllers();
    builder.Services.AddEndpointsApiExplorer();
    builder.Services.AddSwaggerGen();

    // ============================================
    // REDIS CONFIGURATION (Optional - graceful degradation)
    // ============================================
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
            Log.Warning(ex, "Failed to connect to Redis at {ConnectionString}. API will run without caching.", 
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
        options.InstanceName = builder.Configuration["Redis:InstanceName"] ?? "CommunityConnect_API_";
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
    .AddJwtBearer(options =>
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
            if (allowedOrigins.Length > 0)
            {
                policy.WithOrigins(allowedOrigins)
                      .AllowAnyMethod()
                      .AllowAnyHeader()
                      .AllowCredentials()
                      .WithExposedHeaders("X-Cache-Status", "X-RateLimit-Limit", "X-RateLimit-Remaining");
            }
            else
            {
                // Development fallback - allow all
                policy.AllowAnyOrigin()
                      .AllowAnyMethod()
                      .AllowAnyHeader();
            }
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
    // DATABASE CONFIGURATION
    // ============================================
    // Database - Keep DbContext for EF migrations (optional)
    // Uncomment if you want to use EF migrations for schema management
    // builder.Services.AddDbContext<AuthDbContext>(options =>
    //     options.UseSqlServer(builder.Configuration.GetConnectionString("AuthDb")));

    // Register stored procedure-based database service
    builder.Services.AddScoped<IAuthDatabase, AuthDatabaseService>();

    // Services
    builder.Services.AddScoped<IAuthService, AuthService>();

    // ============================================
    // HEALTH CHECKS
    // ============================================
    builder.Services.AddHealthChecks()
        .AddCheck("api", () => 
            Microsoft.Extensions.Diagnostics.HealthChecks.HealthCheckResult.Healthy("API is operational"))
        .AddRedis(redisConnectionString, 
            name: "redis-cache", 
            failureStatus: Microsoft.Extensions.Diagnostics.HealthChecks.HealthStatus.Degraded);

    var app = builder.Build();

    // ============================================
    // MIDDLEWARE PIPELINE
    // ============================================

    // Serilog Request Logging
    app.UseSerilogRequestLogging(options =>
    {
        options.EnrichDiagnosticContext = (diagnosticContext, httpContext) =>
        {
            diagnosticContext.Set("RequestHost", httpContext.Request.Host.Value);
            diagnosticContext.Set("UserAgent", httpContext.Request.Headers["User-Agent"].ToString());
            diagnosticContext.Set("ClientIP", httpContext.Connection.RemoteIpAddress?.ToString());
        };
    });

    // Configure pipeline
    if (app.Environment.IsDevelopment())
    {
        app.UseSwagger();
        app.UseSwaggerUI();
    }

    // Use CORS
    app.UseCors("CommunityConnectCorsPolicy");

    // Use IP Rate Limiting
    app.UseIpRateLimiting();

    app.UseHttpsRedirection();

    // Use Authentication & Authorization
    app.UseAuthentication();
    app.UseAuthorization();

    // Use Cache Middleware (only for API routes)
    app.UseMiddleware<CacheMiddleware>();

    // Map Controllers
    app.MapControllers();

    // ============================================
    // HEALTH CHECK ENDPOINTS
    // ============================================

    // Basic health check - Always returns healthy if API is running
    app.MapHealthChecks("/health", new Microsoft.AspNetCore.Diagnostics.HealthChecks.HealthCheckOptions
    {
        Predicate = (check) => check.Name == "api",
        ResponseWriter = async (context, report) =>
        {
            context.Response.ContentType = "application/json";
            await context.Response.WriteAsJsonAsync(new
            {
                status = report.Status.ToString(),
                message = "API is operational"
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
        Predicate = (check) => check.Name == "api"
    });

    Log.Information("CommunityConnect API started successfully on {BaseUrl}", 
        builder.Configuration["Urls"] ?? "http://localhost:5000");

    await app.RunAsync();
}
catch (Exception ex)
{
    Log.Fatal(ex, "API terminated unexpectedly");
}
finally
{
    Log.CloseAndFlush();
}


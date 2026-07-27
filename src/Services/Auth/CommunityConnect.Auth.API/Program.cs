using CommunityConnect.Auth.Core.Data;
using CommunityConnect.Auth.Core.Services;
using CommunityConnect.Auth.Infrastructure.Data;
using CommunityConnect.Auth.Infrastructure.Services;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Add services
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Database - Keep DbContext for EF migrations (optional)
// Uncomment if you want to use EF migrations for schema management
// builder.Services.AddDbContext<AuthDbContext>(options =>
//     options.UseSqlServer(builder.Configuration.GetConnectionString("AuthDb")));

// Register stored procedure-based database service
builder.Services.AddScoped<IAuthDatabase, AuthDatabaseService>();

// Services
builder.Services.AddScoped<IAuthService, AuthService>();

// CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

var app = builder.Build();

// Configure pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors("AllowAll");
app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

app.Run();

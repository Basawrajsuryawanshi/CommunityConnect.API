# Quick Start Guide - CommunityConnect.API

## ✅ What Has Been Created

Your CommunityConnect.API solution is now fully set up with:

### 📦 Projects Created (31 total)
- **1 Solution File**: CommunityConnect.sln
- **1 API Gateway**: CommunityConnect.Gateway (Ocelot)
- **3 Shared Libraries**: Common, Contracts, MessageBus
- **8 Microservices** (each with API, Core, and optional Infrastructure layers):
  - Auth Service (API, Core, Infrastructure)
  - User Service (API, Core, Infrastructure)
  - Event Service (API, Core, Infrastructure)
  - Discussion Service (API, Core, Infrastructure)
  - Announcement Service (API, Core, Infrastructure)
  - Notification Service (API, Core)
  - Analytics Service (API, Core)
  - Media Service (API, Core)
- **3 Test Projects**: Auth.Tests, User.Tests, IntegrationTests

### 📚 NuGet Packages Installed
- ✅ Entity Framework Core + Npgsql (PostgreSQL)
- ✅ JWT Bearer Authentication
- ✅ FluentValidation
- ✅ AutoMapper
- ✅ Serilog (structured logging)
- ✅ Swagger/OpenAPI (all API projects)
- ✅ Ocelot (API Gateway)
- ✅ MassTransit + RabbitMQ (message bus)
- ✅ Health Checks

### 🏗️ Architecture
Clean Architecture with:
- **API Layer**: Controllers, endpoints, DTOs
- **Core Layer**: Domain entities, interfaces, business logic
- **Infrastructure Layer**: Data access, repositories, DbContext

## 🚀 Running Your First Service

### Option 1: Using Visual Studio
1. Open `CommunityConnect.sln` in Visual Studio
2. Right-click on any API project (e.g., `CommunityConnect.Auth.API`)
3. Select "Set as Startup Project"
4. Press **F5** to run

### Option 2: Using Command Line
```bash
# Navigate to any service
cd src/Services/Auth/CommunityConnect.Auth.API

# Run the service
dotnet run

# The API will start on http://localhost:5050
# Swagger UI available at: http://localhost:5050/swagger
```

### Option 3: Run Multiple Services
Open multiple terminals and run different services:

**Terminal 1 - Auth Service:**
```bash
cd src/Services/Auth/CommunityConnect.Auth.API
dotnet run
```

**Terminal 2 - User Service:**
```bash
cd src/Services/User/CommunityConnect.User.API
dotnet run
```

**Terminal 3 - Gateway:**
```bash
cd src/Gateway/CommunityConnect.Gateway
dotnet run
```

## 📖 Accessing Swagger Documentation

Once a service is running, open your browser and navigate to:
- **Auth Service**: http://localhost:5050/swagger
- **User Service**: http://localhost:5000/swagger (default port)
- **Event Service**: http://localhost:5000/swagger (default port)

> **Note**: Each service will use port 5000 by default. You'll need to configure different ports in `launchSettings.json` to run multiple services simultaneously.

## 🔧 Configuring Ports (Optional)

To run multiple services at the same time, update the `launchSettings.json` file in each API project:

**Path**: `src/Services/{ServiceName}/CommunityConnect.{ServiceName}.API/Properties/launchSettings.json`

Change the port in the `applicationUrl` property:
```json
"applicationUrl": "https://localhost:5001;http://localhost:5000"
```

Suggested port mapping:
- Gateway: 5000
- Auth: 5001
- User: 5002
- Event: 5003
- Discussion: 5004
- Announcement: 5005
- Notification: 5006
- Analytics: 5007
- Media: 5008

## 🗄️ Next Steps - Database Setup

### 1. Install PostgreSQL
Download and install PostgreSQL from https://www.postgresql.org/download/

### 2. Create Databases
```sql
CREATE DATABASE communityconnect_auth;
CREATE DATABASE communityconnect_user;
CREATE DATABASE communityconnect_event;
-- Create databases for other services as needed
```

### 3. Update Connection Strings
Edit `appsettings.json` in each API project:
```json
{
  "ConnectionStrings": {
	"DefaultConnection": "Host=localhost;Database=communityconnect_auth;Username=postgres;Password=yourpassword"
  }
}
```

### 4. Add DbContext (Example for Auth Service)
Create `AuthDbContext.cs` in `CommunityConnect.Auth.Infrastructure/Data/`:
```csharp
using Microsoft.EntityFrameworkCore;

namespace CommunityConnect.Auth.Infrastructure.Data
{
	public class AuthDbContext : DbContext
	{
		public AuthDbContext(DbContextOptions<AuthDbContext> options) 
			: base(options)
		{
		}

		// Add DbSets here
		// public DbSet<User> Users { get; set; }
	}
}
```

### 5. Register DbContext in Program.cs
```csharp
builder.Services.AddDbContext<AuthDbContext>(options =>
	options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));
```

### 6. Create and Run Migrations
```bash
# From Infrastructure project directory
cd src/Services/Auth/CommunityConnect.Auth.Infrastructure

# Add migration
dotnet ef migrations add InitialCreate --startup-project ../CommunityConnect.Auth.API

# Update database
dotnet ef database update --startup-project ../CommunityConnect.Auth.API
```

## 🔒 Setting Up JWT Authentication

Add to `appsettings.json`:
```json
{
  "Jwt": {
	"Key": "YourSuperSecretKeyHere_MustBeAtLeast32Characters",
	"Issuer": "CommunityConnect",
	"Audience": "CommunityConnectUsers",
	"ExpiryInMinutes": 60
  }
}
```

Configure in `Program.cs`:
```csharp
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
	.AddJwtBearer(options =>
	{
		options.TokenValidationParameters = new TokenValidationParameters
		{
			ValidateIssuer = true,
			ValidateAudience = true,
			ValidateLifetime = true,
			ValidateIssuerSigningKey = true,
			ValidIssuer = builder.Configuration["Jwt:Issuer"],
			ValidAudience = builder.Configuration["Jwt:Audience"],
			IssuerSigningKey = new SymmetricSecurityKey(
				Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]))
		};
	});
```

## 📝 Creating Your First Controller

Example `UsersController.cs` in Auth.API:
```csharp
using Microsoft.AspNetCore.Mvc;

namespace CommunityConnect.Auth.API.Controllers
{
	[ApiController]
	[Route("api/[controller]")]
	public class UsersController : ControllerBase
	{
		[HttpGet]
		public IActionResult GetUsers()
		{
			return Ok(new { message = "Hello from Auth Service!" });
		}

		[HttpGet("{id}")]
		public IActionResult GetUser(int id)
		{
			return Ok(new { id, name = "Sample User" });
		}
	}
}
```

## ✅ Verify Everything Works

1. **Build the solution**:
   ```bash
   dotnet build
   ```
   ✅ Should complete with 0 errors (warnings about package vulnerabilities are normal)

2. **Run tests**:
   ```bash
   dotnet test
   ```

3. **Run a service**:
   ```bash
   cd src/Services/Auth/CommunityConnect.Auth.API
   dotnet run
   ```
   ✅ Service should start and show: "Now listening on: http://localhost:5050"

4. **Access Swagger**:
   Open browser: http://localhost:5050/swagger
   ✅ You should see the Swagger UI with the WeatherForecast example endpoint

## 🎯 What to Do Next

1. ✅ **Remove Example Controllers**: Delete `WeatherForecast.cs` and `WeatherForecastController.cs` from each API project
2. 📝 **Design Your Domain Models**: Add entities to the Core projects
3. 🗄️ **Set Up Databases**: Follow the database setup steps above
4. 🔌 **Create Repositories**: Implement data access in Infrastructure projects
5. 🎮 **Build Controllers**: Add your API endpoints in the API projects
6. 🧪 **Write Tests**: Add unit and integration tests
7. 🚪 **Configure Gateway**: Set up Ocelot routing in the Gateway project
8. 📨 **Add Message Bus**: Implement inter-service communication with MassTransit

## 📚 Resources

- [ASP.NET Core Documentation](https://docs.microsoft.com/aspnet/core)
- [Entity Framework Core](https://docs.microsoft.com/ef/core)
- [Ocelot Documentation](https://ocelot.readthedocs.io/)
- [MassTransit Documentation](https://masstransit-project.com/)

## 🐛 Troubleshooting

**Issue: Port already in use**
- Solution: Change port in `launchSettings.json` or stop other applications using that port

**Issue: Package vulnerability warnings**
- Solution: These are warnings about Microsoft.OpenApi 2.0.0. Update when a fix is available or use `<NoWarn>NU1903</NoWarn>` in csproj

**Issue: Build fails**
- Solution: Run `dotnet restore` then `dotnet clean` then `dotnet build`

## 🎉 Congratulations!

Your microservices solution is ready for development! Start building your CommunityConnect platform. 🚀

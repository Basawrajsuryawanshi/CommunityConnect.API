# CommunityConnect.API

A microservices-based community platform built with .NET, following Clean Architecture principles.

## Architecture

This solution follows a microservices architecture with:
- **API Gateway** (Ocelot) - Entry point for all client requests
- **8 Microservices** - Auth, User, Event, Discussion, Announcement, Notification, Analytics, Media
- **Shared Libraries** - Common utilities, contracts, and message bus integration
- **PostgreSQL** - Database for each service
- **RabbitMQ** - Message broker for inter-service communication

## Solution Structure

```
CommunityConnect.API/
├── src/
│   ├── Gateway/
│   │   └── CommunityConnect.Gateway/               # API Gateway (Ocelot)
│   ├── Services/
│   │   ├── Auth/                                    # Authentication & Authorization
│   │   ├── User/                                    # User Management
│   │   ├── Event/                                   # Event Management
│   │   ├── Discussion/                              # Discussion Forums
│   │   ├── Announcement/                            # Announcements
│   │   ├── Notification/                            # Notification Service
│   │   ├── Analytics/                               # Analytics Service
│   │   └── Media/                                   # Media Management
│   └── Shared/
│       ├── CommunityConnect.Common/                # Shared utilities
│       ├── CommunityConnect.Contracts/             # Shared DTOs/Interfaces
│       └── CommunityConnect.MessageBus/            # RabbitMQ integration
├── tests/                                           # Test projects
├── docs/                                           # Documentation
├── scripts/                                        # Database scripts, migrations
└── docker/                                         # Docker compose files
```

## Technologies

- **.NET 10.0** - Latest .NET framework
- **ASP.NET Core Web API** - REST API framework
- **Entity Framework Core** - ORM for data access
- **PostgreSQL (Npgsql)** - Database
- **Ocelot** - API Gateway
- **MassTransit + RabbitMQ** - Message bus
- **JWT Bearer** - Authentication
- **FluentValidation** - Input validation
- **AutoMapper** - Object mapping
- **Serilog** - Structured logging
- **Swagger/OpenAPI** - API documentation
- **xUnit** - Unit testing framework

## Getting Started

### Prerequisites

- .NET 10.0 SDK or later
- PostgreSQL 12+
- RabbitMQ (optional, for message bus features)
- Visual Studio 2026 or VS Code

### Running the Solution

1. **Clone the repository**
   ```bash
   git clone https://github.com/YourUsername/CommunityConnect.API.git
   cd CommunityConnect.API
   ```

2. **Build the solution**
   ```bash
   dotnet build
   ```

3. **Run a specific service** (e.g., Auth Service)
   ```bash
   cd src/Services/Auth/CommunityConnect.Auth.API
   dotnet run
   ```
   The API will be available at `https://localhost:5001/swagger`

4. **Run the Gateway**
   ```bash
   cd src/Gateway/CommunityConnect.Gateway
   dotnet run
   ```

### API Endpoints

Each service has its own Swagger documentation available at:
- Auth Service: `https://localhost:5001/swagger`
- User Service: `https://localhost:5002/swagger`
- Event Service: `https://localhost:5003/swagger`
- Discussion Service: `https://localhost:5004/swagger`
- Announcement Service: `https://localhost:5005/swagger`
- Notification Service: `https://localhost:5006/swagger`
- Analytics Service: `https://localhost:5007/swagger`
- Media Service: `https://localhost:5008/swagger`
- Gateway: `https://localhost:5000/swagger`

*(Note: Update ports in launchSettings.json as needed)*

## Development

### Project Structure per Service

Each service follows Clean Architecture:

```
CommunityConnect.[Service].API/         # Presentation layer
├── Controllers/                        # API endpoints
├── Program.cs                          # Application entry point
└── appsettings.json                    # Configuration

CommunityConnect.[Service].Core/        # Domain layer
├── Entities/                           # Domain models
├── Interfaces/                         # Abstractions
└── Services/                           # Business logic

CommunityConnect.[Service].Infrastructure/ # Infrastructure layer
├── Data/                               # DbContext
├── Repositories/                       # Data access
└── Migrations/                         # EF migrations
```

### Adding Migrations

```bash
cd src/Services/Auth/CommunityConnect.Auth.Infrastructure
dotnet ef migrations add InitialCreate --startup-project ../CommunityConnect.Auth.API
dotnet ef database update --startup-project ../CommunityConnect.Auth.API
```

## Testing

```bash
# Run all tests
dotnet test

# Run specific test project
dotnet test tests/CommunityConnect.Auth.Tests
```

## Contributing

1. Create a feature branch
2. Make your changes
3. Write/update tests
4. Ensure build succeeds
5. Create a pull request

## License

[Your License Here]

## Contact

[Your Contact Information]

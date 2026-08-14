# CommunityConnect.Database

SQL Server Database Project for CommunityConnect application.

## Project Structure

```
src/Database/
├── CommunityConnect.Database.sqlproj     # SQL Server Database Project
├── CommunityConnect.Database.publish.xml # Publish profile
├── Tables/                               # Table definitions
├── StoredProcedures/                     # Stored procedures
└── Scripts/                              # Pre/Post deployment scripts
```

## Getting Started

### Prerequisites
- Visual Studio 2019+ with SQL Server Data Tools (SSDT)
- SQL Server 2016+ or Azure SQL Database
- SQL Server Management Studio (SSMS) - Optional but recommended

### Importing from Existing Database

#### Method 1: Using Visual Studio
1. Open the solution in Visual Studio
2. Right-click on `CommunityConnect.Database` project
3. Select **Import → Database...**
4. Configure connection to your SQL Server
   - Server: `(localdb)\MSSQLLocalDB` or your SQL Server instance
   - Database: `Communityconnect`
5. Select objects to import (Tables, Views, Stored Procedures, etc.)
6. Click **Start** to import

#### Method 2: Using Schema Compare
1. Right-click on `CommunityConnect.Database` project
2. Select **Schema Compare...**
3. Set **Target**: Your database project
4. Set **Source**: Your database
5. Click **Compare**
6. Review differences and click **Update** to import

#### Method 3: Using SSMS + SqlPackage
```powershell
# Extract database to dacpac
SqlPackage.exe /Action:Extract /SourceServerName:(localdb)\MSSQLLocalDB /SourceDatabaseName:Communityconnect /TargetFile:Communityconnect.dacpac

# Then import the dacpac into the project using Visual Studio
```

### Building the Project

#### Using Visual Studio
1. Right-click on the project
2. Select **Build**

#### Using Command Line
```powershell
msbuild src\Database\CommunityConnect.Database.sqlproj /t:Build /p:Configuration=Release
```

### Publishing to Database

#### Using Visual Studio
1. Right-click on the project
2. Select **Publish...**
3. Load the publish profile: `CommunityConnect.Database.publish.xml`
4. Or configure a new connection:
   - **Target database name**: `Communityconnect`
   - **Connection string**: Update as needed
5. Click **Generate Script** to preview changes
6. Click **Publish** to deploy

#### Using Command Line
```powershell
# Using SqlPackage
SqlPackage.exe /Action:Publish `
  /SourceFile:src\Database\bin\Release\CommunityConnect.Database.dacpac `
  /TargetDatabaseName:Communityconnect `
  /TargetServerName:(localdb)\MSSQLLocalDB

# Or using MSBuild with publish profile
msbuild src\Database\CommunityConnect.Database.sqlproj `
  /t:Publish `
  /p:SqlPublishProfilePath=CommunityConnect.Database.publish.xml
```

### Customizing Connection String

Edit `CommunityConnect.Database.publish.xml` and update the `<TargetConnectionString>`:

**LocalDB:**
```xml
<TargetConnectionString>Data Source=(localdb)\MSSQLLocalDB;Integrated Security=True;...</TargetConnectionString>
```

**SQL Server Express:**
```xml
<TargetConnectionString>Data Source=.\SQLEXPRESS;Integrated Security=True;Persist Security Info=False;...</TargetConnectionString>
```

**SQL Server (Windows Auth):**
```xml
<TargetConnectionString>Data Source=YOUR_SERVER;Initial Catalog=Communityconnect;Integrated Security=True;...</TargetConnectionString>
```

**SQL Server (SQL Auth):**
```xml
<TargetConnectionString>Data Source=YOUR_SERVER;Initial Catalog=Communityconnect;User ID=your_user;Password=your_password;...</TargetConnectionString>
```

**Azure SQL Database:**
```xml
<TargetConnectionString>Data Source=your-server.database.windows.net;Initial Catalog=Communityconnect;User ID=your_user;Password=your_password;Encrypt=True;TrustServerCertificate=False;...</TargetConnectionString>
```

## Common Tasks

### Viewing Database Schema
- Open the project in SQL Server Object Explorer (Visual Studio)
- Expand the database node to view tables, stored procedures, etc.

### Comparing with Database
```powershell
# Use Schema Compare in Visual Studio
# Tools → SQL Server → New Schema Comparison
```

### Generating Scripts
- Build the project to generate deployment scripts in `bin\Debug\` or `bin\Release\`
- The `.sql` file contains the complete deployment script

### Version Control
- All database objects are stored as `.sql` files
- Commit changes to Git like any other code
- Use pull requests to review database schema changes

## Troubleshooting

### Build Errors
- Ensure SSDT is installed in Visual Studio
- Check SQL syntax in individual `.sql` files
- Verify foreign key references exist

### Publish Errors
- Verify SQL Server is running
- Check connection string in publish profile
- Ensure you have sufficient permissions
- Review generated deployment script for issues

### Import Issues
- Ensure source database is accessible
- Check firewall settings
- Verify database user permissions

## CI/CD Integration

### Azure DevOps Pipeline Example
```yaml
- task: VSBuild@1
  inputs:
	solution: 'src/Database/CommunityConnect.Database.sqlproj'

- task: SqlAzureDacpacDeployment@1
  inputs:
	azureSubscription: 'Your-Azure-Subscription'
	ServerName: 'your-server.database.windows.net'
	DatabaseName: 'Communityconnect'
	SqlUsername: '$(SqlUser)'
	SqlPassword: '$(SqlPassword)'
	DacpacFile: 'src/Database/bin/Release/CommunityConnect.Database.dacpac'
```

## Best Practices

1. **Always review deployment scripts** before publishing to production
2. **Use Schema Compare** to verify changes before deployment
3. **Test migrations** on a copy of production data
4. **Version control everything** - all schema changes should be committed
5. **Use pre/post deployment scripts** for data migrations
6. **Enable Block on Possible Data Loss** in publish profiles for production

## Resources

- [SQL Server Data Tools Documentation](https://docs.microsoft.com/en-us/sql/ssdt/sql-server-data-tools)
- [SqlPackage.exe Reference](https://docs.microsoft.com/en-us/sql/tools/sqlpackage)
- [Database Project Guide](https://docs.microsoft.com/en-us/sql/ssdt/how-to-create-a-new-database-project)

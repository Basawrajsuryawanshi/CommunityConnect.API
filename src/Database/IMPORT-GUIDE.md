# Import Database Schema from SSMS

This guide explains how to import your existing database schema from SQL Server Management Studio (SSMS) into the CommunityConnect.Database project.

## Prerequisites

- SQL Server with `Communityconnect` database
- Visual Studio 2019+ with SQL Server Data Tools (SSDT)
- The database should be accessible from your development machine

## Steps to Import from Existing Database

### Method 1: Direct Import in Visual Studio (Recommended)

1. **Open Solution in Visual Studio**
   - Open `CommunityConnect.sln` or `CommunityConnect.slnx`
   - You should see the `CommunityConnect.Database` project under `src/Database/`

2. **Import from Database**
   - Right-click on the `CommunityConnect.Database` project
   - Select **Import → Database...**

3. **Configure Connection**
   - Click **Select Connection**
   - Configure your SQL Server connection:
	 - **Server name**: `(localdb)\MSSQLLocalDB` or `.\SQLEXPRESS` or your server name
	 - **Authentication**: Windows Authentication or SQL Server Authentication
	 - **Database name**: `Communityconnect`
   - Click **Connect**

4. **Select Import Options**
   - **Import Settings**: Choose what to import
	 - ✅ Tables
	 - ✅ Views
	 - ✅ Stored Procedures
	 - ✅ Functions
	 - ✅ Schemas
	 - ⬜ Server-level objects (usually not needed)
   - **Folder Structure**: 
	 - Choose "Schema\Object Type" for organization
   - Click **Start**

5. **Wait for Import**
   - The import process will create `.sql` files for all objects
   - Watch the progress in the Data Tools Operations window

6. **Verify Import**
   - Expand the project folders:
	 - `Tables/` - should contain all your tables
	 - `StoredProcedures/` - should contain all stored procedures
   - Build the project to ensure no errors

### Method 2: Schema Compare

1. **Open Schema Compare**
   - Right-click on `CommunityConnect.Database` project
   - Select **Schema Compare...**

2. **Configure Source and Target**
   - **Source**: Click "Select Source" → "Database"
	 - Connect to your `Communityconnect` database
   - **Target**: Should already be set to your project
   - Click **Compare**

3. **Review and Update**
   - Review the differences (everything will be new since project is empty)
   - Select the objects you want to import
   - Click **Update Target** (the arrow button)
   - This will add all selected objects to your project

### Method 3: Using SqlPackage Command Line

1. **Extract Database to DACPAC**
   ```powershell
   # Navigate to your project directory
   cd C:\S\Apps\CommunityConnect.API\CommunityConnect.API

   # Extract database schema to dacpac file
   SqlPackage.exe /Action:Extract `
	 /SourceServerName:(localdb)\MSSQLLocalDB `
	 /SourceDatabaseName:Communityconnect `
	 /TargetFile:.\Communityconnect.dacpac
   ```

2. **Import DACPAC into Project**
   - In Visual Studio, right-click on `CommunityConnect.Database` project
   - Select **Import → Data-tier Application (.dacpac)...**
   - Browse to `Communityconnect.dacpac`
   - Click **Start**

### Method 4: Generate Scripts in SSMS (Manual)

1. **In SSMS**
   - Right-click on the `Communityconnect` database
   - Select **Tasks → Generate Scripts...**

2. **Choose Objects**
   - Select specific objects or all objects
   - Click **Next**

3. **Set Scripting Options**
   - Click **Advanced**
   - Important settings:
	 - **Script for Server Version**: SQL Server 2016+ (match your target)
	 - **Types of data to script**: Schema only
	 - **Script DROP and CREATE**: Script CREATE only
	 - **Script Indexes**: True
	 - **Script Foreign Keys**: True
   - Save scripts to: **File per object**
   - Choose folder: `C:\S\Apps\CommunityConnect.API\CommunityConnect.API\src\Database\`

4. **Organize Files**
   - Move table scripts to `src\Database\Tables\`
   - Move stored procedure scripts to `src\Database\StoredProcedures\`
   - Remove any `USE [database]` statements from scripts

5. **Add to Project**
   - In Visual Studio, right-click on project
   - Select **Add → Existing Item...**
   - Select all the `.sql` files
   - Or edit `.sqlproj` file to include them

## After Import

### 1. Build the Project
```powershell
# In Visual Studio: Right-click project → Build
# Or via command line:
msbuild src\Database\CommunityConnect.Database.sqlproj /t:Build
```

### 2. Fix Any Build Errors
Common issues:
- **Unresolved references**: Check object dependencies
- **Collation conflicts**: Review collation settings
- **Schema issues**: Ensure all schemas are defined

### 3. Update Publish Profile
- Edit `src\Database\CommunityConnect.Database.publish.xml`
- Update connection string to match your environment

### 4. Test Deployment
```powershell
# Generate deployment script (doesn't execute)
SqlPackage.exe /Action:Script `
  /SourceFile:src\Database\bin\Debug\CommunityConnect.Database.dacpac `
  /TargetDatabaseName:Communityconnect_Test `
  /TargetServerName:(localdb)\MSSQLLocalDB `
  /OutputPath:deployment-script.sql

# Review deployment-script.sql before actual deployment
```

## Common Connection Strings

**LocalDB:**
```
Server=(localdb)\MSSQLLocalDB;Database=Communityconnect;Integrated Security=True;
```

**SQL Server Express:**
```
Server=.\SQLEXPRESS;Database=Communityconnect;Integrated Security=True;
```

**SQL Server (Windows Auth):**
```
Server=YOUR_SERVER;Database=Communityconnect;Integrated Security=True;
```

**SQL Server (SQL Auth):**
```
Server=YOUR_SERVER;Database=Communityconnect;User Id=your_user;Password=your_password;
```

## Troubleshooting

### "SQL Server Data Tools not installed"
- Install SSDT from Visual Studio Installer
- Select "Data storage and processing" workload

### "Cannot connect to database"
- Verify SQL Server is running
- Check firewall settings
- Ensure you have necessary permissions
- Test connection in SSMS first

### "Import failed with errors"
- Check Event Viewer for detailed errors
- Ensure no circular dependencies
- Verify all referenced objects exist

### "Build errors after import"
- Review dependencies between objects
- Check for missing schemas or types
- Verify collation settings match

## Next Steps

After successful import:

1. ✅ Build the project
2. ✅ Commit changes to Git
3. ✅ Set up CI/CD pipeline
4. ✅ Document any manual migration scripts needed
5. ✅ Test deployment in staging environment

## Need Help?

- [SQL Server Data Tools Documentation](https://docs.microsoft.com/en-us/sql/ssdt/)
- [SqlPackage Reference](https://docs.microsoft.com/en-us/sql/tools/sqlpackage/)
- [Schema Compare Guide](https://docs.microsoft.com/en-us/sql/ssdt/how-to-use-schema-compare/)

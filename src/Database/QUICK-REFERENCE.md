# 🚀 Quick Reference - Database Project

## 📍 Location
```
src/Database/CommunityConnect.Database.sqlproj
```

## 🔨 Build
```powershell
msbuild src\Database\CommunityConnect.Database.sqlproj /t:Build
```

## 📥 Import from SSMS (Choose One Method)

### Method 1: Visual Studio (Easiest)
1. Open solution in Visual Studio
2. Right-click `CommunityConnect.Database` project
3. Import → Database
4. Connect to: `(localdb)\MSSQLLocalDB` or your server
5. Database: `Communityconnect`
6. Start

### Method 2: Schema Compare
1. Right-click project → Schema Compare
2. Source: Your database
3. Target: Project
4. Compare → Update Target

### Method 3: Command Line
```powershell
SqlPackage.exe /Action:Extract `
  /SourceServerName:(localdb)\MSSQLLocalDB `
  /SourceDatabaseName:Communityconnect `
  /TargetFile:.\Communityconnect.dacpac
```

## 🚀 Deploy to Database
```powershell
# Using publish profile
msbuild src\Database\CommunityConnect.Database.sqlproj /t:Publish /p:SqlPublishProfilePath=src\Database\CommunityConnect.Database.publish.xml

# Or using SqlPackage
SqlPackage.exe /Action:Publish `
  /SourceFile:src\Database\bin\Debug\CommunityConnect.Database.dacpac `
  /TargetDatabaseName:Communityconnect `
  /TargetServerName:(localdb)\MSSQLLocalDB
```

## 🔧 Update Connection String
Edit: `src/Database/CommunityConnect.Database.publish.xml`

**LocalDB:**
```xml
Data Source=(localdb)\MSSQLLocalDB;...
```

**SQL Express:**
```xml
Data Source=.\SQLEXPRESS;...
```

**Remote Server:**
```xml
Data Source=YOUR_SERVER;User ID=user;Password=pass;...
```

## 📂 Project Structure
```
src/Database/
├── *.sqlproj              # Project file
├── *.publish.xml          # Publish profile
├── Tables/                # Place table .sql files here
├── StoredProcedures/      # Place SP .sql files here
└── Scripts/               # Pre/Post deployment scripts
```

## ✅ Status
- ✅ Project created
- ✅ Added to solution
- ✅ Builds successfully
- ⏳ Ready for import from SSMS

## 📖 Documentation
- `README.md` - Full documentation
- `IMPORT-GUIDE.md` - Import instructions
- `SETUP-COMPLETE.md` - Setup summary

## 🆘 Common Commands

**Build project:**
```powershell
msbuild src\Database\CommunityConnect.Database.sqlproj /t:Build
```

**Clean build:**
```powershell
msbuild src\Database\CommunityConnect.Database.sqlproj /t:Clean,Build
```

**Generate script (no deploy):**
```powershell
SqlPackage.exe /Action:Script /SourceFile:src\Database\bin\Debug\CommunityConnect.Database.dacpac /TargetDatabaseName:Communityconnect /OutputPath:deploy.sql
```

## 🎯 Next Steps
1. Import database schema (see IMPORT-GUIDE.md)
2. Build to verify no errors
3. Commit to Git
4. Deploy to test environment

---
**Need help?** See full docs in `src/Database/README.md`

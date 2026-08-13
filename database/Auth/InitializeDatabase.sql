-- ============================================
-- Auth Database Initialization Script
-- This script creates the database for the Auth service
-- ============================================
-- Note: Table creation scripts are located in the Tables folder
-- ============================================

USE master;
GO

-- Create database if it doesn't exist
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'Communityconnect')
BEGIN
	CREATE DATABASE Communityconnect;
	PRINT 'Database Communityconnect created successfully.';
END
ELSE
BEGIN
	PRINT 'Database Communityconnect already exists.';
END
GO

PRINT '============================================';
PRINT 'Database initialization completed!';
PRINT 'Database: Communityconnect';
PRINT '';
PRINT 'Next Steps:';
PRINT '1. Deploy tables from the Tables folder in this order:';
PRINT '   - Users, RefreshTokens, OAuthProviders';
PRINT '   - UserProfiles, Roles, UserRoleAssignments';
PRINT '   - UserPreferences, UserConnections';
PRINT '2. Deploy stored procedures from the StoredProcedures folder';
PRINT '';
PRINT 'To deploy tables in order:';
PRINT '  $tableOrder = @(''Users.sql'', ''RefreshTokens.sql'', ''OAuthProviders.sql'', ''UserProfiles.sql'', ''Roles.sql'', ''UserRoleAssignments.sql'', ''UserPreferences.sql'', ''UserConnections.sql'')';
PRINT '  foreach ($table in $tableOrder) { sqlcmd -S .\SQLEXPRESS -i "Tables\$table" }';
PRINT '============================================';
GO

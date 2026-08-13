-- ============================================
-- sp_GetAllRoles: Gets all available roles
-- ============================================

USE Communityconnect;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetAllRoles')
	DROP PROCEDURE sp_GetAllRoles;
GO

CREATE PROCEDURE sp_GetAllRoles
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		Id, Name, Description, CreatedAt
	FROM Roles
	ORDER BY Name;
END
GO




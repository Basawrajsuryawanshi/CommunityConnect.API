-- ============================================
-- sp_CreateConnectionRequest: Creates a connection request
-- ============================================

USE UserDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_CreateConnectionRequest')
	DROP PROCEDURE sp_CreateConnectionRequest;
GO

CREATE PROCEDURE sp_CreateConnectionRequest
	@UserId UNIQUEIDENTIFIER,
	@ConnectedUserId UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Now DATETIME2 = GETUTCDATE();

	-- Check if connection already exists
	IF EXISTS (
		SELECT 1 FROM UserConnections 
		WHERE (UserId = @UserId AND ConnectedUserId = @ConnectedUserId)
		   OR (UserId = @ConnectedUserId AND ConnectedUserId = @UserId)
	)
	BEGIN
		RAISERROR('Connection already exists between these users', 16, 1);
		RETURN;
	END

	INSERT INTO UserConnections (UserId, ConnectedUserId, Status, RequestedAt)
	VALUES (@UserId, @ConnectedUserId, 'Pending', @Now);

	-- Return created connection
	SELECT 
		Id, UserId, ConnectedUserId, Status, RequestedAt
	FROM UserConnections
	WHERE Id = SCOPE_IDENTITY();
END
GO


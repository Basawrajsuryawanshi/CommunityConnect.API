-- ============================================
-- sp_AcceptConnectionRequest: Accepts a connection request
-- ============================================

USE AuthDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_AcceptConnectionRequest')
	DROP PROCEDURE sp_AcceptConnectionRequest;
GO

CREATE PROCEDURE sp_AcceptConnectionRequest
	@ConnectionId INT,
	@ConnectedUserId INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Now DATETIME2 = GETUTCDATE();

	UPDATE UserConnections
	SET 
		Status = 'Accepted',
		AcceptedAt = @Now
	WHERE 
		Id = @ConnectionId
		AND ConnectedUserId = @ConnectedUserId
		AND Status = 'Pending';

	-- Return updated connection
	SELECT 
		Id, UserId, ConnectedUserId, Status, AcceptedAt
	FROM UserConnections
	WHERE Id = @ConnectionId;
END
GO




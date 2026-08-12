-- ============================================
-- sp_RejectConnectionRequest: Rejects a connection request
-- ============================================

USE AuthDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_RejectConnectionRequest')
	DROP PROCEDURE sp_RejectConnectionRequest;
GO

CREATE PROCEDURE sp_RejectConnectionRequest
	@ConnectionId INT,
	@ConnectedUserId INT
AS
BEGIN
	SET NOCOUNT ON;

	DELETE FROM UserConnections
	WHERE 
		Id = @ConnectionId
		AND ConnectedUserId = @ConnectedUserId
		AND Status = 'Pending';

	SELECT CAST(@@ROWCOUNT AS BIT) AS Success;
END
GO





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

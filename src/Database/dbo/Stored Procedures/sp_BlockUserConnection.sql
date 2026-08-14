
CREATE PROCEDURE sp_BlockUserConnection
	@UserId INT,
	@ConnectedUserId INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Now DATETIME2 = GETUTCDATE();

	-- Delete any existing connection
	DELETE FROM UserConnections
	WHERE (UserId = @UserId AND ConnectedUserId = @ConnectedUserId)
	   OR (UserId = @ConnectedUserId AND ConnectedUserId = @UserId);

	-- Create blocked connection
	INSERT INTO UserConnections (UserId, ConnectedUserId, Status, RequestedAt)
	VALUES (@UserId, @ConnectedUserId, 'Blocked', @Now);

	-- Return blocked connection
	SELECT 
		Id, UserId, ConnectedUserId, Status, RequestedAt
	FROM UserConnections
	WHERE Id = SCOPE_IDENTITY();
END

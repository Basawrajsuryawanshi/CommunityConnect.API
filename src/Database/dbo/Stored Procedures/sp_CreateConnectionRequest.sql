
CREATE PROCEDURE sp_CreateConnectionRequest
	@UserId INT,
	@ConnectedUserId INT
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

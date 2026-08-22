
CREATE OR ALTER PROCEDURE [dbo].[sp_AcceptConnectionRequest]
    @ConnectionId INT,
    @ConnectedUserId INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRAN;

        IF @ConnectionId IS NULL OR @ConnectionId <= 0
            THROW 50018, 'ConnectionId is required.', 1;

        IF @ConnectedUserId IS NULL OR @ConnectedUserId <= 0
            THROW 50019, 'ConnectedUserId is required.', 1;

        IF NOT EXISTS (
            SELECT 1
            FROM dbo.UserConnections
            WHERE Id = @ConnectionId
              AND ConnectedUserId = @ConnectedUserId
        )
            THROW 50020, 'Connection request not found for the specified user.', 1;

        DECLARE @CurrentStatus NVARCHAR(20);

        SELECT @CurrentStatus = Status
        FROM dbo.UserConnections
        WHERE Id = @ConnectionId
          AND ConnectedUserId = @ConnectedUserId;

        IF @CurrentStatus IS NULL
            THROW 50021, 'Connection request not found.', 1;

        IF @CurrentStatus <> 'Pending'
        BEGIN
            IF @CurrentStatus = 'Accepted'
                THROW 50022, 'Connection request is already accepted.', 1;

            IF @CurrentStatus = 'Rejected'
                THROW 50023, 'Connection request was already rejected.', 1;

            IF @CurrentStatus = 'Blocked'
                THROW 50024, 'Connection request was blocked.', 1;

            THROW 50025, 'Connection request cannot be accepted in its current state.', 1;
        END;

        UPDATE dbo.UserConnections
        SET
            Status = 'Accepted',
            AcceptedAt = SYSUTCDATETIME()
        WHERE Id = @ConnectionId
          AND ConnectedUserId = @ConnectedUserId
          AND Status = 'Pending';

        IF @@ROWCOUNT = 0
            THROW 50026, 'Unable to accept connection request.', 1;

        SELECT
            Id,
            UserId,
            ConnectedUserId,
            Status,
            RequestedAt,
            AcceptedAt
        FROM dbo.UserConnections
        WHERE Id = @ConnectionId;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN;

        THROW;
    END CATCH
END
GO

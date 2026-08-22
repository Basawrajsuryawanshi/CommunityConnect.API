
CREATE OR ALTER PROCEDURE [dbo].[sp_CreateUser]
    @Email NVARCHAR(255),
    @PasswordHash NVARCHAR(500),
    @EmailVerified BIT = 0,
    @EmailVerificationToken NVARCHAR(500) = NULL,
    @EmailVerificationExpiry DATETIME2(7) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @UserId INT;
    DECLARE @Now DATETIME2(7) = SYSUTCDATETIME();

    BEGIN TRY
        BEGIN TRAN;

        IF NULLIF(LTRIM(RTRIM(@Email)), '') IS NULL
            THROW 50001, 'Email is required.', 1;

        IF NULLIF(LTRIM(RTRIM(@PasswordHash)), '') IS NULL
            THROW 50002, 'Password hash is required.', 1;

        IF EXISTS (
            SELECT 1
            FROM dbo.Users
            WHERE Email = @Email
              AND IsDeleted = 0
        )
            THROW 50003, 'Email already exists.', 1;

        IF @EmailVerificationExpiry IS NOT NULL
           AND @EmailVerificationExpiry < @Now
            THROW 50004, 'Email verification expiry cannot be in the past.', 1;

        INSERT INTO dbo.Users (
            Email,
            PasswordHash,
            EmailVerified,
            EmailVerificationToken,
            EmailVerificationExpiry,
            IsActive,
            IsDeleted,
            CreatedAt,
            UpdatedAt
        )
        VALUES (
            @Email,
            @PasswordHash,
            @EmailVerified,
            @EmailVerificationToken,
            @EmailVerificationExpiry,
            1,
            0,
            @Now,
            @Now
        );

        SET @UserId = SCOPE_IDENTITY();

        SELECT
            Id,
            Email,
            PasswordHash,
            EmailVerified,
            EmailVerificationToken,
            EmailVerificationExpiry,
            PasswordResetToken,
            PasswordResetExpiry,
            IsActive,
            IsDeleted,
            CreatedAt,
            UpdatedAt,
            LastLoginAt
        FROM dbo.Users
        WHERE Id = @UserId;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN;

        THROW;
    END CATCH
END
GO

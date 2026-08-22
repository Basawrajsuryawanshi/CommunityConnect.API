
CREATE OR ALTER PROCEDURE [dbo].[sp_CreateUserProfile]
    @Id INT,
    @FullName NVARCHAR(255),
    @Email NVARCHAR(255) = NULL,
    @MobileNumber NVARCHAR(10),
    @SchoolName NVARCHAR(255),
    @State NVARCHAR(100),
    @SchoolRegion NVARCHAR(100),
    @PassoutYear INT,
    @Role NVARCHAR(50),
    @University NVARCHAR(255),
    @CurrentState NVARCHAR(100),
    @CurrentDistrict NVARCHAR(100),
    @BloodGroup NVARCHAR(5)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Now DATETIME2(7) = SYSUTCDATETIME();

    BEGIN TRY
        BEGIN TRAN;

        IF @Id IS NULL OR @Id <= 0
            THROW 50005, 'Valid UserId is required.', 1;

        IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Id = @Id AND IsDeleted = 0)
            THROW 50006, 'User does not exist.', 1;

        IF EXISTS (SELECT 1 FROM dbo.UserProfiles WHERE Id = @Id)
            THROW 50007, 'User profile already exists.', 1;

        IF NULLIF(LTRIM(RTRIM(@FullName)), '') IS NULL
            THROW 50008, 'Full name is required.', 1;

        IF NULLIF(LTRIM(RTRIM(@SchoolName)), '') IS NULL
            THROW 50009, 'School name is required.', 1;

        IF NULLIF(LTRIM(RTRIM(@State)), '') IS NULL
            THROW 50010, 'State is required.', 1;

        IF NULLIF(LTRIM(RTRIM(@SchoolRegion)), '') IS NULL
            THROW 50011, 'School region is required.', 1;

        IF NULLIF(LTRIM(RTRIM(@Role)), '') IS NULL
            THROW 50012, 'Role is required.', 1;

        IF NULLIF(LTRIM(RTRIM(@University)), '') IS NULL
            THROW 50013, 'University is required.', 1;

        IF NULLIF(LTRIM(RTRIM(@CurrentState)), '') IS NULL
            THROW 50014, 'Current state is required.', 1;

        IF NULLIF(LTRIM(RTRIM(@CurrentDistrict)), '') IS NULL
            THROW 50015, 'Current district is required.', 1;

        IF @PassoutYear < 1950 OR @PassoutYear > YEAR(GETDATE()) + 10
            THROW 50016, 'Passout year is out of valid range.', 1;

        IF @MobileNumber IS NULL
           OR LEN(@MobileNumber) <> 10
           OR @MobileNumber NOT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
            THROW 50017, 'Mobile number must contain exactly 10 digits.', 1;

        INSERT INTO dbo.UserProfiles (
            Id,
            FullName,
            Email,
            MobileNumber,
            SchoolName,
            State,
            SchoolRegion,
            PassoutYear,
            Role,
            University,
            CurrentState,
            CurrentDistrict,
            BloodGroup,
            CreatedAt,
            UpdatedAt
        )
        VALUES (
            @Id,
            @FullName,
            @Email,
            @MobileNumber,
            @SchoolName,
            @State,
            @SchoolRegion,
            @PassoutYear,
            @Role,
            @University,
            @CurrentState,
            @CurrentDistrict,
            @BloodGroup,
            @Now,
            @Now
        );

        SELECT
            Id,
            FullName,
            Email,
            MobileNumber,
            SchoolName,
            State,
            SchoolRegion,
            PassoutYear,
            Role,
            University,
            CurrentState,
            CurrentDistrict,
            BloodGroup,
            CreatedAt,
            UpdatedAt
        FROM dbo.UserProfiles
        WHERE Id = @Id;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN;

        THROW;
    END CATCH
END
GO

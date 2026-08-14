
CREATE PROCEDURE sp_CreateUserProfile
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

	DECLARE @Now DATETIME2 = GETUTCDATE();

	INSERT INTO UserProfiles (
		Id, FullName, Email, MobileNumber,
		SchoolName, State, SchoolRegion, PassoutYear,
		Role, University, CurrentState, CurrentDistrict,
		BloodGroup, CreatedAt, UpdatedAt
	)
	VALUES (
		@Id, @FullName, @Email, @MobileNumber,
		@SchoolName, @State, @SchoolRegion, @PassoutYear,
		@Role, @University, @CurrentState, @CurrentDistrict,
		@BloodGroup, @Now, @Now
	);

	-- Return the created profile
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
	FROM UserProfiles
	WHERE Id = @Id;
END

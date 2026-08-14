
CREATE PROCEDURE sp_GetUserProfilesBySchool
	@SchoolName NVARCHAR(255),
	@PassoutYear INT = NULL,
	@Limit INT = 50,
	@Offset INT = 0
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		Id, FullName, Email, MobileNumber,
		SchoolName, State, SchoolRegion, PassoutYear,
		Role, University, CurrentState, CurrentDistrict,
		BloodGroup, CreatedAt, UpdatedAt
	FROM UserProfiles
	WHERE 
		SchoolName = @SchoolName
		AND (@PassoutYear IS NULL OR PassoutYear = @PassoutYear)
	ORDER BY PassoutYear DESC, FullName
	OFFSET @Offset ROWS
	FETCH NEXT @Limit ROWS ONLY;
END

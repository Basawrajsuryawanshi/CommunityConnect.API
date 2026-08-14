
CREATE PROCEDURE sp_GetUserProfilesByPassoutYear
	@PassoutYear INT,
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
		PassoutYear = @PassoutYear
	ORDER BY SchoolName, FullName
	OFFSET @Offset ROWS
	FETCH NEXT @Limit ROWS ONLY;
END

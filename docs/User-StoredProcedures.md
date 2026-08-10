# PostgreSQL Stored Procedures for User API

This document lists all the stored procedures that need to be created in the UserDb PostgreSQL database.

## User Profile Operations

### 1. sp_create_user_profile
Creates a new user profile.

**Parameters:**
- p_id UUID
- p_first_name VARCHAR(100)
- p_last_name VARCHAR(100)
- p_display_name VARCHAR(150)
- p_avatar_url TEXT
- p_bio VARCHAR(500)
- p_date_of_birth DATE
- p_gender VARCHAR(20)
- p_phone_number VARCHAR(20)
- p_jnv VARCHAR(100)
- p_batch VARCHAR(20)
- p_student_id VARCHAR(50)
- p_address_line1 TEXT
- p_address_line2 TEXT
- p_city VARCHAR(100)
- p_state VARCHAR(100)
- p_country VARCHAR(100)
- p_postal_code VARCHAR(20)
- p_linkedin_url TEXT
- p_twitter_handle VARCHAR(100)
- p_github_username VARCHAR(100)

**Returns:** UserProfile record

### 2. sp_get_user_profile_by_id
Gets a user profile by ID.

**Parameters:**
- p_user_id UUID

**Returns:** UserProfile record or NULL

### 3. sp_update_user_profile
Updates an existing user profile (only updates non-NULL parameters).

**Parameters:** (same as create, but all optional except p_id)
- p_id UUID
- p_first_name VARCHAR(100) NULL
- p_last_name VARCHAR(100) NULL
- ... (all other fields nullable)
- p_is_profile_complete BOOLEAN NULL
- p_is_public BOOLEAN NULL

**Returns:** Updated UserProfile record

### 4. sp_delete_user_profile
Deletes a user profile.

**Parameters:**
- p_user_id UUID

**Returns:** Number of affected rows

### 5. sp_search_user_profiles
Searches user profiles by term (searches first name, last name, display name, student ID).

**Parameters:**
- p_search_term VARCHAR(200)
- p_limit INT DEFAULT 50
- p_offset INT DEFAULT 0

**Returns:** List of UserProfile records

### 6. sp_get_user_profiles_by_jnv
Gets user profiles by JNV.

**Parameters:**
- p_jnv VARCHAR(100)
- p_limit INT DEFAULT 50
- p_offset INT DEFAULT 0

**Returns:** List of UserProfile records

### 7. sp_get_user_profiles_by_batch
Gets user profiles by batch.

**Parameters:**
- p_batch VARCHAR(20)
- p_limit INT DEFAULT 50
- p_offset INT DEFAULT 0

**Returns:** List of UserProfile records

## Role Operations

### 8. sp_get_all_roles
Gets all available roles.

**Parameters:** None

**Returns:** List of Role records

### 9. sp_assign_user_role
Assigns a role to a user.

**Parameters:**
- p_user_id UUID
- p_role_id INT
- p_assigned_by UUID NULL
- p_expires_at TIMESTAMP NULL

**Returns:** UserRoleAssignment record

### 10. sp_remove_user_role
Removes a role from a user.

**Parameters:**
- p_user_id UUID
- p_role_id INT

**Returns:** Number of affected rows

### 11. sp_get_user_roles
Gets all roles assigned to a user.

**Parameters:**
- p_user_id UUID

**Returns:** List of UserRoleAssignment records

## User Preferences Operations

### 12. sp_get_user_preferences
Gets user preferences.

**Parameters:**
- p_user_id UUID

**Returns:** UserPreference record or NULL

### 13. sp_upsert_user_preferences
Creates or updates user preferences (INSERT ... ON CONFLICT UPDATE).

**Parameters:**
- p_user_id UUID
- p_email_notifications BOOLEAN DEFAULT TRUE
- p_push_notifications BOOLEAN DEFAULT TRUE
- p_sms_notifications BOOLEAN DEFAULT FALSE
- p_event_reminders BOOLEAN DEFAULT TRUE
- p_announcement_alerts BOOLEAN DEFAULT TRUE
- p_discussion_updates BOOLEAN DEFAULT TRUE
- p_theme VARCHAR(20) DEFAULT 'light'
- p_language VARCHAR(10) DEFAULT 'en'

**Returns:** UserPreference record

## User Connections Operations

### 14. sp_create_connection_request
Creates a connection request between users.

**Parameters:**
- p_user_id UUID
- p_connected_user_id UUID

**Returns:** UserConnection record with Status='Pending'

### 15. sp_accept_connection_request
Accepts a pending connection request.

**Parameters:**
- p_connection_id INT
- p_connected_user_id UUID (for security verification)

**Returns:** UserConnection record with Status='Accepted'

### 16. sp_reject_connection_request
Rejects/removes a connection request.

**Parameters:**
- p_connection_id INT
- p_connected_user_id UUID (for security verification)

**Returns:** Number of affected rows

### 17. sp_block_user_connection
Blocks a user connection.

**Parameters:**
- p_user_id UUID
- p_connected_user_id UUID

**Returns:** UserConnection record with Status='Blocked'

### 18. sp_get_user_connections
Gets user connections filtered by status.

**Parameters:**
- p_user_id UUID
- p_status VARCHAR(20) NULL (if NULL, returns all statuses)

**Returns:** List of UserConnection records

### 19. sp_get_pending_connection_requests
Gets pending connection requests for a user.

**Parameters:**
- p_user_id UUID

**Returns:** List of UserConnection records with Status='Pending'

---

## Database Schema Required

### Tables:
1. **UserProfiles** - Main user profile data
2. **Roles** - Available roles (Admin, User, Moderator, etc.)
3. **UserRoleAssignments** - Many-to-many relationship User↔Role
4. **UserPreferences** - User notification and UI preferences
5. **UserConnections** - User-to-user connections/friendships

### Example SQL for creating one stored procedure:

```sql
CREATE OR REPLACE FUNCTION sp_get_user_profile_by_id(p_user_id UUID)
RETURNS TABLE (
	"Id" UUID,
	"FirstName" VARCHAR(100),
	"LastName" VARCHAR(100),
	"DisplayName" VARCHAR(150),
	"AvatarUrl" TEXT,
	"Bio" VARCHAR(500),
	"DateOfBirth" DATE,
	"Gender" VARCHAR(20),
	"PhoneNumber" VARCHAR(20),
	"JNV" VARCHAR(100),
	"Batch" VARCHAR(20),
	"StudentId" VARCHAR(50),
	"AddressLine1" TEXT,
	"AddressLine2" TEXT,
	"City" VARCHAR(100),
	"State" VARCHAR(100),
	"Country" VARCHAR(100),
	"PostalCode" VARCHAR(20),
	"LinkedInUrl" TEXT,
	"TwitterHandle" VARCHAR(100),
	"GitHubUsername" VARCHAR(100),
	"IsProfileComplete" BOOLEAN,
	"IsPublic" BOOLEAN,
	"CreatedAt" TIMESTAMP,
	"UpdatedAt" TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
	RETURN QUERY
	SELECT 
		up."Id",
		up."FirstName",
		up."LastName",
		up."DisplayName",
		up."AvatarUrl",
		up."Bio",
		up."DateOfBirth",
		up."Gender",
		up."PhoneNumber",
		up."JNV",
		up."Batch",
		up."StudentId",
		up."AddressLine1",
		up."AddressLine2",
		up."City",
		up."State",
		up."Country",
		up."PostalCode",
		up."LinkedInUrl",
		up."TwitterHandle",
		up."GitHubUsername",
		up."IsProfileComplete",
		up."IsPublic",
		up."CreatedAt",
		up."UpdatedAt"
	FROM "UserProfiles" up
	WHERE up."Id" = p_user_id;
END;
$$;
```

---

## Next Steps

1. Create all the tables using EF Core migrations or manual SQL
2. Create all 19 stored procedures in PostgreSQL
3. Test each stored procedure independently
4. Run the User.API and test via Swagger

**Note:** PostgreSQL uses functions instead of stored procedures. Use `CREATE OR REPLACE FUNCTION` syntax and `RETURN QUERY SELECT` or `RETURN` for returning data.

using CommunityConnect.Contracts.User;
using CommunityConnect.User.Core.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace CommunityConnect.User.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UserController : ControllerBase
    {
        private readonly IUserService _userService;
        private readonly ILogger<UserController> _logger;

        public UserController(IUserService userService, ILogger<UserController> logger)
        {
            _userService = userService;
            _logger = logger;
        }

        /// <summary>
        /// Get user profile by ID
        /// </summary>
        [HttpGet("{userId:guid}")]
        public async Task<ActionResult<UserProfileResponse>> GetUserProfile(Guid userId)
        {
            try
            {
                var profile = await _userService.GetUserProfileAsync(userId);

                if (profile == null)
                {
                    return NotFound(new { message = $"User profile not found for user {userId}" });
                }

                return Ok(profile);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting user profile {UserId}", userId);
                return StatusCode(500, new { message = "An error occurred while retrieving the user profile" });
            }
        }

        /// <summary>
        /// Create a new user profile
        /// </summary>
        [HttpPost]
        public async Task<ActionResult<UserProfileResponse>> CreateUserProfile([FromBody] CreateUserProfileRequest request)
        {
            try
            {
                var profile = await _userService.CreateUserProfileAsync(request);
                return CreatedAtAction(nameof(GetUserProfile), new { userId = profile.Id }, profile);
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating user profile for user {UserId}", request.UserId);
                return StatusCode(500, new { message = "An error occurred while creating the user profile" });
            }
        }

        /// <summary>
        /// Update user profile
        /// </summary>
        [HttpPut("{userId:guid}")]
        public async Task<ActionResult<UserProfileResponse>> UpdateUserProfile(Guid userId, [FromBody] UpdateUserProfileRequest request)
        {
            try
            {
                var profile = await _userService.UpdateUserProfileAsync(userId, request);
                return Ok(profile);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating user profile {UserId}", userId);
                return StatusCode(500, new { message = "An error occurred while updating the user profile" });
            }
        }

        /// <summary>
        /// Delete user profile
        /// </summary>
        [HttpDelete("{userId:guid}")]
        public async Task<IActionResult> DeleteUserProfile(Guid userId)
        {
            try
            {
                await _userService.DeleteUserProfileAsync(userId);
                return Ok(new { message = "User profile deleted successfully" });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting user profile {UserId}", userId);
                return StatusCode(500, new { message = "An error occurred while deleting the user profile" });
            }
        }

        /// <summary>
        /// Search users with filters and pagination
        /// </summary>
        [HttpPost("search")]
        public async Task<ActionResult<SearchUsersResponse>> SearchUsers([FromBody] SearchUsersRequest request)
        {
            try
            {
                var results = await _userService.SearchUsersAsync(request);
                return Ok(results);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error searching users");
                return StatusCode(500, new { message = "An error occurred while searching users" });
            }
        }

        /// <summary>
        /// Get users by JNV and batch
        /// </summary>
        [HttpGet("jnv/{jnv}/batch/{batch}")]
        public async Task<ActionResult<List<UserBasicInfoResponse>>> GetUsersByJNVAndBatch(string jnv, string batch)
        {
            try
            {
                var users = await _userService.GetUsersByJNVAndBatchAsync(jnv, batch);
                return Ok(users);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting users by JNV {JNV} and batch {Batch}", jnv, batch);
                return StatusCode(500, new { message = "An error occurred while retrieving users" });
            }
        }

        /// <summary>
        /// Get user preferences
        /// </summary>
        [HttpGet("{userId:guid}/preferences")]
        public async Task<ActionResult<UserPreferencesResponse>> GetUserPreferences(Guid userId)
        {
            try
            {
                var preferences = await _userService.GetUserPreferencesAsync(userId);

                if (preferences == null)
                {
                    return NotFound(new { message = $"Preferences not found for user {userId}" });
                }

                return Ok(preferences);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting preferences for user {UserId}", userId);
                return StatusCode(500, new { message = "An error occurred while retrieving user preferences" });
            }
        }

        /// <summary>
        /// Update user preferences
        /// </summary>
        [HttpPut("{userId:guid}/preferences")]
        public async Task<ActionResult<UserPreferencesResponse>> UpdateUserPreferences(Guid userId, [FromBody] UpdateUserPreferencesRequest request)
        {
            try
            {
                var preferences = await _userService.UpdateUserPreferencesAsync(userId, request);
                return Ok(preferences);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating preferences for user {UserId}", userId);
                return StatusCode(500, new { message = "An error occurred while updating user preferences" });
            }
        }

        /// <summary>
        /// Get user connections
        /// </summary>
        [HttpGet("{userId:guid}/connections")]
        public async Task<ActionResult<List<UserConnectionResponse>>> GetUserConnections(Guid userId)
        {
            try
            {
                var connections = await _userService.GetUserConnectionsAsync(userId);
                return Ok(connections);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting connections for user {UserId}", userId);
                return StatusCode(500, new { message = "An error occurred while retrieving connections" });
            }
        }

        /// <summary>
        /// Create a connection request
        /// </summary>
        [HttpPost("{userId:guid}/connections")]
        public async Task<ActionResult<UserConnectionResponse>> CreateConnection(Guid userId, [FromBody] CreateConnectionRequest request)
        {
            try
            {
                var connection = await _userService.CreateConnectionAsync(userId, request);
                return CreatedAtAction(nameof(GetUserConnections), new { userId }, connection);
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new { message = ex.Message });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating connection for user {UserId}", userId);
                return StatusCode(500, new { message = "An error occurred while creating the connection" });
            }
        }

        /// <summary>
        /// Remove a connection
        /// </summary>
        [HttpDelete("{userId:guid}/connections/{connectionId:int}")]
        public async Task<IActionResult> RemoveConnection(Guid userId, int connectionId)
        {
            try
            {
                await _userService.RemoveConnectionAsync(userId, connectionId);
                return Ok(new { message = "Connection removed successfully" });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error removing connection {ConnectionId} for user {UserId}", connectionId, userId);
                return StatusCode(500, new { message = "An error occurred while removing the connection" });
            }
        }

        /// <summary>
        /// Check if connection exists between two users
        /// </summary>
        [HttpGet("{userId:guid}/connections/check/{connectedUserId:guid}")]
        public async Task<ActionResult<bool>> CheckConnectionExists(Guid userId, Guid connectedUserId)
        {
            try
            {
                var exists = await _userService.CheckConnectionExistsAsync(userId, connectedUserId);
                return Ok(new { exists });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error checking connection between {UserId} and {ConnectedUserId}", userId, connectedUserId);
                return StatusCode(500, new { message = "An error occurred while checking the connection" });
            }
        }
    }
}

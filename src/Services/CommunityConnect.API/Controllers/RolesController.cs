using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using CommunityConnect.API.DTOs;
using CommunityConnect.Core.Services;

namespace CommunityConnect.API.Controllers
{
    /// <summary>
    /// Controller for managing user roles
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class RolesController : ControllerBase
    {
        private readonly IRoleService _roleService;
        private readonly ILogger<RolesController> _logger;

        public RolesController(IRoleService roleService, ILogger<RolesController> logger)
        {
            _roleService = roleService;
            _logger = logger;
        }

        /// <summary>
        /// Get all user roles
        /// </summary>
        /// <returns>List of all available roles</returns>
        [HttpGet]
        [AllowAnonymous]
        [ProducesResponseType(typeof(IEnumerable<RoleDto>), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        public async Task<ActionResult<IEnumerable<RoleDto>>> GetAllRoles()
        {
            try
            {
                _logger.LogInformation("Getting all user roles");

                var roles = await _roleService.GetAllRolesAsync();
                var response = roles.Select(RoleDto.FromRole);

                return Ok(response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting user roles");
                return StatusCode(500, new { message = "An error occurred while retrieving user roles" });
            }
        }

        /// <summary>
        /// Get a role by ID
        /// </summary>
        /// <param name="id">Role ID</param>
        /// <returns>Role details</returns>
        [HttpGet("{id}")]
        [AllowAnonymous]
        [ProducesResponseType(typeof(RoleDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        public async Task<ActionResult<RoleDto>> GetRoleById(int id)
        {
            try
            {
                _logger.LogInformation("Getting role with ID: {RoleId}", id);

                var role = await _roleService.GetRoleByIdAsync(id);

                if (role == null)
                {
                    return NotFound(new { message = $"Role with ID {id} not found" });
                }

                return Ok(RoleDto.FromRole(role));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting role with ID: {RoleId}", id);
                return StatusCode(500, new { message = "An error occurred while retrieving the role" });
            }
        }

        /// <summary>
        /// Create a new role
        /// </summary>
        /// <param name="request">Role creation request</param>
        /// <returns>Created role</returns>
        [HttpPost]
        [AllowAnonymous]  // TODO: Remove this after testing - endpoint should require Admin/SuperAdmin role
        // [Authorize(Roles = "Admin,SuperAdmin")]
        [ProducesResponseType(typeof(RoleDto), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        public async Task<ActionResult<RoleDto>> CreateRole([FromBody] CreateRoleRequest request)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    return BadRequest(ModelState);
                }

                _logger.LogInformation("Creating new role: {RoleName}", request.Name);

                var role = await _roleService.CreateRoleAsync(request.Name, request.Description);
                var response = RoleDto.FromRole(role);

                return CreatedAtAction(
                    nameof(GetRoleById),
                    new { id = role.Id },
                    response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating role: {RoleName}", request.Name);
                return StatusCode(500, new { message = "An error occurred while creating the role" });
            }
        }

        /// <summary>
        /// Update an existing role
        /// </summary>
        /// <param name="id">Role ID</param>
        /// <param name="request">Role update request</param>
        /// <returns>Updated role</returns>
        [HttpPut("{id}")]
        [AllowAnonymous]  // TODO: Remove this after testing - endpoint should require Admin/SuperAdmin role
        // [Authorize(Roles = "Admin,SuperAdmin")]
        [ProducesResponseType(typeof(RoleDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        public async Task<ActionResult<RoleDto>> UpdateRole(int id, [FromBody] UpdateRoleRequest request)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    return BadRequest(ModelState);
                }

                _logger.LogInformation("Updating role with ID: {RoleId}", id);

                var role = await _roleService.UpdateRoleAsync(id, request.Name, request.Description);

                if (role == null)
                {
                    return NotFound(new { message = $"Role with ID {id} not found" });
                }

                return Ok(RoleDto.FromRole(role));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating role with ID: {RoleId}", id);
                return StatusCode(500, new { message = "An error occurred while updating the role" });
            }
        }

        /// <summary>
        /// Delete a role
        /// </summary>
        /// <param name="id">Role ID</param>
        /// <returns>No content on success</returns>
        [HttpDelete("{id}")]
        [AllowAnonymous]  // TODO: Remove this after testing - endpoint should require Admin/SuperAdmin role
        // [Authorize(Roles = "Admin,SuperAdmin")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> DeleteRole(int id)
        {
            try
            {
                _logger.LogInformation("Deleting role with ID: {RoleId}", id);

                var result = await _roleService.DeleteRoleAsync(id);

                if (!result)
                {
                    return NotFound(new { message = $"Role with ID {id} not found" });
                }

                return NoContent();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting role with ID: {RoleId}", id);
                return StatusCode(500, new { message = "An error occurred while deleting the role" });
            }
        }
    }
}

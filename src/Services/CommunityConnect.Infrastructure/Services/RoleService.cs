using CommunityConnect.Core.Data;
using CommunityConnect.Core.Entities;
using CommunityConnect.Core.Services;
using Microsoft.Extensions.Logging;

namespace CommunityConnect.Infrastructure.Services
{
    /// <summary>
    /// Service implementation for role management operations
    /// </summary>
    public class RoleService : IRoleService
    {
        private readonly IAuthDatabase _authDatabase;
        private readonly ILogger<RoleService> _logger;

        public RoleService(IAuthDatabase authDatabase, ILogger<RoleService> logger)
        {
            _authDatabase = authDatabase;
            _logger = logger;
        }

        public async Task<List<Role>> GetAllRolesAsync()
        {
            try
            {
                _logger.LogInformation("Retrieving all roles");

                var roles = await _authDatabase.GetAllRolesAsync();

                _logger.LogInformation("Retrieved {Count} roles", roles.Count);

                return roles;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving all roles");
                throw;
            }
        }

        public async Task<Role?> GetRoleByIdAsync(int id)
        {
            try
            {
                _logger.LogInformation("Retrieving role with ID: {RoleId}", id);

                var role = await _authDatabase.GetRoleByIdAsync(id);

                if (role == null)
                {
                    _logger.LogWarning("Role with ID {RoleId} not found", id);
                }

                return role;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving role with ID: {RoleId}", id);
                throw;
            }
        }

        public async Task<Role> CreateRoleAsync(string name, string description)
        {
            try
            {
                _logger.LogInformation("Creating new role: {RoleName}", name);

                var role = await _authDatabase.CreateRoleAsync(name, description);

                _logger.LogInformation("Created role with ID: {RoleId}", role.Id);

                return role;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating role: {RoleName}", name);
                throw;
            }
        }

        public async Task<Role?> UpdateRoleAsync(int id, string name, string description)
        {
            try
            {
                _logger.LogInformation("Updating role with ID: {RoleId}", id);

                var role = await _authDatabase.UpdateRoleAsync(id, name, description);

                if (role == null)
                {
                    _logger.LogWarning("Role with ID {RoleId} not found for update", id);
                }
                else
                {
                    _logger.LogInformation("Updated role with ID: {RoleId}", id);
                }

                return role;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating role with ID: {RoleId}", id);
                throw;
            }
        }

        public async Task<bool> DeleteRoleAsync(int id)
        {
            try
            {
                _logger.LogInformation("Deleting role with ID: {RoleId}", id);

                var result = await _authDatabase.DeleteRoleAsync(id);

                if (result)
                {
                    _logger.LogInformation("Deleted role with ID: {RoleId}", id);
                }
                else
                {
                    _logger.LogWarning("Role with ID {RoleId} not found for deletion", id);
                }

                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting role with ID: {RoleId}", id);
                throw;
            }
        }
    }
}

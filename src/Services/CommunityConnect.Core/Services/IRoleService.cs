using CommunityConnect.Core.Entities;

namespace CommunityConnect.Core.Services
{
    /// <summary>
    /// Service interface for role management operations
    /// </summary>
    public interface IRoleService
    {
        /// <summary>
        /// Get all roles
        /// </summary>
        /// <returns>List of all roles</returns>
        Task<List<Role>> GetAllRolesAsync();

        /// <summary>
        /// Get role by ID
        /// </summary>
        /// <param name="id">Role ID</param>
        /// <returns>Role or null if not found</returns>
        Task<Role?> GetRoleByIdAsync(int id);

        /// <summary>
        /// Create a new role
        /// </summary>
        /// <param name="name">Role name</param>
        /// <param name="description">Role description</param>
        /// <returns>Created role</returns>
        Task<Role> CreateRoleAsync(string name, string description);

        /// <summary>
        /// Update an existing role
        /// </summary>
        /// <param name="id">Role ID</param>
        /// <param name="name">Role name</param>
        /// <param name="description">Role description</param>
        /// <returns>Updated role or null if not found</returns>
        Task<Role?> UpdateRoleAsync(int id, string name, string description);

        /// <summary>
        /// Delete a role
        /// </summary>
        /// <param name="id">Role ID</param>
        /// <returns>True if deleted successfully, false otherwise</returns>
        Task<bool> DeleteRoleAsync(int id);
    }
}

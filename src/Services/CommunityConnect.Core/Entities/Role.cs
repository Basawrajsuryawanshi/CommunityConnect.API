namespace CommunityConnect.Core.Entities
{
    /// <summary>
    /// Role entity representing user roles in the system
    /// </summary>
    public class Role
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
    }
}

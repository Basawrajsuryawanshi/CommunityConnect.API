using CommunityConnect.User.Core.Entities;
using Microsoft.EntityFrameworkCore;

namespace CommunityConnect.User.Infrastructure.Data
{
    public class UserDbContext : DbContext
    {
        public UserDbContext(DbContextOptions<UserDbContext> options) : base(options)
        {
        }

        public DbSet<UserProfile> UserProfiles { get; set; }
        public DbSet<UserPreference> UserPreferences { get; set; }
        public DbSet<UserConnection> UserConnections { get; set; }
        public DbSet<Role> Roles { get; set; }
        public DbSet<UserRoleAssignment> UserRoleAssignments { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // UserProfile Configuration
            modelBuilder.Entity<UserProfile>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.HasIndex(e => e.Id).IsUnique();

                entity.Property(e => e.FirstName).IsRequired().HasMaxLength(100);
                entity.Property(e => e.LastName).IsRequired().HasMaxLength(100);
                entity.Property(e => e.DisplayName).HasMaxLength(150);
                entity.Property(e => e.Bio).HasMaxLength(500);
                entity.Property(e => e.Gender).HasMaxLength(20);
                entity.Property(e => e.PhoneNumber).HasMaxLength(20);
                entity.Property(e => e.JNV).HasMaxLength(100);
                entity.Property(e => e.Batch).HasMaxLength(20);
                entity.Property(e => e.StudentId).HasMaxLength(50);

                entity.HasIndex(e => new { e.JNV, e.Batch });
                entity.HasIndex(e => e.StudentId);

                entity.HasOne(e => e.Preferences)
                    .WithOne(p => p.User)
                    .HasForeignKey<UserPreference>(p => p.UserId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasMany(e => e.RoleAssignments)
                    .WithOne(ra => ra.User)
                    .HasForeignKey(ra => ra.UserId)
                    .OnDelete(DeleteBehavior.Cascade);
            });

            // UserPreference Configuration
            modelBuilder.Entity<UserPreference>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.HasIndex(e => e.UserId).IsUnique();

                entity.Property(e => e.Theme).IsRequired().HasMaxLength(20);
                entity.Property(e => e.Language).IsRequired().HasMaxLength(10);
                entity.Property(e => e.TimeZone).IsRequired().HasMaxLength(50);
            });

            // UserConnection Configuration
            modelBuilder.Entity<UserConnection>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Status).IsRequired().HasMaxLength(20);

                entity.HasIndex(e => new { e.UserId, e.ConnectedUserId }).IsUnique();

                entity.HasOne(e => e.User)
                    .WithMany(u => u.Connections)
                    .HasForeignKey(e => e.UserId)
                    .OnDelete(DeleteBehavior.Restrict);

                entity.HasOne(e => e.ConnectedUser)
                    .WithMany()
                    .HasForeignKey(e => e.ConnectedUserId)
                    .OnDelete(DeleteBehavior.Restrict);
            });

            // Role Configuration
            modelBuilder.Entity<Role>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Name).IsRequired().HasMaxLength(50);
                entity.Property(e => e.Description).HasMaxLength(200);
                entity.HasIndex(e => e.Name).IsUnique();

                // Seed default roles
                entity.HasData(
                    new Role { Id = 1, Name = "User", Description = "Standard user role", CreatedAt = DateTime.UtcNow },
                    new Role { Id = 2, Name = "Admin", Description = "Administrator role", CreatedAt = DateTime.UtcNow },
                    new Role { Id = 3, Name = "Moderator", Description = "Content moderator role", CreatedAt = DateTime.UtcNow }
                );
            });

            // UserRoleAssignment Configuration
            modelBuilder.Entity<UserRoleAssignment>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.HasIndex(e => new { e.UserId, e.RoleId }).IsUnique();

                entity.HasOne(e => e.User)
                    .WithMany(u => u.RoleAssignments)
                    .HasForeignKey(e => e.UserId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasOne(e => e.Role)
                    .WithMany(r => r.UserAssignments)
                    .HasForeignKey(e => e.RoleId)
                    .OnDelete(DeleteBehavior.Cascade);
            });
        }
    }
}

using Helix.Core.Entities;
using Microsoft.EntityFrameworkCore;

namespace Helix.Infra.Persistence;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<Activity> Activities { get; set; }
    public DbSet<Session> Sessions { get; set; }
    public DbSet<User> Users { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // Configure relationships and constraints
        modelBuilder.Entity<Session>()
            .HasOne(s => s.User)
            .WithMany(u => u.Sessions)
            .HasForeignKey(s => s.UserId);

        modelBuilder.Entity<Session>()
            .HasOne(s => s.Activity)
            .WithMany(a => a.Sessions)
            .HasForeignKey(s => s.ActivityId);

        // // Seed predefined activities
        // modelBuilder.Entity<Activity>().HasData(
        //     new Activity { Id = Guid.NewGuid(), Name = "Guitar Practice", ColorHex = "#FF5733" },
        //     new Activity { Id = Guid.NewGuid(), Name = "Coding", ColorHex = "#4CAF50" }
        // );
    }
}
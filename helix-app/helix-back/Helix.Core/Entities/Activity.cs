namespace Helix.Core.Entities;

public class Activity
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public required string Name { get; set; }          // e.g., "Guitar Practice"
    public required string ColorHex { get; set; }      // e.g., "#4CAF50"
    public string? Goal { get; set; }                 // Optional (e.g., "Learn 5 songs")
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    // Navigation property (1-to-many with Session)
    public List<Session> Sessions { get; set; } = new();
}
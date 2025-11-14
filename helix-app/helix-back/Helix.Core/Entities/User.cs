namespace Helix.Core.Entities;

public class User
{
    public Guid Id { get; set; } = Guid.NewGuid();
    
    // Required for Google OAuth
    public required string GoogleId { get; set; }  // Unique identifier from Google
    public required string Email { get; set; }   
    
    // Optional
    public string? DisplayName { get; set; }  
    public string? AvatarUrl { get; set; }
    
    // Navigation property
    public List<Session> Sessions { get; set; } = new();  
}
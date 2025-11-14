namespace Helix.Core.Entities;

public class Session
{
    public Guid Id { get; set; } = Guid.NewGuid();
    
    // Required properties
    public required Guid UserId { get; set; }          
    public required Guid ActivityId { get; set; }      
    public required int DurationMinutes { get; set; }  
    public required DateTime Date { get; set; }       
    public required string EmojiRating { get; set; }   // ← 😞, 😐, 😊, 🤩

    // Optional properties
    public string? Notes { get; set; }   

    // Navigation properties
    public User? User { get; set; }       
    public Activity? Activity { get; set; } 
}
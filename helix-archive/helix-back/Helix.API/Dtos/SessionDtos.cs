using System.ComponentModel.DataAnnotations;

namespace Helix.API.Dtos;

public record SessionDto(
    Guid Id,
    Guid UserId,
    Guid ActivityId,
    int DurationMinutes,
    DateTime Date,
    string EmojiRating,
    string? Notes
    // Consider adding ActivityName or UserName if needed for responses
);

public record CreateSessionDto(
    [Required] Guid UserId,
    [Required] Guid ActivityId,
    [Required] int DurationMinutes,
    [Required] DateTime Date,
    [Required] string EmojiRating, // You might want to validate this (e.g., specific emojis)
    string? Notes
);

public record UpdateSessionDto(
    [Required] int DurationMinutes,
    [Required] DateTime Date,
    [Required] string EmojiRating,
    string? Notes
);
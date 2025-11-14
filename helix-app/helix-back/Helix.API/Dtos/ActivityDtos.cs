using System.ComponentModel.DataAnnotations;

namespace Helix.API.Dtos;

public record ActivityDto(
    Guid Id,
    string Name,
    string ColorHex,
    string? Goal,
    DateTime CreatedAt
);

public record CreateActivityDto(
    [Required] string Name,
    [Required] string ColorHex,
    string? Goal
);

public record UpdateActivityDto(
    [Required] string Name,
    [Required] string ColorHex,
    string? Goal
);
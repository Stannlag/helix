using System.ComponentModel.DataAnnotations;

namespace Helix.API.Dtos;

public record UserDto(
    Guid Id,
    string GoogleId,
    string Email,
    string? DisplayName,
    string? AvatarUrl
);

// Creating users might primarily happen via OAuth flow.
// This DTO is for manual creation if needed, or for an internal admin endpoint.
public record CreateUserDto(
    [Required] string GoogleId,
    [Required] string Email,
    string? DisplayName,
    string? AvatarUrl
);

public record UpdateUserDto( // Users typically update their own profile
    string? DisplayName,
    string? AvatarUrl
);
using Helix.API.Dtos;
using Helix.Core.Entities;
using Helix.Core.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace Helix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class UsersController : ControllerBase
{
    private readonly IDataService _dataService;
    private readonly ILogger<UsersController> _logger;

    public UsersController(IDataService dataService, ILogger<UsersController> logger)
    {
        _dataService = dataService;
        _logger = logger;
    }

    // GET: api/users
    [HttpGet]
    public async Task<ActionResult<IEnumerable<UserDto>>> GetUsers()
    {
        var users = await _dataService.Users.GetAllAsync();
        return Ok(users.Select(u => new UserDto(u.Id, u.GoogleId, u.Email, u.DisplayName, u.AvatarUrl)));
    }

    // GET: api/users/{id}
    // Or GET: api/users/google/{googleId}
    [HttpGet("{id}")] // Assuming 'id' is the Guid PK
    public async Task<ActionResult<UserDto>> GetUser(Guid id)
    {
        var user = await _dataService.Users.GetByIdAsync(id);
        if (user == null)
        {
            return NotFound();
        }
        return Ok(new UserDto(user.Id, user.GoogleId, user.Email, user.DisplayName, user.AvatarUrl));
    }

    [HttpGet("byGoogleId/{googleId}")]
    public async Task<ActionResult<UserDto>> GetUserByGoogleId(string googleId)
    {
        var user = await _dataService.Users.GetByGoogleIdAsync(googleId);
        if (user == null)
        {
            return NotFound();
        }
        return Ok(new UserDto(user.Id, user.GoogleId, user.Email, user.DisplayName, user.AvatarUrl));
    }

    // POST: api/users - User creation is often part of an OAuth flow.
    // This endpoint could be for admin purposes or specific scenarios.
    [HttpPost]
    public async Task<ActionResult<UserDto>> CreateUser(CreateUserDto createUserDto)
    {
        if (await _dataService.Users.ExistsAsync(createUserDto.Email))
        {
            return Conflict($"A user with the email '{createUserDto.Email}' already exists.");
        }
        // Consider checking for existing GoogleId as well if it must be unique

        var user = new User
        {
            GoogleId = createUserDto.GoogleId,
            Email = createUserDto.Email,
            DisplayName = createUserDto.DisplayName,
            AvatarUrl = createUserDto.AvatarUrl
        };

        await _dataService.Users.AddAsync(user);
        await _dataService.CommitAsync();

        var userDto = new UserDto(user.Id, user.GoogleId, user.Email, user.DisplayName, user.AvatarUrl);
        return CreatedAtAction(nameof(GetUser), new { id = user.Id }, userDto);
    }

    // PUT: api/users/{id} - Typically for users updating their own profile.
    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateUser(Guid id, UpdateUserDto updateUserDto)
    {
        var userToUpdate = await _dataService.Users.GetByIdAsync(id);
        if (userToUpdate == null)
        {
            return NotFound();
        }

        userToUpdate.DisplayName = updateUserDto.DisplayName ?? userToUpdate.DisplayName;
        userToUpdate.AvatarUrl = updateUserDto.AvatarUrl ?? userToUpdate.AvatarUrl;

        await _dataService.Users.UpdateAsync(userToUpdate);
        await _dataService.CommitAsync();
        return NoContent();
    }

    // DELETE: api/users/{id}
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteUser(Guid id)
    {
        await _dataService.Users.DeleteAsync(id);
        await _dataService.CommitAsync();
        return NoContent();
    }
}
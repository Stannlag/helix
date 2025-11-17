using Helix.API.Dtos;
using Helix.Core.Entities;
using Helix.Core.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace Helix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ActivitiesController : ControllerBase
{
    private readonly IDataService _dataService;
    private readonly ILogger<ActivitiesController> _logger;

    public ActivitiesController(IDataService dataService, ILogger<ActivitiesController> logger)
    {
        _dataService = dataService;
        _logger = logger;
    }

    // GET: api/activities
    [HttpGet]
    public async Task<ActionResult<IEnumerable<ActivityDto>>> GetActivities()
    {
        var activities = await _dataService.Activities.GetAllAsync();
        return Ok(activities.Select(a => new ActivityDto(a.Id, a.Name, a.ColorHex, a.Goal, a.CreatedAt)));
    }

    // GET: api/activities/{id}
    [HttpGet("{id}")]
    public async Task<ActionResult<ActivityDto>> GetActivity(Guid id)
    {
        var activity = await _dataService.Activities.GetByIdAsync(id);
        if (activity == null)
        {
            return NotFound();
        }
        return Ok(new ActivityDto(activity.Id, activity.Name, activity.ColorHex, activity.Goal, activity.CreatedAt));
    }

    // POST: api/activities
    [HttpPost]
    public async Task<ActionResult<ActivityDto>> CreateActivity(CreateActivityDto createActivityDto)
    {
        if (await _dataService.Activities.ExistsAsync(createActivityDto.Name))
        {
            return Conflict($"An activity with the name '{createActivityDto.Name}' already exists.");
        }

        var activity = new Activity
        {
            Name = createActivityDto.Name,
            ColorHex = createActivityDto.ColorHex,
            Goal = createActivityDto.Goal,
            CreatedAt = DateTime.UtcNow
        };

        await _dataService.Activities.AddAsync(activity);
        await _dataService.CommitAsync();

        var activityDto = new ActivityDto(activity.Id, activity.Name, activity.ColorHex, activity.Goal, activity.CreatedAt);
        return CreatedAtAction(nameof(GetActivity), new { id = activity.Id }, activityDto);
    }

    // PUT: api/activities/{id}
    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateActivity(Guid id, UpdateActivityDto updateActivityDto)
    {
        var activityToUpdate = await _dataService.Activities.GetByIdAsync(id);
        if (activityToUpdate == null)
        {
            return NotFound();
        }

        // Optional: Check for name conflict if the name is being changed
        // if (activityToUpdate.Name != updateActivityDto.Name && await _dataService.Activities.ExistsAsync(updateActivityDto.Name))
        // {
        //     return Conflict($"An activity with the name '{updateActivityDto.Name}' already exists.");
        // }

        activityToUpdate.Name = updateActivityDto.Name;
        activityToUpdate.ColorHex = updateActivityDto.ColorHex;
        activityToUpdate.Goal = updateActivityDto.Goal;

        await _dataService.Activities.UpdateAsync(activityToUpdate);
        await _dataService.CommitAsync();

        return NoContent();
    }

    // DELETE: api/activities/{id}
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteActivity(Guid id)
    {
        var activity = await _dataService.Activities.GetByIdAsync(id);
        if (activity == null)
        {
            return NotFound();
        }
        await _dataService.Activities.DeleteAsync(id);
        await _dataService.CommitAsync();
        return NoContent();
    }
}
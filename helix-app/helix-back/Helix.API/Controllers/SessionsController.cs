using Helix.API.Dtos;
using Helix.Core.Entities;
using Helix.Core.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace Helix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class SessionsController : ControllerBase
{
    private readonly IDataService _dataService;
    private readonly ILogger<SessionsController> _logger;

    public SessionsController(IDataService dataService, ILogger<SessionsController> logger)
    {
        _dataService = dataService;
        _logger = logger;
    }

    
    // TODO: implement the logic to get sessions by daterange and / or EmojiRating

    // GET: api/sessions
    [HttpGet]
    public async Task<ActionResult<IEnumerable<SessionDto>>> GetSessions([FromQuery] Guid? userId, [FromQuery] Guid? activityId)
    {
        IEnumerable<Session> sessions;
        if (userId.HasValue)
        {
            sessions = await _dataService.Sessions.GetByUserIdAsync(userId.Value);
        }
        else if (activityId.HasValue)
        {
            sessions = await _dataService.Sessions.GetByActivityIdAsync(activityId.Value);
        }
        else
        {
            sessions = await _dataService.Sessions.GetAllAsync();
        }
        
        return Ok(sessions.Select(s => new SessionDto(s.Id, s.UserId, s.ActivityId, s.DurationMinutes, s.Date, s.EmojiRating, s.Notes)));
    }

    // GET: api/sessions/{id}
    [HttpGet("{id}")]
    public async Task<ActionResult<SessionDto>> GetSession(Guid id)
    {
        var session = await _dataService.Sessions.GetByIdAsync(id);
        if (session == null)
        {
            return NotFound();
        }
        return Ok(new SessionDto(session.Id, session.UserId, session.ActivityId, session.DurationMinutes, session.Date, session.EmojiRating, session.Notes));
    }

    // POST: api/sessions
    [HttpPost]
    public async Task<ActionResult<SessionDto>> CreateSession(CreateSessionDto createSessionDto)
    {
        // Optional: Validate if UserId and ActivityId exist
        // var userExists = await _dataService.Users.GetByIdAsync(createSessionDto.UserId) != null;
        // var activityExists = await _dataService.Activities.GetByIdAsync(createSessionDto.ActivityId) != null;
        // if (!userExists || !activityExists) return BadRequest("Invalid UserId or ActivityId.");

        // TODO: Check to see here if the fact that we don'texplicitely assign Id is in fact a problem because Id can be passed from the froneend
        var session = new Session
        {
            UserId = createSessionDto.UserId,
            ActivityId = createSessionDto.ActivityId,
            DurationMinutes = createSessionDto.DurationMinutes,
            Date = createSessionDto.Date,
            EmojiRating = createSessionDto.EmojiRating,
            Notes = createSessionDto.Notes
        };

        await _dataService.Sessions.AddAsync(session);
        await _dataService.CommitAsync();

        var sessionDto = new SessionDto(session.Id, session.UserId, session.ActivityId, session.DurationMinutes, session.Date, session.EmojiRating, session.Notes);
        return CreatedAtAction(nameof(GetSession), new { id = session.Id }, sessionDto);
    }

    // PUT: api/sessions/{id}
    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateSession(Guid id, UpdateSessionDto updateSessionDto)
    {
        var sessionToUpdate = await _dataService.Sessions.GetByIdAsync(id);
        if (sessionToUpdate == null)
        {
            return NotFound();
        }

        sessionToUpdate.DurationMinutes = updateSessionDto.DurationMinutes;
        sessionToUpdate.Date = updateSessionDto.Date;
        sessionToUpdate.EmojiRating = updateSessionDto.EmojiRating;
        sessionToUpdate.Notes = updateSessionDto.Notes;

        await _dataService.Sessions.UpdateAsync(sessionToUpdate);
        await _dataService.CommitAsync();
        return NoContent();
    }

    // DELETE: api/sessions/{id}
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteSession(Guid id)
    {
        await _dataService.Sessions.DeleteAsync(id); // Assumes DeleteAsync handles not found gracefully or GetById is checked before
        await _dataService.CommitAsync();
        return NoContent();
    }
}
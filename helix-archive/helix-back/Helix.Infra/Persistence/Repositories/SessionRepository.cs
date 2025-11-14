using Helix.Core.Entities;
using Helix.Core.Interfaces;
using Helix.Infra.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Helix.Infra.Persistence.Repositories;

public class SessionRepository : Repository<Session>, ISessionRepository
{

    //TODO: Do not forget to use DataService when you want to add, update or delete a record in the database.

    public SessionRepository(AppDbContext context) : base(context) { }

    public async Task<IEnumerable<Session>> GetByUserIdAsync(Guid userId)
        => await _context.Sessions
            .Where(s => s.UserId == userId)
            .ToListAsync();

    public async Task<IEnumerable<Session>> GetByActivityIdAsync(Guid activityId)
        => await _context.Sessions
            .Where(s => s.ActivityId == activityId)
            .Include(s => s.Activity)  // Eager load Activity
            .ToListAsync();

    public async Task<IEnumerable<Session>> GetByDateRangeAsync(
        Guid userId, DateTime start, DateTime end)
        => await _context.Sessions
            .Where(s => s.UserId == userId && s.Date >= start && s.Date <= end)
            .OrderBy(s => s.Date)
            .ToListAsync();
}
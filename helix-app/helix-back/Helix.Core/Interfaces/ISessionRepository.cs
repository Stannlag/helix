using Helix.Core.Entities;

namespace Helix.Core.Interfaces;

public interface ISessionRepository : IRepository<Session>
{
    Task<IEnumerable<Session>> GetByUserIdAsync(Guid userId);
    Task<IEnumerable<Session>> GetByActivityIdAsync(Guid activityId);
    Task<IEnumerable<Session>> GetByDateRangeAsync(Guid userId, DateTime start, DateTime end);
}
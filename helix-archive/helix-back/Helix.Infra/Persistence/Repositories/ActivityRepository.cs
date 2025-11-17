using Helix.Core.Entities;
using Helix.Core.Interfaces;
using Helix.Infra.Persistence;

namespace Helix.Infra.Persistence.Repositories;

public class ActivityRepository : Repository<Activity>, IActivityRepository
{
    public ActivityRepository(AppDbContext context) : base(context) { }

    public Task<bool> ExistsAsync(string name)
    {
        throw new NotImplementedException();
    }

    public Task<IEnumerable<Activity>> GetPredefinedActivitiesAsync()
    {
        throw new NotImplementedException();
    }
}
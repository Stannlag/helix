using Helix.Core.Entities;

namespace Helix.Core.Interfaces;

public interface IActivityRepository : IRepository<Activity>
{
    Task<IEnumerable<Activity>> GetPredefinedActivitiesAsync();  // MVP: Global list
    Task<bool> ExistsAsync(string name);                        // Prevent dupes
}
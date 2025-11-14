namespace Helix.Core.Interfaces;

public interface IDataService : IDisposable
{
    IUserRepository Users { get; }
    IActivityRepository Activities { get; }
    ISessionRepository Sessions { get; }
    Task<int> CommitAsync(); // Saves all changes
}
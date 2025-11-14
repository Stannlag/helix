// Infra/Data/DataService.cs
using Helix.Core.Interfaces;
using Helix.Infra.Persistence.Repositories;

namespace Helix.Infra.Persistence;

public class DataService : IDataService
{
    private readonly AppDbContext _context;

    public DataService(AppDbContext context)
    {
        _context = context;
        Activities = new ActivityRepository(_context);
        Sessions = new SessionRepository(_context);
        Users = new UserRepository(_context);
    }

    public IActivityRepository Activities { get; }
    public ISessionRepository Sessions { get; }
    public IUserRepository Users { get; }

    public async Task<int> CommitAsync() => await _context.SaveChangesAsync();

    public void Dispose() => _context.Dispose();
}
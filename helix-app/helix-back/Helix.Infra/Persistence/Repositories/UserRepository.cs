using Helix.Core.Entities;
using Helix.Core.Interfaces;
using Helix.Infra.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Helix.Infra.Persistence.Repositories;

public class UserRepository : Repository<User>, IUserRepository
{
    public UserRepository(AppDbContext context) : base(context) { }

    public async Task<User?> GetByGoogleIdAsync(string googleId)
        => await _context.Users
            .FirstOrDefaultAsync(u => u.GoogleId == googleId);

    public async Task<bool> ExistsAsync(string email)
        => await _context.Users
            .AnyAsync(u => u.Email == email);
}
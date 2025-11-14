// Core/Interfaces/IUserRepository.cs
using Helix.Core.Entities;

namespace Helix.Core.Interfaces;

public interface IUserRepository : IRepository<User>
{
    Task<User?> GetByGoogleIdAsync(string googleId);  // For OAuth lookup
    Task<bool> ExistsAsync(string email);            // Prevent duplicate emails
}
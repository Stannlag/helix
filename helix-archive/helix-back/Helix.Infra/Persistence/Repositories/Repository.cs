// Infra/Data/Repositories/Repository.cs
using Helix.Core.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace Helix.Infra.Persistence.Repositories;

public class Repository<T> : IRepository<T> where T : class
{
    protected readonly AppDbContext _context;

    public Repository(AppDbContext context) => _context = context;

    public async Task<T?> GetByIdAsync(Guid id) 
        => await _context.Set<T>().FindAsync(id);

    public async Task<IEnumerable<T>> GetAllAsync() 
        => await _context.Set<T>().ToListAsync();

    public async Task AddAsync(T entity) 
        => await _context.Set<T>().AddAsync(entity);

    public Task UpdateAsync(T entity)
    {
        _context.Set<T>().Update(entity);
        return Task.CompletedTask;
    }

    public async Task DeleteAsync(Guid id)
    {
        var entity = await GetByIdAsync(id);
        if (entity != null) _context.Set<T>().Remove(entity);
    }

    
}
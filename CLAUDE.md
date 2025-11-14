# CLAUDE.md - AI Assistant Guide for Helix

This document provides comprehensive guidance for AI assistants working on the Helix project.

## Project Overview

**Helix** is a time investment tracker web application that helps users transform scattered efforts into structured growth. The app uses a DNA helix metaphor and features a color-coded calendar system with emoji-driven insights.

### Core Concept
- Users create custom activities (e.g., "Guitar Practice", "Learning Spanish")
- Each activity has a name, color, and optional goal
- Users log time sessions with duration and emoji ratings (😞 😐 😊 🤩)
- Calendar visualizes time allocation with color-coded blocks

### Technology Stack
- **Frontend**: Angular 19 (standalone components)
- **Backend**: .NET 8 (ASP.NET Core Web API)
- **Database**: PostgreSQL 16
- **Authentication**: Firebase Auth (Google OAuth)
- **Calendar**: FullCalendar library
- **UI Components**: Angular Material
- **Deployment**: Azure (Static Web Apps + App Service)

---

## Repository Structure

```
helix/
├── Design/                      # UI/UX mockups and design assets
│   ├── logo.xml
│   ├── month_view.html/png      # Calendar month view mockups
│   └── week_view.html/png       # Calendar week view mockups
│
├── Documentation/
│   ├── Foundational Documents/  # Project charter, roadmap, personas
│   └── Technical Documents/     # Technical specs, user stories
│
├── helix-app/
│   ├── helix-front/            # Angular 19 frontend application
│   │   ├── src/
│   │   │   ├── app/
│   │   │   │   ├── core/       # Core services (auth, etc.)
│   │   │   │   ├── features/   # Feature modules (lazy-loaded)
│   │   │   │   │   ├── auth/
│   │   │   │   │   ├── activities/
│   │   │   │   │   ├── calendar/
│   │   │   │   │   └── sessions/
│   │   │   │   ├── app.component.ts
│   │   │   │   ├── app.routes.ts
│   │   │   │   └── app.config.ts
│   │   │   └── environments/
│   │   ├── angular.json
│   │   └── package.json
│   │
│   └── helix-back/             # .NET 8 backend API
│       ├── Helix.API/          # Web API layer (controllers, DTOs)
│       │   ├── Controllers/    # API controllers
│       │   ├── Dtos/          # Data transfer objects
│       │   └── Program.cs     # Application entry point
│       ├── Helix.Core/        # Business logic layer
│       │   ├── Entities/      # Domain models (User, Activity, Session)
│       │   ├── Interfaces/    # Repository interfaces
│       │   └── Services/      # Business logic services
│       ├── Helix.Infra/       # Infrastructure layer
│       │   └── Persistence/
│       │       ├── AppDbContext.cs
│       │       └── Repositories/
│       └── Helix.sln
│
├── Helix-context.md            # Quick reference context for AI
└── .gitignore
```

---

## Architecture & Design Patterns

### Backend Architecture (.NET 8)

The backend follows **Clean Architecture** principles with clear separation of concerns:

#### Layer Structure
1. **Helix.API** (Presentation Layer)
   - RESTful API controllers
   - DTOs for data transfer
   - Request/response handling
   - Swagger/OpenAPI documentation

2. **Helix.Core** (Domain Layer)
   - Domain entities (User, Activity, Session)
   - Business logic services
   - Repository interfaces
   - No dependencies on external layers

3. **Helix.Infra** (Infrastructure Layer)
   - Entity Framework Core implementation
   - Repository implementations
   - Database context (AppDbContext)
   - Data access logic

#### Key Patterns

**Repository Pattern + Unit of Work**
```csharp
// Access all repositories through IDataService
public interface IDataService
{
    IUserRepository Users { get; }
    IActivityRepository Activities { get; }
    ISessionRepository Sessions { get; }
    Task<int> CommitAsync();
}

// Usage in controllers
await _dataService.Activities.AddAsync(activity);
await _dataService.CommitAsync();
```

**DTO Pattern**
- All API endpoints use DTOs (not entities directly)
- Separate DTOs for Create, Update, and Read operations
- DTOs use C# 9+ record types
- Example: `ActivityDto`, `CreateActivityDto`, `UpdateActivityDto`

**Dependency Injection**
- All dependencies registered in `Program.cs`
- Scoped lifetime for DbContext and DataService
- Constructor injection throughout

#### API Conventions

**Endpoint Structure**
```
GET    /api/activities          # Get all
GET    /api/activities/{id}     # Get by ID
POST   /api/activities          # Create
PUT    /api/activities/{id}     # Update
DELETE /api/activities/{id}     # Delete
```

**Response Patterns**
- 200 OK: Successful GET/PUT
- 201 Created: Successful POST (with Location header)
- 204 No Content: Successful DELETE
- 404 Not Found: Resource doesn't exist
- 409 Conflict: Duplicate/business rule violation

**CORS Configuration**
- Frontend URL configured via `FrontEndUrl` in appsettings
- CORS middleware enabled before authorization
- Allows any header and method from frontend origin

---

### Frontend Architecture (Angular 19)

#### Modern Angular Patterns (v19)

**Standalone Components**
- NO NgModules - all components are standalone
- Components declare their own dependencies via `imports: []`
- Example:
```typescript
@Component({
  selector: 'helix-root',
  imports: [RouterOutlet, CommonModule],
  templateUrl: './app.component.html'
})
export class AppComponent { }
```

**New Control Flow Syntax** (Mandatory in Angular 17+)
```html
<!-- Use @if, @for, @switch instead of *ngIf, *ngFor, *ngSwitch -->
@if (isLoggedIn) {
  <app-calendar />
}

@for (activity of activities; track activity.id) {
  <app-activity-card [activity]="activity" />
}
```

**Function-Based Route Configuration**
```typescript
export const routes: Routes = [
  {
    path: 'login',
    loadComponent: () => import('./features/auth/login/login.component')
      .then(m => m.LoginComponent)
  }
];
```

#### Project Structure Conventions

**Feature-Based Organization**
```
features/
  ├── auth/           # Authentication feature
  ├── activities/     # Activity management
  ├── calendar/       # Calendar visualization
  └── sessions/       # Session logging
```

**Core Services Location**
```
core/
  └── auth/
      └── auth.service.ts   # Shared authentication logic
```

**Component Structure**
Each feature component includes:
- `.component.ts` - Component class
- `.component.html` - Template
- `.component.scss` - Styles
- `.component.spec.ts` - Tests

**Lazy Loading**
- All feature routes use `loadComponent` for code splitting
- Improves initial load performance
- Components loaded on-demand

---

## Database Schema

### Entities

#### Users
```sql
Users
├── Id (UUID, PK)
├── GoogleId (TEXT, UNIQUE, NOT NULL)
├── Email (TEXT, NOT NULL)
└── CreatedAt (TIMESTAMP)
```

#### Activities
```sql
Activities
├── Id (UUID, PK)
├── UserId (UUID, FK → Users)
├── Name (TEXT, NOT NULL)
├── ColorHex (TEXT, DEFAULT '#4CAF50')
├── Goal (TEXT, NULLABLE)
└── CreatedAt (TIMESTAMP)
```

#### Sessions
```sql
Sessions
├── Id (UUID, PK)
├── ActivityId (UUID, FK → Activities)
├── DurationMinutes (INT, CHECK > 0)
├── EmojiRating (TEXT, CHECK IN ('😞','😐','😊','🤩'))
├── Date (DATE, NOT NULL)
└── CreatedAt (TIMESTAMP)
```

### Relationships
- User → Activities (One-to-Many, Cascade Delete)
- Activity → Sessions (One-to-Many, Cascade Delete)

---

## Development Workflows

### Frontend Development

**Prerequisites**
```bash
cd helix-app/helix-front
npm install
```

**Development Server**
```bash
npm start
# Runs on http://localhost:4200
```

**Build**
```bash
npm run build                    # Production build
npm run watch                    # Development build with watch
```

**Testing**
```bash
npm test                         # Run Jasmine/Karma tests
```

### Backend Development

**Prerequisites**
- .NET 8 SDK installed
- PostgreSQL 16 running
- Connection string configured in `appsettings.json`

**Run API**
```bash
cd helix-app/helix-back
dotnet restore
dotnet run --project Helix.API
```

**Database Migrations** (when using EF Core migrations)
```bash
dotnet ef migrations add MigrationName --project Helix.Infra --startup-project Helix.API
dotnet ef database update --project Helix.Infra --startup-project Helix.API
```

**Build Solution**
```bash
dotnet build Helix.sln
```

### Full-Stack Development

1. Start PostgreSQL database
2. Start backend API:
   ```bash
   cd helix-app/helix-back
   dotnet run --project Helix.API
   ```
3. Start frontend dev server:
   ```bash
   cd helix-app/helix-front
   npm start
   ```
4. Access Swagger UI: `http://localhost:5000` (or configured port)
5. Access Angular app: `http://localhost:4200`

---

## Coding Conventions & Best Practices

### Angular (Frontend)

#### Component Guidelines
1. **Always use standalone components** - No NgModules
2. **Use new control flow syntax** - @if, @for, @switch
3. **Signals (when available)** - Prefer signals for reactive state (Angular 16+)
4. **Inject dependencies in constructor** - Use constructor-based DI
5. **Component selector prefix** - Use `helix-` prefix (e.g., `helix-calendar`)

#### TypeScript
- **Strict mode enabled** - Use strict TypeScript settings
- **Type everything** - Avoid `any` type
- **Use interfaces** for data models
- **Async/await** - Prefer over `.then()` chains

#### File Naming
- Components: `feature-name.component.ts`
- Services: `feature-name.service.ts`
- Kebab-case for all files

#### RxJS
- **Unsubscribe from observables** - Use `takeUntil()` or async pipe
- **Prefer async pipe** in templates - Handles subscription lifecycle

### .NET (Backend)

#### C# Conventions
1. **Use C# 12 features** - Records, pattern matching, init-only properties
2. **Nullable reference types enabled** - Explicit nullability
3. **Async all the way** - All I/O operations should be async
4. **Expression-bodied members** - Use for simple methods

#### Naming Conventions
- **PascalCase**: Classes, methods, properties, public fields
- **camelCase**: Local variables, parameters, private fields
- **_camelCase**: Private fields (with underscore prefix)
- **IPascalCase**: Interfaces (with I prefix)

#### Entity Guidelines
```csharp
public class Entity
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public required string Name { get; set; }        // Required property
    public string? OptionalField { get; set; }       // Nullable
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
```

#### Controller Guidelines
```csharp
[ApiController]
[Route("api/[controller]")]
public class ResourceController : ControllerBase
{
    private readonly IDataService _dataService;
    private readonly ILogger<ResourceController> _logger;

    // Constructor injection
    public ResourceController(IDataService dataService, ILogger<ResourceController> logger)
    {
        _dataService = dataService;
        _logger = logger;
    }

    // Use ActionResult<T> for typed responses
    [HttpGet("{id}")]
    public async Task<ActionResult<ResourceDto>> GetResource(Guid id)
    {
        var resource = await _dataService.Resources.GetByIdAsync(id);
        if (resource == null) return NotFound();
        return Ok(MapToDto(resource));
    }
}
```

#### DTO Guidelines
```csharp
// Use records for immutability
public record ResourceDto(Guid Id, string Name, DateTime CreatedAt);

// Use data annotations for validation
public record CreateResourceDto(
    [Required] string Name,
    [Range(1, 1000)] int Value
);
```

### Database Conventions

1. **Use Guid for primary keys** - More distributed-friendly than auto-increment
2. **Timestamp all entities** - Include `CreatedAt` field
3. **Cascade deletes** - Configure appropriate cascade behavior
4. **UTC timestamps** - Always use `DateTime.UtcNow`
5. **Entity relationships** - Use navigation properties in EF Core

---

## Common Tasks & Examples

### Adding a New Entity

1. **Create Entity** in `Helix.Core/Entities/`
```csharp
public class NewEntity
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public required string Name { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
```

2. **Add DbSet** to `AppDbContext`
```csharp
public DbSet<NewEntity> NewEntities => Set<NewEntity>();
```

3. **Create Repository Interface** in `Helix.Core/Interfaces/`
```csharp
public interface INewEntityRepository : IRepository<NewEntity>
{
    // Add custom methods if needed
}
```

4. **Implement Repository** in `Helix.Infra/Persistence/Repositories/`
```csharp
public class NewEntityRepository : Repository<NewEntity>, INewEntityRepository
{
    public NewEntityRepository(AppDbContext context) : base(context) { }
}
```

5. **Add to DataService**
```csharp
// Interface
INewEntityRepository NewEntities { get; }

// Implementation
public INewEntityRepository NewEntities =>
    _newEntityRepository ??= new NewEntityRepository(_context);
```

6. **Create DTOs** in `Helix.API/Dtos/`
```csharp
public record NewEntityDto(Guid Id, string Name, DateTime CreatedAt);
public record CreateNewEntityDto([Required] string Name);
```

7. **Create Controller** in `Helix.API/Controllers/`

8. **Run Migration** (if using EF migrations)

### Adding a New Angular Component

1. **Generate component** (or create manually):
```bash
ng generate component features/feature-name/component-name --standalone
```

2. **Component structure**:
```typescript
import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'helix-component-name',
  imports: [CommonModule],
  templateUrl: './component-name.component.html',
  styleUrl: './component-name.component.scss'
})
export class ComponentNameComponent {
  // Component logic
}
```

3. **Add route** in `app.routes.ts`:
```typescript
{
  path: 'feature-name',
  loadComponent: () => import('./features/feature-name/component-name.component')
    .then(m => m.ComponentNameComponent)
}
```

### Making API Calls from Angular

1. **Create service**:
```typescript
@Injectable({
  providedIn: 'root'
})
export class ResourceService {
  private apiUrl = 'http://localhost:5000/api/resources';

  constructor(private http: HttpClient) { }

  getAll(): Observable<ResourceDto[]> {
    return this.http.get<ResourceDto[]>(this.apiUrl);
  }

  create(resource: CreateResourceDto): Observable<ResourceDto> {
    return this.http.post<ResourceDto>(this.apiUrl, resource);
  }
}
```

2. **Use in component**:
```typescript
export class MyComponent implements OnInit {
  resources: ResourceDto[] = [];

  constructor(private resourceService: ResourceService) { }

  ngOnInit(): void {
    this.resourceService.getAll().subscribe({
      next: (data) => this.resources = data,
      error: (err) => console.error('Error loading resources', err)
    });
  }
}
```

---

## Testing Guidelines

### Backend Testing
- **Unit tests** for services and business logic
- **Integration tests** for repositories and database operations
- **API tests** for controllers (optional)
- Use **xUnit** or **NUnit** framework
- Mock dependencies with **Moq** library

### Frontend Testing
- **Unit tests** with Jasmine/Karma (default Angular setup)
- **Component tests** - Test component logic and rendering
- **Service tests** - Test HTTP calls with mocked HttpClient
- **E2E tests** - Consider Playwright or Cypress (future)

---

## Security Considerations

### Authentication Flow
1. User authenticates with Google via Firebase Auth (frontend)
2. Frontend receives Firebase ID token
3. ID token sent in Authorization header: `Bearer <token>`
4. Backend validates token with Firebase Admin SDK
5. Extract user info (email, Google ID) from validated token
6. Create/retrieve user record in database

### Security Best Practices
- **Never commit secrets** - Use environment variables
- **Validate all inputs** - Use Data Annotations and FluentValidation
- **Use HTTPS** in production
- **CORS** - Only allow specific origins
- **SQL Injection** - EF Core parameterizes queries (safe by default)
- **XSS** - Angular sanitizes by default, be careful with `bypassSecurityTrust*`

---

## Current Project Status

### Completed Features ✅
- Project structure setup (frontend + backend)
- Database schema design
- Basic entity models (User, Activity, Session)
- Repository pattern implementation
- CRUD API endpoints for Activities
- Angular 19 app with routing
- Component structure for auth, activities, calendar, sessions

### In Progress 🚧
- Firebase Authentication integration
- Calendar visualization with FullCalendar
- Session logging UI
- Activity management UI

### Upcoming 📋
- Google OAuth complete implementation
- Calendar data binding with real sessions
- Emoji rating system
- Time allocation visualization
- Activity goal tracking

---

## Troubleshooting

### Common Issues

**Frontend won't start**
- Check Node.js version (should be v18+)
- Delete `node_modules` and run `npm install` again
- Clear Angular cache: `rm -rf .angular`

**Backend won't start**
- Verify .NET 8 SDK is installed: `dotnet --version`
- Check PostgreSQL is running
- Verify connection string in `appsettings.json`

**CORS errors**
- Ensure backend `FrontEndUrl` matches frontend URL
- Check CORS middleware is before `app.MapControllers()`
- Verify frontend is running on expected port

**Database connection fails**
- Check PostgreSQL service is running
- Verify connection string credentials
- Check if database exists
- Review firewall rules

---

## Environment Configuration

### Backend (`appsettings.json`)
```json
{
  "ConnectionStrings": {
    "Default": "Host=localhost;Database=helix;Username=user;Password=pass"
  },
  "FrontEndUrl": "http://localhost:4200"
}
```

### Frontend (`src/environments/`)
```typescript
export const environment = {
  production: false,
  apiUrl: 'http://localhost:5000/api',
  firebase: {
    // Firebase config
  }
};
```

---

## Useful Commands Reference

### Angular CLI
```bash
ng serve                          # Start dev server
ng build                          # Production build
ng test                           # Run tests
ng generate component name        # Generate component
ng generate service name          # Generate service
```

### .NET CLI
```bash
dotnet restore                    # Restore dependencies
dotnet build                      # Build solution
dotnet run                        # Run project
dotnet test                       # Run tests
dotnet ef migrations add Name     # Add migration
dotnet ef database update         # Apply migrations
```

### Git Workflow
```bash
git checkout -b feature/branch-name
git add .
git commit -m "feat: description"
git push origin feature/branch-name
```

---

## Additional Resources

- **Angular Documentation**: https://angular.dev
- **.NET Documentation**: https://learn.microsoft.com/dotnet
- **FullCalendar Docs**: https://fullcalendar.io/docs
- **Angular Material**: https://material.angular.io
- **Entity Framework Core**: https://learn.microsoft.com/ef/core

---

## AI Assistant Guidelines

### When Working on This Project

1. **Understand the context**: Always reference `Helix-context.md` for quick context
2. **Follow architecture**: Respect the Clean Architecture layers in backend
3. **Use modern Angular**: Standalone components, new control flow, signals
4. **Maintain consistency**: Follow established patterns in existing code
5. **Test your changes**: Ensure code compiles and follows conventions
6. **Document as you go**: Update this file if you add new patterns or conventions
7. **Ask before major changes**: Clarify architectural decisions with user
8. **Security first**: Never commit credentials or bypass security measures

### Code Generation Tips

- **Backend**: Generate full CRUD with controller, DTOs, and repository
- **Frontend**: Create component with service, route, and basic template
- **Always**: Include error handling and validation
- **DTOs**: Use separate DTOs for Create, Update, and Read operations
- **Components**: Use standalone components with proper imports
- **Async**: Use async/await for all async operations

### When in Doubt

1. Check existing similar code for patterns
2. Refer to this CLAUDE.md document
3. Consult Helix-context.md for business logic
4. Ask the user for clarification on requirements

---

*Last Updated: 2025-11-14*
*Version: 1.0*

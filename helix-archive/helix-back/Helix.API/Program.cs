using Helix.Core.Interfaces;
using Helix.Infra.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

// Define a CORS policy name
const string myAllowSpecificOrigins = "_myAllowSpecificOrigins";
var frontEndUrl = builder.Configuration["FrontEndUrl"];

// Add DbContext (from Infra)
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("Default")));

// Add DataService and Repositories (from Infra)
builder.Services.AddScoped<IDataService, DataService>();  // ← All repos are injected internally via DataService

// Add CORS services
builder.Services.AddCors(options =>
{
    options.AddPolicy(name: myAllowSpecificOrigins,
                      policy  =>
                      {
                          policy.WithOrigins(frontEndUrl) // Your frontend production URL
                                .AllowAnyHeader()
                                .AllowAnyMethod();
                      });
});

// Add services for controllers
builder.Services.AddControllers();


// Add services for API Exploration (Swagger/OpenAPI)
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "Helix API", Version = "v1" });
});

var app = builder.Build();


// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "Helix API V1");
        c.RoutePrefix = string.Empty; // Serve Swagger UI at app's root
    });
}

// Use HTTPS Redirection (recommended for production)
app.UseHttpsRedirection();

// Use CORS - This must be called before UseAuthorization and MapEndpoints/MapControllers
app.UseCors(myAllowSpecificOrigins);

//maping the controllers
app.MapControllers();
app.Run();
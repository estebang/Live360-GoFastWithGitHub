using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.EntityFrameworkCore;
using TailspinToys.Web.Data;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddRazorPages();
builder.Services.AddDbContext<TailspinContext>(opt =>
    opt.UseInMemoryDatabase("TailspinToys"));

var app = builder.Build();

if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
}

// Add health check endpoint for CI/CD pipeline
app.MapGet("/health", () => new { 
    Status = "Healthy", 
    Timestamp = DateTime.UtcNow,
    Version = System.Reflection.Assembly.GetExecutingAssembly().GetName().Version?.ToString() 
});

app.UseStaticFiles();
app.UseRouting();
app.MapRazorPages();

SeedData.Initialize(app);

app.Run();

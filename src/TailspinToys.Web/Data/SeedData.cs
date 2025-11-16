using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using TailspinToys.Web.Models;

namespace TailspinToys.Web.Data;

public static class SeedData
{
    public static void Initialize(WebApplication app)
    {
        using var scope = app.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<TailspinContext>();

        if (db.Campaigns.Any()) return;

        db.Campaigns.AddRange(
            new Campaign { Name = "Sky Surfer", Description = "A flying toy glider.", GoalAmount = 5000, CurrentAmount = 1200 },
            new Campaign { Name = "RoboRacer", Description = "Programmable racing robot.", GoalAmount = 8000, CurrentAmount = 3500 }
        );

        db.SaveChanges();
    }
}

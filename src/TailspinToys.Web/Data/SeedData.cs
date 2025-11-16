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
            new Campaign 
            { 
                Name = "AI-Powered Learning Assistant", 
                Description = "Revolutionary educational toy that uses AI to adapt to each child's learning style. Featuring GitHub Copilot integration for coding activities and interactive STEM challenges.", 
                GoalAmount = 50000, 
                CurrentAmount = 42500 
            },
            new Campaign 
            { 
                Name = "Cloud-Native Robotics Kit", 
                Description = "Build and program robots that connect to Azure cloud services. Perfect for teaching modern DevOps practices and cloud-first development to the next generation.", 
                GoalAmount = 75000, 
                CurrentAmount = 28750 
            },
            new Campaign 
            { 
                Name = "Live360 STEM Scholarship Fund", 
                Description = "Supporting aspiring developers and IT professionals with conference attendance, training materials, and mentorship opportunities. Empowering the future of technology.", 
                GoalAmount = 100000, 
                CurrentAmount = 87500 
            },
            new Campaign 
            { 
                Name = "GitHub Copilot for Kids", 
                Description = "Introducing young minds to AI-assisted programming with age-appropriate coding toys and interactive learning experiences. Making programming accessible and fun!", 
                GoalAmount = 25000, 
                CurrentAmount = 25000 
            }
        );

        db.SaveChanges();
    }
}

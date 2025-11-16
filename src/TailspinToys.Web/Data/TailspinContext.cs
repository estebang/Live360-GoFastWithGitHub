using Microsoft.EntityFrameworkCore;
using TailspinToys.Web.Models;

namespace TailspinToys.Web.Data;

public class TailspinContext : DbContext
{
    public TailspinContext(DbContextOptions<TailspinContext> options) : base(options) {}

    public DbSet<Campaign> Campaigns => Set<Campaign>();
}

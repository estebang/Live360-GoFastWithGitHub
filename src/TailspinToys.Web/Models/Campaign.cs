namespace TailspinToys.Web.Models;

public class Campaign
{
    public int Id { get; set; }
    public string Name { get; set; } = "";
    public string Description { get; set; } = "";
    public decimal GoalAmount { get; set; }
    public decimal CurrentAmount { get; set; }
}

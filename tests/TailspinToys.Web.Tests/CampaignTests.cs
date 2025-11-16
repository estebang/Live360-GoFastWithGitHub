using Xunit;
using TailspinToys.Web.Models;

public class CampaignTests
{
    [Fact]
    public void Campaign_Goal_Is_Positive()
    {
        var c = new Campaign { GoalAmount = 100 };
        Assert.True(c.GoalAmount > 0);
    }
}

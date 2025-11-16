using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using TailspinToys.Web.Data;
using TailspinToys.Web.Models;

namespace TailspinToys.Web.Pages;

public class CampaignModel : PageModel
{
    private readonly TailspinContext _db;

    public CampaignModel(TailspinContext db)
    {
        _db = db;
    }

    public Campaign? Campaign { get; set; }

    public IActionResult OnGet(int id)
    {
        Campaign = _db.Campaigns.FirstOrDefault(c => c.Id == id);
        if (Campaign == null) return RedirectToPage("Index");
        return Page();
    }
}

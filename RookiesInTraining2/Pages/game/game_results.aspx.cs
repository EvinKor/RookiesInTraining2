using System;
using System.Web.UI;
using RookiesInTraining2.Helpers;

namespace RookiesInTraining2.Pages.game
{
    public partial class game_results : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Check if user is logged in (try both lowercase and capital case keys)
            string userSlug = Session["user_slug"]?.ToString() ?? Session["UserSlug"]?.ToString();
            if (string.IsNullOrEmpty(userSlug))
            {
                Response.Redirect("/Pages/Login.aspx");
                return;
            }

            // Check if Supabase is configured
            if (!SupabaseConfig.IsConfigured())
            {
                Response.Write("<h2>Supabase is not configured!</h2>");
                Response.Write("<p>Please add Supabase credentials to Web.config</p>");
                Response.End();
                return;
            }

            // Get lobby ID from query string
            string lobbyId = Request.QueryString["lobby"];
            if (string.IsNullOrEmpty(lobbyId))
            {
                Response.Redirect("game_dashboard.aspx");
                return;
            }

            System.Diagnostics.Debug.WriteLine("[GameResults] Page loaded");
            System.Diagnostics.Debug.WriteLine($"[GameResults] User: {Session["user_slug"]}");
            System.Diagnostics.Debug.WriteLine($"[GameResults] Lobby ID: {lobbyId}");
        }

        protected string GetSupabaseUrl()
        {
            return SupabaseConfig.SupabaseUrl ?? "";
        }

        protected string GetSupabaseKey()
        {
            return SupabaseConfig.SupabaseKey ?? "";
        }

        protected string GetUserSlug()
        {
            return Session["user_slug"]?.ToString() ?? Session["UserSlug"]?.ToString() ?? "";
        }

        protected string GetUserName()
        {
            return Session["full_name"]?.ToString() ?? Session["FullName"]?.ToString() ?? "Guest";
        }
    }
}


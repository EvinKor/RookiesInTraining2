using System;
using System.Web.UI;
using RookiesInTraining2.Helpers;

namespace RookiesInTraining2.Pages.game
{
    public partial class lobby_room : System.Web.UI.Page
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

            // Get lobby code from query string
            string lobbyCode = Request.QueryString["code"];
            if (string.IsNullOrEmpty(lobbyCode))
            {
                Response.Redirect("game_dashboard.aspx");
                return;
            }

            System.Diagnostics.Debug.WriteLine("[LobbyRoom] Page loaded");
            System.Diagnostics.Debug.WriteLine($"[LobbyRoom] User: {Session["user_slug"]}");
            System.Diagnostics.Debug.WriteLine($"[LobbyRoom] Lobby code: {lobbyCode}");
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

        protected string GetUserEmail()
        {
            return Session["email"]?.ToString() ?? Session["Email"]?.ToString() ?? "";
        }
    }
}


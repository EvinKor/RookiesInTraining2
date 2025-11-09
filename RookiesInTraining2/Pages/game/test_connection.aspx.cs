using System;
using System.Web.UI;
using RookiesInTraining2.Helpers;

namespace RookiesInTraining2.Pages.game
{
    public partial class test_connection : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            System.Diagnostics.Debug.WriteLine("[TestConnection] Page loaded");
        }

        protected string GetSessionStatus()
        {
            string userSlug = Session["user_slug"]?.ToString() ?? Session["UserSlug"]?.ToString();
            return string.IsNullOrEmpty(userSlug) ? "error" : "success";
        }

        protected string GetSessionInfo()
        {
            string userSlug = Session["user_slug"]?.ToString() ?? Session["UserSlug"]?.ToString();
            return string.IsNullOrEmpty(userSlug) ? "❌ No session found" : "✅ Session active";
        }

        protected string GetUserInfo()
        {
            string userSlug = Session["user_slug"]?.ToString() ?? Session["UserSlug"]?.ToString();
            string fullName = Session["full_name"]?.ToString() ?? Session["FullName"]?.ToString();
            string email = Session["email"]?.ToString() ?? Session["Email"]?.ToString();
            string role = Session["role"]?.ToString() ?? Session["Role"]?.ToString();

            return $@"UserSlug: {userSlug ?? "NULL"}
FullName: {fullName ?? "NULL"}
Email: {email ?? "NULL"}
Role: {role ?? "NULL"}
SessionID: {Session.SessionID}
Session Keys: {Session.Count}";
        }

        protected string GetSupabaseStatus()
        {
            return SupabaseConfig.IsConfigured() ? "success" : "error";
        }

        protected string GetSupabaseInfo()
        {
            return SupabaseConfig.IsConfigured() ? "✅ Configured" : "❌ Not configured";
        }

        protected string GetSupabaseUrl()
        {
            return SupabaseConfig.SupabaseUrl ?? "";
        }

        protected string GetSupabaseUrlDisplay()
        {
            string url = SupabaseConfig.SupabaseUrl ?? "";
            return string.IsNullOrEmpty(url) ? "NOT SET" : url;
        }

        protected string GetSupabaseKey()
        {
            return SupabaseConfig.SupabaseKey ?? "";
        }

        protected string GetSupabaseKeyDisplay()
        {
            string key = SupabaseConfig.SupabaseKey ?? "";
            if (string.IsNullOrEmpty(key)) return "NOT SET";
            return key.Substring(0, 30) + "..." + key.Substring(key.Length - 10) + $" ({key.Length} chars)";
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


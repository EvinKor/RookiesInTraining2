using System;
using System.Web.UI;
using RookiesInTraining2.Helpers;

namespace RookiesInTraining2.Pages.game
{
    public partial class game_dashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Debug all session keys
            System.Diagnostics.Debug.WriteLine("========== [GameDashboard] SESSION DEBUG ==========");
            System.Diagnostics.Debug.WriteLine($"[GameDashboard] Session.SessionID: {Session.SessionID}");
            System.Diagnostics.Debug.WriteLine($"[GameDashboard] Session.Count: {Session.Count}");
            foreach (string key in Session.Keys)
            {
                System.Diagnostics.Debug.WriteLine($"[GameDashboard] Session['{key}'] = '{Session[key]}'");
            }
            System.Diagnostics.Debug.WriteLine("=================================================");

            // Check if user is logged in (try both lowercase and capital case keys)
            string userSlug = Session["user_slug"]?.ToString() ?? Session["UserSlug"]?.ToString();
            if (string.IsNullOrEmpty(userSlug))
            {
                System.Diagnostics.Debug.WriteLine("[GameDashboard] ERROR: No session found, redirecting to login");
                Response.Redirect("~/Pages/Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            // Check if Supabase is configured
            if (!SupabaseConfig.IsConfigured())
            {
                Response.Write("<h2>Supabase is not configured!</h2>");
                Response.Write("<p>Please add Supabase credentials to Web.config</p>");
                Response.Write("<p>See SUPABASE_WEB_CONFIG_TEMPLATE.txt for instructions</p>");
                Response.End();
                return;
            }

            System.Diagnostics.Debug.WriteLine("[GameDashboard] ✅ Page loaded successfully!");
            System.Diagnostics.Debug.WriteLine($"[GameDashboard] User logged in: {userSlug}");
        }

        // Helper methods to expose session data to JavaScript
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

        protected string GetBackUrl()
        {
            // Determine where to redirect based on user's role
            string role = Session["Role"]?.ToString() ?? Session["role"]?.ToString() ?? "";
            
            switch (role.ToLower())
            {
                case "admin":
                    return ResolveUrl("~/Pages/admin/dashboard_admin.aspx");
                case "teacher":
                    return ResolveUrl("~/Pages/teacher/dashboard_teacher.aspx");
                case "student":
                    return ResolveUrl("~/Pages/student/dashboard_student.aspx");
                default:
                    return ResolveUrl("~/Pages/Login.aspx");
            }
        }
    }
}


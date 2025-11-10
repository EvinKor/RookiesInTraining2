using System;
using System.Web.UI;

namespace RookiesInTraining2.MasterPages
{
    public partial class dashboard : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Check if user is logged in
            if (Session["UserSlug"] == null)
            {
                Response.Redirect("~/Pages/Login.aspx", false);
                return;
            }

            // Setup header on every load to ensure correct visibility
            SetupHeader();
        }

        private void SetupHeader()
        {
            string role = Session["Role"]?.ToString()?.ToLowerInvariant() ?? "";
            string currentPage = Request.AppRelativeCurrentExecutionFilePath.ToLower();
            string path = Request.Path.ToLower();

            // Check if we're on admin dashboard - check multiple ways to be sure
            bool isAdminDashboard = role == "admin" && 
                (currentPage.Contains("dashboard_admin.aspx") || 
                 path.Contains("dashboard_admin.aspx") ||
                 currentPage.Contains("admin/dashboard_admin") ||
                 path.Contains("admin/dashboard_admin"));

            if (isAdminDashboard)
            {
                // Show avatar, settings, logout
                pnlAdminDashboardHeader.Visible = true;
                pnlOtherPagesHeader.Visible = false;
                SetupAdminDashboardHeader();
            }
            else if (role == "admin")
            {
                // Show dashboard button
                pnlAdminDashboardHeader.Visible = false;
                pnlOtherPagesHeader.Visible = true;
                lnkDashboard.NavigateUrl = "~/Pages/admin/dashboard_admin.aspx";
            }
            else
            {
                // For other roles or fallback, show dashboard header
                pnlAdminDashboardHeader.Visible = true;
                pnlOtherPagesHeader.Visible = false;
                SetupAdminDashboardHeader();
            }
        }

        private void SetupAdminDashboardHeader()
        {
            string fullName = Session["FullName"]?.ToString() ?? "User";
            string role = Session["Role"]?.ToString() ?? "";
            
            // Display user info
            lblUser.Text = $"{fullName} ({GetRoleText(role)})";

            // Set user initial
            if (!string.IsNullOrEmpty(fullName) && fullName.Length > 0)
            {
                imgAvatar.InnerHtml = $"<span class='user-initial'>{fullName[0]}</span>";
            }

            // Set profile settings link based on role
            SetProfileSettingsLink(role);
        }

        protected void BtnLogout_Click(object sender, EventArgs e)
        {
            // Clear session
            Session.Clear();
            Session.Abandon();

            // Redirect to login
            Response.Redirect("~/Pages/Login.aspx", false);
        }

        private string GetRoleText(string role)
        {
            if (string.IsNullOrEmpty(role))
                return "User";

            switch (role.ToLower())
            {
                case "admin":
                    return "Admin";
                case "teacher":
                    return "Teacher";
                case "student":
                    return "Student";
                default:
                    return "User";
            }
        }

        private void SetProfileSettingsLink(string role)
        {
            if (string.IsNullOrEmpty(role))
            {
                lnkProfileSettings.Visible = false;
                return;
            }

            switch (role.ToLower())
            {
                case "admin":
                    lnkProfileSettings.NavigateUrl = "~/Pages/admin/Profile.aspx";
                    lnkProfileSettings.Visible = true;
                    break;
                case "teacher":
                    lnkProfileSettings.NavigateUrl = "~/Pages/teacher/Profile.aspx";
                    lnkProfileSettings.Visible = true;
                    break;
                case "student":
                    lnkProfileSettings.NavigateUrl = "~/Pages/student/Profile.aspx";
                    lnkProfileSettings.Visible = true;
                    break;
                default:
                    lnkProfileSettings.Visible = false;
                    break;
            }
        }

        protected string GetDashboardUrl()
        {
            string role = Session["Role"]?.ToString()?.ToLowerInvariant() ?? "";
            switch (role)
            {
                case "student":
                    return ResolveUrl("~/Pages/student/dashboard_student.aspx");
                case "teacher":
                    return ResolveUrl("~/Pages/teacher/dashboard_teacher.aspx");
                case "admin":
                    return ResolveUrl("~/Pages/admin/dashboard_admin.aspx");
                default:
                    return ResolveUrl("~/Pages/Login.aspx");
            }
        }
    }
}
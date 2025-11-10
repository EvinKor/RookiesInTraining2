using System;
using System.Web.UI;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI.WebControls;
using System.Configuration;
using System.Data.SqlClient;

namespace RookiesInTraining2.MasterPages
{
    public partial class MyMain : System.Web.UI.MasterPage
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Setup header on every load to ensure correct visibility
            SetupHeader();
        }

        private void SetupHeader()
        {
            string role = Session["Role"]?.ToString()?.ToLowerInvariant() ?? "";
            string currentPage = Request.AppRelativeCurrentExecutionFilePath.ToLower();
            string path = Request.Path.ToLower();

            // Check if we're on login or register pages - hide header buttons
            bool isLoginPage = currentPage.Contains("login.aspx") || path.Contains("login.aspx");
            bool isRegisterPage = currentPage.Contains("register.aspx") || path.Contains("register.aspx");

            if (isLoginPage || isRegisterPage)
            {
                // Show centered logo on login/register pages
                pnlNavbarLeft.Visible = false;
                pnlNavbarCenter.Visible = true;
                pnlStudentDashboardHeader.Visible = false;
                pnlOtherPagesHeader.Visible = false;
                return;
            }
            else
            {
                // Show left logo on other pages
                pnlNavbarLeft.Visible = true;
                pnlNavbarCenter.Visible = false;
            }

            // Check if we're on student dashboard - check multiple ways to be sure
            bool isStudentDashboard = role == "student" && 
                (currentPage.Contains("dashboard_student.aspx") || 
                 path.Contains("dashboard_student.aspx") ||
                 currentPage.Contains("student/dashboard_student") ||
                 path.Contains("student/dashboard_student"));

            if (isStudentDashboard)
            {
                // Show avatar, settings, logout
                pnlStudentDashboardHeader.Visible = true;
                pnlOtherPagesHeader.Visible = false;
                SetupStudentDashboardHeader();
            }
            else if (role == "student")
            {
                // Show dashboard button
                pnlStudentDashboardHeader.Visible = false;
                pnlOtherPagesHeader.Visible = true;
                lnkDashboard.NavigateUrl = "~/Pages/student/dashboard_student.aspx";
            }
            else if (role == "teacher")
            {
                // Teacher pages - show dashboard button
                pnlStudentDashboardHeader.Visible = false;
                pnlOtherPagesHeader.Visible = true;
                lnkDashboard.NavigateUrl = "~/Pages/teacher/dashboard_teacher.aspx";
            }
            else
            {
                // Default - hide header buttons if no role
                pnlStudentDashboardHeader.Visible = false;
                pnlOtherPagesHeader.Visible = false;
            }
        }

        private void SetupStudentDashboardHeader()
        {
            string userSlug = Session["UserSlug"]?.ToString();
            string fullName = Session["FullName"]?.ToString() ?? "Student";

            // Set user label
            lblUser.Text = fullName;

            // Set avatar initial
            if (!string.IsNullOrEmpty(fullName) && fullName.Length > 0)
            {
                imgAvatar.InnerHtml = $"<span class='user-initial'>{fullName[0].ToString().ToUpper()}</span>";
            }

            // Set profile settings link
            lnkProfileSettings.NavigateUrl = "~/Pages/student/Profile.aspx";
        }

        protected void BtnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/Pages/Login.aspx", false);
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
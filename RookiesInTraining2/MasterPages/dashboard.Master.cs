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

            if (!IsPostBack)
            {
                // Display user info
                string fullName = Session["FullName"]?.ToString() ?? "用户";
                string role = Session["Role"]?.ToString() ?? "";
                
                lblUser.Text = $"{fullName} ({GetRoleText(role)})";

                // Set user initial
                if (!string.IsNullOrEmpty(fullName) && fullName.Length > 0)
                {
                    imgAvatar.InnerHtml = $"<span class='user-initial'>{fullName[0]}</span>";
                }
            }

            // Wire up logout button
            btnLogout.Click += BtnLogout_Click;
        }

        private void BtnLogout_Click(object sender, EventArgs e)
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
    }
}
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;   // for Debug.WriteLine
using System.Security.Cryptography;
using System.Text;
using System.Web;           // for HttpUtility

namespace RookiesInTraining2.Pages
{
    public partial class Login : System.Web.UI.Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Disable unobtrusive validation to avoid jQuery requirement
            System.Web.UI.ValidationSettings.UnobtrusiveValidationMode =
                System.Web.UI.UnobtrusiveValidationMode.None;

            if (!IsPostBack && Session["UserSlug"] != null)
                RedirectByRole(Session["Role"] as string);
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            Page.Validate("LoginGroup");
            if (!Page.IsValid) return;

            // normalize inputs
            string email = (txtLoginEmail.Text ?? "").Trim().ToLowerInvariant();
            string pwd = (txtLoginPassword.Text ?? "").Trim();

#if DEBUG
            Debug.WriteLine($"[LOGIN] Email entered: {email}");
            Debug.WriteLine($"[LOGIN] Password entered: {pwd}");
#endif

            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = con.CreateCommand())
                {
                    con.Open();

                    // Fetch user data with hashed password
                    cmd.CommandText = @"
                    SELECT TOP (1)
                        user_slug, display_name, role_global, password_hash
                    FROM dbo.Users
                    WHERE LTRIM(RTRIM(LOWER(email))) = @e AND is_deleted = 0;";

                    cmd.Parameters.AddWithValue("@e", email);

                    using (var rd = cmd.ExecuteReader(CommandBehavior.SingleRow))
                    {
                        if (!rd.Read())
                        {
#if DEBUG
                            Debug.WriteLine("[LOGIN] No user found for that email.");
#endif
                            lblLoginError.Text = "Invalid email or password.";
                            return;
                        }

                        string userSlug = rd["user_slug"].ToString();
                        string fullName = rd["display_name"].ToString();
                        string role = rd["role_global"].ToString();
                        string dbPasswordHash = (rd["password_hash"] as string ?? "").Trim();

#if DEBUG
                        Debug.WriteLine($"[LOGIN] DB password_hash: {dbPasswordHash}");
#endif

                        // Hash the input password and compare
                        string inputPasswordHash = Sha256Hex(pwd);

#if DEBUG
                        Debug.WriteLine($"[LOGIN] Input password_hash: {inputPasswordHash}");
#endif

                        if (!string.Equals(dbPasswordHash, inputPasswordHash, StringComparison.OrdinalIgnoreCase))
                        {
#if DEBUG
                            Debug.WriteLine("[LOGIN] Passwords do NOT match.");
#endif
                            lblLoginError.Text = "Invalid email or password.";
                            return;
                        }

#if DEBUG
                        Debug.WriteLine("[LOGIN] Passwords match. Logging in…");
#endif

                        // Success → Set session and redirect
                        Session["UserSlug"] = userSlug;
                        Session["FullName"] = fullName;
                        Session["Email"] = email;
                        Session["Role"] = role;

#if DEBUG
                        Debug.WriteLine($"[LOGIN] Logged in as {fullName} ({role})");
#endif

                        RedirectByRole(role);
                    }
                }
            }
            catch (Exception ex)
            {
#if DEBUG
                Debug.WriteLine("[LOGIN] EXCEPTION: " + ex);
#endif
                lblLoginError.Text = "Login failed. " + Server.HtmlEncode(ex.Message);
            }
        }

        private static string Sha256Hex(string input)
        {
            using (var sha = SHA256.Create())
            {
                var bytes = sha.ComputeHash(Encoding.UTF8.GetBytes(input));
                var sb = new StringBuilder(bytes.Length * 2);
                foreach (var b in bytes) sb.Append(b.ToString("x2"));
                return sb.ToString();
            }
        }

        private void RedirectByRole(string role)
        {
            if (string.IsNullOrWhiteSpace(role))
            {
                Response.Redirect("~/Pages/Login.aspx", false);
                return;
            }

            switch (role.Trim().ToLowerInvariant())
            {
                case "student": Response.Redirect("~/Pages/dashboard_student.aspx", false); break;
                case "teacher": Response.Redirect("~/Pages/dashboard_teacher.aspx", false); break;
                case "admin": Response.Redirect("~/Pages/dashboard_admin.aspx", false); break;
                default: Response.Redirect("~/Pages/Login.aspx", false); break;
            }
        }
    }
}

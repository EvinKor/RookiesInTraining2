using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Globalization;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;

namespace RookiesInTraining2.Pages
{
    public partial class Register : System.Web.UI.Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            System.Web.UI.ValidationSettings.UnobtrusiveValidationMode =
                System.Web.UI.UnobtrusiveValidationMode.None;

            if (!IsPostBack && Session["UserSlug"] != null)
                Response.Redirect("~/Pages/student/dashboard_student.aspx");
        }

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            Page.Validate("RegGroup");
            if (!Page.IsValid) return;

            string fullName = txtFullName.Text.Trim();
            string email = txtRegEmail.Text.Trim().ToLowerInvariant();
            string password = txtRegPassword.Text.Trim();

            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = con.CreateCommand())
                {
                    con.Open();

                    // (1) email exists?
                    cmd.CommandText = @"SELECT TOP (1) 1 FROM dbo.Users WHERE email = @e AND is_deleted = 0;";
                    cmd.Parameters.AddWithValue("@e", email);
                    if (cmd.ExecuteScalar() != null)
                    {
                        lblRegError.Text = "Email already registered.";
                        return;
                    }

                    // (2) Hash password and insert user
                    // Only students can register - teachers must be created by admin
                    cmd.Parameters.Clear();
                    string slug = NewSlugUnique(fullName, SlugExists, maxLen: 40);
                    string role = "student"; // Force student role - only admin can create teachers
                    string passwordHash = HashPassword(password);

                    cmd.CommandText = @"
                    INSERT INTO dbo.Users
                    ( user_slug, full_name, display_name, email, password_hash, 
                      role, role_global, avatar_url,
                      created_at, updated_at, is_deleted )
                    VALUES
                    ( @slug, @name, @name, @e, @hash,
                      @role, @role, @avatar,
                      SYSUTCDATETIME(), SYSUTCDATETIME(), 0 );";

                    cmd.Parameters.AddWithValue("@slug", slug);
                    cmd.Parameters.AddWithValue("@name", fullName);
                    cmd.Parameters.AddWithValue("@e", email);
                    cmd.Parameters.AddWithValue("@hash", passwordHash);
                    cmd.Parameters.AddWithValue("@role", role);
                    cmd.Parameters.AddWithValue("@avatar", DBNull.Value);
                    cmd.ExecuteNonQuery();

                    // (3) session + redirect
                    Session["UserSlug"] = slug;
                    Session["FullName"] = fullName;
                    Session["Email"] = email;
                    Session["Role"] = role;

                    RedirectByRole(role);
                }
            }
            catch (Exception ex)
            {
                lblRegError.Text = "Registration failed. " + Server.HtmlEncode(ex.Message);
            }
        }

        // ---------- helpers ----------
        private bool SlugExists(string slug)
        {
            using (var con = new SqlConnection(ConnStr))
            using (var cmd = con.CreateCommand())
            {
                cmd.CommandText = "SELECT 1 FROM dbo.Users WHERE user_slug = @slug AND is_deleted = 0";
                cmd.Parameters.AddWithValue("@slug", slug);
                con.Open();
                return cmd.ExecuteScalar() != null;
            }
        }

        private static string NewSlugUnique(string fullName, Func<string, bool> exists, int maxLen = 40)
        {
            var baseSlug = SlugifyName(fullName, maxLen);
            var slug = baseSlug; int i = 2;

            while (exists(slug))
            {
                var suffix = "-" + i.ToString(CultureInfo.InvariantCulture);
                var cutLen = Math.Max(1, maxLen - suffix.Length);
                slug = baseSlug.Length > cutLen ? baseSlug.Substring(0, cutLen).Trim('-') + suffix : baseSlug + suffix;
                i++;
            }
            return slug;
        }

        private static string SlugifyName(string fullName, int maxLen = 40)
        {
            if (string.IsNullOrWhiteSpace(fullName)) return "user";
            string s = fullName.Trim().ToLowerInvariant();

            var sb = new StringBuilder(s.Length);
            foreach (var ch in s.Normalize(NormalizationForm.FormD))
            {
                var cat = CharUnicodeInfo.GetUnicodeCategory(ch);
                if (cat != System.Globalization.UnicodeCategory.NonSpacingMark) sb.Append(ch);
            }
            s = sb.ToString().Normalize(NormalizationForm.FormC);
            s = Regex.Replace(s, @"[^a-z0-9]+", "-").Trim('-');
            s = Regex.Replace(s, "-{2,}", "-");
            if (s.Length == 0) s = "user";
            if (s.Length > maxLen) s = s.Substring(0, maxLen).Trim('-');
            return s;
        }

        private void RedirectByRole(string role)
        {
            if (string.IsNullOrWhiteSpace(role)) { Response.Redirect("~/Pages/Login.aspx", false); return; }

            switch (role.Trim().ToLowerInvariant())
            {
                case "student": Response.Redirect("~/Pages/student/dashboard_student.aspx", false); break;
                case "teacher": Response.Redirect("~/Pages/teacher/dashboard_teacher.aspx", false); break;
                case "admin": Response.Redirect("~/Pages/admin/dashboard_admin.aspx", false); break;
                default: Response.Redirect("~/Pages/Login.aspx", false); break;
            }
        }

        /// <summary>
        /// Hash password using SHA256
        /// </summary>
        private string HashPassword(string password)
        {
            using (SHA256 sha256 = SHA256.Create())
            {
                byte[] bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(password));
                StringBuilder builder = new StringBuilder();
                for (int i = 0; i < bytes.Length; i++)
                {
                    builder.Append(bytes[i].ToString("x2"));
                }
                return builder.ToString();
            }
        }
    }
}

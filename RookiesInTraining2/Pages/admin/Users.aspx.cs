using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using System.Web.UI;

namespace RookiesInTraining2.Pages
{
    public partial class ManageUsers : System.Web.UI.Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Check authentication - only admin can access
            if (Session["UserSlug"] == null || Session["Role"]?.ToString() != "admin")
            {
                Response.Redirect("~/Pages/Login.aspx", false);
                return;
            }

            if (!IsPostBack)
            {
                LoadUsers();
                
                // Check if user slug is in query string to show details modal
                string userSlug = Request.QueryString["user"];
                if (!string.IsNullOrEmpty(userSlug))
                {
                    LoadUserDetailsForModal(userSlug);
                }
            }
        }

        private void LoadUsers()
        {
            try
            {
                string searchTerm = txtSearch.Text.Trim();
                string roleFilter = ddlRoleFilter.SelectedValue;

                using (var con = new SqlConnection(ConnStr))
                using (var cmd = con.CreateCommand())
                {
                    con.Open();

                    // Build query with filters
                    var query = new StringBuilder(@"
                        SELECT 
                            user_slug as UserSlug,
                            full_name as FullName,
                            display_name as DisplayName,
                            email as Email,
                            role_global as Role,
                            FORMAT(created_at, 'yyyy-MM-dd HH:mm') as CreatedAt
                        FROM dbo.Users
                        WHERE is_deleted = 0");

                    if (!string.IsNullOrEmpty(searchTerm))
                    {
                        query.Append(" AND (LOWER(full_name) LIKE @search OR LOWER(email) LIKE @search)");
                        cmd.Parameters.AddWithValue("@search", "%" + searchTerm.ToLower() + "%");
                    }

                    if (!string.IsNullOrEmpty(roleFilter))
                    {
                        query.Append(" AND role_global = @role");
                        cmd.Parameters.AddWithValue("@role", roleFilter);
                    }

                    query.Append(" ORDER BY created_at DESC");

                    cmd.CommandText = query.ToString();

                    var users = new List<dynamic>();
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            users.Add(new
                            {
                                UserSlug = reader["UserSlug"].ToString(),
                                FullName = reader["FullName"].ToString(),
                                DisplayName = reader["DisplayName"].ToString(),
                                Email = reader["Email"].ToString(),
                                Role = reader["Role"].ToString(),
                                CreatedAt = reader["CreatedAt"].ToString()
                            });
                        }
                    }

                    if (users.Count > 0)
                    {
                        rptUsers.DataSource = users;
                        rptUsers.DataBind();
                        lblNoUsers.Visible = false;
                        lblUserCount.Text = $"{users.Count} user(s) found";
                    }
                    else
                    {
                        lblNoUsers.Visible = true;
                        lblUserCount.Text = "0 users found";
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[Users] Error loading users: {ex.Message}");
                lblNoUsers.Visible = true;
                lblNoUsers.Text = "Error loading users. Please try again.";
            }
        }

        protected void txtSearch_TextChanged(object sender, EventArgs e)
        {
            LoadUsers();
        }

        protected void ddlRoleFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadUsers();
        }


        private void LoadUserDetailsForModal(string userSlug)
        {
            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = con.CreateCommand())
                {
                    con.Open();
                    cmd.CommandText = @"
                        SELECT 
                            user_slug,
                            display_name,
                            email,
                            role_global,
                            FORMAT(created_at, 'yyyy-MM-dd HH:mm') as created_at
                        FROM dbo.Users
                        WHERE user_slug = @slug AND is_deleted = 0";

                    cmd.Parameters.AddWithValue("@slug", userSlug);

                    using (var reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            // Store user details in hidden fields for JavaScript to access
                            hfModalUserSlug.Value = reader["user_slug"].ToString();
                            hfModalDisplayName.Value = reader["display_name"].ToString();
                            hfModalEmail.Value = reader["email"].ToString();
                            hfModalRole.Value = reader["role_global"].ToString();
                            hfModalCreatedAt.Value = reader["created_at"].ToString();
                            hfShowModal.Value = "true";
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[Users] Error loading user details: {ex.Message}");
            }
        }

        protected void btnCreateUser_Click(object sender, EventArgs e)
        {
            Page.Validate("CreateUserGroup");
            if (!Page.IsValid) return;

            string fullName = txtCreateFullName.Text.Trim();
            string email = txtCreateEmail.Text.Trim().ToLowerInvariant();
            string password = txtCreatePassword.Text.Trim();
            string role = ddlCreateRole.SelectedValue;

            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = con.CreateCommand())
                {
                    con.Open();

                    // Check if email already exists
                    cmd.CommandText = "SELECT TOP (1) 1 FROM dbo.Users WHERE email = @e AND is_deleted = 0";
                    cmd.Parameters.AddWithValue("@e", email);
                    if (cmd.ExecuteScalar() != null)
                    {
                        lblCreateError.Text = "Email already registered.";
                        return;
                    }

                    // Generate unique slug
                    string slug = NewSlugUnique(fullName, SlugExists, maxLen: 40);
                    string passwordHash = HashPassword(password);

                    // Insert new user
                    cmd.Parameters.Clear();
                    cmd.CommandText = @"
                        INSERT INTO dbo.Users
                        ( user_slug, full_name, display_name, email, password_hash, 
                          role, role_global, avatar_url,
                          created_at, updated_at, is_deleted )
                        VALUES
                        ( @slug, @name, @name, @e, @hash,
                          @role, @role, @avatar,
                          SYSUTCDATETIME(), SYSUTCDATETIME(), 0 )";

                    cmd.Parameters.AddWithValue("@slug", slug);
                    cmd.Parameters.AddWithValue("@name", fullName);
                    cmd.Parameters.AddWithValue("@e", email);
                    cmd.Parameters.AddWithValue("@hash", passwordHash);
                    cmd.Parameters.AddWithValue("@role", role);
                    cmd.Parameters.AddWithValue("@avatar", DBNull.Value);
                    cmd.ExecuteNonQuery();

                    // Clear form and reload
                    txtCreateFullName.Text = "";
                    txtCreateEmail.Text = "";
                    txtCreatePassword.Text = "";
                    txtCreateConfirmPassword.Text = "";
                    lblCreateError.Text = "";

                    // Close modal using JavaScript
                    ClientScript.RegisterStartupScript(this.GetType(), "closeModal", 
                        "setTimeout(function() { var modal = bootstrap.Modal.getInstance(document.getElementById('createUserModal')); if(modal) modal.hide(); }, 100);", true);

                    LoadUsers();
                }
            }
            catch (Exception ex)
            {
                lblCreateError.Text = "Error creating user: " + Server.HtmlEncode(ex.Message);
                System.Diagnostics.Debug.WriteLine($"[Users] Error creating user: {ex.Message}");
            }
        }

        protected void rptUsers_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "DeleteUser")
            {
                string userSlug = e.CommandArgument.ToString();
                string currentUserSlug = Session["UserSlug"]?.ToString();

                // Prevent admin from deleting themselves
                if (userSlug == currentUserSlug)
                {
                    ClientScript.RegisterStartupScript(this.GetType(), "showError",
                        "alert('You cannot delete your own account!');", true);
                    return;
                }

                try
                {
                    using (var con = new SqlConnection(ConnStr))
                    using (var cmd = con.CreateCommand())
                    {
                        con.Open();

                        // Soft delete user
                        cmd.CommandText = @"
                            UPDATE dbo.Users
                            SET is_deleted = 1,
                                deleted_at = SYSUTCDATETIME(),
                                deleted_by_slug = @deletedBy,
                                updated_at = SYSUTCDATETIME()
                            WHERE user_slug = @slug";

                        cmd.Parameters.AddWithValue("@slug", userSlug);
                        cmd.Parameters.AddWithValue("@deletedBy", currentUserSlug);
                        cmd.ExecuteNonQuery();

                        LoadUsers();
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"[Users] Error deleting user: {ex.Message}");
                    ClientScript.RegisterStartupScript(this.GetType(), "showError",
                        $"alert('Error deleting user: {Server.HtmlEncode(ex.Message)}');", true);
                }
            }
        }

        // Helper methods
        protected string GetRoleBadgeColor(string role)
        {
            if (string.IsNullOrEmpty(role))
                return "secondary";

            switch (role.ToLower())
            {
                case "admin":
                    return "danger";
                case "teacher":
                    return "primary";
                case "student":
                    return "success";
                default:
                    return "secondary";
            }
        }

        protected string GetRoleText(string role)
        {
            if (string.IsNullOrEmpty(role))
                return "Unknown";

            switch (role.ToLower())
            {
                case "admin":
                    return "Admin";
                case "teacher":
                    return "Teacher";
                case "student":
                    return "Student";
                default:
                    return "Unknown";
            }
        }

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
            var slug = baseSlug;
            int i = 2;

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


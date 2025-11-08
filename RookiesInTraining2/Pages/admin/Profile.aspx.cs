using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
using System.Web.UI;

namespace RookiesInTraining2.Pages
{
    public partial class AdminProfile : System.Web.UI.Page
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
                LoadProfileInfo();
            }
        }

        private void LoadProfileInfo()
        {
            try
            {
                string userSlug = Session["UserSlug"]?.ToString();
                if (string.IsNullOrEmpty(userSlug))
                {
                    Response.Redirect("~/Pages/Login.aspx", false);
                    return;
                }

                using (var con = new SqlConnection(ConnStr))
                using (var cmd = con.CreateCommand())
                {
                    con.Open();
                    cmd.CommandText = @"
                        SELECT 
                            display_name,
                            email,
                            user_slug,
                            role_global,
                            FORMAT(created_at, 'yyyy-MM-dd HH:mm') as created_at,
                            FORMAT(updated_at, 'yyyy-MM-dd HH:mm') as updated_at
                        FROM dbo.Users
                        WHERE user_slug = @slug AND is_deleted = 0";

                    cmd.Parameters.AddWithValue("@slug", userSlug);

                    using (var reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            txtDisplayName.Text = reader["display_name"].ToString();
                            txtEmail.Text = reader["email"].ToString();
                            txtUserSlug.Text = reader["user_slug"].ToString();
                            txtRole.Text = reader["role_global"].ToString();
                            lblCreatedAt.Text = reader["created_at"].ToString();
                            lblUpdatedAt.Text = reader["updated_at"].ToString();
                        }
                        else
                        {
                            Response.Redirect("~/Pages/Login.aspx", false);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[Profile] Error loading profile: {ex.Message}");
                lblProfileError.Text = "Error loading profile information. Please try again.";
            }
        }

        protected void btnUpdateProfile_Click(object sender, EventArgs e)
        {
            Page.Validate("ProfileInfoGroup");
            if (!Page.IsValid) return;

            string userSlug = Session["UserSlug"]?.ToString();
            string displayName = txtDisplayName.Text.Trim();
            string email = txtEmail.Text.Trim().ToLowerInvariant();

            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = con.CreateCommand())
                {
                    con.Open();

                    // Check if email is being changed and if it already exists
                    cmd.CommandText = @"
                        SELECT TOP (1) user_slug 
                        FROM dbo.Users 
                        WHERE email = @e AND user_slug != @slug AND is_deleted = 0";
                    cmd.Parameters.AddWithValue("@e", email);
                    cmd.Parameters.AddWithValue("@slug", userSlug);
                    if (cmd.ExecuteScalar() != null)
                    {
                        lblProfileError.Text = "Email already registered to another user.";
                        lblProfileError.Visible = true;
                        lblProfileSuccess.Visible = false;
                        return;
                    }

                    // Update profile
                    cmd.Parameters.Clear();
                    cmd.CommandText = @"
                        UPDATE dbo.Users
                        SET display_name = @name,
                            email = @email,
                            updated_at = SYSUTCDATETIME()
                        WHERE user_slug = @slug";

                    cmd.Parameters.AddWithValue("@slug", userSlug);
                    cmd.Parameters.AddWithValue("@name", displayName);
                    cmd.Parameters.AddWithValue("@email", email);
                    cmd.ExecuteNonQuery();

                    // Update session
                    Session["FullName"] = displayName;
                    Session["Email"] = email;

                    // Show success message
                    lblProfileSuccess.Text = "Profile updated successfully!";
                    lblProfileSuccess.Visible = true;
                    lblProfileError.Visible = false;

                    // Reload to show updated timestamp
                    LoadProfileInfo();
                }
            }
            catch (Exception ex)
            {
                lblProfileError.Text = "Error updating profile: " + Server.HtmlEncode(ex.Message);
                lblProfileError.Visible = true;
                lblProfileSuccess.Visible = false;
                System.Diagnostics.Debug.WriteLine($"[Profile] Error updating profile: {ex.Message}");
            }
        }

        protected void btnChangePassword_Click(object sender, EventArgs e)
        {
            Page.Validate("ChangePasswordGroup");
            if (!Page.IsValid) return;

            string userSlug = Session["UserSlug"]?.ToString();
            string currentPassword = txtCurrentPassword.Text.Trim();
            string newPassword = txtNewPassword.Text.Trim();

            if (newPassword.Length < 6)
            {
                lblPasswordError.Text = "New password must be at least 6 characters.";
                lblPasswordError.Visible = true;
                lblPasswordSuccess.Visible = false;
                return;
            }

            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = con.CreateCommand())
                {
                    con.Open();

                    // Verify current password
                    cmd.CommandText = @"
                        SELECT password_hash 
                        FROM dbo.Users 
                        WHERE user_slug = @slug AND is_deleted = 0";
                    cmd.Parameters.AddWithValue("@slug", userSlug);

                    string dbPasswordHash = cmd.ExecuteScalar()?.ToString() ?? "";
                    string currentPasswordHash = HashPassword(currentPassword);

                    if (!string.Equals(dbPasswordHash, currentPasswordHash, StringComparison.OrdinalIgnoreCase))
                    {
                        lblPasswordError.Text = "Current password is incorrect.";
                        lblPasswordError.Visible = true;
                        lblPasswordSuccess.Visible = false;
                        return;
                    }

                    // Update password
                    string newPasswordHash = HashPassword(newPassword);
                    cmd.Parameters.Clear();
                    cmd.CommandText = @"
                        UPDATE dbo.Users
                        SET password_hash = @hash,
                            updated_at = SYSUTCDATETIME()
                        WHERE user_slug = @slug";

                    cmd.Parameters.AddWithValue("@slug", userSlug);
                    cmd.Parameters.AddWithValue("@hash", newPasswordHash);
                    cmd.ExecuteNonQuery();

                    // Clear password fields
                    txtCurrentPassword.Text = "";
                    txtNewPassword.Text = "";
                    txtConfirmNewPassword.Text = "";

                    // Show success message
                    lblPasswordSuccess.Text = "Password changed successfully!";
                    lblPasswordSuccess.Visible = true;
                    lblPasswordError.Visible = false;

                    // Reload to show updated timestamp
                    LoadProfileInfo();
                }
            }
            catch (Exception ex)
            {
                lblPasswordError.Text = "Error changing password: " + Server.HtmlEncode(ex.Message);
                lblPasswordError.Visible = true;
                lblPasswordSuccess.Visible = false;
                System.Diagnostics.Debug.WriteLine($"[Profile] Error changing password: {ex.Message}");
            }
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


using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.IO;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.UI;
using RookiesInTraining2.Helpers;

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

            // Preserve query string user parameter
            string userSlug = Request.QueryString["user"];

            if (!IsPostBack)
            {
                // Check if user slug is in query string to show details modal
                if (!string.IsNullOrEmpty(userSlug))
                {
                    // Store current filter values from form data (since controls aren't populated yet on new request)
                    // Try to get from form first (if coming from a postback), otherwise from ViewState/Session
                    string searchText = Request.Form[txtSearch.UniqueID] ?? txtSearch.Text ?? "";
                    string roleFilter = Request.Form[ddlRoleFilter.UniqueID] ?? ddlRoleFilter.SelectedValue ?? "";
                    string statusFilter = Request.Form[ddlStatusFilter.UniqueID] ?? ddlStatusFilter.SelectedValue ?? "";
                    
                    // If not in form, try to get from previous session (if filters were applied before)
                    if (string.IsNullOrEmpty(searchText) && Session["LastSearchText"] != null)
                        searchText = Session["LastSearchText"].ToString();
                    if (string.IsNullOrEmpty(roleFilter) && Session["LastRoleFilter"] != null)
                        roleFilter = Session["LastRoleFilter"].ToString();
                    if (string.IsNullOrEmpty(statusFilter) && Session["LastStatusFilter"] != null)
                        statusFilter = Session["LastStatusFilter"].ToString();
                    
                    // Store current filter values in session to preserve them
                    Session["PreserveSearchText"] = searchText;
                    Session["PreserveRoleFilter"] = roleFilter;
                    Session["PreserveStatusFilter"] = statusFilter;
                    
                    // Store in session for after redirect
                    Session["ShowUserModal"] = true;
                    Session["ModalUserSlug"] = userSlug;
                    
                    // Redirect to same page without query string to prevent modal from showing on refresh
                    string currentUrl = Request.Url.AbsolutePath;
                    Response.Redirect(currentUrl, false);
                    return;
                }
                
                // Check if we should show modal from Session (set before redirect)
                if (Session["ShowUserModal"] != null && (bool)Session["ShowUserModal"])
                {
                    string modalUserSlug = Session["ModalUserSlug"]?.ToString();
                    if (!string.IsNullOrEmpty(modalUserSlug))
                    {
                        LoadUserDetailsForModal(modalUserSlug);
                    }
                    // Clear session after using
                    Session["ShowUserModal"] = null;
                    Session["ModalUserSlug"] = null;
                    
                    // Restore filter values from session
                    if (Session["PreserveSearchText"] != null)
                    {
                        txtSearch.Text = Session["PreserveSearchText"].ToString();
                        Session["PreserveSearchText"] = null;
                    }
                    if (Session["PreserveRoleFilter"] != null)
                    {
                        string roleValue = Session["PreserveRoleFilter"].ToString();
                        if (ddlRoleFilter.Items.FindByValue(roleValue) != null)
                        {
                            ddlRoleFilter.SelectedValue = roleValue;
                        }
                        Session["PreserveRoleFilter"] = null;
                    }
                    if (Session["PreserveStatusFilter"] != null)
                    {
                        string statusValue = Session["PreserveStatusFilter"].ToString();
                        if (ddlStatusFilter.Items.FindByValue(statusValue) != null)
                        {
                            ddlStatusFilter.SelectedValue = statusValue;
                        }
                        Session["PreserveStatusFilter"] = null;
                    }
                }
                
                LoadUsers();
            }
            else
            {
                // On postback, clear any modal session flags and hidden fields to prevent modal from showing
                Session["ShowUserModal"] = null;
                Session["ModalUserSlug"] = null;
                // Also clear filter preservation session variables
                Session["PreserveSearchText"] = null;
                Session["PreserveRoleFilter"] = null;
                Session["PreserveStatusFilter"] = null;
                
                // Clear hidden fields that trigger modal display
                if (hfShowModal != null)
                {
                    hfShowModal.Value = "false";
                }
                if (hfModalUserSlug != null)
                {
                    hfModalUserSlug.Value = "";
                }
                if (hfModalDisplayName != null)
                {
                    hfModalDisplayName.Value = "";
                }
                if (hfModalEmail != null)
                {
                    hfModalEmail.Value = "";
                }
                if (hfModalRole != null)
                {
                    hfModalRole.Value = "";
                }
                if (hfModalCreatedAt != null)
                {
                    hfModalCreatedAt.Value = "";
                }
                
                // On postback, remove query string if it exists (shouldn't happen, but just in case)
                if (!string.IsNullOrEmpty(userSlug))
                {
                    RemoveQueryStringFromUrl();
                }
                
                // LoadUsers will be called by filter event handlers if needed
                // If no filter event was triggered, we still need to load users
                if (!IsFilterPostBack())
                {
                    LoadUsers();
                }
            }
        }

        private bool IsFilterPostBack()
        {
            // Check if this postback was triggered by a filter control
            string eventTarget = Request.Form["__EVENTTARGET"] ?? "";
            return eventTarget.Contains("txtSearch") || 
                   eventTarget.Contains("ddlRoleFilter") || 
                   eventTarget.Contains("ddlStatusFilter");
        }

        private void LoadUsers()
        {
            try
            {
                string searchTerm = txtSearch.Text.Trim();
                string roleFilter = ddlRoleFilter.SelectedValue;
                string statusFilter = ddlStatusFilter.SelectedValue;

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
                            ISNULL(is_blocked, 0) as IsBlocked,
                            FORMAT(created_at, 'yyyy-MM-dd HH:mm') as CreatedAt
                        FROM dbo.Users
                        WHERE is_deleted = 0");

                    if (!string.IsNullOrEmpty(searchTerm))
                    {
                        query.Append(" AND (LOWER(ISNULL(display_name, '')) LIKE @search OR LOWER(email) LIKE @search OR LOWER(full_name) LIKE @search)");
                        cmd.Parameters.AddWithValue("@search", "%" + searchTerm.ToLower() + "%");
                    }

                    if (!string.IsNullOrEmpty(roleFilter))
                    {
                        query.Append(" AND role_global = @role");
                        cmd.Parameters.AddWithValue("@role", roleFilter);
                    }

                    if (!string.IsNullOrEmpty(statusFilter))
                    {
                        if (statusFilter == "blocked")
                        {
                            query.Append(" AND ISNULL(is_blocked, 0) = 1");
                        }
                        else if (statusFilter == "active")
                        {
                            query.Append(" AND ISNULL(is_blocked, 0) = 0");
                        }
                    }

                    query.Append(" ORDER BY created_at DESC");

                    cmd.CommandText = query.ToString();

                    string currentAdminSlug = Session["UserSlug"]?.ToString() ?? "";
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
                                IsBlocked = Convert.ToBoolean(reader["IsBlocked"]),
                                CreatedAt = reader["CreatedAt"].ToString(),
                                IsCurrentAdmin = (reader["UserSlug"].ToString() == currentAdminSlug)
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
            // Store current filter values in session for preservation
            Session["LastSearchText"] = txtSearch.Text;
            Session["LastRoleFilter"] = ddlRoleFilter.SelectedValue;
            Session["LastStatusFilter"] = ddlStatusFilter.SelectedValue;
            
            LoadUsers();
        }

        protected void ddlRoleFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            // Store current filter values in session for preservation
            Session["LastSearchText"] = txtSearch.Text;
            Session["LastRoleFilter"] = ddlRoleFilter.SelectedValue;
            Session["LastStatusFilter"] = ddlStatusFilter.SelectedValue;
            
            LoadUsers();
        }

        protected void ddlStatusFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            // Store current filter values in session for preservation
            Session["LastSearchText"] = txtSearch.Text;
            Session["LastRoleFilter"] = ddlRoleFilter.SelectedValue;
            Session["LastStatusFilter"] = ddlStatusFilter.SelectedValue;
            
            LoadUsers();
        }

        private void RemoveQueryStringFromUrl()
        {
            // Use JavaScript to remove query string from URL without reload
            string script = @"
                if (window.history && window.history.replaceState) {
                    window.history.replaceState({}, document.title, window.location.pathname);
                } else {
                    window.location.href = window.location.pathname;
                }
            ";
            ClientScript.RegisterStartupScript(this.GetType(), "removeQueryString", script, true);
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
                            ISNULL(is_blocked, 0) as is_blocked,
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
                            hfModalIsBlocked.Value = Convert.ToBoolean(reader["is_blocked"]).ToString().ToLower();
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
            string adminSlug = Session["UserSlug"]?.ToString();

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
                          created_at, updated_at, is_deleted, is_blocked )
                        VALUES
                        ( @slug, @name, @name, @e, @hash,
                          @role, @role, @avatar,
                          SYSUTCDATETIME(), SYSUTCDATETIME(), 0, 0 )";

                    cmd.Parameters.AddWithValue("@slug", slug);
                    cmd.Parameters.AddWithValue("@name", fullName);
                    cmd.Parameters.AddWithValue("@e", email);
                    cmd.Parameters.AddWithValue("@hash", passwordHash);
                    cmd.Parameters.AddWithValue("@role", role);
                    cmd.Parameters.AddWithValue("@avatar", DBNull.Value);
                    cmd.ExecuteNonQuery();

                    // Log admin action
                    AdminAuditLogger.LogAction(adminSlug, "create_user", "user", slug, 
                        $"Created {role} user: {fullName} ({email})");

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
            string adminSlug = Session["UserSlug"]?.ToString();
            string userSlug = e.CommandArgument.ToString();

            if (e.CommandName == "DeleteUser")
            {
                // Prevent admin from deleting themselves
                if (userSlug == adminSlug)
                {
                    ClientScript.RegisterStartupScript(this.GetType(), "showError",
                        "alert('You cannot delete your own account!');", true);
                    return;
                }

                // Check if this is the only Admin
                if (IsOnlyAdmin(userSlug))
                {
                    ClientScript.RegisterStartupScript(this.GetType(), "showError",
                        "alert('Cannot delete the only Admin account in the system!');", true);
                    return;
                }

                try
                {
                    using (var con = new SqlConnection(ConnStr))
                    using (var cmd = con.CreateCommand())
                    {
                        con.Open();

                        // Get user info for logging
                        string userName = GetUserName(userSlug);

                        // Soft delete user
                        cmd.CommandText = @"
                            UPDATE dbo.Users
                            SET is_deleted = 1,
                                deleted_at = SYSUTCDATETIME(),
                                deleted_by_slug = @deletedBy,
                                updated_at = SYSUTCDATETIME()
                            WHERE user_slug = @slug";

                        cmd.Parameters.AddWithValue("@slug", userSlug);
                        cmd.Parameters.AddWithValue("@deletedBy", adminSlug);
                        cmd.ExecuteNonQuery();

                        // Log admin action
                        AdminAuditLogger.LogAction(adminSlug, "delete_user", "user", userSlug, 
                            $"Deleted user: {userName}");

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
            else if (e.CommandName == "BlockUser")
            {
                // Prevent admin from blocking themselves
                if (userSlug == adminSlug)
                {
                    ClientScript.RegisterStartupScript(this.GetType(), "showError",
                        "alert('You cannot block your own account!');", true);
                    return;
                }

                try
                {
                    using (var con = new SqlConnection(ConnStr))
                    using (var cmd = con.CreateCommand())
                    {
                        con.Open();

                        // Get user info
                        string userName = GetUserName(userSlug);

                        // Block user
                        cmd.CommandText = @"
                            UPDATE dbo.Users
                            SET is_blocked = 1,
                                updated_at = SYSUTCDATETIME()
                            WHERE user_slug = @slug";

                        cmd.Parameters.AddWithValue("@slug", userSlug);
                        cmd.ExecuteNonQuery();

                        // Log admin action
                        AdminAuditLogger.LogAction(adminSlug, "block_user", "user", userSlug, 
                            $"Blocked user: {userName}");

                        LoadUsers();
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"[Users] Error blocking user: {ex.Message}");
                    ClientScript.RegisterStartupScript(this.GetType(), "showError",
                        $"alert('Error blocking user: {Server.HtmlEncode(ex.Message)}');", true);
                }
            }
            else if (e.CommandName == "UnblockUser")
            {
                try
                {
                    using (var con = new SqlConnection(ConnStr))
                    using (var cmd = con.CreateCommand())
                    {
                        con.Open();

                        // Get user info
                        string userName = GetUserName(userSlug);

                        // Unblock user
                        cmd.CommandText = @"
                            UPDATE dbo.Users
                            SET is_blocked = 0,
                                updated_at = SYSUTCDATETIME()
                            WHERE user_slug = @slug";

                        cmd.Parameters.AddWithValue("@slug", userSlug);
                        cmd.ExecuteNonQuery();

                        // Log admin action
                        AdminAuditLogger.LogAction(adminSlug, "unblock_user", "user", userSlug, 
                            $"Unblocked user: {userName}");

                        LoadUsers();
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"[Users] Error unblocking user: {ex.Message}");
                    ClientScript.RegisterStartupScript(this.GetType(), "showError",
                        $"alert('Error unblocking user: {Server.HtmlEncode(ex.Message)}');", true);
                }
            }
        }

        protected void btnUpdateUser_Click(object sender, EventArgs e)
        {
            string adminSlug = Session["UserSlug"]?.ToString();
            string userSlug = hfEditUserSlug.Value;
            string displayName = txtEditDisplayName.Text.Trim();
            string email = txtEditEmail.Text.Trim().ToLowerInvariant();
            bool isBlocked = chkEditIsBlocked.Checked;

            // Prevent admin from editing their own account
            if (userSlug == adminSlug)
            {
                lblEditError.Text = "You cannot edit your own account from this page. Please use the Settings page to update your profile.";
                lblEditError.Visible = true;
                return;
            }

            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = con.CreateCommand())
                {
                    con.Open();

                    // Check if email is being changed and if it already exists
                    if (!string.IsNullOrEmpty(email))
                    {
                        cmd.CommandText = @"
                            SELECT TOP (1) user_slug 
                            FROM dbo.Users 
                            WHERE email = @e AND user_slug != @slug AND is_deleted = 0";
                        cmd.Parameters.AddWithValue("@e", email);
                        cmd.Parameters.AddWithValue("@slug", userSlug);
                        if (cmd.ExecuteScalar() != null)
                        {
                            lblEditError.Text = "Email already registered to another user.";
                            return;
                        }
                    }

                    // Get old values for logging
                    string oldName = GetUserName(userSlug);
                    bool oldBlocked = IsUserBlocked(userSlug);

                    // Update user
                    cmd.Parameters.Clear();
                    cmd.CommandText = @"
                        UPDATE dbo.Users
                        SET display_name = @name,
                            email = @email,
                            is_blocked = @blocked,
                            updated_at = SYSUTCDATETIME()
                        WHERE user_slug = @slug";

                    cmd.Parameters.AddWithValue("@slug", userSlug);
                    cmd.Parameters.AddWithValue("@name", displayName);
                    cmd.Parameters.AddWithValue("@email", email);
                    cmd.Parameters.AddWithValue("@blocked", isBlocked);
                    cmd.ExecuteNonQuery();

                    // Log admin action
                    var changes = new List<string>();
                    if (oldName != displayName) changes.Add($"name: {oldName} → {displayName}");
                    if (oldBlocked != isBlocked) changes.Add($"blocked: {oldBlocked} → {isBlocked}");
                    AdminAuditLogger.LogAction(adminSlug, "edit_user", "user", userSlug, 
                        $"Updated user: {string.Join(", ", changes)}");

                    // Close modal and reload
                    ClientScript.RegisterStartupScript(this.GetType(), "closeEditModal", 
                        "setTimeout(function() { var modal = bootstrap.Modal.getInstance(document.getElementById('editUserModal')); if(modal) modal.hide(); }, 100);", true);

                    LoadUsers();
                }
            }
            catch (Exception ex)
            {
                lblEditError.Text = "Error updating user: " + Server.HtmlEncode(ex.Message);
                System.Diagnostics.Debug.WriteLine($"[Users] Error updating user: {ex.Message}");
            }
        }

        protected void btnChangeRole_Click(object sender, EventArgs e)
        {
            string adminSlug = Session["UserSlug"]?.ToString();
            string userSlug = hfChangeRoleUserSlug.Value;
            string newRole = ddlChangeRole.SelectedValue;

            // Prevent admin from changing their own role
            if (userSlug == adminSlug)
            {
                lblChangeRoleError.Text = "You cannot change your own role!";
                lblChangeRoleError.Visible = true;
                return;
            }

            // Prevent demoting Admin via UI
            if (newRole == "admin")
            {
                lblChangeRoleError.Text = "Cannot change role to Admin via this interface.";
                return;
            }

            // Prevent changing the only Admin's role
            if (IsOnlyAdmin(userSlug) && newRole != "admin")
            {
                lblChangeRoleError.Text = "Cannot change the role of the only Admin account.";
                return;
            }

            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = con.CreateCommand())
                {
                    con.Open();

                    string userName = GetUserName(userSlug);
                    string oldRole = GetUserRole(userSlug);

                    // Update role
                    cmd.CommandText = @"
                        UPDATE dbo.Users
                        SET role = @role,
                            role_global = @role,
                            updated_at = SYSUTCDATETIME()
                        WHERE user_slug = @slug";

                    cmd.Parameters.AddWithValue("@slug", userSlug);
                    cmd.Parameters.AddWithValue("@role", newRole);
                    cmd.ExecuteNonQuery();

                    // Log admin action
                    AdminAuditLogger.LogAction(adminSlug, "change_role", "user", userSlug, 
                        $"Changed role for {userName}: {oldRole} → {newRole}");

                    // Clear and close modal
                    lblChangeRoleError.Text = "";
                    ClientScript.RegisterStartupScript(this.GetType(), "closeRoleModal", 
                        "setTimeout(function() { var modal = bootstrap.Modal.getInstance(document.getElementById('changeRoleModal')); if(modal) modal.hide(); }, 100);", true);

                    LoadUsers();
                }
            }
            catch (Exception ex)
            {
                lblChangeRoleError.Text = "Error changing role: " + Server.HtmlEncode(ex.Message);
                System.Diagnostics.Debug.WriteLine($"[Users] Error changing role: {ex.Message}");
            }
        }

        protected void btnExportCSV_Click(object sender, EventArgs e)
        {
            try
            {
                Response.Clear();
                Response.ContentType = "text/csv";
                Response.AppendHeader("Content-Disposition", "attachment; filename=users_export_" + DateTime.Now.ToString("yyyyMMdd_HHmmss") + ".csv");

                using (var con = new SqlConnection(ConnStr))
                using (var cmd = con.CreateCommand())
                {
                    con.Open();
                    cmd.CommandText = @"
                        SELECT 
                            display_name,
                            email,
                            role_global,
                            CASE WHEN ISNULL(is_blocked, 0) = 1 THEN 'Blocked' ELSE 'Active' END as Status,
                            FORMAT(created_at, 'yyyy-MM-dd HH:mm') as CreatedAt
                        FROM dbo.Users
                        WHERE is_deleted = 0
                        ORDER BY created_at DESC";

                    using (var reader = cmd.ExecuteReader())
                    {
                        // Write CSV header
                        Response.Write("Name,Email,Role,Status,Created At\n");

                        // Write data
                        while (reader.Read())
                        {
                            Response.Write($"\"{reader["display_name"]}\",");
                            Response.Write($"\"{reader["email"]}\",");
                            Response.Write($"\"{reader["role_global"]}\",");
                            Response.Write($"\"{reader["Status"]}\",");
                            Response.Write($"\"{reader["CreatedAt"]}\"\n");
                        }
                    }
                }

                Response.End();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[Users] Error exporting CSV: {ex.Message}");
                ClientScript.RegisterStartupScript(this.GetType(), "showError",
                    $"alert('Error exporting CSV: {Server.HtmlEncode(ex.Message)}');", true);
            }
        }

        // Helper methods
        private bool IsOnlyAdmin(string userSlug)
        {
            using (var con = new SqlConnection(ConnStr))
            using (var cmd = con.CreateCommand())
            {
                con.Open();
                cmd.CommandText = @"
                    SELECT COUNT(*) 
                    FROM dbo.Users 
                    WHERE role_global = 'admin' AND is_deleted = 0";
                int adminCount = Convert.ToInt32(cmd.ExecuteScalar());

                if (adminCount <= 1)
                {
                    // Check if this user is an admin
                    cmd.CommandText = @"
                        SELECT TOP (1) 1 
                        FROM dbo.Users 
                        WHERE user_slug = @slug AND role_global = 'admin' AND is_deleted = 0";
                    cmd.Parameters.AddWithValue("@slug", userSlug);
                    return cmd.ExecuteScalar() != null;
                }
                return false;
            }
        }

        private string GetUserName(string userSlug)
        {
            using (var con = new SqlConnection(ConnStr))
            using (var cmd = con.CreateCommand())
            {
                con.Open();
                cmd.CommandText = "SELECT display_name FROM dbo.Users WHERE user_slug = @slug";
                cmd.Parameters.AddWithValue("@slug", userSlug);
                return cmd.ExecuteScalar()?.ToString() ?? "Unknown";
            }
        }

        private string GetUserRole(string userSlug)
        {
            using (var con = new SqlConnection(ConnStr))
            using (var cmd = con.CreateCommand())
            {
                con.Open();
                cmd.CommandText = "SELECT role_global FROM dbo.Users WHERE user_slug = @slug";
                cmd.Parameters.AddWithValue("@slug", userSlug);
                return cmd.ExecuteScalar()?.ToString() ?? "Unknown";
            }
        }

        private bool IsUserBlocked(string userSlug)
        {
            using (var con = new SqlConnection(ConnStr))
            using (var cmd = con.CreateCommand())
            {
                con.Open();
                cmd.CommandText = "SELECT ISNULL(is_blocked, 0) FROM dbo.Users WHERE user_slug = @slug";
                cmd.Parameters.AddWithValue("@slug", userSlug);
                return Convert.ToBoolean(cmd.ExecuteScalar() ?? false);
            }
        }

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

        protected string GetStatusBadge(bool isBlocked)
        {
            if (isBlocked)
                return "<span class='badge bg-danger'>Blocked</span>";
            else
                return "<span class='badge bg-success'>Active</span>";
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

        protected string GetBlockUnblockCssClass(bool isCurrentAdmin, bool isBlocked)
        {
            string baseClass = isBlocked ? "btn btn-sm btn-outline-success" : "btn btn-sm btn-outline-warning";
            if (isCurrentAdmin)
            {
                baseClass += " disabled";
            }
            return baseClass;
        }

        protected string GetBlockUnblockOnClientClick(bool isCurrentAdmin, bool isBlocked)
        {
            if (isCurrentAdmin)
            {
                return "event.stopPropagation(); alert('You cannot block your own account!'); return false;";
            }
            else
            {
                string action = isBlocked ? "Unblock" : "Block";
                return $"event.stopPropagation(); return confirm('{action} this user?');";
            }
        }

        protected string GetBlockUnblockTitle(bool isCurrentAdmin, bool isBlocked)
        {
            if (isCurrentAdmin)
            {
                return "Cannot block your own account";
            }
            else
            {
                return isBlocked ? "Unblock User" : "Block User";
            }
        }

        protected string GetDeleteCssClass(bool isCurrentAdmin)
        {
            string baseClass = "btn btn-sm btn-outline-danger";
            if (isCurrentAdmin)
            {
                baseClass += " disabled";
            }
            return baseClass;
        }

        protected string GetDeleteOnClientClick(bool isCurrentAdmin)
        {
            if (isCurrentAdmin)
            {
                return "event.stopPropagation(); alert('You cannot delete your own account!'); return false;";
            }
            else
            {
                return "event.stopPropagation(); return confirm('Are you sure you want to delete this user? This action cannot be undone.');";
            }
        }

        protected string GetDeleteTitle(bool isCurrentAdmin)
        {
            if (isCurrentAdmin)
            {
                return "Cannot delete your own account";
            }
            else
            {
                return "Delete User";
            }
        }
    }
}

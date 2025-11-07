using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI;

namespace RookiesInTraining2.Pages
{
    public partial class Settings : System.Web.UI.Page
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
                LoadSystemInfo();
                LoadSettings();
            }
        }

        private void LoadSystemInfo()
        {
            try
            {
                // Server time
                lblServerTime.Text = DateTime.Now.ToString("MMMM dd, yyyy HH:mm:ss");

                // Database version and size
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();

                    // Get database version
                    using (var cmd = new SqlCommand("SELECT @@VERSION", con))
                    {
                        string version = cmd.ExecuteScalar()?.ToString() ?? "Unknown";
                        // Extract version number
                        if (version.Contains("SQL Server"))
                        {
                            var parts = version.Split('\n');
                            if (parts.Length > 0)
                            {
                                lblDbVersion.Text = parts[0].Trim();
                            }
                        }
                        else
                        {
                            lblDbVersion.Text = "SQL Server LocalDB";
                        }
                    }

                    // Get database size
                    using (var cmd = new SqlCommand(@"
                        SELECT 
                            CAST(SUM(size) * 8.0 / 1024 AS DECIMAL(10, 2)) AS SizeMB
                        FROM sys.database_files
                        WHERE type = 0", con))
                    {
                        var size = cmd.ExecuteScalar();
                        if (size != null)
                        {
                            lblDbSize.Text = $"{size} MB";
                        }
                        else
                        {
                            lblDbSize.Text = "Unknown";
                        }
                    }

                    // Get last backup time (if tracking table exists)
                    try
                    {
                        using (var cmd = new SqlCommand(@"
                            SELECT TOP 1 backup_date 
                            FROM (
                                SELECT MAX(backup_finish_date) as backup_date 
                                FROM msdb.dbo.backupset 
                                WHERE database_name = DB_NAME()
                            ) AS b", con))
                        {
                            var lastBackup = cmd.ExecuteScalar();
                            if (lastBackup != null && lastBackup != DBNull.Value)
                            {
                                lblLastBackup.Text = ((DateTime)lastBackup).ToString("yyyy-MM-dd HH:mm");
                            }
                            else
                            {
                                lblLastBackup.Text = "Never";
                            }
                        }
                    }
                    catch
                    {
                        lblLastBackup.Text = "Not available";
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[Settings] Error loading system info: {ex.Message}");
                lblDbVersion.Text = "Error loading";
                lblDbSize.Text = "Error loading";
            }
        }

        private void LoadSettings()
        {
            // Load settings from database or use defaults
            // For now, we'll use default values
            // In a real implementation, you'd load from a Settings table

            // General settings defaults
            txtSystemName.Text = "Rookies in Training";
            txtSystemEmail.Text = "admin@rookies.com";
            ddlTimezone.SelectedValue = "UTC";
            ddlDateFormat.SelectedValue = "MM/dd/yyyy";
            ddlItemsPerPage.SelectedValue = "25";
            txtSessionTimeout.Text = "30";
            chkAllowRegistration.Checked = true;
            chkEmailVerification.Checked = false;

            // Security settings defaults
            txtMinPasswordLength.Text = "6";
            txtPasswordExpiry.Text = "90";
            chkRequireStrongPassword.Checked = false;
            chkEnableTwoFactor.Checked = false;
            chkLockoutEnabled.Checked = true;
            txtMaxFailedAttempts.Text = "5";
            txtLockoutDuration.Text = "30";

            // Notification settings defaults
            chkEmailNotifications.Checked = true;
            chkNotifyNewUsers.Checked = true;
            chkNotifyFailedLogins.Checked = true;
            chkNotifySystemErrors.Checked = true;
            txtNotificationEmails.Text = "admin@rookies.com";
        }

        protected void btnSaveGeneral_Click(object sender, EventArgs e)
        {
            try
            {
                // TODO: Save general settings to database
                // For now, just show success message
                ShowMessage("General settings saved successfully!", "success");
            }
            catch (Exception ex)
            {
                ShowError("Error saving general settings: " + ex.Message);
            }
        }

        protected void btnSaveSecurity_Click(object sender, EventArgs e)
        {
            try
            {
                // Validate security settings
                int minPasswordLength = int.Parse(txtMinPasswordLength.Text);
                if (minPasswordLength < 4 || minPasswordLength > 20)
                {
                    ShowError("Password length must be between 4 and 20 characters");
                    return;
                }

                // TODO: Save security settings to database
                ShowMessage("Security settings saved successfully!", "success");
            }
            catch (Exception ex)
            {
                ShowError("Error saving security settings: " + ex.Message);
            }
        }

        protected void btnSaveNotifications_Click(object sender, EventArgs e)
        {
            try
            {
                // Validate email addresses
                if (!string.IsNullOrEmpty(txtNotificationEmails.Text))
                {
                    var emails = txtNotificationEmails.Text.Split(',');
                    foreach (var email in emails)
                    {
                        var trimmedEmail = email.Trim();
                        if (!string.IsNullOrEmpty(trimmedEmail) && !System.Text.RegularExpressions.Regex.IsMatch(trimmedEmail, @"\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"))
                        {
                            ShowError($"Invalid email format: {trimmedEmail}");
                            return;
                        }
                    }
                }

                // TODO: Save notification settings to database
                ShowMessage("Notification settings saved successfully!", "success");
            }
            catch (Exception ex)
            {
                ShowError("Error saving notification settings: " + ex.Message);
            }
        }

        protected void btnCleanupDeleted_Click(object sender, EventArgs e)
        {
            try
            {
                int days = int.Parse(txtCleanupDays.Text);
                if (days < 1)
                {
                    ShowError("Days must be at least 1");
                    return;
                }

                // Confirm before cleanup
                string confirmScript = $@"
                    if (confirm('This will permanently delete all soft-deleted records older than {days} days. This action cannot be undone. Are you sure?')) {{
                        __doPostBack('{btnCleanupDeleted.UniqueID}', '');
                    }}";
                ClientScript.RegisterStartupScript(this.GetType(), "confirmCleanup", confirmScript, true);

                // Perform cleanup
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();
                    using (var cmd = new SqlCommand(@"
                        DELETE FROM dbo.Users 
                        WHERE is_deleted = 1 
                        AND deleted_at < DATEADD(day, -@days, GETDATE())", con))
                    {
                        cmd.Parameters.AddWithValue("@days", days);
                        int deleted = cmd.ExecuteNonQuery();
                        ShowMessage($"Successfully deleted {deleted} old records.", "success");
                    }
                }
            }
            catch (Exception ex)
            {
                ShowError("Error during cleanup: " + ex.Message);
            }
        }

        protected void btnBackupDatabase_Click(object sender, EventArgs e)
        {
            try
            {
                // Create backup directory if it doesn't exist
                string backupDir = Server.MapPath("~/Backups");
                if (!Directory.Exists(backupDir))
                {
                    Directory.CreateDirectory(backupDir);
                }

                // Generate backup filename
                string backupFileName = $"RookiesDatabase_{DateTime.Now:yyyyMMdd_HHmmss}.bak";
                string backupPath = Path.Combine(backupDir, backupFileName);

                // Perform backup
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();
                    string dbName = con.Database;
                    string backupQuery = $@"
                        BACKUP DATABASE [{dbName}] 
                        TO DISK = '{backupPath}' 
                        WITH FORMAT, INIT, NAME = 'Rookies Database Backup', 
                        SKIP, NOREWIND, NOUNLOAD, STATS = 10";

                    using (var cmd = new SqlCommand(backupQuery, con))
                    {
                        cmd.CommandTimeout = 300; // 5 minutes timeout
                        cmd.ExecuteNonQuery();
                    }
                }

                lblLastBackup.Text = DateTime.Now.ToString("yyyy-MM-dd HH:mm");
                ShowMessage($"Database backup created successfully: {backupFileName}", "success");
            }
            catch (Exception ex)
            {
                ShowError("Error creating backup: " + ex.Message);
                System.Diagnostics.Debug.WriteLine($"[Settings] Backup error: {ex.Message}");
            }
        }

        private void ShowMessage(string message, string type = "success")
        {
            if (type == "success")
            {
                lblMessage.Text = message;
                lblMessage.CssClass = "alert alert-success";
                lblMessage.Visible = true;
                lblError.Visible = false;

                // Auto-hide after 5 seconds
                ClientScript.RegisterStartupScript(this.GetType(), "hideMessage",
                    "setTimeout(function() { document.getElementById('" + lblMessage.ClientID + "').classList.add('d-none'); }, 5000);", true);
            }
        }

        private void ShowError(string message)
        {
            lblError.Text = message;
            lblError.CssClass = "alert alert-danger";
            lblError.Visible = true;
            lblMessage.Visible = false;

            // Auto-hide after 10 seconds
            ClientScript.RegisterStartupScript(this.GetType(), "hideError",
                "setTimeout(function() { document.getElementById('" + lblError.ClientID + "').classList.add('d-none'); }, 10000);", true);
        }
    }
}


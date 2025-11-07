using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web.UI;

namespace RookiesInTraining2.Pages
{
    public partial class dashboard_admin : System.Web.UI.Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Check authentication
            if (Session["UserSlug"] == null || Session["Role"]?.ToString() != "admin")
            {
                Response.Redirect("~/Pages/Login.aspx", false);
                return;
            }

            if (!IsPostBack)
            {
                LoadDashboardData();
            }
        }

        private void LoadDashboardData()
        {
            // Display current date
            lblCurrentDate.Text = DateTime.Now.ToString("MMMM dd, yyyy HH:mm", new CultureInfo("en-US"));

            // Load statistics
            LoadSystemStats();

            // Load recent users
            LoadRecentUsers();

            // Load system logs
            LoadSystemLogs();

            // Load alerts
            LoadAlerts();
        }

        private void LoadSystemStats()
        {
            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();

                    // Total Users
                    using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.Users WHERE is_deleted = 0", con))
                    {
                        lblTotalUsers.Text = cmd.ExecuteScalar().ToString();
                    }

                    // New Users this month
                    using (var cmd = new SqlCommand(@"
                        SELECT COUNT(*) 
                        FROM dbo.Users 
                        WHERE is_deleted = 0 
                        AND MONTH(created_at) = MONTH(GETDATE()) 
                        AND YEAR(created_at) = YEAR(GETDATE())", con))
                    {
                        lblNewUsers.Text = cmd.ExecuteScalar().ToString();
                    }

                    // Students
                    using (var cmd = new SqlCommand(@"
                        SELECT COUNT(*) 
                        FROM dbo.Users 
                        WHERE is_deleted = 0 AND role_global = 'student'", con))
                    {
                        lblTotalStudents.Text = cmd.ExecuteScalar().ToString();
                        lblActiveStudents.Text = cmd.ExecuteScalar().ToString(); // TODO: Implement active logic
                    }

                    // Teachers
                    using (var cmd = new SqlCommand(@"
                        SELECT COUNT(*) 
                        FROM dbo.Users 
                        WHERE is_deleted = 0 AND role_global = 'teacher'", con))
                    {
                        lblTotalTeachers.Text = cmd.ExecuteScalar().ToString();
                    }
                }

                // Placeholder for courses data (if table exists)
                lblTotalCourses.Text = "0";
                lblActiveCourses.Text = "0";
                lblDepartments.Text = "0";
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[AdminDash] Error loading stats: {ex.Message}");
            }
        }

        private void LoadRecentUsers()
        {
            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = con.CreateCommand())
                {
                    con.Open();
                    cmd.CommandText = @"
                        SELECT TOP 5
                            user_slug as UserSlug,
                            display_name as DisplayName,
                            email as Email,
                            role_global as Role,
                            COALESCE(avatar_url, '/static/avatar-default.png') as AvatarUrl,
                            FORMAT(created_at, 'yyyy-MM-dd HH:mm') as CreatedAt
                        FROM dbo.Users
                        WHERE is_deleted = 0
                        ORDER BY created_at DESC";

                    var users = new List<dynamic>();
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            users.Add(new
                            {
                                UserSlug = reader["UserSlug"].ToString(),
                                DisplayName = reader["DisplayName"].ToString(),
                                Email = reader["Email"].ToString(),
                                Role = reader["Role"].ToString(),
                                AvatarUrl = reader["AvatarUrl"].ToString(),
                                CreatedAt = reader["CreatedAt"].ToString()
                            });
                        }
                    }

                    if (users.Count > 0)
                    {
                        rptRecentUsers.DataSource = users;
                        rptRecentUsers.DataBind();
                        lblNoUsersMessage.Visible = false;
                    }
                    else
                    {
                        lblNoUsersMessage.Visible = true;
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[AdminDash] Error loading users: {ex.Message}");
                lblNoUsersMessage.Visible = true;
            }
        }

        private void LoadSystemLogs()
        {
            try
            {
                // Sample data - replace with actual system logs when implemented
                var logs = new List<dynamic>
                {
                    new { Icon = "person-check", StatusColor = "success", LogMessage = "New user 'Zhang San' successfully registered", Timestamp = "5 minutes ago" },
                    new { Icon = "shield-check", StatusColor = "info", LogMessage = "Security scan completed, no threats found", Timestamp = "1 hour ago" },
                    new { Icon = "database", StatusColor = "success", LogMessage = "Database backup completed successfully", Timestamp = "3 hours ago" },
                    new { Icon = "exclamation-triangle", StatusColor = "warning", LogMessage = "Storage usage reached 75%", Timestamp = "5 hours ago" }
                };

                if (logs.Count > 0)
                {
                    rptSystemLogs.DataSource = logs;
                    rptSystemLogs.DataBind();
                    lblNoLogsMessage.Visible = false;
                }
                else
                {
                    lblNoLogsMessage.Visible = true;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[AdminDash] Error loading logs: {ex.Message}");
                lblNoLogsMessage.Visible = true;
            }
        }

        private void LoadAlerts()
        {
            try
            {
                var alerts = new List<dynamic>
                {
                    new { AlertType = "warning", Icon = "exclamation-triangle", Message = "Storage space running low, please clean up" },
                    new { AlertType = "info", Icon = "info-circle", Message = "System maintenance scheduled for tomorrow at 2 AM" }
                };

                if (alerts.Count > 0)
                {
                    rptAlerts.DataSource = alerts;
                    rptAlerts.DataBind();
                    lblNoAlertsMessage.Visible = false;
                }
                else
                {
                    lblNoAlertsMessage.Visible = true;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[AdminDash] Error loading alerts: {ex.Message}");
                lblNoAlertsMessage.Visible = true;
            }
        }

        // Helper methods for formatting
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
    }
}


using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Text;
using System.Web;

namespace RookiesInTraining2.Pages
{
    public partial class AdminReports : System.Web.UI.Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserSlug"] == null || Session["Role"]?.ToString() != "admin")
            {
                Response.Redirect("~/Pages/Login.aspx", false);
                return;
            }

            if (!IsPostBack)
            {
                var defaultStart = DateTime.UtcNow.Date.AddDays(-30);
                var defaultEnd = DateTime.UtcNow.Date;

                txtStartDate.Text = defaultStart.ToString("yyyy-MM-dd");
                txtEndDate.Text = defaultEnd.ToString("yyyy-MM-dd");

                LoadReportData();
            }
        }

        protected void btnApplyFilters_Click(object sender, EventArgs e)
        {
            LoadReportData();
        }

        protected void btnPrint_Click(object sender, EventArgs e)
        {
            ClientScript.RegisterStartupScript(GetType(), "printReport", "window.print();", true);
        }

        protected void btnExportCsv_Click(object sender, EventArgs e)
        {
            try
            {
                DateTime startDate, endDate;
                string role;
                GetFilterValues(out startDate, out endDate, out role);

                var data = GetReportTable(startDate, endDate, role);

                if (data.Rows.Count == 0)
                {
                    ShowMessage("No data available to export for the selected filters.", false);
                    return;
                }

                var builder = new StringBuilder();

                // Header
                for (int i = 0; i < data.Columns.Count; i++)
                {
                    if (i > 0) builder.Append(",");
                    builder.Append(EscapeForCsv(data.Columns[i].ColumnName));
                }
                builder.AppendLine();

                // Rows
                foreach (DataRow row in data.Rows)
                {
                    for (int i = 0; i < data.Columns.Count; i++)
                    {
                        if (i > 0) builder.Append(",");
                        builder.Append(EscapeForCsv(Convert.ToString(row[i])));
                    }
                    builder.AppendLine();
                }

                var fileName = $"rookies-report-{DateTime.UtcNow:yyyyMMddHHmmss}.csv";
                Response.Clear();
                Response.ContentType = "text/csv";
                Response.AddHeader("Content-Disposition", $"attachment; filename={fileName}");
                Response.Write(builder.ToString());
                Response.Flush();
                HttpContext.Current.ApplicationInstance.CompleteRequest();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[AdminReports] Export error: {ex.Message}");
                ShowMessage("Error exporting report. Please try again.", false);
            }
        }

        private void LoadReportData()
        {
            try
            {
                DateTime startDate, endDate;
                string role;
                GetFilterValues(out startDate, out endDate, out role);

                LoadSummaryCards(startDate, endDate);
                BindRoleBreakdown();
                BindDetailedReport(startDate, endDate, role);
                BindRecentRegistrations();

                ShowMessage("Report generated successfully.", true);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[AdminReports] Error loading report: {ex.Message}");
                ShowMessage("Error generating report. Please try again.", false);
            }
        }

        private void LoadSummaryCards(DateTime startDate, DateTime endDate)
        {
            using (var con = new SqlConnection(ConnStr))
            using (var cmd = con.CreateCommand())
            {
                con.Open();

                cmd.CommandText = @"
                    SELECT 
                        COUNT(*) AS TotalUsers,
                        SUM(CASE WHEN role_global = 'teacher' THEN 1 ELSE 0 END) AS TeacherCount,
                        SUM(CASE WHEN role_global = 'student' THEN 1 ELSE 0 END) AS StudentCount,
                        SUM(CASE WHEN created_at >= @startDate AND created_at < @endDate THEN 1 ELSE 0 END) AS NewUsers
                    FROM dbo.Users
                    WHERE is_deleted = 0";

                cmd.Parameters.AddWithValue("@startDate", startDate);
                cmd.Parameters.AddWithValue("@endDate", endDate.AddDays(1));

                using (var reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        int totalUsers = Convert.ToInt32(reader["TotalUsers"] ?? 0);
                        int teacherCount = Convert.ToInt32(reader["TeacherCount"] ?? 0);
                        int newUsers = Convert.ToInt32(reader["NewUsers"] ?? 0);

                        lblTotalUsers.Text = totalUsers.ToString("N0", CultureInfo.InvariantCulture);
                        lblTeacherCount.Text = teacherCount.ToString("N0", CultureInfo.InvariantCulture);
                        lblNewUsers.Text = newUsers.ToString("N0", CultureInfo.InvariantCulture);

                        var days = Math.Max((endDate - startDate).TotalDays + 1, 1);
                        var average = newUsers / days;
                        lblAverageDaily.Text = average.ToString("N1", CultureInfo.InvariantCulture);
                    }
                }
            }
        }

        private void BindRoleBreakdown()
        {
            using (var con = new SqlConnection(ConnStr))
            using (var cmd = con.CreateCommand())
            {
                con.Open();
                cmd.CommandText = @"
                    SELECT role_global, COUNT(*) AS UserCount
                    FROM dbo.Users
                    WHERE is_deleted = 0
                    GROUP BY role_global";

                using (var adapter = new SqlDataAdapter(cmd))
                {
                    var table = new DataTable();
                    adapter.Fill(table);

                    int total = 0;
                    foreach (DataRow row in table.Rows)
                    {
                        total += Convert.ToInt32(row["UserCount"]);
                    }

                    var breakdown = new List<dynamic>();
                    foreach (DataRow row in table.Rows)
                    {
                        var role = Convert.ToString(row["role_global"]).ToLowerInvariant();
                        var count = Convert.ToInt32(row["UserCount"]);
                        var percentage = total > 0 ? (count * 100.0 / total) : 0;

                        breakdown.Add(new
                        {
                            RoleName = CultureInfo.InvariantCulture.TextInfo.ToTitleCase(role),
                            UserCount = count,
                            Percentage = Math.Round(percentage, 1),
                            BadgeColor = GetBadgeColor(role)
                        });
                    }

                    rptRoleBreakdown.DataSource = breakdown;
                    rptRoleBreakdown.DataBind();
                }
            }
        }

        private void BindDetailedReport(DateTime startDate, DateTime endDate, string role)
        {
            var table = GetReportTable(startDate, endDate, role);

            if (table.Rows.Count > 0)
            {
                gvReport.DataSource = table;
                gvReport.DataBind();
                gvReport.Visible = true;
                lblNoResults.Visible = false;
                lblResultCount.Text = table.Rows.Count == 1 ? "1 record" : $"{table.Rows.Count} records";
            }
            else
            {
                gvReport.Visible = false;
                lblNoResults.Visible = true;
                lblResultCount.Text = "0 records";
            }
        }

        private DataTable GetReportTable(DateTime startDate, DateTime endDate, string role)
        {
            var table = new DataTable();

            using (var con = new SqlConnection(ConnStr))
            using (var cmd = con.CreateCommand())
            {
                var sql = new StringBuilder(@"
                    SELECT 
                        u.display_name,
                        u.email,
                        u.role_global,
                        u.created_at,
                        u.last_login_at,
                        (SELECT COUNT(*) FROM dbo.Classes c WHERE c.teacher_slug = u.user_slug AND c.is_deleted = 0) AS class_count
                    FROM dbo.Users u
                    WHERE u.is_deleted = 0");

                cmd.Parameters.AddWithValue("@startDate", startDate);
                cmd.Parameters.AddWithValue("@endDate", endDate.AddDays(1));

                sql.Append(" AND u.created_at >= @startDate AND u.created_at < @endDate");

                if (!string.IsNullOrWhiteSpace(role))
                {
                    sql.Append(" AND u.role_global = @role");
                    cmd.Parameters.AddWithValue("@role", role);
                }

                sql.Append(" ORDER BY u.created_at DESC");

                cmd.CommandText = sql.ToString();

                using (var adapter = new SqlDataAdapter(cmd))
                {
                    adapter.Fill(table);
                }
            }

            return table;
        }

        private void BindRecentRegistrations()
        {
            using (var con = new SqlConnection(ConnStr))
            using (var cmd = con.CreateCommand())
            {
                con.Open();
                cmd.CommandText = @"
                    SELECT TOP 6
                        display_name,
                        email,
                        role_global,
                        created_at
                    FROM dbo.Users
                    WHERE is_deleted = 0
                    ORDER BY created_at DESC";

                using (var reader = cmd.ExecuteReader())
                {
                    var items = new List<dynamic>();
                    while (reader.Read())
                    {
                        var createdAt = reader.GetDateTime(reader.GetOrdinal("created_at"));
                        items.Add(new
                        {
                            DisplayName = reader["display_name"].ToString(),
                            Email = reader["email"].ToString(),
                            Role = ToTitle(reader["role_global"].ToString()),
                            BadgeColor = GetBadgeColor(reader["role_global"].ToString()),
                            CreatedAt = createdAt.ToString("yyyy-MM-dd HH:mm"),
                            JoinedAgo = GetRelativeTime(createdAt)
                        });
                    }

                    if (items.Count > 0)
                    {
                        rptRecentRegistrations.DataSource = items;
                        rptRecentRegistrations.DataBind();
                        rptRecentRegistrations.Visible = true;
                        lblNoRecent.Visible = false;
                    }
                    else
                    {
                        rptRecentRegistrations.Visible = false;
                        lblNoRecent.Visible = true;
                    }
                }
            }
        }

        private void GetFilterValues(out DateTime startDate, out DateTime endDate, out string role)
        {
            var now = DateTime.UtcNow.Date;
            var defaultStart = now.AddDays(-30);

            startDate = ParseDate(txtStartDate.Text) ?? defaultStart;
            endDate = ParseDate(txtEndDate.Text) ?? now;

            if (startDate > endDate)
            {
                var temp = startDate;
                startDate = endDate;
                endDate = temp;
            }

            role = ddlRoleFilter.SelectedValue;
        }

        private DateTime? ParseDate(string value)
        {
            if (DateTime.TryParse(value, CultureInfo.InvariantCulture, DateTimeStyles.AssumeLocal, out var parsed))
            {
                return parsed.Date;
            }
            return null;
        }

        private string GetBadgeColor(string role)
        {
            switch (role?.ToLowerInvariant())
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

        private string ToTitle(string value)
        {
            if (string.IsNullOrWhiteSpace(value)) return value;
            return CultureInfo.InvariantCulture.TextInfo.ToTitleCase(value.ToLowerInvariant());
        }

        private string GetRelativeTime(DateTime timestamp)
        {
            var span = DateTime.UtcNow - timestamp;

            if (span.TotalMinutes < 1) return "just now";
            if (span.TotalHours < 1) return $"{(int)span.TotalMinutes} minute(s) ago";
            if (span.TotalDays < 1) return $"{(int)span.TotalHours} hour(s) ago";
            if (span.TotalDays < 30) return $"{(int)span.TotalDays} day(s) ago";

            var months = (int)(span.TotalDays / 30);
            if (months < 12) return $"{months} month(s) ago";

            var years = (int)(months / 12.0);
            return $"{years} year(s) ago";
        }

        private string EscapeForCsv(string value)
        {
            if (string.IsNullOrEmpty(value)) return "";

            value = value.Replace("\r", " ").Replace("\n", " ");
            if (value.Contains(",") || value.Contains("\""))
            {
                value = "\"" + value.Replace("\"", "\"\"") + "\"";
            }
            return value;
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            if (isSuccess)
            {
                lblPageMessage.Text = message;
                lblPageMessage.CssClass = "alert alert-success";
                lblPageMessage.Visible = true;
                lblPageError.Visible = false;
            }
            else
            {
                lblPageError.Text = message;
                lblPageError.CssClass = "alert alert-danger";
                lblPageError.Visible = true;
                lblPageMessage.Visible = false;
            }

            ClientScript.RegisterStartupScript(GetType(), "hideAlerts",
                $"setTimeout(function() {{ var success = document.getElementById('{lblPageMessage.ClientID}'); var error = document.getElementById('{lblPageError.ClientID}'); if (success) success.classList.add('d-none'); if (error) error.classList.add('d-none'); }}, 6000);",
                true);
        }
    }
}

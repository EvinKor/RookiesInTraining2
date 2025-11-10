using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Text;
using System.Web.UI;

namespace RookiesInTraining2.Pages.admin
{
    public partial class ActivityLog : System.Web.UI.Page
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

                LoadActivityLogs();
            }
        }

        protected void btnApplyFilters_Click(object sender, EventArgs e)
        {
            LoadActivityLogs();
        }

        private void LoadActivityLogs()
        {
            try
            {
                string actionType = ddlActionType.SelectedValue;
                string adminSearch = txtAdminSearch.Text.Trim();
                DateTime? startDate = ParseDate(txtStartDate.Text);
                DateTime? endDate = ParseDate(txtEndDate.Text);

                var table = GetActivityLogsTable(actionType, adminSearch, startDate, endDate);

                if (table.Rows.Count > 0)
                {
                    gvActivityLogs.DataSource = table;
                    gvActivityLogs.DataBind();
                    gvActivityLogs.Visible = true;
                    lblNoLogs.Visible = false;
                    lblLogCount.Text = $"{table.Rows.Count} log(s) found";
                }
                else
                {
                    gvActivityLogs.Visible = false;
                    lblNoLogs.Visible = true;
                    lblLogCount.Text = "0 logs found";
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[ActivityLog] Error loading logs: {ex.Message}");
                ShowMessage("Error loading activity logs. Please try again.", false);
            }
        }

        private DataTable GetActivityLogsTable(string actionType, string adminSearch, DateTime? startDate, DateTime? endDate)
        {
            var table = new DataTable();

            using (var con = new SqlConnection(ConnStr))
            using (var cmd = con.CreateCommand())
            {
                var sql = new StringBuilder(@"
                    SELECT 
                        al.log_id,
                        al.action_type as ActionType,
                        ISNULL(u.display_name, u.full_name) as AdminName,
                        al.admin_slug,
                        ISNULL(al.target_type, 'N/A') as TargetType,
                        ISNULL(al.target_slug, '') as TargetSlug,
                        ISNULL(al.details, '') as Details,
                        al.created_at as CreatedAt
                    FROM dbo.AdminLogs al
                    LEFT JOIN dbo.Users u ON al.admin_slug = u.user_slug
                    WHERE 1=1");

                if (!string.IsNullOrWhiteSpace(actionType))
                {
                    sql.Append(" AND al.action_type = @actionType");
                    cmd.Parameters.AddWithValue("@actionType", actionType);
                }

                if (!string.IsNullOrWhiteSpace(adminSearch))
                {
                    sql.Append(" AND (LOWER(u.full_name) LIKE @adminSearch OR LOWER(ISNULL(u.display_name, '')) LIKE @adminSearch)");
                    cmd.Parameters.AddWithValue("@adminSearch", "%" + adminSearch.ToLower() + "%");
                }

                if (startDate.HasValue)
                {
                    sql.Append(" AND al.created_at >= @startDate");
                    cmd.Parameters.AddWithValue("@startDate", startDate.Value);
                }

                if (endDate.HasValue)
                {
                    sql.Append(" AND al.created_at < @endDate");
                    cmd.Parameters.AddWithValue("@endDate", endDate.Value.AddDays(1));
                }

                sql.Append(" ORDER BY al.created_at DESC");

                cmd.CommandText = sql.ToString();

                using (var adapter = new SqlDataAdapter(cmd))
                {
                    adapter.Fill(table);
                }
            }

            return table;
        }

        protected void gvActivityLogs_PageIndexChanging(object sender, System.Web.UI.WebControls.GridViewPageEventArgs e)
        {
            gvActivityLogs.PageIndex = e.NewPageIndex;
            LoadActivityLogs();
        }

        protected void gvActivityLogs_Sorting(object sender, System.Web.UI.WebControls.GridViewSortEventArgs e)
        {
            LoadActivityLogs();
        }

        protected string FormatActionType(string actionType)
        {
            if (string.IsNullOrWhiteSpace(actionType)) return "Unknown";
            return CultureInfo.InvariantCulture.TextInfo.ToTitleCase(actionType.Replace("_", " ").ToLowerInvariant());
        }

        protected string GetActionIcon(string actionType)
        {
            if (string.IsNullOrWhiteSpace(actionType)) return "info-circle";

            string lower = actionType.ToLowerInvariant();
            if (lower.Contains("delete")) return "trash";
            if (lower.Contains("create")) return "plus-circle";
            if (lower.Contains("block")) return "lock";
            if (lower.Contains("unblock")) return "unlock";
            if (lower.Contains("edit")) return "pencil";
            if (lower.Contains("change")) return "arrow-repeat";
            return "info-circle";
        }

        protected string GetActionColor(string actionType)
        {
            if (string.IsNullOrWhiteSpace(actionType)) return "info";

            string lower = actionType.ToLowerInvariant();
            if (lower.Contains("delete")) return "danger";
            if (lower.Contains("create")) return "success";
            if (lower.Contains("block")) return "warning";
            if (lower.Contains("unblock")) return "success";
            if (lower.Contains("edit")) return "primary";
            if (lower.Contains("change")) return "info";
            return "info";
        }

        private DateTime? ParseDate(string value)
        {
            if (DateTime.TryParse(value, CultureInfo.InvariantCulture, DateTimeStyles.AssumeLocal, out var parsed))
            {
                return parsed.Date;
            }
            return null;
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


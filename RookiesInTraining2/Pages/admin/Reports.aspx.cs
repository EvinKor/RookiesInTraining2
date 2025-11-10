using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
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
                ddlTimePeriod.SelectedValue = "30";

                LoadReportData();
            }
        }

        protected void ddlTimePeriod_SelectedIndexChanged(object sender, EventArgs e)
        {
            var now = DateTime.UtcNow.Date;
            int days = int.Parse(ddlTimePeriod.SelectedValue);
            
            if (days > 0)
            {
                txtStartDate.Text = now.AddDays(-days).ToString("yyyy-MM-dd");
                txtEndDate.Text = now.ToString("yyyy-MM-dd");
            }
            
            LoadReportData();
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
                string searchTerm, statusFilter;
                GetFilterValues(out startDate, out endDate, out searchTerm, out statusFilter);

                var table = GetStudentsTable(startDate, endDate, searchTerm, statusFilter);

                if (table.Rows.Count == 0)
                {
                    ShowMessage("No data available to export for the selected filters.", false);
                    return;
                }

                var builder = new StringBuilder();

                // Header
                for (int i = 0; i < table.Columns.Count; i++)
                {
                    if (i > 0) builder.Append(",");
                    builder.Append(EscapeForCsv(table.Columns[i].ColumnName));
                }
                builder.AppendLine();

                // Rows
                foreach (DataRow row in table.Rows)
                {
                    for (int i = 0; i < table.Columns.Count; i++)
                    {
                        if (i > 0) builder.Append(",");
                        builder.Append(EscapeForCsv(Convert.ToString(row[i])));
                    }
                    builder.AppendLine();
                }

                var fileName = $"students-report-{DateTime.UtcNow:yyyyMMddHHmmss}.csv";
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
                string searchTerm, statusFilter;
                GetFilterValues(out startDate, out endDate, out searchTerm, out statusFilter);

                LoadSummaryCards();
                LoadStudentMetrics(startDate, endDate);
                LoadTeacherMetrics(startDate, endDate);
                LoadClassMetrics();
                LoadStudentsData(startDate, endDate, searchTerm, statusFilter);
                LoadTeachersData(startDate, endDate, searchTerm);
                LoadClassesData(searchTerm);

                ShowMessage("Report generated successfully.", true);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[AdminReports] Error loading report: {ex.Message}");
                ShowMessage("Error generating report. Please try again.", false);
            }
        }

        private void LoadSummaryCards()
        {
            using (var con = new SqlConnection(ConnStr))
            using (var cmd = con.CreateCommand())
            {
                con.Open();

                // Total Students
                cmd.CommandText = "SELECT COUNT(*) FROM Users WHERE role = 'student' AND is_deleted = 0";
                lblTotalStudents.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString("N0");

                // Active Students (logged in last 30 days or enrolled in active classes)
                cmd.CommandText = @"
                    SELECT COUNT(DISTINCT u.user_slug)
                    FROM Users u
                    INNER JOIN Enrollments e ON u.user_slug = e.user_slug
                    INNER JOIN Classes c ON e.class_slug = c.class_slug
                    WHERE u.role = 'student' 
                      AND u.is_deleted = 0
                      AND e.is_deleted = 0
                      AND c.is_deleted = 0
                      AND e.joined_at >= DATEADD(day, -30, SYSUTCDATETIME())";
                lblActiveStudents.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString("N0");

                // Total Teachers
                cmd.CommandText = "SELECT COUNT(*) FROM Users WHERE role = 'teacher' AND is_deleted = 0";
                lblTotalTeachers.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString("N0");

                // Active Teachers (have created classes or have active classes)
                cmd.CommandText = @"
                    SELECT COUNT(DISTINCT u.user_slug)
                    FROM Users u
                    INNER JOIN Classes c ON u.user_slug = c.teacher_slug
                    WHERE u.role = 'teacher' 
                      AND u.is_deleted = 0
                      AND c.is_deleted = 0
                      AND c.created_at >= DATEADD(day, -30, SYSUTCDATETIME())";
                lblActiveTeachers.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString("N0");

                // Total Classes
                cmd.CommandText = "SELECT COUNT(*) FROM Classes WHERE is_deleted = 0";
                lblTotalClasses.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString("N0");

                // Active Classes (with at least one student)
                cmd.CommandText = @"
                    SELECT COUNT(DISTINCT c.class_slug)
                    FROM Classes c
                    INNER JOIN Enrollments e ON c.class_slug = e.class_slug
                    WHERE c.is_deleted = 0 
                      AND e.is_deleted = 0
                      AND e.role_in_class = 'student'";
                lblActiveClasses.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString("N0");
            }
        }

        private void LoadStudentMetrics(DateTime startDate, DateTime endDate)
        {
            using (var con = new SqlConnection(ConnStr))
            using (var cmd = con.CreateCommand())
            {
                con.Open();

                // New Students (24h)
                cmd.CommandText = @"
                    SELECT COUNT(*) FROM Users 
                    WHERE role = 'student' AND is_deleted = 0 
                      AND created_at >= DATEADD(day, -1, SYSUTCDATETIME())";
                lblNewStudents24h.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString("N0");

                // New Students (Week)
                cmd.CommandText = @"
                    SELECT COUNT(*) FROM Users 
                    WHERE role = 'student' AND is_deleted = 0 
                      AND created_at >= DATEADD(day, -7, SYSUTCDATETIME())";
                lblNewStudentsWeek.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString("N0");

                // New Students (Month)
                cmd.CommandText = @"
                    SELECT COUNT(*) FROM Users 
                    WHERE role = 'student' AND is_deleted = 0 
                      AND created_at >= DATEADD(day, -30, SYSUTCDATETIME())";
                lblNewStudentsMonth.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString("N0");

                // Blocked Students
                cmd.CommandText = @"
                    SELECT COUNT(*) FROM Users 
                    WHERE role = 'student' AND is_deleted = 0 AND ISNULL(is_blocked, 0) = 1";
                lblBlockedStudents.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString("N0");

                // Student Progress
                LoadStudentProgress(con);
            }
        }

        private void LoadStudentProgress(SqlConnection con)
        {
            using (var cmd = con.CreateCommand())
            {
                // Level 1 Complete
                cmd.CommandText = @"
                    SELECT COUNT(DISTINCT u.user_slug)
                    FROM Users u
                    INNER JOIN Enrollments e ON u.user_slug = e.user_slug
                    INNER JOIN Levels l ON e.class_slug = l.class_slug
                    INNER JOIN Attempts a ON u.user_slug = a.user_slug AND l.quiz_slug = a.quiz_slug
                    WHERE u.role = 'student' AND u.is_deleted = 0
                      AND l.level_number = 1
                      AND l.is_deleted = 0
                      AND a.is_deleted = 0
                      AND a.passed = 1";
                var level1Result = cmd.ExecuteScalar();
                lblLevel1Complete.Text = (level1Result != null && level1Result != DBNull.Value) ? Convert.ToInt32(level1Result).ToString("N0") : "0";

                // Level 2 Complete
                cmd.CommandText = @"
                    SELECT COUNT(DISTINCT u.user_slug)
                    FROM Users u
                    INNER JOIN Enrollments e ON u.user_slug = e.user_slug
                    INNER JOIN Levels l ON e.class_slug = l.class_slug
                    INNER JOIN Attempts a ON u.user_slug = a.user_slug AND l.quiz_slug = a.quiz_slug
                    WHERE u.role = 'student' AND u.is_deleted = 0
                      AND l.level_number = 2
                      AND l.is_deleted = 0
                      AND a.is_deleted = 0
                      AND a.passed = 1";
                var level2Result = cmd.ExecuteScalar();
                lblLevel2Complete.Text = (level2Result != null && level2Result != DBNull.Value) ? Convert.ToInt32(level2Result).ToString("N0") : "0";

                // Level 3 Complete
                cmd.CommandText = @"
                    SELECT COUNT(DISTINCT u.user_slug)
                    FROM Users u
                    INNER JOIN Enrollments e ON u.user_slug = e.user_slug
                    INNER JOIN Levels l ON e.class_slug = l.class_slug
                    INNER JOIN Attempts a ON u.user_slug = a.user_slug AND l.quiz_slug = a.quiz_slug
                    WHERE u.role = 'student' AND u.is_deleted = 0
                      AND l.level_number = 3
                      AND l.is_deleted = 0
                      AND a.is_deleted = 0
                      AND a.passed = 1";
                var level3Result = cmd.ExecuteScalar();
                lblLevel3Complete.Text = (level3Result != null && level3Result != DBNull.Value) ? Convert.ToInt32(level3Result).ToString("N0") : "0";

                // Average Progress (simplified - based on passed quizzes)
                cmd.CommandText = @"
                    SELECT 
                        COUNT(DISTINCT u.user_slug) as total_students,
                        COUNT(DISTINCT CASE WHEN a.passed = 1 THEN u.user_slug END) as completed_students
                    FROM Users u
                    LEFT JOIN Enrollments e ON u.user_slug = e.user_slug AND e.is_deleted = 0
                    LEFT JOIN Attempts a ON u.user_slug = a.user_slug AND a.is_deleted = 0
                    WHERE u.role = 'student' AND u.is_deleted = 0";
                
                using (var reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        int total = Convert.ToInt32(reader["total_students"] ?? 0);
                        int completed = Convert.ToInt32(reader["completed_students"] ?? 0);
                        double avgProgress = total > 0 ? (completed * 100.0 / total) : 0;
                        lblAvgProgress.Text = $"{avgProgress:F1}%";
                        lblFullProgress.Text = completed.ToString("N0");
                    }
                    else
                    {
                        lblAvgProgress.Text = "0%";
                        lblFullProgress.Text = "0";
                    }
                }
            }
        }

        private void LoadTeacherMetrics(DateTime startDate, DateTime endDate)
        {
            using (var con = new SqlConnection(ConnStr))
            using (var cmd = con.CreateCommand())
            {
                con.Open();

                // New Teachers (24h)
                cmd.CommandText = @"
                    SELECT COUNT(*) FROM Users 
                    WHERE role = 'teacher' AND is_deleted = 0 
                      AND created_at >= DATEADD(day, -1, SYSUTCDATETIME())";
                lblNewTeachers24h.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString("N0");

                // New Teachers (Week)
                cmd.CommandText = @"
                    SELECT COUNT(*) FROM Users 
                    WHERE role = 'teacher' AND is_deleted = 0 
                      AND created_at >= DATEADD(day, -7, SYSUTCDATETIME())";
                lblNewTeachersWeek.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString("N0");

                // New Teachers (Month)
                cmd.CommandText = @"
                    SELECT COUNT(*) FROM Users 
                    WHERE role = 'teacher' AND is_deleted = 0 
                      AND created_at >= DATEADD(day, -30, SYSUTCDATETIME())";
                lblNewTeachersMonth.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString("N0");

                // Total Classes Created
                cmd.CommandText = "SELECT COUNT(*) FROM Classes WHERE is_deleted = 0";
                lblTotalClassesCreated.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString("N0");
            }
        }

        private void LoadClassMetrics()
        {
            using (var con = new SqlConnection(ConnStr))
            using (var cmd = con.CreateCommand())
            {
                con.Open();

                // Inactive Classes
                cmd.CommandText = @"
                    SELECT COUNT(DISTINCT c.class_slug)
                    FROM Classes c
                    LEFT JOIN Enrollments e ON c.class_slug = e.class_slug AND e.is_deleted = 0 AND e.role_in_class = 'student'
                    WHERE c.is_deleted = 0
                      AND e.enrollment_slug IS NULL";
                lblInactiveClasses.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString("N0");

                // Average Students per Class
                cmd.CommandText = @"
                    SELECT 
                        AVG(CAST(student_count AS FLOAT)) as avg_students
                    FROM (
                        SELECT c.class_slug, COUNT(DISTINCT e.user_slug) as student_count
                        FROM Classes c
                        LEFT JOIN Enrollments e ON c.class_slug = e.class_slug AND e.is_deleted = 0 AND e.role_in_class = 'student'
                        WHERE c.is_deleted = 0
                        GROUP BY c.class_slug
                    ) as class_counts";
                var avgResult = cmd.ExecuteScalar();
                if (avgResult != null && avgResult != DBNull.Value)
                {
                    lblAvgStudentsPerClass.Text = Math.Round(Convert.ToDouble(avgResult), 1).ToString("N1");
                }
                else
                {
                    lblAvgStudentsPerClass.Text = "0";
                }

                // Most Popular Class
                cmd.CommandText = @"
                    SELECT TOP 1 c.class_name, COUNT(DISTINCT e.user_slug) as student_count
                    FROM Classes c
                    LEFT JOIN Enrollments e ON c.class_slug = e.class_slug AND e.is_deleted = 0 AND e.role_in_class = 'student'
                    WHERE c.is_deleted = 0
                    GROUP BY c.class_slug, c.class_name
                    ORDER BY student_count DESC";
                using (var reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        lblMostPopularClass.Text = reader["class_name"].ToString();
                    }
                    else
                    {
                        lblMostPopularClass.Text = "N/A";
                    }
                }
            }
        }

        private void LoadStudentsData(DateTime startDate, DateTime endDate, string searchTerm, string statusFilter)
        {
            var table = GetStudentsTable(startDate, endDate, searchTerm, statusFilter);

            if (table.Rows.Count > 0)
            {
                gvStudents.DataSource = table;
                gvStudents.DataBind();
                gvStudents.Visible = true;
                lblNoStudents.Visible = false;
                lblStudentCount.Text = $"{table.Rows.Count} student(s)";
            }
            else
            {
                gvStudents.Visible = false;
                lblNoStudents.Visible = true;
                lblStudentCount.Text = "0 students";
            }
        }

        private DataTable GetStudentsTable(DateTime startDate, DateTime endDate, string searchTerm, string statusFilter)
        {
            var table = new DataTable();

            using (var con = new SqlConnection(ConnStr))
            using (var cmd = con.CreateCommand())
            {
                var sql = new StringBuilder(@"
                    SELECT 
                        u.user_slug as StudentID,
                        ISNULL(u.display_name, u.full_name) as Name,
                        u.email as Email,
                        'Student' as Role,
                        u.created_at as EnrollmentDate,
                        ISNULL((
                            SELECT COUNT(DISTINCT CASE WHEN a.passed = 1 THEN a.quiz_slug END) * 100.0 / NULLIF(COUNT(DISTINCT l.quiz_slug), 0)
                            FROM Enrollments e
                            LEFT JOIN Levels l ON e.class_slug = l.class_slug AND l.is_deleted = 0
                            LEFT JOIN Attempts a ON u.user_slug = a.user_slug AND l.quiz_slug = a.quiz_slug AND a.is_deleted = 0
                            WHERE e.user_slug = u.user_slug AND e.is_deleted = 0
                        ), 0) as Progress,
                        CASE WHEN ISNULL(u.is_blocked, 0) = 1 THEN 'Blocked' ELSE 'Active' END as Status,
                        u.is_blocked,
                        u.full_name,
                        u.created_at
                    FROM Users u
                    WHERE u.role = 'student' AND u.is_deleted = 0");

                if (!string.IsNullOrWhiteSpace(searchTerm))
                {
                    sql.Append(" AND (LOWER(u.full_name) LIKE @search OR LOWER(u.email) LIKE @search OR LOWER(ISNULL(u.display_name, '')) LIKE @search)");
                    cmd.Parameters.AddWithValue("@search", "%" + searchTerm.ToLower() + "%");
                }

                if (statusFilter == "blocked")
                {
                    sql.Append(" AND ISNULL(u.is_blocked, 0) = 1");
                }
                else if (statusFilter == "active")
                {
                    sql.Append(" AND ISNULL(u.is_blocked, 0) = 0");
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

        private void LoadTeachersData(DateTime startDate, DateTime endDate, string searchTerm)
        {
            var table = GetTeachersTable(startDate, endDate, searchTerm);

            if (table.Rows.Count > 0)
            {
                gvTeachers.DataSource = table;
                gvTeachers.DataBind();
                gvTeachers.Visible = true;
                lblNoTeachers.Visible = false;
                lblTeacherCount.Text = $"{table.Rows.Count} teacher(s)";
            }
            else
            {
                gvTeachers.Visible = false;
                lblNoTeachers.Visible = true;
                lblTeacherCount.Text = "0 teachers";
            }
        }

        private DataTable GetTeachersTable(DateTime startDate, DateTime endDate, string searchTerm)
        {
            var table = new DataTable();

            using (var con = new SqlConnection(ConnStr))
            using (var cmd = con.CreateCommand())
            {
                var sql = new StringBuilder(@"
                    SELECT 
                        u.user_slug as TeacherID,
                        ISNULL(u.display_name, u.full_name) as Name,
                        u.email as Email,
                        'Teacher' as Role,
                        (SELECT COUNT(*) FROM Classes c WHERE c.teacher_slug = u.user_slug AND c.is_deleted = 0) as ClassesCreated,
                        u.created_at as ActiveSince,
                        (SELECT COUNT(DISTINCT e.user_slug) 
                         FROM Classes c
                         INNER JOIN Enrollments e ON c.class_slug = e.class_slug
                         WHERE c.teacher_slug = u.user_slug 
                           AND c.is_deleted = 0 
                           AND e.is_deleted = 0 
                           AND e.role_in_class = 'student') as NumberOfStudents,
                        u.full_name,
                        u.created_at
                    FROM Users u
                    WHERE u.role = 'teacher' AND u.is_deleted = 0");

                if (!string.IsNullOrWhiteSpace(searchTerm))
                {
                    sql.Append(" AND (LOWER(u.full_name) LIKE @search OR LOWER(u.email) LIKE @search OR LOWER(ISNULL(u.display_name, '')) LIKE @search)");
                    cmd.Parameters.AddWithValue("@search", "%" + searchTerm.ToLower() + "%");
                }

                sql.Append(" ORDER BY ClassesCreated DESC, u.created_at DESC");

                cmd.CommandText = sql.ToString();

                using (var adapter = new SqlDataAdapter(cmd))
                {
                    adapter.Fill(table);
                }
            }

            return table;
        }

        private void LoadClassesData(string searchTerm)
        {
            var table = GetClassesTable(searchTerm);

            if (table.Rows.Count > 0)
            {
                gvClasses.DataSource = table;
                gvClasses.DataBind();
                gvClasses.Visible = true;
                lblNoClasses.Visible = false;
                lblClassCount.Text = $"{table.Rows.Count} class(es)";
            }
            else
            {
                gvClasses.Visible = false;
                lblNoClasses.Visible = true;
                lblClassCount.Text = "0 classes";
            }
        }

        private DataTable GetClassesTable(string searchTerm)
        {
            var table = new DataTable();

            using (var con = new SqlConnection(ConnStr))
            using (var cmd = con.CreateCommand())
            {
                var sql = new StringBuilder(@"
                    SELECT 
                        c.class_slug as ClassID,
                        c.class_name as ClassName,
                        ISNULL(u.display_name, u.full_name) as Teacher,
                        c.class_code as ClassCode,
                        COUNT(DISTINCT e.user_slug) as TotalStudents,
                        COUNT(DISTINCT CASE WHEN e.joined_at >= DATEADD(day, -30, SYSUTCDATETIME()) THEN e.user_slug END) as ActiveStudents,
                        c.created_at as EnrollmentDate,
                        c.class_slug,
                        c.class_name,
                        u.display_name,
                        u.full_name,
                        c.created_at
                    FROM Classes c
                    LEFT JOIN Users u ON c.teacher_slug = u.user_slug
                    LEFT JOIN Enrollments e ON c.class_slug = e.class_slug AND e.is_deleted = 0 AND e.role_in_class = 'student'
                    WHERE c.is_deleted = 0");

                if (!string.IsNullOrWhiteSpace(searchTerm))
                {
                    sql.Append(" AND (LOWER(c.class_name) LIKE @search OR LOWER(c.class_code) LIKE @search)");
                    cmd.Parameters.AddWithValue("@search", "%" + searchTerm.ToLower() + "%");
                }

                sql.Append(" GROUP BY c.class_slug, c.class_name, c.class_code, u.display_name, u.full_name, c.created_at");
                sql.Append(" ORDER BY TotalStudents DESC, c.created_at DESC");

                cmd.CommandText = sql.ToString();

                using (var adapter = new SqlDataAdapter(cmd))
                {
                    adapter.Fill(table);
                }
            }

            return table;
        }

        protected void gvStudents_PageIndexChanging(object sender, System.Web.UI.WebControls.GridViewPageEventArgs e)
        {
            gvStudents.PageIndex = e.NewPageIndex;
            DateTime startDate, endDate;
            string searchTerm, statusFilter;
            GetFilterValues(out startDate, out endDate, out searchTerm, out statusFilter);
            LoadStudentsData(startDate, endDate, searchTerm, statusFilter);
        }

        protected void gvStudents_Sorting(object sender, System.Web.UI.WebControls.GridViewSortEventArgs e)
        {
            // Sorting handled by SQL query
            LoadReportData();
        }

        protected void gvTeachers_PageIndexChanging(object sender, System.Web.UI.WebControls.GridViewPageEventArgs e)
        {
            gvTeachers.PageIndex = e.NewPageIndex;
            DateTime startDate, endDate;
            string searchTerm, statusFilter;
            GetFilterValues(out startDate, out endDate, out searchTerm, out statusFilter);
            LoadTeachersData(startDate, endDate, searchTerm);
        }

        protected void gvTeachers_Sorting(object sender, System.Web.UI.WebControls.GridViewSortEventArgs e)
        {
            LoadReportData();
        }

        protected void gvClasses_PageIndexChanging(object sender, System.Web.UI.WebControls.GridViewPageEventArgs e)
        {
            gvClasses.PageIndex = e.NewPageIndex;
            DateTime startDate, endDate;
            string searchTerm, statusFilter;
            GetFilterValues(out startDate, out endDate, out searchTerm, out statusFilter);
            LoadClassesData(searchTerm);
        }

        protected void gvClasses_Sorting(object sender, System.Web.UI.WebControls.GridViewSortEventArgs e)
        {
            LoadReportData();
        }

        private void GetFilterValues(out DateTime startDate, out DateTime endDate, out string searchTerm, out string statusFilter)
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

            searchTerm = txtSearch.Text.Trim();
            statusFilter = ddlStatusFilter.SelectedValue;
        }

        private DateTime? ParseDate(string value)
        {
            if (DateTime.TryParse(value, CultureInfo.InvariantCulture, DateTimeStyles.AssumeLocal, out var parsed))
            {
                return parsed.Date;
            }
            return null;
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

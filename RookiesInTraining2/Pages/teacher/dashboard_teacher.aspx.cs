using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Globalization;
using System.Web.Script.Serialization;
using System.Web.UI;

namespace RookiesInTraining2.Pages
{
    public partial class dashboard_teacher : System.Web.UI.Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Check authentication
            if (Session["UserSlug"] == null || Session["Role"]?.ToString() != "teacher")
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
            string userSlug = Session["UserSlug"]?.ToString();
            string fullName = Session["FullName"]?.ToString() ?? "Teacher";

            // Display teacher name and current date
            lblTeacherName.Text = fullName;
            lblCurrentDate.Text = DateTime.Now.ToString("MMMM dd, yyyy", new CultureInfo("en-US"));

            // Load stats
            LoadStats(userSlug);

            // Load classes for the class cards display
            LoadClasses(userSlug);

            // Load recent activity
            LoadRecentActivity(userSlug);

            // Load pending items
            LoadPendingItems(userSlug);
        }

        private void LoadStats(string userSlug)
        {
            try
            {
                // Placeholder data - replace with actual queries
                lblTodayClasses.Text = "2";
                lblMyCourses.Text = "5";
                lblTotalStudents.Text = "120";
                lblPendingAssignments.Text = "8";
                lblMaterials.Text = "45";
                lblPendingCount.Text = "8";
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[TeacherDash] Error loading stats: {ex.Message}");
            }
        }


        private void LoadRecentActivity(string userSlug)
        {
            try
            {
                // Sample data
                var activities = new List<dynamic>
                {
                    new { Icon = "person-check", IconColor = "success", ActivityText = "Student 'Li Ming' submitted assignment", TimeAgo = "30 minutes ago" },
                    new { Icon = "file-earmark-plus", IconColor = "primary", ActivityText = "Uploaded new material 'Chapter 5 PPT'", TimeAgo = "2 hours ago" },
                    new { Icon = "clipboard-check", IconColor = "info", ActivityText = "Graded 15 assignments", TimeAgo = "Yesterday" },
                    new { Icon = "star", IconColor = "warning", ActivityText = "Received positive feedback", TimeAgo = "2 days ago" }
                };

                if (activities.Count > 0)
                {
                    rptActivity.DataSource = activities;
                    rptActivity.DataBind();
                    lblNoActivityMessage.Visible = false;
                }
                else
                {
                    lblNoActivityMessage.Visible = true;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[TeacherDash] Error loading activity: {ex.Message}");
                lblNoActivityMessage.Visible = true;
            }
        }

        private void LoadPendingItems(string userSlug)
        {
            try
            {
                // Sample data
                var pending = new List<dynamic>
                {
                    new { ItemTitle = "Assignment 2", CourseName = "C# Fundamentals", Count = 5 },
                    new { ItemTitle = "Quiz 3", CourseName = "ASP.NET", Count = 3 }
                };

                if (pending.Count > 0)
                {
                    rptPendingItems.DataSource = pending;
                    rptPendingItems.DataBind();
                    lblNoPendingMessage.Visible = false;
                }
                else
                {
                    lblNoPendingMessage.Visible = true;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[TeacherDash] Error loading pending: {ex.Message}");
                lblNoPendingMessage.Visible = true;
            }
        }

        private void LoadClasses(string teacherSlug)
        {
            List<dynamic> classes = new List<dynamic>();

            System.Diagnostics.Debug.WriteLine($"[Dashboard] ========== LoadClasses START ==========");
            System.Diagnostics.Debug.WriteLine($"[Dashboard] Teacher Slug: {teacherSlug}");
            System.Diagnostics.Debug.WriteLine($"[Dashboard] Connection String: {(string.IsNullOrEmpty(ConnStr) ? "EMPTY!" : "OK")}");

            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();
                    System.Diagnostics.Debug.WriteLine($"[Dashboard] Database connection opened successfully");
                    
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            SELECT 
                                c.class_slug AS ClassSlug,
                                c.class_name AS ClassName,
                                c.description AS Description,
                                c.icon AS Icon,
                                c.color AS Color,
                                c.class_code AS ClassCode,
                                COUNT(DISTINCT e.user_slug) AS StudentCount,
                                COUNT(DISTINCT l.level_slug) AS LevelCount
                            FROM Classes c
                            LEFT JOIN Enrollments e ON c.class_slug = e.class_slug 
                                AND e.role_in_class = 'student' AND e.is_deleted = 0
                            LEFT JOIN Levels l ON c.class_slug = l.class_slug AND l.is_deleted = 0
                            WHERE c.teacher_slug = @teacherSlug AND c.is_deleted = 0
                            GROUP BY c.class_slug, c.class_name, c.description, c.icon, c.color, c.class_code, c.created_at
                            ORDER BY c.created_at DESC";

                        cmd.Parameters.AddWithValue("@teacherSlug", teacherSlug);
                        
                        System.Diagnostics.Debug.WriteLine($"[Dashboard] Executing query with teacher_slug: {teacherSlug}");

                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                classes.Add(new
                                {
                                    ClassSlug = reader["ClassSlug"].ToString(),
                                    ClassName = reader["ClassName"].ToString(),
                                    Description = reader["Description"].ToString(),
                                    Icon = reader["Icon"].ToString(),
                                    Color = reader["Color"].ToString(),
                                    ClassCode = reader["ClassCode"].ToString(),
                                    StudentCount = Convert.ToInt32(reader["StudentCount"]),
                                    LevelCount = Convert.ToInt32(reader["LevelCount"])
                                });
                            }
                        }
                    }
                }

                // Serialize to JSON for JavaScript
                var serializer = new JavaScriptSerializer();
                string json = serializer.Serialize(classes);
                hfClassesJson.Value = json;

                System.Diagnostics.Debug.WriteLine($"[Dashboard] ✅ SUCCESS: Loaded {classes.Count} classes for teacher {teacherSlug}");
                System.Diagnostics.Debug.WriteLine($"[Dashboard] JSON length: {json.Length}");
                System.Diagnostics.Debug.WriteLine($"[Dashboard] JSON content: {json}");
                System.Diagnostics.Debug.WriteLine($"[Dashboard] ========== LoadClasses END ==========");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[Dashboard] ❌ ERROR loading classes: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"[Dashboard] Stack trace: {ex.StackTrace}");
                System.Diagnostics.Debug.WriteLine($"[Dashboard] ========== LoadClasses END (ERROR) ==========");
                hfClassesJson.Value = "[]";
            }
        }
    }
}


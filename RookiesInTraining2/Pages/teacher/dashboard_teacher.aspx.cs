using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
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
                // Only set values for labels that still exist
                // lblTodayClasses is in the welcome section
                lblTodayClasses.Text = "2"; // Placeholder - can be replaced with actual query
                
                // lblPendingCount is in the Pending Assignments card
                lblPendingCount.Text = "8"; // Placeholder - can be replaced with actual query
                
                // Note: The following labels were removed when stat cards were removed:
                // - lblMyCourses
                // - lblTotalStudents
                // - lblPendingAssignments
                // - lblMaterials
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
                var activities = new List<dynamic>();

                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();

                    // Get recently created classes (last 30 days, limit 10)
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            SELECT TOP 10
                                class_name AS ClassName,
                                created_at AS ActivityDate,
                                'class_created' AS ActivityType
                            FROM Classes
                            WHERE teacher_slug = @teacherSlug 
                              AND is_deleted = 0
                              AND created_at >= DATEADD(day, -30, GETUTCDATE())
                            ORDER BY created_at DESC";

                        cmd.Parameters.AddWithValue("@teacherSlug", userSlug);

                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                DateTime activityDate = Convert.ToDateTime(reader["ActivityDate"]);
                                activities.Add(new
                                {
                                    Icon = "collection",
                                    IconColor = "primary",
                                    ActivityText = $"Created class '{reader["ClassName"]}'",
                                    TimeAgo = GetTimeAgo(activityDate),
                                    ActivityDate = activityDate
                                });
                            }
                        }
                    }

                    // Get recently joined students (last 30 days, limit 10)
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            SELECT TOP 10
                                u.full_name AS StudentName,
                                c.class_name AS ClassName,
                                e.joined_at AS ActivityDate,
                                'student_joined' AS ActivityType
                            FROM Enrollments e
                            INNER JOIN Users u ON e.user_slug = u.user_slug
                            INNER JOIN Classes c ON e.class_slug = c.class_slug
                            WHERE c.teacher_slug = @teacherSlug
                              AND e.role_in_class = 'student'
                              AND e.is_deleted = 0
                              AND c.is_deleted = 0
                              AND e.joined_at >= DATEADD(day, -30, GETUTCDATE())
                            ORDER BY e.joined_at DESC";

                        cmd.Parameters.AddWithValue("@teacherSlug", userSlug);

                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                DateTime activityDate = Convert.ToDateTime(reader["ActivityDate"]);
                                activities.Add(new
                                {
                                    Icon = "person-plus",
                                    IconColor = "success",
                                    ActivityText = $"Student '{reader["StudentName"]}' joined '{reader["ClassName"]}'",
                                    TimeAgo = GetTimeAgo(activityDate),
                                    ActivityDate = activityDate
                                });
                            }
                        }
                    }
                }

                // Sort by date (most recent first) and take top 10
                var sortedActivities = activities
                    .OrderByDescending(a => 
                    {
                        var prop = a.GetType().GetProperty("ActivityDate");
                        return prop != null ? (DateTime)prop.GetValue(a) : DateTime.MinValue;
                    })
                    .Take(10)
                    .ToList();

                var finalActivities = new List<dynamic>();
                foreach (var activity in sortedActivities)
                {
                    finalActivities.Add(new
                    {
                        Icon = activity.GetType().GetProperty("Icon").GetValue(activity).ToString(),
                        IconColor = activity.GetType().GetProperty("IconColor").GetValue(activity).ToString(),
                        ActivityText = activity.GetType().GetProperty("ActivityText").GetValue(activity).ToString(),
                        TimeAgo = activity.GetType().GetProperty("TimeAgo").GetValue(activity).ToString()
                    });
                }
                activities = finalActivities;

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
                System.Diagnostics.Debug.WriteLine($"[TeacherDash] Stack trace: {ex.StackTrace}");
                lblNoActivityMessage.Visible = true;
            }
        }

        private string GetTimeAgo(DateTime dateTime)
        {
            TimeSpan timeSpan = DateTime.UtcNow - dateTime;

            if (timeSpan.TotalMinutes < 1)
                return "Just now";
            else if (timeSpan.TotalMinutes < 60)
                return $"{(int)timeSpan.TotalMinutes} minute{(timeSpan.TotalMinutes >= 2 ? "s" : "")} ago";
            else if (timeSpan.TotalHours < 24)
                return $"{(int)timeSpan.TotalHours} hour{(timeSpan.TotalHours >= 2 ? "s" : "")} ago";
            else if (timeSpan.TotalDays < 7)
                return $"{(int)timeSpan.TotalDays} day{(timeSpan.TotalDays >= 2 ? "s" : "")} ago";
            else if (timeSpan.TotalDays < 30)
            {
                int weeks = (int)(timeSpan.TotalDays / 7);
                return $"{weeks} week{(weeks >= 2 ? "s" : "")} ago";
            }
            else
            {
                int months = (int)(timeSpan.TotalDays / 30);
                return $"{months} month{(months >= 2 ? "s" : "")} ago";
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

                // Set the classes count in the label
                lblMyClassesCount.Text = classes.Count.ToString();

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
                lblMyClassesCount.Text = "0";
            }
        }
    }
}


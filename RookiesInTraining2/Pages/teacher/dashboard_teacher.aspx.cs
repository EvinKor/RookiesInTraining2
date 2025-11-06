using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Globalization;
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

            // Load courses
            LoadCourses(userSlug);

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

        private void LoadCourses(string userSlug)
        {
            try
            {
                // Sample data - replace with actual database query
                var courses = new List<dynamic>
                {
                    new { CourseName = "C# Fundamentals", StudentCount = 35 },
                    new { CourseName = "ASP.NET Web Forms", StudentCount = 28 },
                    new { CourseName = "Database Design", StudentCount = 42 },
                    new { CourseName = "Software Engineering", StudentCount = 30 }
                };

                if (courses.Count > 0)
                {
                    rptCourses.DataSource = courses;
                    rptCourses.DataBind();
                    lblNoCoursesMessage.Visible = false;
                }
                else
                {
                    lblNoCoursesMessage.Visible = true;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[TeacherDash] Error loading courses: {ex.Message}");
                lblNoCoursesMessage.Visible = true;
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
    }
}


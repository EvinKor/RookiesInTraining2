using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.Script.Serialization;
using System.Web.UI;

namespace RookiesInTraining2.Pages
{
    public partial class teacher_browse_classes : System.Web.UI.Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Check authentication
            if (Session["UserSlug"] == null)
            {
                Response.Redirect("~/Pages/Login.aspx", false);
                return;
            }

            // Check role
            string role = Convert.ToString(Session["Role"])?.ToLowerInvariant();
            if (role != "teacher" && role != "admin")
            {
                Response.Redirect("~/Pages/Login.aspx", false);
                return;
            }

            if (!IsPostBack)
            {
                LoadClasses();
            }
        }

        private void LoadClasses()
        {
            string teacherSlug = Session["UserSlug"]?.ToString() ?? "";
            List<ClassItem> classes = new List<ClassItem>();

            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = con.CreateCommand())
                {
                    cmd.CommandText = @"
                        SELECT 
                            c.class_slug,
                            c.class_name,
                            c.class_code,
                            c.description,
                            c.icon,
                            c.color,
                            c.created_at,
                            COUNT(DISTINCT e.user_slug) AS student_count,
                            COUNT(DISTINCT l.level_slug) AS level_count
                        FROM Classes c
                        LEFT JOIN Enrollments e ON e.class_slug = c.class_slug 
                            AND e.role_in_class = 'student' AND e.is_deleted = 0
                        LEFT JOIN Levels l ON l.class_slug = c.class_slug AND l.is_deleted = 0
                        WHERE c.teacher_slug = @teacherSlug AND c.is_deleted = 0
                        GROUP BY c.class_slug, c.class_name, c.class_code, c.description, 
                                 c.icon, c.color, c.created_at
                        ORDER BY c.created_at DESC";

                    cmd.Parameters.AddWithValue("@teacherSlug", teacherSlug);

                    con.Open();
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            classes.Add(new ClassItem
                            {
                                ClassSlug = reader["class_slug"].ToString(),
                                ClassName = reader["class_name"].ToString(),
                                ClassCode = reader["class_code"].ToString(),
                                Description = reader["description"].ToString(),
                                Icon = reader["icon"].ToString(),
                                Color = reader["color"].ToString(),
                                StudentCount = Convert.ToInt32(reader["student_count"]),
                                LevelCount = Convert.ToInt32(reader["level_count"]),
                                CreatedAt = Convert.ToDateTime(reader["created_at"])
                            });
                        }
                    }
                }

                // Serialize to JSON for JavaScript
                var serializer = new JavaScriptSerializer();
                hfClassesJson.Value = serializer.Serialize(classes);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[TeacherBrowseClasses] Error: {ex}");
            }
        }

        // Data class
        public class ClassItem
        {
            public string ClassSlug { get; set; }
            public string ClassName { get; set; }
            public string ClassCode { get; set; }
            public string Description { get; set; }
            public string Icon { get; set; }
            public string Color { get; set; }
            public int StudentCount { get; set; }
            public int LevelCount { get; set; }
            public DateTime CreatedAt { get; set; }
        }
    }
}


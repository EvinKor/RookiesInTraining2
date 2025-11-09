using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace RookiesInTraining2.Pages.admin
{
    public partial class manage_classes : System.Web.UI.Page
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
                LoadClasses();
                LoadAllLevels();
                LoadAllForumPosts();
            }
        }

        private void LoadClasses()
        {
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
                            COUNT(DISTINCT e.user_slug) AS student_count,
                            COUNT(DISTINCT l.level_slug) AS level_count,
                            u.display_name AS teacher_name
                        FROM Classes c
                        LEFT JOIN Enrollments e ON e.class_slug = c.class_slug 
                            AND e.role_in_class = 'student' AND e.is_deleted = 0
                        LEFT JOIN Levels l ON l.class_slug = c.class_slug AND l.is_deleted = 0
                        LEFT JOIN Users u ON c.teacher_slug = u.user_slug
                        WHERE c.is_deleted = 0
                        GROUP BY c.class_slug, c.class_name, c.class_code, c.description, 
                                 c.icon, c.color, c.created_at, u.display_name
                        ORDER BY c.created_at DESC";

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
                                Description = reader["description"]?.ToString() ?? "",
                                Icon = reader["icon"]?.ToString() ?? "bi-book",
                                Color = reader["color"]?.ToString() ?? "#667eea",
                                StudentCount = Convert.ToInt32(reader["student_count"]),
                                LevelCount = Convert.ToInt32(reader["level_count"]),
                                TeacherName = reader["teacher_name"]?.ToString() ?? "Unknown"
                            });
                        }
                    }
                }

                // Bind to repeater
                rptClasses.DataSource = classes;
                rptClasses.DataBind();

                // Serialize for JavaScript
                var serializer = new JavaScriptSerializer();
                hfClassesJson.Value = serializer.Serialize(classes);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[ManageClasses] Error loading classes: {ex}");
            }
        }

        private void LoadAllLevels()
        {
            System.Diagnostics.Debug.WriteLine($"[ManageClasses][LoadAllLevels] Loading all levels for admin");
            List<LevelItem> levels = new List<LevelItem>();

            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = con.CreateCommand())
                {
                    cmd.CommandText = @"
                        SELECT 
                            l.level_slug, l.class_slug, l.level_number, l.title, l.description,
                            l.content_type, l.xp_reward, l.estimated_minutes, l.is_published, l.quiz_slug
                        FROM Levels l
                        INNER JOIN Classes c ON c.class_slug = l.class_slug
                        WHERE l.is_deleted = 0 AND c.is_deleted = 0
                        ORDER BY l.class_slug, l.level_number";

                    con.Open();
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            var level = new LevelItem
                            {
                                LevelSlug = reader["level_slug"].ToString(),
                                ClassSlug = reader["class_slug"].ToString(),
                                LevelNumber = Convert.ToInt32(reader["level_number"]),
                                Title = reader["title"].ToString(),
                                Description = reader["description"]?.ToString() ?? "",
                                ContentType = reader["content_type"]?.ToString() ?? "",
                                XpReward = Convert.ToInt32(reader["xp_reward"]),
                                EstimatedMinutes = Convert.ToInt32(reader["estimated_minutes"]),
                                IsPublished = Convert.ToBoolean(reader["is_published"]),
                                QuizSlug = reader["quiz_slug"]?.ToString()
                            };
                            levels.Add(level);
                            System.Diagnostics.Debug.WriteLine($"[ManageClasses][LoadAllLevels] Added level: {level.LevelSlug} for class: {level.ClassSlug}");
                        }
                    }
                }

                System.Diagnostics.Debug.WriteLine($"[ManageClasses][LoadAllLevels] Total levels loaded: {levels.Count}");
                var serializer = new JavaScriptSerializer();
                string jsonData = serializer.Serialize(levels);
                hfLevelsJson.Value = jsonData;
                System.Diagnostics.Debug.WriteLine($"[ManageClasses][LoadAllLevels] Serialized JSON length: {jsonData.Length}");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[ManageClasses][LoadAllLevels] Error loading levels: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"[ManageClasses][LoadAllLevels] Stack trace: {ex.StackTrace}");
            }
        }

        private void LoadAllForumPosts()
        {
            List<dynamic> posts = new List<dynamic>();

            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            SELECT 
                                fp.post_slug AS PostSlug,
                                fp.class_slug AS ClassSlug,
                                fp.title AS Title,
                                fp.content AS Content,
                                fp.user_slug AS AuthorSlug,
                                fp.created_at AS CreatedAt,
                                u.full_name AS AuthorName,
                                (SELECT COUNT(*) FROM ForumReplies fr 
                                 WHERE fr.post_slug = fp.post_slug AND fr.is_deleted = 0) AS ReplyCount,
                                (SELECT TOP 3 
                                    fr.content + '||' + ISNULL(u2.full_name, 'Anonymous') + '||' + CONVERT(VARCHAR, fr.created_at, 127) + ';;'
                                 FROM ForumReplies fr
                                 LEFT JOIN Users u2 ON fr.user_slug = u2.user_slug
                                 WHERE fr.post_slug = fp.post_slug AND fr.is_deleted = 0
                                 ORDER BY fr.created_at ASC
                                 FOR XML PATH('')) AS TopReplies
                            FROM ForumPosts fp
                            LEFT JOIN Users u ON fp.user_slug = u.user_slug
                            INNER JOIN Classes c ON fp.class_slug = c.class_slug
                            WHERE fp.is_deleted = 0 
                              AND c.is_deleted = 0
                            ORDER BY fp.created_at DESC";

                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                string topRepliesRaw = reader["TopReplies"]?.ToString() ?? "";
                                List<dynamic> topReplies = new List<dynamic>();
                                
                                if (!string.IsNullOrWhiteSpace(topRepliesRaw))
                                {
                                    // Parse the concatenated replies
                                    string[] replyParts = topRepliesRaw.Split(new[] { ";;" }, StringSplitOptions.RemoveEmptyEntries);
                                    foreach (string part in replyParts)
                                    {
                                        if (!string.IsNullOrWhiteSpace(part))
                                        {
                                            string[] fields = part.Split(new[] { "||" }, StringSplitOptions.None);
                                            if (fields.Length >= 3)
                                            {
                                                topReplies.Add(new
                                                {
                                                    Content = fields[0],
                                                    AuthorName = fields[1],
                                                    CreatedAt = fields[2]
                                                });
                                            }
                                        }
                                    }
                                }

                                posts.Add(new
                                {
                                    PostSlug = reader["PostSlug"].ToString(),
                                    ClassSlug = reader["ClassSlug"].ToString(),
                                    Title = reader["Title"].ToString(),
                                    Content = reader["Content"].ToString(),
                                    AuthorSlug = reader["AuthorSlug"].ToString(),
                                    AuthorName = reader["AuthorName"]?.ToString() ?? "Anonymous",
                                    CreatedAt = Convert.ToDateTime(reader["CreatedAt"]).ToString("o"),
                                    ReplyCount = Convert.ToInt32(reader["ReplyCount"]),
                                    TopReplies = topReplies
                                });
                            }
                        }
                    }
                }

                var serializer = new JavaScriptSerializer();
                hfForumPostsJson.Value = serializer.Serialize(posts);
                System.Diagnostics.Debug.WriteLine($"[Forum] Loaded {posts.Count} forum posts");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[Forum] Error loading posts: {ex.Message}");
                hfForumPostsJson.Value = "[]";
            }
        }

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
            public string TeacherName { get; set; }
        }

        protected void btnConfirmDelete_Click(object sender, EventArgs e)
        {
            string adminSlug = Session["UserSlug"]?.ToString();
            string classSlug = hfDeleteClassSlug.Value;
            string className = hfDeleteClassName.Value;

            if (string.IsNullOrEmpty(classSlug) || string.IsNullOrEmpty(adminSlug))
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "deleteError",
                    "alert('Invalid request. Please try again.');", true);
                return;
            }

            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();
                    using (var tx = con.BeginTransaction())
                    {
                        try
                        {
                            // Soft delete the class
                            using (var cmd = con.CreateCommand())
                            {
                                cmd.Transaction = tx;
                                cmd.CommandText = @"
                                    UPDATE Classes 
                                    SET is_deleted = 1, updated_at = SYSUTCDATETIME()
                                    WHERE class_slug = @classSlug";
                                cmd.Parameters.AddWithValue("@classSlug", classSlug);
                                cmd.ExecuteNonQuery();
                            }

                            // Soft delete all levels
                            using (var cmd = con.CreateCommand())
                            {
                                cmd.Transaction = tx;
                                cmd.CommandText = @"
                                    UPDATE Levels 
                                    SET is_deleted = 1, updated_at = SYSUTCDATETIME()
                                    WHERE class_slug = @classSlug";
                                cmd.Parameters.AddWithValue("@classSlug", classSlug);
                                cmd.ExecuteNonQuery();
                            }

                            // Soft delete all quizzes
                            using (var cmd = con.CreateCommand())
                            {
                                cmd.Transaction = tx;
                                cmd.CommandText = @"
                                    UPDATE Quizzes 
                                    SET is_deleted = 1, updated_at = SYSUTCDATETIME()
                                    WHERE class_slug = @classSlug";
                                cmd.Parameters.AddWithValue("@classSlug", classSlug);
                                cmd.ExecuteNonQuery();
                            }

                            // Soft delete all enrollments
                            using (var cmd = con.CreateCommand())
                            {
                                cmd.Transaction = tx;
                                cmd.CommandText = @"
                                    UPDATE Enrollments 
                                    SET is_deleted = 1
                                    WHERE class_slug = @classSlug";
                                cmd.Parameters.AddWithValue("@classSlug", classSlug);
                                cmd.ExecuteNonQuery();
                            }

                            tx.Commit();

                            // Log admin action
                            Helpers.AdminAuditLogger.LogAction(adminSlug, "delete_class", "class", classSlug,
                                $"Deleted class: {className}");

                            // Redirect to refresh the page
                            ScriptManager.RegisterStartupScript(this, GetType(), "deleteSuccess",
                                "alert('Class deleted successfully!'); window.location.href = 'manage_classes.aspx';", true);
                        }
                        catch (Exception ex)
                        {
                            tx.Rollback();
                            System.Diagnostics.Debug.WriteLine($"[DeleteClass] Error: {ex.Message}");
                            ScriptManager.RegisterStartupScript(this, GetType(), "deleteError",
                                $"alert('Error deleting class: {ex.Message}');", true);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[DeleteClass] Error: {ex.Message}");
                ScriptManager.RegisterStartupScript(this, GetType(), "deleteError",
                    $"alert('Error deleting class: {ex.Message}');", true);
            }
        }

        public class LevelItem
        {
            public string LevelSlug { get; set; }
            public string ClassSlug { get; set; }
            public int LevelNumber { get; set; }
            public string Title { get; set; }
            public string Description { get; set; }
            public string ContentType { get; set; }
            public int XpReward { get; set; }
            public int EstimatedMinutes { get; set; }
            public bool IsPublished { get; set; }
            public string QuizSlug { get; set; }
        }
    }
}


using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Globalization;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace RookiesInTraining2.Pages.teacher
{
    public partial class manage_classes : System.Web.UI.Page
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
                LoadAllLevels();
                LoadAllForumPosts();
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
                                LevelCount = Convert.ToInt32(reader["level_count"])
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
            string teacherSlug = Session["UserSlug"]?.ToString() ?? "";
            System.Diagnostics.Debug.WriteLine($"[ManageClasses][LoadAllLevels] Loading levels for teacher: {teacherSlug}");
            List<LevelItem> levels = new List<LevelItem>();

            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = con.CreateCommand())
                {
                    cmd.CommandText = @"
                        SELECT 
                            l.level_slug, l.class_slug, l.level_number, l.title, l.description,
                            l.xp_reward, l.estimated_minutes, l.quiz_slug, l.is_published
                        FROM Levels l
                        INNER JOIN Classes c ON c.class_slug = l.class_slug
                        WHERE c.teacher_slug = @teacherSlug 
                          AND l.is_deleted = 0 AND c.is_deleted = 0
                        ORDER BY l.class_slug, l.level_number";

                    cmd.Parameters.AddWithValue("@teacherSlug", teacherSlug);

                    con.Open();
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            var level = new LevelItem
                            {
                                LevelSlug = reader["level_slug"].ToString(),
                                ClassSlug = reader["class_slug"].ToString(),
                                LevelNumber = reader["level_number"] != DBNull.Value ? Convert.ToInt32(reader["level_number"]) : 0,
                                Title = reader["title"].ToString(),
                                Description = reader["description"]?.ToString() ?? "",
                                ContentType = "learning", // Default
                                XpReward = reader["xp_reward"] != DBNull.Value ? Convert.ToInt32(reader["xp_reward"]) : 100,
                                EstimatedMinutes = reader["estimated_minutes"] != DBNull.Value ? Convert.ToInt32(reader["estimated_minutes"]) : 30,
                                IsPublished = reader["is_published"] != DBNull.Value ? Convert.ToBoolean(reader["is_published"]) : true,
                                QuizSlug = reader["quiz_slug"]?.ToString()
                            };
                            levels.Add(level);
                            System.Diagnostics.Debug.WriteLine($"[ManageClasses][LoadAllLevels] Added level: {level.Title} ({level.LevelSlug}) for class: {level.ClassSlug}");
                        }
                    }
                }

                System.Diagnostics.Debug.WriteLine($"[ManageClasses][LoadAllLevels] Total levels loaded: {levels.Count}");
                var serializer = new JavaScriptSerializer();
                string jsonData = serializer.Serialize(levels);
                hfLevelsJson.Value = jsonData;
                System.Diagnostics.Debug.WriteLine($"[ManageClasses][LoadAllLevels] Serialized JSON length: {jsonData.Length}");
                System.Diagnostics.Debug.WriteLine($"[ManageClasses][LoadAllLevels] First 200 chars of JSON: {(jsonData.Length > 200 ? jsonData.Substring(0, 200) : jsonData)}");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[ManageClasses][LoadAllLevels] Error loading levels: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"[ManageClasses][LoadAllLevels] Stack trace: {ex.StackTrace}");
            }
        }

        // Removed btnCreateStorymodeLevel_Click - now using separate create_level.aspx page
        // The method was moved to create_level.aspx.cs to avoid POST resubmission issues

        protected void btnConfirmDelete_Click(object sender, EventArgs e)
        {
            string classSlug = hfDeleteClassSlug.Value;
            string expectedClassName = hfDeleteClassName.Value;
            string typedClassName = txtDeleteConfirm.Text.Trim();

            lblDeleteError.Visible = false;

            // Validate class name matches
            if (typedClassName != expectedClassName)
            {
                lblDeleteError.Text = "Class name does not match. Deletion cancelled.";
                lblDeleteError.Visible = true;
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
                            // Soft delete: Set is_deleted = 1 instead of actually deleting
                            // This preserves data for potential recovery
                            
                            // 1. Soft delete the class
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

                            // 2. Soft delete all levels in this class
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

                            // 3. Soft delete all quizzes in this class
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

                            // 4. Soft delete all enrollments
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
                            System.Diagnostics.Debug.WriteLine($"[DeleteClass] Successfully deleted class: {classSlug}");

                            // Redirect to refresh the page
                            ScriptManager.RegisterStartupScript(this, GetType(), "deleteSuccess",
                                "alert('Class deleted successfully!'); window.location.href = 'manage_classes.aspx';", true);
                        }
                        catch (Exception ex)
                        {
                            tx.Rollback();
                            System.Diagnostics.Debug.WriteLine($"[DeleteClass] Error: {ex.Message}");
                            throw;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                lblDeleteError.Text = $"Error deleting class: {ex.Message}";
                lblDeleteError.Visible = true;
                System.Diagnostics.Debug.WriteLine($"[DeleteClass] Exception: {ex}");
            }
        }

        private Tuple<string, string> HandleFileUpload(FileUpload upload, string classSlug, string levelSlug)
        {
            if (!upload.HasFile) return Tuple.Create<string, string>(null, null);

            string extension = Path.GetExtension(upload.FileName).ToLowerInvariant();
            string contentType = null;

            switch (extension)
            {
                case ".pptx":
                case ".ppt":
                    contentType = "powerpoint";
                    break;
                case ".pdf":
                    contentType = "pdf";
                    break;
                default:
                    throw new Exception("Unsupported file type. Please upload PowerPoint or PDF.");
            }

            string uploadFolder = Server.MapPath($"~/Uploads/{classSlug}/{levelSlug}/");
            if (!Directory.Exists(uploadFolder))
            {
                Directory.CreateDirectory(uploadFolder);
            }

            string safeFileName = $"{levelSlug}_{DateTime.Now:yyyyMMddHHmmss}{extension}";
            string filePath = Path.Combine(uploadFolder, safeFileName);
            upload.SaveAs(filePath);

            string relativeUrl = $"/Uploads/{classSlug}/{levelSlug}/{safeFileName}";
            return Tuple.Create(contentType, relativeUrl);
        }

        private string SlugifyText(string text)
        {
            if (string.IsNullOrWhiteSpace(text)) return "item";

            string slug = text.Trim().ToLowerInvariant();
            var sb = new StringBuilder(slug.Length);
            foreach (var ch in slug.Normalize(NormalizationForm.FormD))
            {
                var cat = CharUnicodeInfo.GetUnicodeCategory(ch);
                if (cat != UnicodeCategory.NonSpacingMark)
                    sb.Append(ch);
            }
            slug = sb.ToString().Normalize(NormalizationForm.FormC);
            slug = Regex.Replace(slug, @"[^a-z0-9]+", "-");
            slug = slug.Trim('-');
            slug = Regex.Replace(slug, "-{2,}", "-");

            if (string.IsNullOrEmpty(slug)) slug = "item";
            if (slug.Length > 80) slug = slug.Substring(0, 80).TrimEnd('-');

            return slug;
        }

        private string GenerateUniqueSlug(string baseSlug, string tableName, string columnName, SqlConnection con)
        {
            string slug = baseSlug;
            int counter = 1;

            while (SlugExists(slug, tableName, columnName, con))
            {
                slug = baseSlug + "-" + counter.ToString(CultureInfo.InvariantCulture);
                counter++;

                if (counter > 1000)
                {
                    slug = baseSlug + "-" + Guid.NewGuid().ToString("N").Substring(0, 8);
                    break;
                }
            }

            return slug;
        }

        private void LoadAllForumPosts()
        {
            string teacherSlug = Session["UserSlug"]?.ToString() ?? "";
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
                            WHERE c.teacher_slug = @teacherSlug 
                              AND fp.is_deleted = 0 
                              AND c.is_deleted = 0
                            ORDER BY fp.created_at DESC";

                        cmd.Parameters.AddWithValue("@teacherSlug", teacherSlug);

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
                                    AuthorName = reader["AuthorName"].ToString(),
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


        private bool SlugExists(string slug, string tableName, string columnName, SqlConnection con)
        {
            using (var cmd = con.CreateCommand())
            {
                cmd.CommandText = $"SELECT TOP 1 1 FROM {tableName} WHERE {columnName} = @slug AND is_deleted = 0";
                cmd.Parameters.AddWithValue("@slug", slug);
                return cmd.ExecuteScalar() != null;
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


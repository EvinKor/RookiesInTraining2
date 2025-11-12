using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Text;
using System.Web.Script.Serialization;
using System.Web.UI;
using RookiesInTraining2.Helpers;

namespace RookiesInTraining2.Pages
{
    public partial class ManageClasses : System.Web.UI.Page
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
            try
            {
                string searchTerm = txtSearch.Text.Trim();

                using (var con = new SqlConnection(ConnStr))
                using (var cmd = con.CreateCommand())
                {
                    con.Open();

                    var query = new StringBuilder(@"
                        SELECT 
                            c.class_slug as ClassSlug,
                            c.class_name as ClassName,
                            c.class_code as ClassCode,
                            c.description as Description,
                            u.display_name as TeacherName,
                            COUNT(DISTINCT e.user_slug) as StudentCount,
                            COUNT(DISTINCT l.level_slug) as LevelCount,
                            FORMAT(c.created_at, 'yyyy-MM-dd HH:mm') as CreatedAt,
                            ISNULL(c.icon, 'bi-book') as Icon,
                            ISNULL(c.color, '#667eea') as Color
                        FROM dbo.Classes c
                        LEFT JOIN dbo.Users u ON c.teacher_slug = u.user_slug
                        LEFT JOIN dbo.Enrollments e ON c.class_slug = e.class_slug 
                            AND e.role_in_class = 'student' AND e.is_deleted = 0
                        LEFT JOIN dbo.Levels l ON l.class_slug = c.class_slug AND l.is_deleted = 0
                        WHERE c.is_deleted = 0");

                    if (!string.IsNullOrEmpty(searchTerm))
                    {
                        query.Append(" AND (LOWER(c.class_name) LIKE @search OR LOWER(c.class_code) LIKE @search)");
                        cmd.Parameters.AddWithValue("@search", "%" + searchTerm.ToLower() + "%");
                    }

                    query.Append(" GROUP BY c.class_slug, c.class_name, c.class_code, c.description, u.display_name, c.created_at, c.icon, c.color");
                    query.Append(" ORDER BY c.created_at DESC");

                    cmd.CommandText = query.ToString();

                    var classes = new List<dynamic>();
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            classes.Add(new
                            {
                                ClassSlug = reader["ClassSlug"].ToString(),
                                ClassName = reader["ClassName"].ToString(),
                                ClassCode = reader["ClassCode"].ToString(),
                                Description = reader["Description"]?.ToString() ?? "",
                                TeacherName = reader["TeacherName"]?.ToString() ?? "Unknown",
                                StudentCount = Convert.ToInt32(reader["StudentCount"]),
                                LevelCount = Convert.ToInt32(reader["LevelCount"]),
                                CreatedAt = reader["CreatedAt"].ToString(),
                                Icon = reader["Icon"]?.ToString() ?? "bi-book",
                                Color = reader["Color"]?.ToString() ?? "#667eea"
                            });
                        }
                    }

                    // Serialize for JavaScript
                    var serializer = new JavaScriptSerializer();
                    hfClassesJson.Value = serializer.Serialize(classes);

                    if (classes.Count > 0)
                    {
                        rptClasses.DataSource = classes;
                        rptClasses.DataBind();
                        lblNoClasses.Visible = false;
                        lblClassCount.Text = $"{classes.Count} class(es) found";
                    }
                    else
                    {
                        lblNoClasses.Visible = true;
                        lblClassCount.Text = "0 classes found";
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[Classes] Error loading classes: {ex.Message}");
                lblNoClasses.Visible = true;
                lblNoClasses.Text = "Error loading classes. Please try again.";
            }
        }

        private void LoadAllLevels()
        {
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
                            levels.Add(new LevelItem
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
                            });
                        }
                    }
                }

                var serializer = new JavaScriptSerializer();
                hfLevelsJson.Value = serializer.Serialize(levels);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[Classes] Error loading levels: {ex.Message}");
                hfLevelsJson.Value = "[]";
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
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[Classes] Error loading forum posts: {ex.Message}");
                hfForumPostsJson.Value = "[]";
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

        protected void txtSearch_TextChanged(object sender, EventArgs e)
        {
            LoadClasses();
        }

        protected void rptClasses_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "DeleteClass")
            {
                string adminSlug = Session["UserSlug"]?.ToString();
                string classSlug = e.CommandArgument.ToString();

                try
                {
                    using (var con = new SqlConnection(ConnStr))
                    {
                        con.Open();
                        using (var tx = con.BeginTransaction())
                        {
                            try
                            {
                                // Get class name for logging
                                string className = "";
                                using (var cmd = con.CreateCommand())
                                {
                                    cmd.Transaction = tx;
                                    cmd.CommandText = "SELECT class_name FROM Classes WHERE class_slug = @slug";
                                    cmd.Parameters.AddWithValue("@slug", classSlug);
                                    className = cmd.ExecuteScalar()?.ToString() ?? "Unknown";
                                }

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
                                AdminAuditLogger.LogAction(adminSlug, "delete_class", "class", classSlug, 
                                    $"Deleted class: {className}");

                                // Reload data
                                LoadClasses();
                                LoadAllLevels();
                                LoadAllForumPosts();
                            }
                            catch (Exception ex)
                            {
                                tx.Rollback();
                                throw ex;
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"[Classes] Error deleting class: {ex.Message}");
                    ClientScript.RegisterStartupScript(this.GetType(), "showError",
                        $"alert('Error deleting class: {Server.HtmlEncode(ex.Message)}');", true);
                }
            }
        }

        protected void btnExportCSV_Click(object sender, EventArgs e)
        {
            try
            {
                Response.Clear();
                Response.ContentType = "text/csv";
                Response.AppendHeader("Content-Disposition", "attachment; filename=classes_export_" + DateTime.Now.ToString("yyyyMMdd_HHmmss") + ".csv");

                using (var con = new SqlConnection(ConnStr))
                using (var cmd = con.CreateCommand())
                {
                    con.Open();
                    cmd.CommandText = @"
                        SELECT 
                            c.class_name,
                            c.class_code,
                            u.display_name as teacher_name,
                            COUNT(DISTINCT e.user_slug) as student_count,
                            FORMAT(c.created_at, 'yyyy-MM-dd HH:mm') as created_at
                        FROM Classes c
                        LEFT JOIN Users u ON c.teacher_slug = u.user_slug
                        LEFT JOIN Enrollments e ON c.class_slug = e.class_slug 
                            AND e.role_in_class = 'student' AND e.is_deleted = 0
                        WHERE c.is_deleted = 0
                        GROUP BY c.class_name, c.class_code, u.display_name, c.created_at
                        ORDER BY c.created_at DESC";

                    using (var reader = cmd.ExecuteReader())
                    {
                        // Write CSV header
                        Response.Write("Class Name,Class Code,Teacher,Student Count,Created At\n");

                        // Write data
                        while (reader.Read())
                        {
                            Response.Write($"\"{reader["class_name"]}\",");
                            Response.Write($"\"{reader["class_code"]}\",");
                            Response.Write($"\"{reader["teacher_name"] ?? "Unknown"}\",");
                            Response.Write($"\"{reader["student_count"]}\",");
                            Response.Write($"\"{reader["created_at"]}\"\n");
                        }
                    }
                }

                Response.End();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[Classes] Error exporting CSV: {ex.Message}");
                ClientScript.RegisterStartupScript(this.GetType(), "showError",
                    $"alert('Error exporting CSV: {Server.HtmlEncode(ex.Message)}');", true);
            }
        }
    }
}


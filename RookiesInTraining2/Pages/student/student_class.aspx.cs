using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.Script.Serialization;
using System.Web.UI;

namespace RookiesInTraining2.Pages.student
{
    public partial class student_class : System.Web.UI.Page
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
            if (role != "student")
            {
                Response.Redirect("~/Pages/Login.aspx", false);
                return;
            }

            if (!IsPostBack)
            {
                string classSlug = Request.QueryString["class"];
                if (string.IsNullOrWhiteSpace(classSlug))
                {
                    Response.Redirect("~/Pages/student/dashboard_student.aspx", false);
                    return;
                }

                hfClassSlug.Value = classSlug;

                // Set the create post link
                lnkCreatePost.NavigateUrl = $"~/Pages/student/create_forum_post.aspx?class={classSlug}";

                // Load class data
                LoadClassInfo(classSlug);
                LoadLevels(classSlug);
                LoadForumPosts(classSlug);
                LoadProgress(classSlug);
            }
        }

        private void LoadClassInfo(string classSlug)
        {
            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            SELECT class_name, class_code
                            FROM Classes
                            WHERE class_slug = @classSlug AND is_deleted = 0";
                        cmd.Parameters.AddWithValue("@classSlug", classSlug);

                        using (var reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                lblClassName.Text = reader["class_name"].ToString();
                                lblClassCode.Text = reader["class_code"].ToString();
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[StudentClass] Error loading class info: {ex.Message}");
            }
        }

        private void LoadLevels(string classSlug)
        {
            string studentSlug = Session["UserSlug"]?.ToString() ?? "";
            List<dynamic> levels = new List<dynamic>();

            try
            {
                System.Diagnostics.Debug.WriteLine($"[StudentClass] Loading levels for class: {classSlug}");
                System.Diagnostics.Debug.WriteLine($"[StudentClass] Student slug: {studentSlug}");

                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            SELECT 
                                l.level_slug,
                                l.title,
                                l.level_number,
                                l.description,
                                l.xp_reward,
                                l.estimated_minutes,
                                l.quiz_slug
                            FROM Levels l
                            WHERE l.class_slug = @classSlug 
                              AND l.is_deleted = 0
                            ORDER BY l.level_number ASC";

                        cmd.Parameters.AddWithValue("@classSlug", classSlug);

                        System.Diagnostics.Debug.WriteLine($"[StudentClass] SQL Query: {cmd.CommandText}");

                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                string levelTitle = reader["title"].ToString();
                                System.Diagnostics.Debug.WriteLine($"[StudentClass] Found level: {levelTitle}");
                                
                                levels.Add(new
                                {
                                    LevelSlug = reader["level_slug"].ToString(),
                                    LevelNumber = reader["level_number"] != DBNull.Value ? Convert.ToInt32(reader["level_number"]) : 0,
                                    Title = levelTitle,
                                    Description = reader["description"]?.ToString() ?? "",
                                    EstimatedMinutes = reader["estimated_minutes"] != DBNull.Value ? Convert.ToInt32(reader["estimated_minutes"]) : 30,
                                    XpReward = reader["xp_reward"] != DBNull.Value ? Convert.ToInt32(reader["xp_reward"]) : 100,
                                    QuizSlug = reader["quiz_slug"]?.ToString() ?? "",
                                    IsCompleted = false // Will check progress separately
                                });
                            }
                        }
                    }
                }

                System.Diagnostics.Debug.WriteLine($"[StudentClass] Total levels loaded: {levels.Count}");
                var serializer = new JavaScriptSerializer();
                hfLevelsJson.Value = serializer.Serialize(levels);
                System.Diagnostics.Debug.WriteLine($"[StudentClass] Levels JSON: {hfLevelsJson.Value}");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[StudentClass] Error loading levels: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"[StudentClass] Stack trace: {ex.StackTrace}");
                hfLevelsJson.Value = "[]";
            }
        }

        private void LoadForumPosts(string classSlug)
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
                                fp.title AS Title,
                                fp.content AS Content,
                                fp.created_at AS CreatedAt,
                                u.full_name AS AuthorName,
                                (SELECT COUNT(*) FROM ForumReplies fr 
                                 WHERE fr.post_slug = fp.post_slug AND fr.is_deleted = 0) AS ReplyCount
                            FROM ForumPosts fp
                            LEFT JOIN Users u ON fp.user_slug = u.user_slug
                            WHERE fp.class_slug = @classSlug AND fp.is_deleted = 0
                            ORDER BY fp.created_at DESC";

                        cmd.Parameters.AddWithValue("@classSlug", classSlug);

                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                posts.Add(new
                                {
                                    PostSlug = reader["PostSlug"].ToString(),
                                    Title = reader["Title"].ToString(),
                                    Content = reader["Content"].ToString(),
                                    CreatedAt = Convert.ToDateTime(reader["CreatedAt"]).ToString("o"),
                                    AuthorName = reader["AuthorName"].ToString(),
                                    ReplyCount = Convert.ToInt32(reader["ReplyCount"])
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
                System.Diagnostics.Debug.WriteLine($"[StudentClass] Error loading forum: {ex.Message}");
                hfForumPostsJson.Value = "[]";
            }
        }

        private void LoadProgress(string classSlug)
        {
            string studentSlug = Session["UserSlug"]?.ToString() ?? "";
            // Progress tracking - can be implemented later
            hfProgressJson.Value = "{}";
        }
    }
}


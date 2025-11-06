using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using Newtonsoft.Json;

namespace RookiesInTraining2.Pages
{
    public partial class story_stage : System.Web.UI.Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Guard: Check authentication
            if (Session["UserSlug"] == null)
            {
                Response.Redirect("~/Pages/Login.aspx", false);
                return;
            }

            // Guard: Check role
            string role = Session["Role"]?.ToString()?.ToLowerInvariant() ?? "";
            if (role != "student")
            {
                Response.Redirect("~/Pages/Login.aspx", false);
                return;
            }

            string stageSlug = Request.QueryString["stage"];
            if (string.IsNullOrEmpty(stageSlug))
            {
                Response.Redirect("~/Pages/student/story.aspx", false);
                return;
            }

            hfStageSlug.Value = stageSlug;

            if (!IsPostBack)
            {
                LoadStageData(stageSlug);
            }
        }

        private void LoadStageData(string stageSlug)
        {
            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();

                    // Load stage info
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            SELECT l.level_slug, l.title, l.description, l.xp_reward, l.estimated_minutes,
                                   c.class_name
                            FROM Levels l
                            INNER JOIN Classes c ON l.class_slug = c.class_slug
                            WHERE l.level_slug = @slug AND l.is_deleted = 0";

                        cmd.Parameters.AddWithValue("@slug", stageSlug);

                        using (var reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                stageTitle.InnerText = reader["title"].ToString();
                                stageDescription.InnerText = reader["description"]?.ToString() ?? "";
                                stageXP.InnerText = reader["xp_reward"].ToString();
                                stageTime.InnerText = reader["estimated_minutes"].ToString();
                                breadcrumbStage.InnerText = reader["title"].ToString();
                            }
                        }
                    }

                    // Find quiz for this level
                    string quizSlug = null;
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            SELECT TOP 1 quiz_slug, title, xp_reward
                            FROM Quizzes
                            WHERE level_slug = @stageSlug AND is_deleted = 0 AND published = 1
                            ORDER BY created_at";

                        cmd.Parameters.AddWithValue("@stageSlug", stageSlug);

                        using (var reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                quizSlug = reader["quiz_slug"].ToString();
                                
                                var quizData = new
                                {
                                    quizSlug = quizSlug,
                                    title = reader["title"].ToString(),
                                    xpReward = Convert.ToInt32(reader["xp_reward"])
                                };

                                var serializer = new JavaScriptSerializer();
                                hfQuizData.Value = serializer.Serialize(quizData);

                                // Load questions
                                var questions = LoadQuestions(quizSlug, con);
                                hfQuestionsJson.Value = serializer.Serialize(questions);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[StoryStage] Error: {ex}");
            }
        }

        private List<QuestionData> LoadQuestions(string quizSlug, SqlConnection con)
        {
            var questions = new List<QuestionData>();

            using (var cmd = con.CreateCommand())
            {
                cmd.CommandText = @"
                    SELECT 
                        question_slug, body_text, options_json, answer_idx, 
                        ISNULL(explanation, '') AS explanation,
                        ISNULL(order_no, 1) AS order_no
                    FROM Questions
                    WHERE quiz_slug = @quizSlug AND is_deleted = 0
                    ORDER BY order_no, created_at";

                cmd.Parameters.AddWithValue("@quizSlug", quizSlug);

                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        var optionsJson = reader["options_json"].ToString();
                        var options = JsonConvert.DeserializeObject<List<string>>(optionsJson) ?? new List<string>();

                        questions.Add(new QuestionData
                        {
                            QuestionSlug = reader["question_slug"].ToString(),
                            BodyText = reader["body_text"].ToString(),
                            Options = options,
                            AnswerIdx = Convert.ToInt32(reader["answer_idx"]),
                            Explanation = reader["explanation"].ToString()
                        });
                    }
                }
            }

            return questions;
        }

        [WebMethod]
        public static object CompleteStage(string stageSlug, int score, int xpEarned, int correctAnswers, int totalQuestions)
        {
            try
            {
                var userSlug = System.Web.HttpContext.Current.Session["UserSlug"]?.ToString();
                if (string.IsNullOrEmpty(userSlug))
                {
                    return new { success = false, message = "Not authenticated" };
                }

                var connStr = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
                using (var con = new SqlConnection(connStr))
                {
                    con.Open();

                    // Update or create StudentLevelProgress
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            IF EXISTS (SELECT 1 FROM StudentLevelProgress WHERE student_slug = @userSlug AND level_slug = @stageSlug)
                            BEGIN
                                UPDATE StudentLevelProgress
                                SET status = 'completed', completed_at = SYSUTCDATETIME(), updated_at = SYSUTCDATETIME()
                                WHERE student_slug = @userSlug AND level_slug = @stageSlug
                            END
                            ELSE
                            BEGIN
                                INSERT INTO StudentLevelProgress (progress_slug, student_slug, level_slug, status, completed_at, created_at, updated_at)
                                VALUES (NEWID(), @userSlug, @stageSlug, 'completed', SYSUTCDATETIME(), SYSUTCDATETIME(), SYSUTCDATETIME())
                            END";

                        cmd.Parameters.AddWithValue("@userSlug", userSlug);
                        cmd.Parameters.AddWithValue("@stageSlug", stageSlug);
                        cmd.ExecuteNonQuery();
                    }

                    // Award XP (simple implementation - can be enhanced with ProgressService)
                    // TODO: Use ProgressService here

                    // Check if next stage should be unlocked
                    bool unlockNext = false;
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            SELECT TOP 1 1
                            FROM Levels
                            WHERE level_number = (
                                SELECT level_number + 1 
                                FROM Levels 
                                WHERE level_slug = @stageSlug
                            ) AND is_deleted = 0";

                        cmd.Parameters.AddWithValue("@stageSlug", stageSlug);
                        unlockNext = cmd.ExecuteScalar() != null;
                    }

                    return new { success = true, unlockNext = unlockNext };
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[CompleteStage] Error: {ex}");
                return new { success = false, message = ex.Message };
            }
        }

        public class QuestionData
        {
            public string QuestionSlug { get; set; }
            public string BodyText { get; set; }
            public List<string> Options { get; set; }
            public int AnswerIdx { get; set; }
            public string Explanation { get; set; }
        }
    }
}


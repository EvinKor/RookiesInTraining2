using System;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Web;
using System.Web.Script.Serialization;
using System.Collections.Generic;

namespace RookiesInTraining2.api
{
    public class SaveQuizAttempt : IHttpHandler
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";

            try
            {
                // Check authentication
                if (context.Session["UserSlug"] == null)
                {
                    context.Response.Write("{\"success\":false,\"error\":\"Not authenticated\"}");
                    return;
                }

                string studentSlug = context.Session["UserSlug"].ToString();

                // Read request body
                string json;
                using (var reader = new StreamReader(context.Request.InputStream))
                {
                    json = reader.ReadToEnd();
                }

                var serializer = new JavaScriptSerializer();
                var data = serializer.Deserialize<Dictionary<string, object>>(json);

                string quizSlug = data["quiz_slug"].ToString();
                string levelSlug = data["level_slug"].ToString();
                int score = Convert.ToInt32(data["score"]);
                bool passed = Convert.ToBoolean(data["passed"]);

                System.Diagnostics.Debug.WriteLine($"[SaveQuizAttempt] Student: {studentSlug}, Quiz: {quizSlug}, Score: {score}, Passed: {passed}");

                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();

                    // Generate unique attempt slug
                    string attemptSlug = "attempt-" + Guid.NewGuid().ToString();

                    // Save to Attempts table
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            INSERT INTO Attempts 
                            (attempt_slug, user_slug, quiz_slug, score, max_score, passed, started_at, finished_at, is_deleted)
                            VALUES 
                            (@attemptSlug, @userSlug, @quizSlug, @score, 100, @passed, GETDATE(), GETDATE(), 0)";

                        cmd.Parameters.AddWithValue("@attemptSlug", attemptSlug);
                        cmd.Parameters.AddWithValue("@userSlug", studentSlug);
                        cmd.Parameters.AddWithValue("@quizSlug", quizSlug);
                        cmd.Parameters.AddWithValue("@score", score);
                        cmd.Parameters.AddWithValue("@passed", passed);

                        cmd.ExecuteNonQuery();
                    }

                    // If passed, update StudentLevelProgress
                    if (passed)
                    {
                        using (var cmd = con.CreateCommand())
                        {
                            // Check if progress record exists
                            cmd.CommandText = @"
                                SELECT COUNT(*) 
                                FROM StudentLevelProgress 
                                WHERE student_slug = @studentSlug AND level_slug = @levelSlug";

                            cmd.Parameters.AddWithValue("@studentSlug", studentSlug);
                            cmd.Parameters.AddWithValue("@levelSlug", levelSlug);

                            int exists = (int)cmd.ExecuteScalar();

                            if (exists > 0)
                            {
                                // Update existing record
                                cmd.CommandText = @"
                                    UPDATE StudentLevelProgress 
                                    SET status = 'completed', completed_at = GETDATE(), updated_at = GETDATE()
                                    WHERE student_slug = @studentSlug AND level_slug = @levelSlug";
                            }
                            else
                            {
                                // Insert new record
                                string progressSlug = "progress-" + Guid.NewGuid().ToString();
                                cmd.CommandText = @"
                                    INSERT INTO StudentLevelProgress 
                                    (progress_slug, student_slug, level_slug, status, completed_at, created_at, updated_at)
                                    VALUES 
                                    (@progressSlug, @studentSlug, @levelSlug, 'completed', GETDATE(), GETDATE(), GETDATE())";

                                cmd.Parameters.AddWithValue("@progressSlug", progressSlug);
                            }

                            cmd.ExecuteNonQuery();
                        }

                        System.Diagnostics.Debug.WriteLine($"[SaveQuizAttempt] Updated progress for level: {levelSlug}");
                    }
                }

                context.Response.Write("{\"success\":true}");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[SaveQuizAttempt] Error: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"[SaveQuizAttempt] Stack: {ex.StackTrace}");
                context.Response.Write($"{{\"success\":false,\"error\":\"{ex.Message.Replace("\"", "\\\"")}\"}}}");
            }
        }

        public bool IsReusable => false;
    }
}


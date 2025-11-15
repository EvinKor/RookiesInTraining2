<%@ WebHandler Language="C#" Class="GetClassLevels" %>

using System;
using System.Web;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Web.Script.Serialization;

public class LevelInfo
{
    public string LevelSlug { get; set; }
    public int LevelNumber { get; set; }
    public string Title { get; set; }
    public string Description { get; set; }
    public string QuizSlugFromLevel { get; set; }
    public string QuizSlugFromQuizzes { get; set; }
}

public class GetClassLevels : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json";
        context.Response.AppendHeader("X-Debug-Info", "GetClassLevels");
        
        try
        {
            string classSlug = context.Request.QueryString["classSlug"];
            string debugMode = context.Request.QueryString["debug"]; // Add ?debug=1 to see all levels
            
            System.Diagnostics.Debug.WriteLine($"[GetClassLevels] ===== START ===== Class: {classSlug}, Debug: {debugMode}");
            
            if (string.IsNullOrEmpty(classSlug))
            {
                System.Diagnostics.Debug.WriteLine("[GetClassLevels] No classSlug provided");
                context.Response.Write("[]");
                return;
            }

            var levels = new List<object>();
            var connStringConfig = System.Configuration.ConfigurationManager.ConnectionStrings["ConnectionString"];
            if (connStringConfig == null)
            {
                throw new Exception("Connection string 'ConnectionString' not found in web.config");
            }
            string connectionString = connStringConfig.ConnectionString;

            using (var con = new SqlConnection(connectionString))
            {
                con.Open();

                // First, get all levels for the class
                string levelsQuery = @"
                    SELECT 
                        l.level_slug,
                        l.level_number,
                        l.title,
                        l.description,
                        l.quiz_slug,
                        q.quiz_slug AS quiz_slug_from_quizzes
                    FROM Levels l
                    LEFT JOIN Quizzes q ON q.level_slug = l.level_slug AND q.is_deleted = 0
                    WHERE l.class_slug = @classSlug 
                      AND l.is_deleted = 0
                    ORDER BY l.level_number ASC";

                System.Diagnostics.Debug.WriteLine($"[GetClassLevels] Querying levels for class: {classSlug}");

                // First, collect all level data
                var levelData = new List<LevelInfo>();
                using (var cmd = new SqlCommand(levelsQuery, con))
                {
                    cmd.Parameters.AddWithValue("@classSlug", classSlug);

                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            levelData.Add(new LevelInfo
                            {
                                LevelSlug = reader["level_slug"].ToString(),
                                LevelNumber = reader["level_number"] != DBNull.Value ? Convert.ToInt32(reader["level_number"]) : 0,
                                Title = reader["title"].ToString(),
                                Description = reader["description"]?.ToString() ?? "",
                                QuizSlugFromLevel = reader["quiz_slug"]?.ToString() ?? "",
                                QuizSlugFromQuizzes = reader["quiz_slug_from_quizzes"]?.ToString() ?? ""
                            });
                        }
                    }
                }
                
                System.Diagnostics.Debug.WriteLine($"[GetClassLevels] Found {levelData.Count} total levels for class: {classSlug}");

                // Now check each level for questions
                foreach (var level in levelData)
                {
                    string resolvedQuizSlug = !string.IsNullOrEmpty(level.QuizSlugFromLevel) 
                        ? level.QuizSlugFromLevel 
                        : level.QuizSlugFromQuizzes;

                    System.Diagnostics.Debug.WriteLine($"[GetClassLevels] Level: {level.LevelSlug}, Quiz from level: {level.QuizSlugFromLevel}, Quiz from quizzes: {level.QuizSlugFromQuizzes}, Resolved: {resolvedQuizSlug}");

                    if (string.IsNullOrEmpty(resolvedQuizSlug))
                    {
                        System.Diagnostics.Debug.WriteLine($"[GetClassLevels] Level {level.LevelSlug} has no quiz_slug, skipping");
                        continue;
                    }

                    // Check for questions in Questions table (QuizQuestions is only in Supabase, not local DB)
                    int questionsCount = 0;
                    try
                    {
                        using (var qCmd = new SqlCommand("SELECT COUNT(*) FROM dbo.Questions WHERE quiz_slug = @quizSlug AND is_deleted = 0", con))
                        {
                            qCmd.Parameters.AddWithValue("@quizSlug", resolvedQuizSlug);
                            object qResult = qCmd.ExecuteScalar();
                            questionsCount = qResult != null ? Convert.ToInt32(qResult) : 0;
                        }
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine($"[GetClassLevels] Error checking Questions table for quiz {resolvedQuizSlug}: {ex.Message}");
                    }

                    int totalQuestions = questionsCount;

                    System.Diagnostics.Debug.WriteLine($"[GetClassLevels] Level {level.LevelSlug} (Quiz: {resolvedQuizSlug}) - Questions: {questionsCount}, Total: {totalQuestions}");

                    // In debug mode, return all levels; otherwise only return levels with questions
                    if (debugMode == "1" || totalQuestions > 0)
                    {
                        levels.Add(new
                        {
                            level_slug = level.LevelSlug,
                            level_number = level.LevelNumber,
                            title = level.Title,
                            description = level.Description,
                            quiz_slug = resolvedQuizSlug,
                            question_count = totalQuestions,
                            debug_info = debugMode == "1" ? new {
                                quiz_from_level = level.QuizSlugFromLevel,
                                quiz_from_quizzes = level.QuizSlugFromQuizzes,
                                questions_count = questionsCount
                            } : null
                        });
                    }
                }
                
                System.Diagnostics.Debug.WriteLine($"[GetClassLevels] Found {levels.Count} levels with questions for class: {classSlug}");
            }

            System.Diagnostics.Debug.WriteLine($"[GetClassLevels] ===== END ===== Returning {levels.Count} levels");
            
            var serializer = new JavaScriptSerializer();
            string json = serializer.Serialize(levels);
            System.Diagnostics.Debug.WriteLine($"[GetClassLevels] JSON Response: {json}");
            context.Response.Write(json);
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("[GetClassLevels] ===== ERROR =====");
            System.Diagnostics.Debug.WriteLine("[GetClassLevels] Error: " + ex.Message);
            System.Diagnostics.Debug.WriteLine("[GetClassLevels] StackTrace: " + ex.StackTrace);
            if (ex.InnerException != null)
            {
                System.Diagnostics.Debug.WriteLine("[GetClassLevels] InnerException: " + ex.InnerException.Message);
            }
            context.Response.Write("[]");
        }
    }

    public bool IsReusable
    {
        get { return false; }
    }
}


<%@ WebHandler Language="C#" Class="GetClassQuizzes" %>

using System;
using System.Web;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Web.Script.Serialization;

public class GetClassQuizzes : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json";
        
        try
        {
            string classSlug = context.Request.QueryString["classSlug"];
            
            if (string.IsNullOrEmpty(classSlug))
            {
                context.Response.Write("[]");
                return;
            }

            var quizzes = new List<object>();
            var connStringConfig = System.Configuration.ConfigurationManager.ConnectionStrings["ConnectionString"];
            if (connStringConfig == null)
            {
                throw new Exception("Connection string 'ConnectionString' not found in web.config");
            }
            string connectionString = connStringConfig.ConnectionString;

            using (var con = new SqlConnection(connectionString))
            {
                con.Open();

                // Get quizzes from levels in the class
                string query = @"
                    SELECT 
                        q.quiz_slug,
                        q.quiz_title,
                        q.time_limit,
                        q.passing_score,
                        l.level_title,
                        COUNT(qq.question_slug) AS question_count
                    FROM Quizzes q
                    INNER JOIN Levels l ON q.level_slug = l.level_slug
                    LEFT JOIN QuizQuestions qq ON q.quiz_slug = qq.quiz_slug AND qq.is_deleted = 0
                    WHERE l.class_slug = @classSlug 
                      AND l.is_deleted = 0 
                      AND q.is_deleted = 0
                    GROUP BY q.quiz_slug, q.quiz_title, q.time_limit, q.passing_score, l.level_title
                    HAVING COUNT(qq.question_slug) > 0
                    ORDER BY l.order_no, q.quiz_title";

                using (var cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@classSlug", classSlug);

                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            quizzes.Add(new
                            {
                                quiz_slug = reader["quiz_slug"].ToString(),
                                quiz_title = $"{reader["level_title"]} - {reader["quiz_title"]}",
                                time_limit = reader["time_limit"],
                                passing_score = reader["passing_score"],
                                question_count = reader["question_count"]
                            });
                        }
                    }
                }
            }

            var serializer = new JavaScriptSerializer();
            context.Response.Write(serializer.Serialize(quizzes));
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("[GetClassQuizzes] Error: " + ex.Message);
            context.Response.Write("[]");
        }
    }

    public bool IsReusable
    {
        get { return false; }
    }
}


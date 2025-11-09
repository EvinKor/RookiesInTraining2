<%@ WebHandler Language="C#" Class="GetQuizQuestions" %>

using System;
using System.Web;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Web.Script.Serialization;

public class GetQuizQuestions : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json";
        
        try
        {
            string quizSlug = context.Request.QueryString["quizSlug"];
            
            if (string.IsNullOrEmpty(quizSlug))
            {
                context.Response.Write("[]");
                return;
            }

            var questions = new List<object>();
            string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["RookiesConnectionString"].ConnectionString;

            using (var con = new SqlConnection(connectionString))
            {
                con.Open();

                string query = @"
                    SELECT 
                        question_slug,
                        body_text,
                        option_a,
                        option_b,
                        option_c,
                        option_d,
                        correct_answer,
                        points,
                        order_no
                    FROM QuizQuestions
                    WHERE quiz_slug = @quizSlug 
                      AND is_deleted = 0
                    ORDER BY order_no";

                using (var cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@quizSlug", quizSlug);

                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            questions.Add(new
                            {
                                question_slug = reader["question_slug"].ToString(),
                                body_text = reader["body_text"].ToString(),
                                question_text = reader["body_text"].ToString(), // Alias for compatibility
                                option_a = reader["option_a"].ToString(),
                                option_b = reader["option_b"].ToString(),
                                option_c = reader["option_c"].ToString(),
                                option_d = reader["option_d"].ToString(),
                                correct_answer = reader["correct_answer"].ToString(),
                                points = reader["points"] != DBNull.Value ? Convert.ToInt32(reader["points"]) : 100,
                                order_no = reader["order_no"] != DBNull.Value ? Convert.ToInt32(reader["order_no"]) : 0
                            });
                        }
                    }
                }
            }

            var serializer = new JavaScriptSerializer();
            context.Response.Write(serializer.Serialize(questions));
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("[GetQuizQuestions] Error: " + ex.Message);
            context.Response.Write("[]");
        }
    }

    public bool IsReusable
    {
        get { return false; }
    }
}


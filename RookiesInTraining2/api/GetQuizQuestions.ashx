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
            var connStringConfig = System.Configuration.ConfigurationManager.ConnectionStrings["ConnectionString"];
            if (connStringConfig == null)
            {
                throw new Exception("Connection string 'ConnectionString' not found in web.config");
            }
            string connectionString = connStringConfig.ConnectionString;

            using (var con = new SqlConnection(connectionString))
            {
                con.Open();

                // First try QuizQuestions table (multiplayer format) - but this table may not exist in local DB
                // So wrap it in try-catch to gracefully fall back to Questions table
                try
                {
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
                catch (Exception ex)
                {
                    // QuizQuestions table doesn't exist (it's only in Supabase), so ignore and try Questions table
                    System.Diagnostics.Debug.WriteLine("[GetQuizQuestions] QuizQuestions table not found, trying Questions table: " + ex.Message);
                }

                // If no questions found in QuizQuestions, try Questions table (class quiz format)
                if (questions.Count == 0)
                {
                    string questionsQuery = @"
                        SELECT 
                            question_slug,
                            body_text,
                            options_json,
                            answer_idx,
                            order_no
                        FROM Questions
                        WHERE quiz_slug = @quizSlug 
                          AND is_deleted = 0
                        ORDER BY order_no";

                    using (var cmd = new SqlCommand(questionsQuery, con))
                    {
                        cmd.Parameters.AddWithValue("@quizSlug", quizSlug);

                        using (var reader = cmd.ExecuteReader())
                        {
                            var jsonSerializer = new JavaScriptSerializer();
                            while (reader.Read())
                            {
                                string optionsJson = reader["options_json"]?.ToString() ?? "[]";
                                int answerIdx = reader["answer_idx"] != DBNull.Value ? Convert.ToInt32(reader["answer_idx"]) : 0;
                                
                                // Parse options from JSON
                                string[] options = new string[4] { "", "", "", "" };
                                try
                                {
                                    var optionsList = jsonSerializer.Deserialize<List<string>>(optionsJson);
                                    if (optionsList != null && optionsList.Count > 0)
                                    {
                                        for (int i = 0; i < Math.Min(4, optionsList.Count); i++)
                                        {
                                            options[i] = optionsList[i] ?? "";
                                        }
                                    }
                                }
                                catch
                                {
                                    // If JSON parsing fails, use empty options
                                }

                                // Convert answer_idx to letter (0=A, 1=B, 2=C, 3=D)
                                string correctAnswer = answerIdx >= 0 && answerIdx < 4 ? 
                                    ((char)('A' + answerIdx)).ToString() : "A";

                                questions.Add(new
                                {
                                    question_slug = reader["question_slug"].ToString(),
                                    body_text = reader["body_text"].ToString(),
                                    question_text = reader["body_text"].ToString(), // Alias for compatibility
                                    option_a = options[0],
                                    option_b = options[1],
                                    option_c = options[2],
                                    option_d = options[3],
                                    correct_answer = correctAnswer,
                                    points = 100, // Default points for class questions
                                    order_no = reader["order_no"] != DBNull.Value ? Convert.ToInt32(reader["order_no"]) : 0
                                });
                            }
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


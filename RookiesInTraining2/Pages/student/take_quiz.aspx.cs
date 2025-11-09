using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.Script.Serialization;
using System.Web.UI;

namespace RookiesInTraining2.Pages.student
{
    public partial class take_quiz : System.Web.UI.Page
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
                string quizSlug = Request.QueryString["quiz"];
                string levelSlug = Request.QueryString["level"];
                string classSlug = Request.QueryString["class"];
                
                if (string.IsNullOrWhiteSpace(quizSlug) || string.IsNullOrWhiteSpace(levelSlug) || string.IsNullOrWhiteSpace(classSlug))
                {
                    Response.Redirect("~/Pages/student/dashboard_student.aspx", false);
                    return;
                }

                hfQuizSlug.Value = quizSlug;
                hfLevelSlug.Value = levelSlug;
                hfClassSlug.Value = classSlug;
                
                lnkCancel.NavigateUrl = $"~/Pages/student/take_level.aspx?level={levelSlug}&class={classSlug}";

                // Load quiz data
                LoadQuiz(quizSlug, levelSlug);
            }
        }

        private void LoadQuiz(string quizSlug, string levelSlug)
        {
            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();

                    // Load quiz info
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            SELECT 
                                q.title, 
                                q.time_limit_minutes,
                                q.passing_score,
                                l.xp_reward
                            FROM Quizzes q
                            INNER JOIN Levels l ON q.quiz_slug = l.quiz_slug
                            WHERE q.quiz_slug = @quizSlug 
                              AND l.level_slug = @levelSlug
                              AND q.is_deleted = 0 
                              AND l.is_deleted = 0";

                        cmd.Parameters.AddWithValue("@quizSlug", quizSlug);
                        cmd.Parameters.AddWithValue("@levelSlug", levelSlug);

                        using (var reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                lblQuizTitle.Text = reader["title"].ToString();
                                lblTimeLimit.Text = reader["time_limit_minutes"].ToString();
                                lblPassingScore.Text = reader["passing_score"].ToString();
                                
                                hfTimeLimit.Value = reader["time_limit_minutes"].ToString();
                                hfPassingScore.Value = reader["passing_score"].ToString();
                                hfXpReward.Value = reader["xp_reward"].ToString();
                            }
                            else
                            {
                                System.Diagnostics.Debug.WriteLine("[TakeQuiz] Quiz not found");
                                Response.Redirect("~/Pages/student/dashboard_student.aspx", false);
                                return;
                            }
                        }
                    }

                    // Load questions
                    List<dynamic> questions = new List<dynamic>();
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            SELECT 
                                question_slug,
                                body_text,
                                options_json,
                                answer_idx
                            FROM Questions
                            WHERE quiz_slug = @quizSlug AND is_deleted = 0
                            ORDER BY order_no ASC";

                        cmd.Parameters.AddWithValue("@quizSlug", quizSlug);

                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                string optionsJson = reader["options_json"]?.ToString() ?? "[]";
                                int answerIdx = reader["answer_idx"] != DBNull.Value ? Convert.ToInt32(reader["answer_idx"]) : 0;
                                
                                // Parse options JSON
                                var serializer = new JavaScriptSerializer();
                                List<string> optionsList = serializer.Deserialize<List<string>>(optionsJson);
                                
                                // Convert answer_idx to letter (0->A, 1->B, etc.)
                                string correctAnswer = "";
                                if (answerIdx >= 0 && answerIdx < 4)
                                {
                                    correctAnswer = ((char)('A' + answerIdx)).ToString();
                                }
                                
                                questions.Add(new
                                {
                                    QuestionSlug = reader["question_slug"].ToString(),
                                    QuestionText = reader["body_text"].ToString(),
                                    OptionA = optionsList.Count > 0 ? optionsList[0] : "",
                                    OptionB = optionsList.Count > 1 ? optionsList[1] : "",
                                    OptionC = optionsList.Count > 2 ? optionsList[2] : "",
                                    OptionD = optionsList.Count > 3 ? optionsList[3] : "",
                                    CorrectAnswer = correctAnswer
                                });
                            }
                        }
                    }

                    System.Diagnostics.Debug.WriteLine($"[TakeQuiz] Loaded {questions.Count} questions");

                    var jsonSerializer = new JavaScriptSerializer();
                    hfQuestionsJson.Value = jsonSerializer.Serialize(questions);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[TakeQuiz] Error: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"[TakeQuiz] Stack: {ex.StackTrace}");
            }
        }
    }
}


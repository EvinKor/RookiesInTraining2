using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace RookiesInTraining2.Pages.teacher
{
    public partial class edit_quiz : System.Web.UI.Page
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
                string quizSlug = Request.QueryString["quiz"];
                string levelSlug = Request.QueryString["level"];
                string classSlug = Request.QueryString["class"];
                
                if (string.IsNullOrWhiteSpace(quizSlug) || string.IsNullOrWhiteSpace(classSlug))
                {
                    Response.Redirect("~/Pages/teacher/manage_classes.aspx", false);
                    return;
                }

                hfQuizSlug.Value = quizSlug;
                hfLevelSlug.Value = levelSlug;
                hfClassSlug.Value = classSlug;
                
                // Set back link
                lnkBack.NavigateUrl = $"~/Pages/teacher/manage_classes.aspx?class={classSlug}&tab=storymode";
                lnkAddQuestions.NavigateUrl = $"~/Pages/teacher/add_questions.aspx?quiz={quizSlug}&class={classSlug}";
                lnkAddFirstQuestion.NavigateUrl = $"~/Pages/teacher/add_questions.aspx?quiz={quizSlug}&class={classSlug}";

                // Load quiz details
                LoadQuiz(quizSlug);
                
                // Load questions
                LoadQuestions(quizSlug);
            }
        }

        private void LoadQuiz(string quizSlug)
        {
            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            SELECT title, mode, time_limit_minutes, passing_score, published
                            FROM Quizzes
                            WHERE quiz_slug = @quizSlug AND is_deleted = 0";

                        cmd.Parameters.AddWithValue("@quizSlug", quizSlug);

                        using (var reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                lblQuizTitle.Text = reader["title"].ToString();
                                txtTitle.Text = reader["title"].ToString();
                                ddlMode.SelectedValue = reader["mode"].ToString();
                                txtTimeLimit.Text = reader["time_limit_minutes"].ToString();
                                txtPassingScore.Text = reader["passing_score"].ToString();
                                // chkPublished checkbox removed - published status is read-only
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[EditQuiz] Error loading quiz: {ex.Message}");
            }
        }

        private void LoadQuestions(string quizSlug)
        {
            List<dynamic> questions = new List<dynamic>();

            System.Diagnostics.Debug.WriteLine($"[EditQuiz] ========== LoadQuestions START ==========");
            System.Diagnostics.Debug.WriteLine($"[EditQuiz] Quiz Slug: {quizSlug}");

            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            SELECT question_slug, order_no, body_text, question_type, difficulty
                            FROM Questions
                            WHERE quiz_slug = @quizSlug AND is_deleted = 0
                            ORDER BY order_no ASC";

                        cmd.Parameters.AddWithValue("@quizSlug", quizSlug);

                        System.Diagnostics.Debug.WriteLine($"[EditQuiz] Executing query...");

                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                questions.Add(new
                                {
                                    QuestionSlug = reader["question_slug"].ToString(),
                                    QuestionNumber = Convert.ToInt32(reader["order_no"]),
                                    QuestionText = reader["body_text"].ToString(),
                                    QuestionType = reader["question_type"].ToString(),
                                    Points = 10 // Default points
                                });
                            }
                        }
                    }
                }

                System.Diagnostics.Debug.WriteLine($"[EditQuiz] Found {questions.Count} questions");

                if (questions.Count > 0)
                {
                    rptQuestions.DataSource = questions;
                    rptQuestions.DataBind();
                    lblNoQuestions.Visible = false;
                    System.Diagnostics.Debug.WriteLine($"[EditQuiz] ✅ Questions bound to repeater");
                }
                else
                {
                    lblNoQuestions.Visible = true;
                    System.Diagnostics.Debug.WriteLine($"[EditQuiz] No questions found - showing empty state");
                }
                
                System.Diagnostics.Debug.WriteLine($"[EditQuiz] ========== LoadQuestions END ==========");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[EditQuiz] ❌ ERROR loading questions: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"[EditQuiz] Stack trace: {ex.StackTrace}");
                lblNoQuestions.Visible = true;
            }
        }

        protected void btnSaveSettings_Click(object sender, EventArgs e)
        {
            string quizSlug = hfQuizSlug.Value;
            string classSlug = hfClassSlug.Value;
            string title = txtTitle.Text.Trim();
            string mode = ddlMode.SelectedValue;
            int timeLimit = int.Parse(txtTimeLimit.Text);
            int passingScore = int.Parse(txtPassingScore.Text);
            // chkPublished checkbox removed - preserve existing published status
            bool published = false;

            if (string.IsNullOrWhiteSpace(title))
            {
                lblError.Text = "Quiz title is required.";
                lblError.Visible = true;
                return;
            }

            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();
                    
                    // Get current published status from database
                    using (var getPublishedCmd = con.CreateCommand())
                    {
                        getPublishedCmd.CommandText = "SELECT published FROM Quizzes WHERE quiz_slug = @quizSlug AND is_deleted = 0";
                        getPublishedCmd.Parameters.AddWithValue("@quizSlug", hfQuizSlug.Value);
                        object result = getPublishedCmd.ExecuteScalar();
                        if (result != null)
                        {
                            published = Convert.ToBoolean(result);
                        }
                    }
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            UPDATE Quizzes 
                            SET title = @title,
                                mode = @mode,
                                time_limit_minutes = @timeLimit,
                                passing_score = @passingScore,
                                published = @published,
                                updated_at = SYSUTCDATETIME()
                            WHERE quiz_slug = @quizSlug AND is_deleted = 0";

                        cmd.Parameters.AddWithValue("@quizSlug", quizSlug);
                        cmd.Parameters.AddWithValue("@title", title);
                        cmd.Parameters.AddWithValue("@mode", mode);
                        cmd.Parameters.AddWithValue("@timeLimit", timeLimit);
                        cmd.Parameters.AddWithValue("@passingScore", passingScore);
                        cmd.Parameters.AddWithValue("@published", published ? 1 : 0);

                        cmd.ExecuteNonQuery();
                    }
                }

                // Redirect to refresh
                Response.Redirect($"~/Pages/teacher/edit_quiz.aspx?quiz={quizSlug}&level={hfLevelSlug.Value}&class={classSlug}", false);
            }
            catch (Exception ex)
            {
                lblError.Text = $"Error saving quiz settings: {Server.HtmlEncode(ex.Message)}";
                lblError.Visible = true;
                System.Diagnostics.Debug.WriteLine($"[EditQuiz] Error: {ex}");
            }
        }

        protected void DeleteQuestion_Command(object sender, CommandEventArgs e)
        {
            string questionSlug = e.CommandArgument.ToString();
            string quizSlug = hfQuizSlug.Value;
            string classSlug = hfClassSlug.Value;
            string levelSlug = hfLevelSlug.Value;

            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            UPDATE Questions 
                            SET is_deleted = 1, updated_at = SYSUTCDATETIME()
                            WHERE question_slug = @questionSlug";

                        cmd.Parameters.AddWithValue("@questionSlug", questionSlug);
                        cmd.ExecuteNonQuery();
                    }
                }

                // Redirect to refresh
                Response.Redirect($"~/Pages/teacher/edit_quiz.aspx?quiz={quizSlug}&level={levelSlug}&class={classSlug}", false);
            }
            catch (Exception ex)
            {
                lblError.Text = $"Error deleting question: {Server.HtmlEncode(ex.Message)}";
                lblError.Visible = true;
                System.Diagnostics.Debug.WriteLine($"[EditQuiz] Delete error: {ex}");
            }
        }
    }
}


using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace RookiesInTraining2.Pages
{
    public partial class add_questions : System.Web.UI.Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Disable unobtrusive validation
            System.Web.UI.ValidationSettings.UnobtrusiveValidationMode =
                System.Web.UI.UnobtrusiveValidationMode.None;

            // Guard: Check authentication
            if (Session["UserSlug"] == null)
            {
                Response.Redirect("~/Pages/Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            // Guard: Check role
            string role = Convert.ToString(Session["Role"])?.ToLowerInvariant() ?? "";
            if (role != "teacher" && role != "admin")
            {
                Response.Redirect("~/Pages/Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            // Guard: Check quiz slug
            string quizSlug = Request.QueryString["quiz"];
            if (string.IsNullOrEmpty(quizSlug))
            {
                Response.Redirect("~/Pages/teacher_classes.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (!IsPostBack)
            {
                hfQuizSlug.Value = quizSlug;
                LoadQuizData(quizSlug);
            }
        }

        private void LoadQuizData(string quizSlug)
        {
            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();

                    // Load quiz info
                    var quiz = LoadQuiz(quizSlug, con);
                    if (quiz == null)
                    {
                        Response.Redirect("~/Pages/teacher_classes.aspx", false);
                        return;
                    }

                    // Load questions
                    var questions = LoadQuestions(quizSlug, con);

                    // Serialize to JSON
                    var serializer = new JavaScriptSerializer();
                    hfQuizData.Value = serializer.Serialize(quiz);
                    hfQuestionsJson.Value = serializer.Serialize(questions);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[AddQuestions] Error: {ex}");
            }
        }

        private QuizInfo LoadQuiz(string quizSlug, SqlConnection con)
        {
            using (var cmd = con.CreateCommand())
            {
                cmd.CommandText = @"
                    SELECT quiz_slug, title, mode, published,
                           ISNULL(time_limit_minutes, 30) AS time_limit_minutes,
                           ISNULL(passing_score, 70) AS passing_score
                    FROM Quizzes
                    WHERE quiz_slug = @slug AND is_deleted = 0";

                cmd.Parameters.AddWithValue("@slug", quizSlug);

                using (var reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        return new QuizInfo
                        {
                            QuizSlug = reader["quiz_slug"].ToString(),
                            Title = reader["title"].ToString(),
                            Mode = reader["mode"].ToString(),
                            Published = Convert.ToBoolean(reader["published"]),
                            TimeLimit = Convert.ToInt32(reader["time_limit_minutes"]),
                            PassingScore = Convert.ToInt32(reader["passing_score"])
                        };
                    }
                }
            }
            return null;
        }

        private List<QuestionInfo> LoadQuestions(string quizSlug, SqlConnection con)
        {
            var questions = new List<QuestionInfo>();

            using (var cmd = con.CreateCommand())
            {
                cmd.CommandText = @"
                    SELECT 
                        question_slug, body_text, options_json, answer_idx, 
                        difficulty, ISNULL(explanation, '') AS explanation,
                        ISNULL(order_no, 1) AS order_no
                    FROM Questions
                    WHERE quiz_slug = @quizSlug AND is_deleted = 0
                    ORDER BY order_no, created_at";

                cmd.Parameters.AddWithValue("@quizSlug", quizSlug);

                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        questions.Add(new QuestionInfo
                        {
                            QuestionSlug = reader["question_slug"].ToString(),
                            BodyText = reader["body_text"].ToString(),
                            OptionsJson = reader["options_json"].ToString(),
                            AnswerIdx = Convert.ToInt32(reader["answer_idx"]),
                            Difficulty = Convert.ToInt32(reader["difficulty"]),
                            Explanation = reader["explanation"].ToString(),
                            OrderNo = Convert.ToInt32(reader["order_no"])
                        });
                    }
                }
            }

            return questions;
        }

        protected void btnSaveQuestion_Click(object sender, EventArgs e)
        {
            SaveQuestion(false);
        }

        protected void btnSaveAndAddAnother_Click(object sender, EventArgs e)
        {
            SaveQuestion(true);
        }

        private void SaveQuestion(bool addAnother)
        {
            Page.Validate("AddQuestion");
            if (!Page.IsValid) return;

            string quizSlug = hfQuizSlug.Value;
            string questionText = txtQuestionBody.Text.Trim();
            string option1 = txtOption1.Text.Trim();
            string option2 = txtOption2.Text.Trim();
            string option3 = txtOption3.Text.Trim();
            string option4 = txtOption4.Text.Trim();
            int correctIdx = int.Parse(hfCorrectAnswerIdx.Value);
            int difficulty = int.Parse(ddlDifficulty.SelectedValue);
            string explanation = txtExplanation.Text.Trim();

            // Validate at least 2 options filled
            int filledOptions = 0;
            if (!string.IsNullOrEmpty(option1)) filledOptions++;
            if (!string.IsNullOrEmpty(option2)) filledOptions++;
            if (!string.IsNullOrEmpty(option3)) filledOptions++;
            if (!string.IsNullOrEmpty(option4)) filledOptions++;

            if (filledOptions < 2)
            {
                lblQuestionError.Text = "Please provide at least 2 answer options.";
                lblQuestionError.Visible = true;
                return;
            }

            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();

                    // Generate slug
                    string questionSlug = "q-" + Guid.NewGuid().ToString("N").Substring(0, 12);

                    // Get next order number
                    int orderNo = 1;
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = "SELECT ISNULL(MAX(order_no), 0) + 1 FROM Questions WHERE quiz_slug = @quiz AND is_deleted = 0";
                        cmd.Parameters.AddWithValue("@quiz", quizSlug);
                        orderNo = Convert.ToInt32(cmd.ExecuteScalar());
                    }

                    // Build options JSON
                    var options = new List<string>();
                    if (!string.IsNullOrEmpty(option1)) options.Add(option1);
                    if (!string.IsNullOrEmpty(option2)) options.Add(option2);
                    if (!string.IsNullOrEmpty(option3)) options.Add(option3);
                    if (!string.IsNullOrEmpty(option4)) options.Add(option4);

                    var serializer = new JavaScriptSerializer();
                    string optionsJson = serializer.Serialize(options);

                    // Insert question
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            INSERT INTO Questions
                            (question_slug, quiz_slug, body_text, options_json, answer_idx,
                             difficulty, explanation, order_no, created_at, updated_at, is_deleted)
                            VALUES
                            (@slug, @quizSlug, @body, @options, @answerIdx,
                             @difficulty, @explanation, @orderNo, SYSUTCDATETIME(), SYSUTCDATETIME(), 0)";

                        cmd.Parameters.AddWithValue("@slug", questionSlug);
                        cmd.Parameters.AddWithValue("@quizSlug", quizSlug);
                        cmd.Parameters.AddWithValue("@body", questionText);
                        cmd.Parameters.AddWithValue("@options", optionsJson);
                        cmd.Parameters.AddWithValue("@answerIdx", correctIdx);
                        cmd.Parameters.AddWithValue("@difficulty", difficulty);
                        cmd.Parameters.AddWithValue("@explanation", (object)explanation ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@orderNo", orderNo);

                        cmd.ExecuteNonQuery();
                    }

                    // Clear form
                    ClearQuestionForm();

                    // Reload data
                    LoadQuizData(quizSlug);

                    if (addAnother)
                    {
                        ScriptManager.RegisterStartupScript(this, GetType(), "success",
                            "showSuccessToast('Question added! Add another one.');", true);
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, GetType(), "closeModal",
                            "closeAddQuestionModal(); showSuccessToast('Question added successfully!');", true);
                    }
                }
            }
            catch (Exception ex)
            {
                lblQuestionError.Text = "Error saving question: " + Server.HtmlEncode(ex.Message);
                lblQuestionError.Visible = true;
                System.Diagnostics.Debug.WriteLine($"[AddQuestions] Error: {ex}");
            }
        }

        private void ClearQuestionForm()
        {
            txtQuestionBody.Text = "";
            txtOption1.Text = "";
            txtOption2.Text = "";
            txtOption3.Text = "";
            txtOption4.Text = "";
            txtExplanation.Text = "";
            ddlDifficulty.SelectedValue = "3";
            hfCorrectAnswerIdx.Value = "0";
            lblQuestionError.Visible = false;
        }

        #region Data Classes

        public class QuizInfo
        {
            public string QuizSlug { get; set; }
            public string Title { get; set; }
            public string Mode { get; set; }
            public bool Published { get; set; }
            public int TimeLimit { get; set; }
            public int PassingScore { get; set; }
        }

        public class QuestionInfo
        {
            public string QuestionSlug { get; set; }
            public string BodyText { get; set; }
            public string OptionsJson { get; set; }
            public int AnswerIdx { get; set; }
            public int Difficulty { get; set; }
            public string Explanation { get; set; }
            public int OrderNo { get; set; }
        }

        #endregion
    }
}


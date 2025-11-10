using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace RookiesInTraining2.Pages.teacher
{
    public partial class edit_question : System.Web.UI.Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Disable unobtrusive validation
            System.Web.UI.ValidationSettings.UnobtrusiveValidationMode =
                System.Web.UI.UnobtrusiveValidationMode.None;

            // Check authentication
            if (Session["UserSlug"] == null)
            {
                Response.Redirect("~/Pages/Login.aspx", false);
                return;
            }

            // Check role
            string role = Convert.ToString(Session["Role"])?.ToLowerInvariant() ?? "";
            if (role != "teacher" && role != "admin")
            {
                Response.Redirect("~/Pages/Login.aspx", false);
                return;
            }

            if (!IsPostBack)
            {
                string questionSlug = Request.QueryString["question"];
                string quizSlug = Request.QueryString["quiz"];
                string classSlug = Request.QueryString["class"];

                if (string.IsNullOrWhiteSpace(questionSlug) || string.IsNullOrWhiteSpace(quizSlug))
                {
                    Response.Redirect("~/Pages/teacher/manage_classes.aspx", false);
                    return;
                }

                hfQuestionSlug.Value = questionSlug;
                hfQuizSlug.Value = quizSlug;
                hfClassSlug.Value = classSlug ?? "";

                // Set back link to edit quiz page
                string levelSlug = Request.QueryString["level"] ?? "";
                if (!string.IsNullOrWhiteSpace(classSlug))
                {
                    if (!string.IsNullOrWhiteSpace(levelSlug))
                    {
                        lnkBack.NavigateUrl = $"~/Pages/teacher/edit_quiz.aspx?quiz={quizSlug}&level={levelSlug}&class={classSlug}";
                    }
                    else
                    {
                        lnkBack.NavigateUrl = $"~/Pages/teacher/edit_quiz.aspx?quiz={quizSlug}&class={classSlug}";
                    }
                }
                else
                {
                    if (!string.IsNullOrWhiteSpace(levelSlug))
                    {
                        lnkBack.NavigateUrl = $"~/Pages/teacher/edit_quiz.aspx?quiz={quizSlug}&level={levelSlug}";
                    }
                    else
                    {
                        lnkBack.NavigateUrl = $"~/Pages/teacher/edit_quiz.aspx?quiz={quizSlug}";
                    }
                }

                // Load question data
                LoadQuestion(questionSlug, quizSlug);
            }
        }

        private void LoadQuestion(string questionSlug, string quizSlug)
        {
            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();

                    // Load quiz title
                    using (var quizCmd = con.CreateCommand())
                    {
                        quizCmd.CommandText = "SELECT title FROM Quizzes WHERE quiz_slug = @quizSlug AND is_deleted = 0";
                        quizCmd.Parameters.AddWithValue("@quizSlug", quizSlug);
                        object quizTitle = quizCmd.ExecuteScalar();
                        if (quizTitle != null)
                        {
                            lblQuizTitle.Text = quizTitle.ToString();
                        }
                    }

                    // Load question
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            SELECT body_text, options_json, answer_idx, difficulty, explanation
                            FROM Questions
                            WHERE question_slug = @questionSlug AND quiz_slug = @quizSlug AND is_deleted = 0";

                        cmd.Parameters.AddWithValue("@questionSlug", questionSlug);
                        cmd.Parameters.AddWithValue("@quizSlug", quizSlug);

                        using (var reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                txtQuestionBody.Text = reader["body_text"].ToString();
                                
                                // Parse options JSON
                                string optionsJson = reader["options_json"]?.ToString() ?? "[]";
                                var serializer = new JavaScriptSerializer();
                                var options = serializer.Deserialize<List<string>>(optionsJson);

                                // Populate option textboxes
                                if (options.Count > 0) txtOption1.Text = options[0];
                                if (options.Count > 1) txtOption2.Text = options[1];
                                if (options.Count > 2) txtOption3.Text = options[2];
                                if (options.Count > 3) txtOption4.Text = options[3];

                                // Set correct answer
                                int answerIdx = Convert.ToInt32(reader["answer_idx"]);
                                hfCorrectAnswerIdx.Value = answerIdx.ToString();
                                
                                // Store answer index in a hidden field for JavaScript
                                Page.ClientScript.RegisterStartupScript(this.GetType(), "SetCorrectAnswer", 
                                    $"document.getElementById('radio{answerIdx}').checked = true;", true);
                                
                                // Set difficulty
                                int difficulty = Convert.ToInt32(reader["difficulty"]);
                                if (ddlDifficulty.Items.FindByValue(difficulty.ToString()) != null)
                                {
                                    ddlDifficulty.SelectedValue = difficulty.ToString();
                                }

                                // Set explanation
                                txtExplanation.Text = reader["explanation"]?.ToString() ?? "";
                            }
                            else
                            {
                                lblError.Text = "Question not found.";
                                lblError.Visible = true;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[EditQuestion] Error loading question: {ex}");
                lblError.Text = $"Error loading question: {Server.HtmlEncode(ex.Message)}";
                lblError.Visible = true;
            }
        }

        protected void btnSaveQuestion_Click(object sender, EventArgs e)
        {
            Page.Validate("EditQuestion");
            if (!Page.IsValid) return;

            string questionSlug = hfQuestionSlug.Value;
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
                lblError.Text = "Please provide at least 2 answer options.";
                lblError.Visible = true;
                return;
            }

            // Validate correct answer index
            if (correctIdx >= filledOptions)
            {
                lblError.Text = "The selected correct answer must be one of the provided options.";
                lblError.Visible = true;
                return;
            }

            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();

                    // Build options JSON
                    var options = new List<string>();
                    if (!string.IsNullOrEmpty(option1)) options.Add(option1);
                    if (!string.IsNullOrEmpty(option2)) options.Add(option2);
                    if (!string.IsNullOrEmpty(option3)) options.Add(option3);
                    if (!string.IsNullOrEmpty(option4)) options.Add(option4);

                    var serializer = new JavaScriptSerializer();
                    string optionsJson = serializer.Serialize(options);

                    // Update question
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            UPDATE Questions
                            SET body_text = @body,
                                options_json = @options,
                                answer_idx = @answerIdx,
                                difficulty = @difficulty,
                                explanation = @explanation,
                                updated_at = SYSUTCDATETIME()
                            WHERE question_slug = @questionSlug AND quiz_slug = @quizSlug AND is_deleted = 0";

                        cmd.Parameters.AddWithValue("@questionSlug", questionSlug);
                        cmd.Parameters.AddWithValue("@quizSlug", quizSlug);
                        cmd.Parameters.AddWithValue("@body", questionText);
                        cmd.Parameters.AddWithValue("@options", optionsJson);
                        cmd.Parameters.AddWithValue("@answerIdx", correctIdx);
                        cmd.Parameters.AddWithValue("@difficulty", difficulty);
                        cmd.Parameters.AddWithValue("@explanation", (object)explanation ?? DBNull.Value);

                        int rowsAffected = cmd.ExecuteNonQuery();
                        
                        if (rowsAffected == 0)
                        {
                            lblError.Text = "Question not found or could not be updated.";
                            lblError.Visible = true;
                            return;
                        }
                    }

                    System.Diagnostics.Debug.WriteLine($"[EditQuestion] Question updated: {questionSlug}");

                    // Redirect back to edit quiz page
                    string classSlug = hfClassSlug.Value;
                    string levelSlug = Request.QueryString["level"] ?? "";
                    string redirectUrl = $"~/Pages/teacher/edit_quiz.aspx?quiz={quizSlug}";
                    if (!string.IsNullOrWhiteSpace(levelSlug))
                    {
                        redirectUrl += $"&level={levelSlug}";
                    }
                    if (!string.IsNullOrWhiteSpace(classSlug))
                    {
                        redirectUrl += $"&class={classSlug}";
                    }
                    Response.Redirect(redirectUrl, false);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[EditQuestion] Error: {ex}");
                lblError.Text = $"Error updating question: {Server.HtmlEncode(ex.Message)}";
                lblError.Visible = true;
            }
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            string quizSlug = hfQuizSlug.Value;
            string classSlug = hfClassSlug.Value;
            string levelSlug = Request.QueryString["level"] ?? "";
            string redirectUrl = $"~/Pages/teacher/edit_quiz.aspx?quiz={quizSlug}";
            if (!string.IsNullOrWhiteSpace(levelSlug))
            {
                redirectUrl += $"&level={levelSlug}";
            }
            if (!string.IsNullOrWhiteSpace(classSlug))
            {
                redirectUrl += $"&class={classSlug}";
            }
            Response.Redirect(redirectUrl, false);
        }
    }
}


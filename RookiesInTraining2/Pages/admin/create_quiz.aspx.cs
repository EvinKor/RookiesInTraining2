using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Text;
using System.Text.RegularExpressions;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace RookiesInTraining2.Pages.admin
{
    public partial class create_quiz : System.Web.UI.Page
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

            // Check role - admin only
            string role = Convert.ToString(Session["Role"])?.ToLowerInvariant();
            if (role != "admin")
            {
                Response.Redirect("~/Pages/Login.aspx", false);
                return;
            }

            if (!IsPostBack)
            {
                string classSlug = Request.QueryString["class"];
                string quizSlug = Request.QueryString["quiz"];
                string levelSlug = Request.QueryString["level"];
                
                if (string.IsNullOrWhiteSpace(classSlug))
                {
                    Response.Redirect("~/Pages/admin/manage_classes.aspx", false);
                    return;
                }

                hfClassSlug.Value = classSlug;
                
                // Set back link to storymode tab
                lnkBack.NavigateUrl = $"~/Pages/admin/manage_classes.aspx?class={classSlug}&tab=storymode";

                // If quiz slug exists, we're editing an existing quiz
                if (!string.IsNullOrWhiteSpace(quizSlug))
                {
                    hfQuizSlug.Value = quizSlug;
                    hfLevelSlug.Value = levelSlug ?? "";
                    
                    // Hide level selection, load quiz data
                    pnlLevelSelection.Visible = false;
                    LoadQuiz(quizSlug);
                    LoadQuestions(quizSlug);
                    
                    // Update page title
                    lblPageTitle.Text = "Edit Quiz";
                    
                    // Set add questions links
                    lnkAddQuestions.NavigateUrl = $"~/Pages/admin/add_questions.aspx?quiz={quizSlug}&class={classSlug}";
                    lnkAddFirstQuestion.NavigateUrl = $"~/Pages/admin/add_questions.aspx?quiz={quizSlug}&class={classSlug}";
                    lnkAddQuestions.Visible = true;
                }
                else
                {
                    // Creating new quiz - show level selection
                    pnlLevelSelection.Visible = true;
                    // Questions section will show empty state after quiz is created
                    lblNoQuestions.Visible = false;
                    rptQuestions.Visible = false;
                    lnkAddQuestions.Visible = false;
                    
                    // Load levels for dropdown
                    LoadLevels(classSlug);
                }
            }
        }

        private void LoadLevels(string classSlug)
        {
            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            SELECT level_slug, level_number, title
                            FROM Levels
                            WHERE class_slug = @classSlug AND is_deleted = 0
                            ORDER BY level_number ASC";

                        cmd.Parameters.AddWithValue("@classSlug", classSlug);

                        ddlLevelForQuiz.Items.Clear();
                        ddlLevelForQuiz.Items.Add(new System.Web.UI.WebControls.ListItem("-- Select Level --", ""));

                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                string levelSlug = reader["level_slug"].ToString();
                                int levelNumber = Convert.ToInt32(reader["level_number"]);
                                string title = reader["title"].ToString();
                                
                                ddlLevelForQuiz.Items.Add(new System.Web.UI.WebControls.ListItem(
                                    $"Level {levelNumber}: {title}", levelSlug));
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[CreateQuiz] Error loading levels: {ex.Message}");
                lblError.Text = "Error loading levels.";
                lblError.Visible = true;
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
                            SELECT title, mode, time_limit_minutes, passing_score, published, level_slug
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
                                hfLevelSlug.Value = reader["level_slug"].ToString();
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[CreateQuiz] Error loading quiz: {ex.Message}");
            }
        }

        private void LoadQuestions(string quizSlug)
        {
            List<dynamic> questions = new List<dynamic>();

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

                if (questions.Count > 0)
                {
                    rptQuestions.DataSource = questions;
                    rptQuestions.DataBind();
                    lblNoQuestions.Visible = false;
                    rptQuestions.Visible = true;
                    lnkAddQuestions.Visible = true;
                }
                else
                {
                    lblNoQuestions.Visible = true;
                    rptQuestions.Visible = false;
                    lnkAddQuestions.Visible = true;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[CreateQuiz] Error loading questions: {ex.Message}");
                lblNoQuestions.Visible = true;
                rptQuestions.Visible = false;
            }
        }

        protected void btnSaveSettings_Click(object sender, EventArgs e)
        {
            string classSlug = hfClassSlug.Value;
            string quizSlug = hfQuizSlug.Value;
            bool isEdit = !string.IsNullOrWhiteSpace(quizSlug);

            if (isEdit)
            {
                // Update existing quiz
                UpdateQuiz(quizSlug, classSlug);
            }
            else
            {
                // Create new quiz
                CreateQuiz(classSlug);
            }
        }

        private void CreateQuiz(string classSlug)
        {
            if (!Page.IsValid) return;

            string levelSlug = ddlLevelForQuiz.SelectedValue;
            if (string.IsNullOrWhiteSpace(levelSlug))
            {
                lblError.Text = "Please select a level.";
                lblError.Visible = true;
                return;
            }

            string quizTitle = txtTitle.Text.Trim();
            if (string.IsNullOrWhiteSpace(quizTitle))
            {
                lblError.Text = "Quiz title is required.";
                lblError.Visible = true;
                return;
            }

            int timeLimit = int.Parse(txtTimeLimit.Text);
            int passingScore = int.Parse(txtPassingScore.Text);
            string mode = ddlMode.SelectedValue;
            bool publish = false;
            string adminSlug = Session["UserSlug"]?.ToString() ?? "";

            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();

                    // Check if level already has a quiz
                    using (var checkCmd = con.CreateCommand())
                    {
                        checkCmd.CommandText = @"
                            SELECT COUNT(*) 
                            FROM Quizzes 
                            WHERE level_slug = @levelSlug AND is_deleted = 0";
                        checkCmd.Parameters.AddWithValue("@levelSlug", levelSlug);
                        
                        int existingQuizCount = Convert.ToInt32(checkCmd.ExecuteScalar());
                        if (existingQuizCount > 0)
                        {
                            lblError.Text = "This level already has a quiz. Each level can only have one quiz.";
                            lblError.Visible = true;
                            return;
                        }
                    }

                    // Generate slug
                    string baseSlug = SlugifyText(quizTitle);
                    string quizSlug = GenerateUniqueSlug(baseSlug, "Quizzes", "quiz_slug", con);

                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            INSERT INTO Quizzes 
                            (quiz_slug, title, mode, published, created_by_slug,
                             class_slug, level_slug, time_limit_minutes, passing_score,
                             created_at, updated_at, is_deleted)
                            VALUES 
                            (@slug, @title, @mode, @publish, @adminSlug,
                             @classSlug, @levelSlug, @timeLimit, @passingScore,
                             SYSUTCDATETIME(), SYSUTCDATETIME(), 0)";

                        cmd.Parameters.AddWithValue("@slug", quizSlug);
                        cmd.Parameters.AddWithValue("@title", quizTitle);
                        cmd.Parameters.AddWithValue("@mode", mode);
                        cmd.Parameters.AddWithValue("@publish", publish ? 1 : 0);
                        cmd.Parameters.AddWithValue("@adminSlug", adminSlug);
                        cmd.Parameters.AddWithValue("@classSlug", classSlug);
                        cmd.Parameters.AddWithValue("@levelSlug", levelSlug);
                        cmd.Parameters.AddWithValue("@timeLimit", timeLimit);
                        cmd.Parameters.AddWithValue("@passingScore", passingScore);

                        cmd.ExecuteNonQuery();
                    }

                    // Redirect to edit mode with quiz slug
                    Response.Redirect($"~/Pages/admin/create_quiz.aspx?quiz={quizSlug}&level={levelSlug}&class={classSlug}", false);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[CreateQuiz] Error: {ex}");
                lblError.Text = $"Error creating quiz: {Server.HtmlEncode(ex.Message)}";
                lblError.Visible = true;
            }
        }

        private void UpdateQuiz(string quizSlug, string classSlug)
        {
            string title = txtTitle.Text.Trim();
            string mode = ddlMode.SelectedValue;
            int timeLimit = int.Parse(txtTimeLimit.Text);
            int passingScore = int.Parse(txtPassingScore.Text);
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
                        getPublishedCmd.Parameters.AddWithValue("@quizSlug", quizSlug);
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

                // Reload quiz data and redirect to refresh
                LoadQuiz(quizSlug);
                LoadQuestions(quizSlug);
                lblError.Text = "Quiz settings saved successfully.";
                lblError.CssClass = "alert alert-success";
                lblError.Visible = true;
            }
            catch (Exception ex)
            {
                lblError.Text = $"Error saving quiz settings: {Server.HtmlEncode(ex.Message)}";
                lblError.Visible = true;
                System.Diagnostics.Debug.WriteLine($"[CreateQuiz] Error: {ex}");
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
                Response.Redirect($"~/Pages/admin/create_quiz.aspx?quiz={quizSlug}&level={levelSlug}&class={classSlug}", false);
            }
            catch (Exception ex)
            {
                lblError.Text = $"Error deleting question: {Server.HtmlEncode(ex.Message)}";
                lblError.Visible = true;
                System.Diagnostics.Debug.WriteLine($"[CreateQuiz] Delete error: {ex}");
            }
        }

        private string SlugifyText(string text)
        {
            string slug = text.ToLowerInvariant();
            slug = Regex.Replace(slug, @"[^a-z0-9\s-]", "");
            slug = Regex.Replace(slug, @"\s+", "-");
            slug = Regex.Replace(slug, @"-+", "-");
            slug = slug.Trim('-');
            return slug;
        }

        private string GenerateUniqueSlug(string baseSlug, string tableName, string columnName, SqlConnection con)
        {
            string slug = baseSlug;
            int counter = 1;

            while (SlugExists(slug, tableName, columnName, con))
            {
                slug = $"{baseSlug}-{counter}";
                counter++;
            }

            return slug;
        }

        private bool SlugExists(string slug, string tableName, string columnName, SqlConnection con)
        {
            using (var cmd = con.CreateCommand())
            {
                cmd.CommandText = $"SELECT COUNT(*) FROM {tableName} WHERE {columnName} = @slug";
                cmd.Parameters.AddWithValue("@slug", slug);
                int count = (int)cmd.ExecuteScalar();
                return count > 0;
            }
        }
    }
}


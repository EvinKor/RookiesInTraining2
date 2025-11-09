using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Text;
using System.Text.RegularExpressions;
using System.Web.UI;

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
                if (string.IsNullOrWhiteSpace(classSlug))
                {
                    Response.Redirect("~/Pages/admin/manage_classes.aspx", false);
                    return;
                }

                hfClassSlug.Value = classSlug;
                
                // Set back link to storymode tab
                lnkBack.NavigateUrl = $"~/Pages/admin/manage_classes.aspx?class={classSlug}&tab=storymode";
                lnkCancel.NavigateUrl = $"~/Pages/admin/manage_classes.aspx?class={classSlug}&tab=storymode";

                // Load levels for dropdown
                LoadLevels(classSlug);
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

        protected void btnCreateQuiz_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string classSlug = hfClassSlug.Value;
            string levelSlug = ddlLevelForQuiz.SelectedValue;
            string quizTitle = txtQuizTitle.Text.Trim();
            int timeLimit = int.Parse(txtTimeLimit.Text);
            int passingScore = int.Parse(txtPassingScore.Text);
            string mode = ddlQuizMode.SelectedValue;
            bool publish = chkPublishQuiz.Checked;
            string adminSlug = Session["UserSlug"]?.ToString() ?? "";
            
            System.Diagnostics.Debug.WriteLine($"[CreateQuiz] Creating quiz: {quizTitle}");
            System.Diagnostics.Debug.WriteLine($"[CreateQuiz] Class: {classSlug}, Level: {levelSlug}");
            System.Diagnostics.Debug.WriteLine($"[CreateQuiz] Mode: {mode}, Publish: {publish}");

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

                    System.Diagnostics.Debug.WriteLine($"[CreateQuiz] Quiz created successfully: {quizSlug}");

                    // Redirect back to manage classes (storymode tab)
                    Response.Redirect($"~/Pages/admin/manage_classes.aspx?class={classSlug}&tab=storymode", false);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[CreateQuiz] Error: {ex}");
                lblError.Text = $"Error creating quiz: {Server.HtmlEncode(ex.Message)}";
                lblError.Visible = true;
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


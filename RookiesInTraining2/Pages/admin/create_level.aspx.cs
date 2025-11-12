using System;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using System.Web.UI;

namespace RookiesInTraining2.Pages.admin
{
    public partial class create_level : System.Web.UI.Page
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
                    Response.Redirect("~/Pages/admin/Classes.aspx", false);
                    return;
                }

                hfClassSlug.Value = classSlug;
                
                // Set back link to storymode tab
                lnkBack.NavigateUrl = $"~/Pages/admin/Classes.aspx?class={classSlug}&tab=storymode";
                lnkCancel.NavigateUrl = $"~/Pages/admin/Classes.aspx?class={classSlug}&tab=storymode";

                // Load next level number
                LoadNextLevelNumber(classSlug);
            }
        }

        private void LoadNextLevelNumber(string classSlug)
        {
            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            SELECT ISNULL(MAX(level_number), 0) + 1 AS NextLevel
                            FROM Levels
                            WHERE class_slug = @classSlug AND is_deleted = 0";
                        cmd.Parameters.AddWithValue("@classSlug", classSlug);

                        object result = cmd.ExecuteScalar();
                        int nextLevel = result != null ? Convert.ToInt32(result) : 1;
                        
                        txtLevelNumber.Text = nextLevel.ToString();
                        txtQuizTitle.Text = $"Level {nextLevel} Quiz";
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[CreateLevel] Error loading next level: {ex.Message}");
                txtLevelNumber.Text = "1";
                txtQuizTitle.Text = "Level 1 Quiz";
            }
        }

        protected void btnCreateLevel_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string classSlug = hfClassSlug.Value;
            string adminSlug = Session["UserSlug"]?.ToString() ?? "";
            
            string title = txtLevelTitle.Text.Trim();
            string description = txtDescription.Text.Trim();
            int levelNumber = int.Parse(txtLevelNumber.Text);
            int minutes = int.Parse(txtMinutes.Text);
            int xp = int.Parse(txtXP.Text);
            
            string quizTitle = txtQuizTitle.Text.Trim();
            string quizMode = ddlQuizMode.SelectedValue;
            int timeLimit = int.Parse(txtTimeLimit.Text);
            int passingScore = int.Parse(txtPassingScore.Text);

            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();

                    // Generate slugs
                    string levelSlug = GenerateUniqueSlug(SlugifyText($"{classSlug}-level-{levelNumber}"), "Levels", "level_slug", con);
                    string quizSlug = GenerateUniqueSlug(SlugifyText($"{quizTitle}"), "Quizzes", "quiz_slug", con);

                    // Handle file upload
                    string contentType = null;
                    string contentUrl = null;

                    if (fileUpload.HasFile)
                    {
                        var result = HandleFileUpload(fileUpload, classSlug, levelSlug);
                        contentType = result.Item1;
                        contentUrl = result.Item2;
                    }

                    // Insert Quiz first
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            INSERT INTO Quizzes 
                            (quiz_slug, title, mode, class_slug, level_slug, time_limit_minutes, passing_score, 
                             published, created_by_slug, created_at, updated_at, is_deleted)
                            VALUES 
                            (@quizSlug, @quizTitle, @mode, @classSlug, @levelSlug, @timeLimit, @passingScore,
                             1, @createdBy, SYSUTCDATETIME(), SYSUTCDATETIME(), 0)";

                        cmd.Parameters.AddWithValue("@quizSlug", quizSlug);
                        cmd.Parameters.AddWithValue("@quizTitle", quizTitle);
                        cmd.Parameters.AddWithValue("@mode", quizMode);
                        cmd.Parameters.AddWithValue("@classSlug", classSlug);
                        cmd.Parameters.AddWithValue("@levelSlug", levelSlug);
                        cmd.Parameters.AddWithValue("@timeLimit", timeLimit);
                        cmd.Parameters.AddWithValue("@passingScore", passingScore);
                        cmd.Parameters.AddWithValue("@createdBy", adminSlug);

                        cmd.ExecuteNonQuery();
                    }

                    // Insert Level with quiz reference
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            INSERT INTO Levels 
                            (level_slug, class_slug, level_number, title, description, content_type, content_url, 
                             quiz_slug, xp_reward, estimated_minutes, is_published, created_at, updated_at, is_deleted)
                            VALUES 
                            (@levelSlug, @classSlug, @levelNumber, @title, @description, @contentType, @contentUrl,
                             @quizSlug, @xp, @minutes, 1, SYSUTCDATETIME(), SYSUTCDATETIME(), 0)";

                        cmd.Parameters.AddWithValue("@levelSlug", levelSlug);
                        cmd.Parameters.AddWithValue("@classSlug", classSlug);
                        cmd.Parameters.AddWithValue("@levelNumber", levelNumber);
                        cmd.Parameters.AddWithValue("@title", title);
                        cmd.Parameters.AddWithValue("@description", (object)description ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@contentType", (object)contentType ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@contentUrl", (object)contentUrl ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@quizSlug", quizSlug);
                        cmd.Parameters.AddWithValue("@xp", xp);
                        cmd.Parameters.AddWithValue("@minutes", minutes);

                        cmd.ExecuteNonQuery();
                    }

                    System.Diagnostics.Debug.WriteLine($"[CreateLevel] Level created successfully: {levelSlug}");

                    // Redirect back to classes page (storymode tab)
                    Response.Redirect($"~/Pages/admin/Classes.aspx?class={classSlug}&tab=storymode", false);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[CreateLevel] Error: {ex}");
                lblError.Text = $"Error creating level: {Server.HtmlEncode(ex.Message)}";
                lblError.Visible = true;
            }
        }

        private Tuple<string, string> HandleFileUpload(System.Web.UI.WebControls.FileUpload upload, string classSlug, string levelSlug)
        {
            if (!upload.HasFile) return Tuple.Create<string, string>(null, null);

            string extension = Path.GetExtension(upload.FileName).ToLowerInvariant();
            string contentType = null;

            switch (extension)
            {
                case ".pptx":
                case ".ppt":
                    contentType = "powerpoint";
                    break;
                case ".pdf":
                    contentType = "pdf";
                    break;
                default:
                    throw new Exception("Unsupported file type. Please upload PowerPoint or PDF.");
            }

            string uploadFolder = Server.MapPath($"~/Uploads/{classSlug}/{levelSlug}/");
            if (!Directory.Exists(uploadFolder))
            {
                Directory.CreateDirectory(uploadFolder);
            }

            // Create short, safe filename to avoid path length issues
            string safeFileName = $"material-{DateTime.Now.Ticks}{extension}";
            string filePath = Path.Combine(uploadFolder, safeFileName);
            
            // Validate path length (Windows limit is 260 chars)
            if (filePath.Length > 250)
            {
                throw new Exception("File path too long. Please use shorter class/level names.");
            }
            
            upload.SaveAs(filePath);

            string contentUrl = $"/Uploads/{classSlug}/{levelSlug}/{safeFileName}";
            return Tuple.Create(contentType, contentUrl);
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


using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Globalization;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace RookiesInTraining2.Pages
{
    public partial class class_detail : System.Web.UI.Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
        private const bool ALLOW_ADMIN_VIEW = true;

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
            if (role != "teacher" && !(ALLOW_ADMIN_VIEW && role == "admin"))
            {
                Response.Redirect("~/Pages/Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            // Guard: Check class slug
            string classSlug = Request.QueryString["slug"];
            if (string.IsNullOrEmpty(classSlug))
            {
                Response.Redirect("~/Pages/teacher/teacher_browse_classes.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (!IsPostBack)
            {
                hfClassSlug.Value = classSlug;
                LoadClassData(classSlug);
                LoadLevelsDropdown(classSlug);
            }
        }

        private void LoadClassData(string classSlug)
        {
            string teacherSlug = Session["UserSlug"]?.ToString() ?? "";
            var serializer = new JavaScriptSerializer();

            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();

                    // Load class info
                    var classData = LoadClass(classSlug, teacherSlug, con);
                    if (classData == null)
                    {
                        // Class not found - show error with more detail
                        System.Diagnostics.Debug.WriteLine($"[ClassDetail] Class not found - Slug: {classSlug}, Teacher: {teacherSlug}");
                        
                        // Set error state in hidden field
                        var errorData = new { ClassName = "", ClassCode = "", Error = "Class not found" };
                        hfClassData.Value = serializer.Serialize(errorData);
                        
                        ScriptManager.RegisterStartupScript(this, GetType(), "classNotFound",
                            $"console.error('Class not found with slug: {Server.HtmlEncode(classSlug)}'); " +
                            $"alert('Class not found. You may not have access to this class.'); " +
                            $"setTimeout(function() {{ window.location.href = 'teacher_browse_classes.aspx'; }}, 2000);", true);
                        return;
                    }

                    System.Diagnostics.Debug.WriteLine($"[ClassDetail] Loaded class: {classData.ClassName} ({classData.ClassSlug})");

                    // Load levels
                    var levels = LoadLevels(classSlug, con);
                    System.Diagnostics.Debug.WriteLine($"[ClassDetail] Loaded {levels.Count} levels");

                    // Load students
                    var students = LoadStudents(classSlug, con);
                    System.Diagnostics.Debug.WriteLine($"[ClassDetail] Loaded {students.Count} students");

                    // Load quizzes
                    var quizzes = LoadQuizzes(classSlug, con);
                    System.Diagnostics.Debug.WriteLine($"[ClassDetail] Loaded {quizzes.Count} quizzes");

                    // Serialize to JSON
                    hfClassData.Value = serializer.Serialize(classData);
                    hfLevelsJson.Value = serializer.Serialize(levels);
                    hfStudentsJson.Value = serializer.Serialize(students);
                    hfQuizzesJson.Value = serializer.Serialize(quizzes);
                    
                    System.Diagnostics.Debug.WriteLine($"[ClassDetail] Data serialization complete");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[ClassDetail] Error loading class data: {ex}");
                ScriptManager.RegisterStartupScript(this, GetType(), "loadError",
                    $"console.error('Error loading class:', {Server.HtmlEncode(ex.Message)}); " +
                    $"alert('Error loading class data. Please try again or contact support.');", true);
            }
        }

        private ClassData LoadClass(string classSlug, string teacherSlug, SqlConnection con)
        {
            using (var cmd = con.CreateCommand())
            {
                cmd.CommandText = @"
                    SELECT class_slug, class_name, class_code, 
                           ISNULL(description, '') AS description,
                           ISNULL(icon, 'bi-book') AS icon,
                           ISNULL(color, '#6c5ce7') AS color
                    FROM Classes
                    WHERE class_slug = @slug 
                      AND is_deleted = 0
                      AND (teacher_slug = @teacherSlug OR @isAdmin = 1)";

                cmd.Parameters.AddWithValue("@slug", classSlug);
                cmd.Parameters.AddWithValue("@teacherSlug", teacherSlug);

                var role = (Convert.ToString(Session["Role"]) ?? "").ToLowerInvariant();
                cmd.Parameters.AddWithValue("@isAdmin", role == "admin" ? 1 : 0);

                using (var reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        return new ClassData
                        {
                            ClassSlug = reader["class_slug"].ToString(),
                            ClassName = reader["class_name"].ToString(),
                            ClassCode = reader["class_code"].ToString(),
                            Description = reader["description"].ToString(),
                            Icon = reader["icon"].ToString(),
                            Color = reader["color"].ToString()
                        };
                    }
                }
            }
            return null;
        }

        private List<LevelData> LoadLevels(string classSlug, SqlConnection con)
        {
            var levels = new List<LevelData>();

            using (var cmd = con.CreateCommand())
            {
                cmd.CommandText = @"
                    SELECT 
                        l.level_slug, l.level_number, l.title, l.description,
                        l.content_type, l.content_url, l.xp_reward, l.estimated_minutes,
                        l.is_published, l.created_at,
                        COUNT(DISTINCT ls.slide_slug) AS slide_count,
                        (SELECT COUNT(*) FROM Quizzes WHERE level_slug = l.level_slug AND is_deleted = 0) AS quiz_count
                    FROM Levels l
                    LEFT JOIN LevelSlides ls ON l.level_slug = ls.level_slug AND ls.is_deleted = 0
                    WHERE l.class_slug = @classSlug AND l.is_deleted = 0
                    GROUP BY l.level_slug, l.level_number, l.title, l.description,
                             l.content_type, l.content_url, l.xp_reward, l.estimated_minutes,
                             l.is_published, l.created_at
                    ORDER BY l.level_number";

                cmd.Parameters.AddWithValue("@classSlug", classSlug);

                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        levels.Add(new LevelData
                        {
                            LevelSlug = reader["level_slug"].ToString(),
                            LevelNumber = Convert.ToInt32(reader["level_number"]),
                            Title = reader["title"].ToString(),
                            Description = reader["description"].ToString(),
                            ContentType = reader["content_type"].ToString(),
                            ContentUrl = reader["content_url"].ToString(),
                            XpReward = Convert.ToInt32(reader["xp_reward"]),
                            EstimatedMinutes = Convert.ToInt32(reader["estimated_minutes"]),
                            IsPublished = Convert.ToBoolean(reader["is_published"]),
                            SlideCount = Convert.ToInt32(reader["slide_count"]),
                            QuizCount = Convert.ToInt32(reader["quiz_count"])
                        });
                    }
                }
            }

            return levels;
        }

        private List<StudentData> LoadStudents(string classSlug, SqlConnection con)
        {
            var students = new List<StudentData>();

            using (var cmd = con.CreateCommand())
            {
                cmd.CommandText = @"
                    SELECT 
                        u.user_slug, u.display_name, u.email,
                        e.joined_at,
                        COUNT(DISTINCT a.attempt_slug) AS attempts,
                        AVG(CASE WHEN a.finished_at IS NOT NULL THEN a.score ELSE NULL END) AS avg_score
                    FROM Enrollments e
                    JOIN Users u ON e.user_slug = u.user_slug
                    LEFT JOIN Attempts a ON u.user_slug = a.user_slug AND a.is_deleted = 0
                    WHERE e.class_slug = @classSlug 
                        AND e.role_in_class = 'student'
                        AND e.is_deleted = 0
                        AND u.is_deleted = 0
                    GROUP BY u.user_slug, u.display_name, u.email, e.joined_at
                    ORDER BY e.joined_at DESC";

                cmd.Parameters.AddWithValue("@classSlug", classSlug);

                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        int avgScoreInt = 0;
                        if (reader["avg_score"] != DBNull.Value)
                        {
                            decimal avg = Convert.ToDecimal(reader["avg_score"]);
                            avgScoreInt = (int)Math.Round(avg);
                        }

                        students.Add(new StudentData
                        {
                            UserSlug = reader["user_slug"].ToString(),
                            DisplayName = reader["display_name"].ToString(),
                            Email = reader["email"].ToString(),
                            JoinedAt = Convert.ToDateTime(reader["joined_at"]),
                            Attempts = Convert.ToInt32(reader["attempts"]),
                            AvgScore = avgScoreInt
                        });
                    }
                }
            }

            return students;
        }

        private List<QuizData> LoadQuizzes(string classSlug, SqlConnection con)
        {
            var quizzes = new List<QuizData>();

            using (var cmd = con.CreateCommand())
            {
                cmd.CommandText = @"
                    SELECT 
                        q.quiz_slug, q.title, q.mode, q.published,
                        q.time_limit_minutes, q.passing_score,
                        ISNULL(q.level_slug, '') AS level_slug,
                        q.created_at,
                        (SELECT COUNT(*) FROM Questions WHERE quiz_slug = q.quiz_slug AND is_deleted = 0) AS question_count,
                        (SELECT COUNT(DISTINCT user_slug) FROM Attempts WHERE quiz_slug = q.quiz_slug AND is_deleted = 0) AS attempt_count
                    FROM Quizzes q
                    WHERE q.class_slug = @classSlug AND q.is_deleted = 0
                    ORDER BY q.created_at DESC";

                cmd.Parameters.AddWithValue("@classSlug", classSlug);

                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        quizzes.Add(new QuizData
                        {
                            QuizSlug = reader["quiz_slug"].ToString(),
                            Title = reader["title"].ToString(),
                            Mode = reader["mode"].ToString(),
                            Published = Convert.ToBoolean(reader["published"]),
                            TimeLimit = reader["time_limit_minutes"] != DBNull.Value
                                ? Convert.ToInt32(reader["time_limit_minutes"])
                                : 30,
                            PassingScore = reader["passing_score"] != DBNull.Value
                                ? Convert.ToInt32(reader["passing_score"])
                                : 70,
                            LevelSlug = reader["level_slug"].ToString(),
                            QuestionCount = Convert.ToInt32(reader["question_count"]),
                            AttemptCount = Convert.ToInt32(reader["attempt_count"])
                        });
                    }
                }
            }

            return quizzes;
        }

        private void LoadLevelsDropdown(string classSlug)
        {
            ddlLevelForQuiz.Items.Clear();
            ddlLevelForQuiz.Items.Add(new ListItem("-- Select Level --", ""));

            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = con.CreateCommand())
                {
                    con.Open();
                    cmd.CommandText = @"
                        SELECT level_slug, level_number, title
                        FROM Levels
                        WHERE class_slug = @classSlug AND is_deleted = 0
                        ORDER BY level_number";

                    cmd.Parameters.AddWithValue("@classSlug", classSlug);

                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string text = $"Level {reader["level_number"]}: {reader["title"]}";
                            ddlLevelForQuiz.Items.Add(new ListItem(text, reader["level_slug"].ToString()));
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[ClassDetail] Error loading levels: {ex}");
            }
        }

        protected void btnSaveLevel_Click(object sender, EventArgs e)
        {
            // Hide any previous errors
            lblLevelError.Visible = false;
            lblLevelError.Text = "";

            // Validate form
            Page.Validate("CreateLevel");
            if (!Page.IsValid)
            {
                lblLevelError.Text = "Please fill in all required fields correctly.";
                lblLevelError.Visible = true;
                lblLevelError.CssClass = "alert alert-danger";
                return;
            }

            // Validate inputs
            if (string.IsNullOrWhiteSpace(hfClassSlug.Value))
            {
                lblLevelError.Text = "Error: Class slug is missing. Please refresh the page.";
                lblLevelError.Visible = true;
                lblLevelError.CssClass = "alert alert-danger";
                return;
            }

            string classSlug = hfClassSlug.Value;
            string teacherSlug = Session["UserSlug"]?.ToString() ?? "";
            
            if (string.IsNullOrWhiteSpace(teacherSlug))
            {
                lblLevelError.Text = "Error: You must be logged in to create levels.";
                lblLevelError.Visible = true;
                lblLevelError.CssClass = "alert alert-danger";
                return;
            }

            // Parse and validate inputs
            if (!int.TryParse(txtLevelNumber.Text, out int levelNumber) || levelNumber <= 0)
            {
                lblLevelError.Text = "Please enter a valid level number (must be greater than 0).";
                lblLevelError.Visible = true;
                lblLevelError.CssClass = "alert alert-danger";
                return;
            }

            string title = txtLevelTitle.Text.Trim();
            if (string.IsNullOrWhiteSpace(title))
            {
                lblLevelError.Text = "Level title is required.";
                lblLevelError.Visible = true;
                lblLevelError.CssClass = "alert alert-danger";
                return;
            }

            string description = txtLevelDescription.Text.Trim();
            
            if (!int.TryParse(txtEstimatedMinutes.Text, out int minutes) || minutes <= 0)
            {
                minutes = 15; // Default
            }

            if (!int.TryParse(txtXpReward.Text, out int xp) || xp <= 0)
            {
                xp = 50; // Default
            }

            bool publish = chkPublishLevel.Checked;

            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();

                    // Generate slug
                    string baseSlug = SlugifyText($"{classSlug}-level-{levelNumber}");
                    string levelSlug = GenerateUniqueSlug(baseSlug, "Levels", "level_slug", con);

                    // Handle file upload
                    string contentType = null;
                    string contentUrl = null;

                    if (fileUpload.HasFile)
                    {
                        try
                        {
                            var result = HandleFileUpload(fileUpload, classSlug, levelSlug);
                            contentType = result.Item1;
                            contentUrl = result.Item2;
                        }
                        catch (Exception uploadEx)
                        {
                            lblLevelError.Text = "Error uploading file: " + Server.HtmlEncode(uploadEx.Message);
                            lblLevelError.Visible = true;
                            lblLevelError.CssClass = "alert alert-danger";
                            return;
                        }
                    }

                    // Insert level
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            INSERT INTO Levels 
                            (level_slug, class_slug, level_number, title, description, 
                             content_type, content_url, xp_reward, estimated_minutes, is_published,
                             created_at, updated_at, is_deleted)
                            VALUES 
                            (@slug, @classSlug, @levelNum, @title, @desc,
                             @contentType, @contentUrl, @xp, @minutes, @publish,
                             SYSUTCDATETIME(), SYSUTCDATETIME(), 0)";

                        cmd.Parameters.AddWithValue("@slug", levelSlug);
                        cmd.Parameters.AddWithValue("@classSlug", classSlug);
                        cmd.Parameters.AddWithValue("@levelNum", levelNumber);
                        cmd.Parameters.AddWithValue("@title", title);
                        cmd.Parameters.AddWithValue("@desc", string.IsNullOrWhiteSpace(description) ? (object)DBNull.Value : description);
                        cmd.Parameters.AddWithValue("@contentType", (object)contentType ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@contentUrl", (object)contentUrl ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@xp", xp);
                        cmd.Parameters.AddWithValue("@minutes", minutes);
                        cmd.Parameters.AddWithValue("@publish", publish);

                        cmd.ExecuteNonQuery();
                    }

                    System.Diagnostics.Debug.WriteLine($"[ClassDetail] Level created successfully: {levelSlug}");

                    // Clear form
                    ClearLevelForm();

                    // Reload data
                    LoadClassData(classSlug);
                    LoadLevelsDropdown(classSlug);

                    // Close modal and refresh page to show new level
                    ScriptManager.RegisterStartupScript(this, GetType(), "closeModal",
                        "setTimeout(function() { " +
                        "  const modalElement = document.getElementById('createLevelModal'); " +
                        "  if (modalElement) { " +
                        "    const modal = bootstrap.Modal.getInstance(modalElement); " +
                        "    if (modal) modal.hide(); " +
                        "  } " +
                        "  window.location.reload(); " +
                        "}, 500);", true);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[ClassDetail] Error creating level: {ex}");
                lblLevelError.Text = "Error creating level: " + Server.HtmlEncode(ex.Message);
                lblLevelError.Visible = true;
                lblLevelError.CssClass = "alert alert-danger";
            }
        }

        protected void btnSaveQuiz_Click(object sender, EventArgs e)
        {
            Page.Validate("CreateQuiz");
            if (!Page.IsValid) return;

            string classSlug = hfClassSlug.Value;
            string levelSlug = ddlLevelForQuiz.SelectedValue;
            string quizTitle = txtQuizTitle.Text.Trim();
            int timeLimit = int.Parse(txtTimeLimit.Text);
            int passingScore = int.Parse(txtPassingScore.Text);
            string mode = ddlQuizMode.SelectedValue;
            bool publish = chkPublishQuiz.Checked;
            string teacherSlug = Session["UserSlug"]?.ToString() ?? "";

            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();

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
                            (@slug, @title, @mode, @publish, @teacherSlug,
                             @classSlug, @levelSlug, @timeLimit, @passingScore,
                             SYSUTCDATETIME(), SYSUTCDATETIME(), 0)";

                        cmd.Parameters.AddWithValue("@slug", quizSlug);
                        cmd.Parameters.AddWithValue("@title", quizTitle);
                        cmd.Parameters.AddWithValue("@mode", mode);
                        cmd.Parameters.AddWithValue("@publish", publish ? 1 : 0);
                        cmd.Parameters.AddWithValue("@teacherSlug", teacherSlug);
                        cmd.Parameters.AddWithValue("@classSlug", classSlug);
                        cmd.Parameters.AddWithValue("@levelSlug", string.IsNullOrWhiteSpace(levelSlug) ? (object)DBNull.Value : levelSlug);
                        cmd.Parameters.AddWithValue("@timeLimit", timeLimit);
                        cmd.Parameters.AddWithValue("@passingScore", passingScore);

                        cmd.ExecuteNonQuery();
                    }

                    // Clear form
                    ClearQuizForm();

                    // Reload data
                    LoadClassData(classSlug);

                    // Redirect to add questions
                    ScriptManager.RegisterStartupScript(this, GetType(), "redirect",
                        $"closeCreateQuizModal(); window.location.href='add_questions.aspx?quiz={quizSlug}';", true);
                }
            }
            catch (Exception ex)
            {
                lblQuizError.Text = "Error creating quiz: " + Server.HtmlEncode(ex.Message);
                lblQuizError.Visible = true;
                System.Diagnostics.Debug.WriteLine($"[ClassDetail] Quiz Error: {ex}");
            }
        }

        #region File Upload Handler

        private Tuple<string, string> HandleFileUpload(FileUpload upload, string classSlug, string levelSlug)
        {
            if (!upload.HasFile) return Tuple.Create<string, string>(null, null);

            string extension = Path.GetExtension(upload.FileName).ToLowerInvariant();
            string contentType = null;

            // Determine content type
            switch (extension)
            {
                case ".pptx":
                case ".ppt":
                    contentType = "powerpoint";
                    break;
                case ".pdf":
                    contentType = "pdf";
                    break;
                case ".mp4":
                case ".avi":
                case ".mov":
                    contentType = "video";
                    break;
                default:
                    throw new Exception("Unsupported file type. Please upload PowerPoint, PDF, or Video.");
            }

            // Create upload directory
            string uploadFolder = Server.MapPath($"~/Uploads/{classSlug}/{levelSlug}/");
            if (!Directory.Exists(uploadFolder))
            {
                Directory.CreateDirectory(uploadFolder);
            }

            // Save file
            string safeFileName = $"{levelSlug}_{DateTime.Now:yyyyMMddHHmmss}{extension}";
            string filePath = Path.Combine(uploadFolder, safeFileName);
            upload.SaveAs(filePath);

            // Return relative URL
            string relativeUrl = $"/Uploads/{classSlug}/{levelSlug}/{safeFileName}";

            // TODO: If PowerPoint, process slides here
            return Tuple.Create(contentType, relativeUrl);
        }

        #endregion

        #region Helper Methods

        private void ClearLevelForm()
        {
            txtLevelNumber.Text = "";
            txtLevelTitle.Text = "";
            txtLevelDescription.Text = "";
            txtEstimatedMinutes.Text = "15";
            txtXpReward.Text = "50";
            chkPublishLevel.Checked = true;
            lblLevelError.Visible = false;
            lblLevelError.Text = "";
            lblLevelError.CssClass = "alert alert-danger";
        }

        private void ClearQuizForm()
        {
            txtQuizTitle.Text = "";
            txtTimeLimit.Text = "30";
            txtPassingScore.Text = "70";
            ddlQuizMode.SelectedIndex = 0;
            chkPublishQuiz.Checked = false;
            lblQuizError.Visible = false;
        }

        private string SlugifyText(string text)
        {
            if (string.IsNullOrWhiteSpace(text)) return "item";

            string slug = text.Trim().ToLowerInvariant();

            // Remove accents
            var sb = new StringBuilder(slug.Length);
            foreach (var ch in slug.Normalize(NormalizationForm.FormD))
            {
                var cat = CharUnicodeInfo.GetUnicodeCategory(ch);
                if (cat != UnicodeCategory.NonSpacingMark)
                    sb.Append(ch);
            }
            slug = sb.ToString().Normalize(NormalizationForm.FormC);

            // Replace non-alphanumeric
            slug = Regex.Replace(slug, @"[^a-z0-9]+", "-");
            slug = slug.Trim('-');
            slug = Regex.Replace(slug, "-{2,}", "-");

            if (string.IsNullOrEmpty(slug)) slug = "item";
            if (slug.Length > 80) slug = slug.Substring(0, 80).TrimEnd('-');

            return slug;
        }

        private string GenerateUniqueSlug(string baseSlug, string tableName, string columnName, SqlConnection con)
        {
            string slug = baseSlug;
            int counter = 1;

            while (SlugExists(slug, tableName, columnName, con))
            {
                slug = baseSlug + "-" + counter.ToString(CultureInfo.InvariantCulture);
                counter++;

                if (counter > 1000)
                {
                    slug = baseSlug + "-" + Guid.NewGuid().ToString("N").Substring(0, 8);
                    break;
                }
            }

            return slug;
        }

        private bool SlugExists(string slug, string tableName, string columnName, SqlConnection con)
        {
            using (var cmd = con.CreateCommand())
            {
                cmd.CommandText = $"SELECT TOP 1 1 FROM {tableName} WHERE {columnName} = @slug AND is_deleted = 0";
                cmd.Parameters.AddWithValue("@slug", slug);
                return cmd.ExecuteScalar() != null;
            }
        }

        #endregion

        #region Data Classes

        public class ClassData
        {
            public string ClassSlug { get; set; }
            public string ClassName { get; set; }
            public string ClassCode { get; set; }
            public string Description { get; set; }
            public string Icon { get; set; }
            public string Color { get; set; }
        }

        public class LevelData
        {
            public string LevelSlug { get; set; }
            public int LevelNumber { get; set; }
            public string Title { get; set; }
            public string Description { get; set; }
            public string ContentType { get; set; }
            public string ContentUrl { get; set; }
            public int XpReward { get; set; }
            public int EstimatedMinutes { get; set; }
            public bool IsPublished { get; set; }
            public int SlideCount { get; set; }
            public int QuizCount { get; set; }
        }

        public class StudentData
        {
            public string UserSlug { get; set; }
            public string DisplayName { get; set; }
            public string Email { get; set; }
            public DateTime JoinedAt { get; set; }
            public int Attempts { get; set; }
            public int AvgScore { get; set; }
        }

        public class QuizData
        {
            public string QuizSlug { get; set; }
            public string Title { get; set; }
            public string Mode { get; set; }
            public bool Published { get; set; }
            public int TimeLimit { get; set; }
            public int PassingScore { get; set; }
            public string LevelSlug { get; set; }
            public int QuestionCount { get; set; }
            public int AttemptCount { get; set; }
        }

        #endregion
    }
}

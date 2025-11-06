using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;

namespace RookiesInTraining2.Pages
{
    public partial class teacher_create_module : System.Web.UI.Page
    {
        private static readonly string ConnStr = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Authorization check
            if (Session["UserSlug"] == null)
            {
                Response.Redirect("~/Pages/Login.aspx", false);
                return;
            }

            var role = Convert.ToString(Session["Role"])?.ToLowerInvariant();
            if (role != "teacher" && role != "admin")
            {
                Response.Redirect("~/Pages/Login.aspx", false);
                return;
            }

            if (!IsPostBack)
            {
                // Generate initial class code
                txtClassCode.Text = GenerateRandomClassCode(6);
            }
        }

        protected void btnCreateModule_Click(object sender, EventArgs e)
        {
            try
            {
                // Get teacher slug
                string teacherSlug = Convert.ToString(Session["UserSlug"]);

                // Parse JSON from hidden field
                string json = hfDraftJson.Value;
                if (string.IsNullOrWhiteSpace(json))
                {
                    ShowError("No data found. Please complete the form.");
                    return;
                }

                var serializer = new JavaScriptSerializer();
                var draft = serializer.Deserialize<ModuleDraft>(json);

                // Validate
                if (draft == null || draft.ClassInfo == null || draft.Levels == null)
                {
                    ShowError("Invalid data format.");
                    return;
                }

                if (string.IsNullOrWhiteSpace(draft.ClassInfo.Name) || draft.ClassInfo.Name.Length < 3)
                {
                    ShowError("Class name must be at least 3 characters.");
                    return;
                }

                if (draft.Levels.Count < 3)
                {
                    ShowError("Minimum 3 levels required.");
                    return;
                }

                // Validate each level
                foreach (var level in draft.Levels)
                {
                    if (level.LevelNumber < 1)
                    {
                        ShowError($"Invalid level number: {level.LevelNumber}");
                        return;
                    }
                    if (string.IsNullOrWhiteSpace(level.Title) || level.Title.Length < 3)
                    {
                        ShowError($"Level {level.LevelNumber} title must be at least 3 characters.");
                        return;
                    }
                    if (level.Minutes < 0 || level.Xp < 0)
                    {
                        ShowError($"Level {level.LevelNumber} has invalid minutes or XP.");
                        return;
                    }
                }

                // Begin transaction
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();
                    using (var tx = con.BeginTransaction())
                    {
                        try
                        {
                            // Generate unique class slug
                            string baseSlug = SlugifyText(draft.ClassInfo.Name);
                            string classSlug = GenerateUniqueSlug(baseSlug, "Classes", "class_slug", con, tx);

                            // Validate class code uniqueness
                            string classCode = draft.ClassInfo.ClassCode;
                            if (string.IsNullOrWhiteSpace(classCode))
                            {
                                classCode = GenerateRandomClassCode(6);
                            }
                            classCode = EnsureUniqueClassCode(classCode, con, tx);

                            // Insert Class
                            using (var cmd = con.CreateCommand())
                            {
                                cmd.Transaction = tx;
                                cmd.CommandText = @"
                                    INSERT INTO dbo.Classes 
                                    (class_slug, teacher_slug, class_name, class_code, description, icon, color, created_at, updated_at, is_deleted)
                                    VALUES 
                                    (@class_slug, @teacher_slug, @class_name, @class_code, @description, @icon, @color, SYSUTCDATETIME(), SYSUTCDATETIME(), 0)";

                                cmd.Parameters.AddWithValue("@class_slug", classSlug);
                                cmd.Parameters.AddWithValue("@teacher_slug", teacherSlug);
                                cmd.Parameters.AddWithValue("@class_name", draft.ClassInfo.Name);
                                cmd.Parameters.AddWithValue("@class_code", classCode);
                                cmd.Parameters.AddWithValue("@description", draft.ClassInfo.Description ?? "");
                                cmd.Parameters.AddWithValue("@icon", "bi-" + draft.ClassInfo.Icon);
                                cmd.Parameters.AddWithValue("@color", draft.ClassInfo.Color);

                                cmd.ExecuteNonQuery();
                            }

                            // Create upload directory
                            string uploadsBasePath = Server.MapPath("~/Uploads");
                            if (!Directory.Exists(uploadsBasePath))
                            {
                                Directory.CreateDirectory(uploadsBasePath);
                            }

                            string classUploadPath = Path.Combine(uploadsBasePath, classSlug);
                            if (!Directory.Exists(classUploadPath))
                            {
                                Directory.CreateDirectory(classUploadPath);
                            }

                            // Insert Levels
                            foreach (var level in draft.Levels)
                            {
                                string levelSlug = GenerateUniqueSlug(
                                    SlugifyText($"{classSlug}-level-{level.LevelNumber}"),
                                    "Levels",
                                    "level_slug",
                                    con,
                                    tx
                                );

                                string contentType = null;
                                string contentUrl = null;

                                // Handle file upload if present
                                if (!string.IsNullOrWhiteSpace(level.FileName))
                                {
                                    // File was uploaded in client; we need to find it in Request.Files
                                    // Since we're using client-side file handling, files will be in Request.Files
                                    var fileKey = $"level_{level.LevelNumber}_file";
                                    if (Request.Files.Count > 0)
                                    {
                                        // Try to match by original name
                                        HttpPostedFile uploadedFile = null;
                                        for (int i = 0; i < Request.Files.Count; i++)
                                        {
                                            var file = Request.Files[i];
                                            if (file.FileName == level.FileName && file.ContentLength > 0)
                                            {
                                                uploadedFile = file;
                                                break;
                                            }
                                        }

                                        if (uploadedFile != null)
                                        {
                                            var result = HandleFileUpload(uploadedFile, classSlug, levelSlug, classUploadPath);
                                            contentType = result.Item1;
                                            contentUrl = result.Item2;
                                        }
                                    }
                                }

                                // Create quiz for this level
                                string quizSlug = GenerateUniqueSlug(
                                    SlugifyText($"{level.Title}-quiz"),
                                    "Quizzes",
                                    "quiz_slug",
                                    con,
                                    tx
                                );
                                
                                // Insert Quiz first
                                using (var cmd = con.CreateCommand())
                                {
                                    cmd.Transaction = tx;
                                    cmd.CommandText = @"
                                        INSERT INTO dbo.Quizzes 
                                        (quiz_slug, title, mode, class_slug, level_slug, time_limit_minutes, passing_score, 
                                         published, created_by_slug, created_at, updated_at, is_deleted)
                                        VALUES 
                                        (@quiz_slug, @quiz_title, @mode, @class_slug, @level_slug, @time_limit, @passing_score,
                                         @published, @created_by, SYSUTCDATETIME(), SYSUTCDATETIME(), 0)";

                                    cmd.Parameters.AddWithValue("@quiz_slug", quizSlug);
                                    cmd.Parameters.AddWithValue("@quiz_title", level.Quiz?.Title ?? $"{level.Title} Quiz");
                                    cmd.Parameters.AddWithValue("@mode", level.Quiz?.Mode ?? "story");
                                    cmd.Parameters.AddWithValue("@class_slug", classSlug);
                                    cmd.Parameters.AddWithValue("@level_slug", levelSlug);
                                    cmd.Parameters.AddWithValue("@time_limit", level.Quiz?.TimeLimit ?? 30);
                                    cmd.Parameters.AddWithValue("@passing_score", level.Quiz?.PassingScore ?? 70);
                                    cmd.Parameters.AddWithValue("@published", (level.Quiz?.Publish ?? true) ? 1 : 0);
                                    cmd.Parameters.AddWithValue("@created_by", teacherSlug);

                                    cmd.ExecuteNonQuery();
                                }

                                // Insert Level with quiz reference
                                using (var cmd = con.CreateCommand())
                                {
                                    cmd.Transaction = tx;
                                    cmd.CommandText = @"
                                        INSERT INTO dbo.Levels 
                                        (level_slug, class_slug, level_number, title, description, content_type, content_url, 
                                         quiz_slug, xp_reward, estimated_minutes, is_published, created_at, updated_at, is_deleted)
                                        VALUES 
                                        (@level_slug, @class_slug, @level_number, @title, @description, @content_type, @content_url,
                                         @quiz_slug, @xp_reward, @estimated_minutes, @is_published, SYSUTCDATETIME(), SYSUTCDATETIME(), 0)";

                                    cmd.Parameters.AddWithValue("@level_slug", levelSlug);
                                    cmd.Parameters.AddWithValue("@class_slug", classSlug);
                                    cmd.Parameters.AddWithValue("@level_number", level.LevelNumber);
                                    cmd.Parameters.AddWithValue("@title", level.Title);
                                    cmd.Parameters.AddWithValue("@description", level.Description ?? "");
                                    cmd.Parameters.AddWithValue("@content_type", (object)contentType ?? DBNull.Value);
                                    cmd.Parameters.AddWithValue("@content_url", (object)contentUrl ?? DBNull.Value);
                                    cmd.Parameters.AddWithValue("@quiz_slug", quizSlug);
                                    cmd.Parameters.AddWithValue("@xp_reward", level.Xp);
                                    cmd.Parameters.AddWithValue("@estimated_minutes", level.Minutes);
                                    cmd.Parameters.AddWithValue("@is_published", level.Publish ? 1 : 0);

                                    cmd.ExecuteNonQuery();
                                }
                                
                                System.Diagnostics.Debug.WriteLine($"[CreateModule] Level {level.LevelNumber} created with quiz: {quizSlug}");
                            }

                            // Commit transaction
                            tx.Commit();
                            
                            System.Diagnostics.Debug.WriteLine($"[CreateModule] ✓ Module created successfully!");
                            System.Diagnostics.Debug.WriteLine($"[CreateModule] Class Slug: {classSlug}");
                            System.Diagnostics.Debug.WriteLine($"[CreateModule] Teacher Slug: {teacherSlug}");
                            System.Diagnostics.Debug.WriteLine($"[CreateModule] Levels Created: {draft.Levels.Count}");

                            // Redirect to class detail
                            Response.Redirect($"~/Pages/teacher/class_detail.aspx?slug={classSlug}", false);
                        }
                        catch (Exception ex)
                        {
                            tx.Rollback();
                            System.Diagnostics.Debug.WriteLine($"[CreateModule] ❌ ERROR during creation: {ex}");
                            System.Diagnostics.Debug.WriteLine($"[CreateModule] Stack trace: {ex.StackTrace}");
                            throw new Exception("Failed to create module: " + ex.Message, ex);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowError("Error creating module: " + ex.Message);
            }
        }

        private Tuple<string, string> HandleFileUpload(HttpPostedFile file, string classSlug, string levelSlug, string classUploadPath)
        {
            if (file == null || file.ContentLength == 0)
            {
                return null;
            }

            // Get extension
            string ext = Path.GetExtension(file.FileName).ToLowerInvariant();

            // Determine content type
            string contentType = null;
            switch (ext)
            {
                case ".ppt":
                case ".pptx":
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
                    throw new Exception($"Unsupported file type: {ext}");
            }

            // Create level-specific directory
            string levelUploadPath = Path.Combine(classUploadPath, levelSlug);
            if (!Directory.Exists(levelUploadPath))
            {
                Directory.CreateDirectory(levelUploadPath);
            }

            // Generate safe filename
            string timestamp = DateTime.Now.ToString("yyyyMMddHHmmss");
            string safeFileName = $"{levelSlug}_{timestamp}{ext}";
            string physicalPath = Path.Combine(levelUploadPath, safeFileName);

            // Save file
            file.SaveAs(physicalPath);

            // Return relative URL
            string relativeUrl = $"/Uploads/{classSlug}/{levelSlug}/{safeFileName}";
            return Tuple.Create(contentType, relativeUrl);
        }

        private string GenerateRandomClassCode(int length)
        {
            const string chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"; // Removed confusing chars
            var random = new Random();
            var code = new StringBuilder();
            for (int i = 0; i < length; i++)
            {
                code.Append(chars[random.Next(chars.Length)]);
            }
            return code.ToString();
        }

        private string EnsureUniqueClassCode(string code, SqlConnection con, SqlTransaction tx)
        {
            string uniqueCode = code;
            int attempt = 0;
            while (ClassCodeExists(uniqueCode, con, tx))
            {
                attempt++;
                uniqueCode = code + attempt;
                if (attempt > 100)
                {
                    uniqueCode = GenerateRandomClassCode(8);
                    break;
                }
            }
            return uniqueCode;
        }

        private bool ClassCodeExists(string code, SqlConnection con, SqlTransaction tx)
        {
            using (var cmd = con.CreateCommand())
            {
                cmd.Transaction = tx;
                cmd.CommandText = "SELECT COUNT(*) FROM dbo.Classes WHERE class_code = @code AND is_deleted = 0";
                cmd.Parameters.AddWithValue("@code", code);
                int count = (int)cmd.ExecuteScalar();
                return count > 0;
            }
        }

        private string SlugifyText(string text)
        {
            if (string.IsNullOrWhiteSpace(text))
                return "item";

            text = text.ToLowerInvariant().Trim();
            text = Regex.Replace(text, @"\s+", "-");
            text = Regex.Replace(text, @"[^a-z0-9\-]", "");
            text = Regex.Replace(text, @"\-{2,}", "-");
            text = text.Trim('-');

            if (string.IsNullOrEmpty(text))
                text = "item";

            if (text.Length > 100)
                text = text.Substring(0, 100).TrimEnd('-');

            return text;
        }

        private string GenerateUniqueSlug(string baseSlug, string tableName, string columnName, SqlConnection con, SqlTransaction tx)
        {
            string slug = baseSlug;
            int suffix = 1;

            while (SlugExists(slug, tableName, columnName, con, tx))
            {
                slug = $"{baseSlug}-{suffix}";
                suffix++;
                if (suffix > 1000)
                {
                    slug = $"{baseSlug}-{Guid.NewGuid().ToString("N").Substring(0, 8)}";
                    break;
                }
            }

            return slug;
        }

        private bool SlugExists(string slug, string tableName, string columnName, SqlConnection con, SqlTransaction tx)
        {
            using (var cmd = con.CreateCommand())
            {
                cmd.Transaction = tx;
                cmd.CommandText = $"SELECT COUNT(*) FROM dbo.{tableName} WHERE {columnName} = @slug AND is_deleted = 0";
                cmd.Parameters.AddWithValue("@slug", slug);
                int count = (int)cmd.ExecuteScalar();
                return count > 0;
            }
        }

        private void ShowError(string message)
        {
            lblError.Text = message;
            lblError.Visible = true;
        }

        // Data classes for deserialization
        public class ModuleDraft
        {
            public ClassInfo ClassInfo { get; set; }
            public List<LevelItem> Levels { get; set; }
        }

        public class ClassInfo
        {
            public string Name { get; set; }
            public string Description { get; set; }
            public string Icon { get; set; }
            public string Color { get; set; }
            public string ClassCode { get; set; }
        }

        public class LevelItem
        {
            public int LevelNumber { get; set; }
            public string Title { get; set; }
            public string Description { get; set; }
            public int Minutes { get; set; }
            public int Xp { get; set; }
            public bool Publish { get; set; }
            public string FileName { get; set; }
            public string ContentType { get; set; }
            public QuizItem Quiz { get; set; }
        }
        
        public class QuizItem
        {
            public string Title { get; set; }
            public string Mode { get; set; }
            public int TimeLimit { get; set; }
            public int PassingScore { get; set; }
            public bool Publish { get; set; }
        }
    }
}



using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace RookiesInTraining2.Pages
{
    public partial class teacher_classes : System.Web.UI.Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
        private const bool ALLOW_ADMIN_VIEW = true;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Disable unobtrusive validation
            System.Web.UI.ValidationSettings.UnobtrusiveValidationMode =
                System.Web.UI.UnobtrusiveValidationMode.None;

            // Guard: Check if user is logged in
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

            if (!IsPostBack)
            {
                LoadClasses();
            }
        }

        private void LoadClasses()
        {
            string teacherSlug = Session["UserSlug"]?.ToString() ?? "";
            var classes = new List<ClassItem>();

            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = con.CreateCommand())
                {
                    con.Open();

                    // Get classes created by this teacher
                    cmd.CommandText = @"
                        SELECT 
                            c.class_slug,
                            c.class_name,
                            c.class_code,
                            c.created_at,
                            COUNT(DISTINCT e.user_slug) AS student_count
                        FROM Classes c
                        LEFT JOIN Enrollments e ON c.class_slug = e.class_slug 
                            AND e.is_deleted = 0 
                            AND e.role_in_class = 'student'
                        WHERE c.teacher_slug = @teacherSlug 
                            AND c.is_deleted = 0
                        GROUP BY c.class_slug, c.class_name, c.class_code, c.created_at
                        ORDER BY c.created_at DESC";

                    cmd.Parameters.AddWithValue("@teacherSlug", teacherSlug);

                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            classes.Add(new ClassItem
                            {
                                ClassSlug = reader["class_slug"].ToString(),
                                ClassName = reader["class_name"].ToString(),
                                ClassCode = reader["class_code"].ToString(),
                                CreatedAt = Convert.ToDateTime(reader["created_at"]),
                                StudentCount = Convert.ToInt32(reader["student_count"])
                            });
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[TeacherClasses] Error loading classes: {ex.Message}");
            }

            // Serialize to JSON for JavaScript
            var serializer = new JavaScriptSerializer();
            hfClassesJson.Value = serializer.Serialize(classes);
        }

        protected void btnSaveClass_Click(object sender, EventArgs e)
        {
            string teacherSlug = Session["UserSlug"]?.ToString() ?? "";
            string className = txtClassName.Text.Trim();
            string classCode = txtClassCode.Text.Trim().ToUpperInvariant();
            string description = txtDescription.Text.Trim();
            string icon = hfSelectedIcon.Value;
            string color = hfSelectedColor.Value;

            // Parse levels data from JSON
            List<LevelData> levelsData = new List<LevelData>();
            try
            {
                if (!string.IsNullOrWhiteSpace(hfLevelsData.Value))
                {
                    var serializer = new JavaScriptSerializer();
                    levelsData = serializer.Deserialize<List<LevelData>>(hfLevelsData.Value);
                }
                else
                {
                    // Fallback: read from fixed inputs
                    levelsData.Add(new LevelData { LevelNumber = 1, Title = txtLevel1Title.Text.Trim(), MaterialType = "upload", ManualContent = txtLevel1Content.Text });
                    levelsData.Add(new LevelData { LevelNumber = 2, Title = txtLevel2Title.Text.Trim(), MaterialType = "upload", ManualContent = txtLevel2Content.Text });
                    levelsData.Add(new LevelData { LevelNumber = 3, Title = txtLevel3Title.Text.Trim(), MaterialType = "upload", ManualContent = txtLevel3Content.Text });
                }
            }
            catch (Exception ex)
            {
                lblModalError.Text = "Error parsing level data: " + Server.HtmlEncode(ex.Message);
                lblModalError.Visible = true;
                return;
            }

            // Validate minimum 3 levels
            if (levelsData == null || levelsData.Count < 3)
            {
                lblModalError.Text = "Minimum 3 levels required!";
                lblModalError.Visible = true;
                return;
            }

            // Validate all level titles are filled
            if (levelsData.Any(l => string.IsNullOrWhiteSpace(l.Title)))
            {
                lblModalError.Text = "All level titles are required!";
                lblModalError.Visible = true;
                return;
            }

            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();

                    // Check if class code already exists
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            SELECT TOP 1 1 
                            FROM Classes 
                            WHERE class_code = @code AND is_deleted = 0";
                        cmd.Parameters.AddWithValue("@code", classCode);

                        if (cmd.ExecuteScalar() != null)
                        {
                            lblModalError.Text = "Class code already exists. Please use a different code.";
                            lblModalError.Visible = true;
                            return;
                        }
                    }

                    // Generate unique slug for class
                    string baseSlug = SlugifyClassName(className);
                    string classSlug = GenerateUniqueSlug(baseSlug, "Classes", "class_slug", con);

                    // Insert new class
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            INSERT INTO Classes 
                            (class_slug, class_name, class_code, description, teacher_slug, icon, color,
                             created_at, updated_at, is_deleted)
                            VALUES 
                            (@slug, @name, @code, @desc, @teacherSlug, @icon, @color,
                             SYSUTCDATETIME(), SYSUTCDATETIME(), 0)";

                        cmd.Parameters.AddWithValue("@slug", classSlug);
                        cmd.Parameters.AddWithValue("@name", className);
                        cmd.Parameters.AddWithValue("@code", classCode);
                        cmd.Parameters.AddWithValue("@desc", (object)description ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@teacherSlug", teacherSlug);
                        cmd.Parameters.AddWithValue("@icon", icon);
                        cmd.Parameters.AddWithValue("@color", color);

                        cmd.ExecuteNonQuery();
                    }

                    // Auto-enroll teacher
                    using (var cmd = con.CreateCommand())
                    {
                        string enrollSlug = "enroll-" + Guid.NewGuid().ToString("N").Substring(0, 12);
                        cmd.CommandText = @"
                            INSERT INTO Enrollments
                            (enrollment_slug, class_slug, user_slug, role_in_class, joined_at, is_deleted)
                            VALUES
                            (@enrollSlug, @classSlug, @teacherSlug, 'teacher', SYSUTCDATETIME(), 0)";

                        cmd.Parameters.AddWithValue("@enrollSlug", enrollSlug);
                        cmd.Parameters.AddWithValue("@classSlug", classSlug);
                        cmd.Parameters.AddWithValue("@teacherSlug", teacherSlug);

                        cmd.ExecuteNonQuery();
                    }

                    // Create all levels dynamically
                    foreach (var levelData in levelsData)
                    {
                        CreateLevelFromData(con, classSlug, levelData, Request.Files);
                    }

                    // Clear form
                    ClearForm();

                    // Reload classes
                    LoadClasses();

                    // Close modal and show success
                    ScriptManager.RegisterStartupScript(this, GetType(), "success",
                        "closeClassModal(); alert('Class created successfully with 5 levels!'); window.location.reload();", true);
                }
            }
            catch (Exception ex)
            {
                lblModalError.Text = "Error creating class: " + Server.HtmlEncode(ex.Message);
                lblModalError.Visible = true;
                System.Diagnostics.Debug.WriteLine($"[TeacherClasses] Error: {ex}");
            }
        }

        private void CreateLevelFromData(SqlConnection con, string classSlug, LevelData levelData, HttpFileCollection files)
        {
            string levelSlug = $"{classSlug}-level-{levelData.LevelNumber}";
            string contentType = null;
            string contentUrl = null;

            // Handle file upload or manual content
            if (levelData.MaterialType == "upload" && files.Count > 0)
            {
                // Try to find uploaded file for this level
                // Files from dynamically added inputs won't have server controls, so we check HttpFileCollection
                for (int i = 0; i < files.Count; i++)
                {
                    var file = files[i];
                    if (file != null && file.ContentLength > 0)
                    {
                        // This is a simplified approach - in production you'd match by field name
                        var result = HandleLevelFileUploadFromHttpFile(file, classSlug, levelSlug);
                        if (result.Item1 != null)
                        {
                            contentType = result.Item1;
                            contentUrl = result.Item2;
                            break; // Use first valid file found
                        }
                    }
                }
            }
            else if (levelData.MaterialType == "manual" && !string.IsNullOrWhiteSpace(levelData.ManualContent))
            {
                contentType = "html";
                contentUrl = null; // Will store in description
            }

            using (var cmd = con.CreateCommand())
            {
                cmd.CommandText = @"
                    INSERT INTO Levels 
                    (level_slug, class_slug, level_number, title, description,
                     content_type, content_url, xp_reward, estimated_minutes, is_published,
                     created_at, updated_at, is_deleted)
                    VALUES 
                    (@slug, @classSlug, @levelNum, @title, @desc,
                     @contentType, @contentUrl, 50, 15, 1,
                     SYSUTCDATETIME(), SYSUTCDATETIME(), 0)";

                cmd.Parameters.AddWithValue("@slug", levelSlug);
                cmd.Parameters.AddWithValue("@classSlug", classSlug);
                cmd.Parameters.AddWithValue("@levelNum", levelData.LevelNumber);
                cmd.Parameters.AddWithValue("@title", levelData.Title);
                cmd.Parameters.AddWithValue("@desc", levelData.MaterialType == "manual" ? levelData.ManualContent : $"Learning material for {levelData.Title}");
                cmd.Parameters.AddWithValue("@contentType", (object)contentType ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@contentUrl", (object)contentUrl ?? DBNull.Value);

                cmd.ExecuteNonQuery();
            }
        }

        private Tuple<string, string> HandleLevelFileUploadFromHttpFile(HttpPostedFile file, string classSlug, string levelSlug)
        {
            if (file == null || file.ContentLength == 0) return Tuple.Create<string, string>(null, null);

            string extension = System.IO.Path.GetExtension(file.FileName).ToLowerInvariant();
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
                case ".mp4":
                case ".avi":
                case ".mov":
                    contentType = "video";
                    break;
                default:
                    return Tuple.Create<string, string>(null, null);
            }

            // Create directory
            string uploadFolder = Server.MapPath($"~/Uploads/{classSlug}/");
            if (!System.IO.Directory.Exists(uploadFolder))
            {
                System.IO.Directory.CreateDirectory(uploadFolder);
            }

            // Save file
            string safeFileName = $"{levelSlug}{extension}";
            string filePath = System.IO.Path.Combine(uploadFolder, safeFileName);
            file.SaveAs(filePath);

            string relativeUrl = $"/Uploads/{classSlug}/{safeFileName}";

            return Tuple.Create(contentType, relativeUrl);
        }

        private Tuple<string, string> HandleLevelFileUpload(FileUpload upload, string classSlug, string levelSlug)
        {
            if (!upload.HasFile) return Tuple.Create<string, string>(null, null);

            string extension = System.IO.Path.GetExtension(upload.FileName).ToLowerInvariant();
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
                case ".mp4":
                case ".avi":
                case ".mov":
                    contentType = "video";
                    break;
                default:
                    return Tuple.Create<string, string>(null, null);
            }

            // Create directory
            string uploadFolder = Server.MapPath($"~/Uploads/{classSlug}/");
            if (!System.IO.Directory.Exists(uploadFolder))
            {
                System.IO.Directory.CreateDirectory(uploadFolder);
            }

            // Save file
            string safeFileName = $"{levelSlug}{extension}";
            string filePath = System.IO.Path.Combine(uploadFolder, safeFileName);
            upload.SaveAs(filePath);

            string relativeUrl = $"/Uploads/{classSlug}/{safeFileName}";

            return Tuple.Create(contentType, relativeUrl);
        }

        private void ClearForm()
        {
            txtClassName.Text = "";
            txtClassCode.Text = "";
            txtDescription.Text = "";
            txtLevel1Title.Text = "";
            txtLevel2Title.Text = "";
            txtLevel3Title.Text = "";
            txtLevel1Content.Text = "";
            txtLevel2Content.Text = "";
            txtLevel3Content.Text = "";
            hfLevelsData.Value = "";
            lblModalError.Visible = false;
        }

        // Data class for level information
        public class LevelData
        {
            public int LevelNumber { get; set; }
            public string Title { get; set; }
            public string MaterialType { get; set; } // "upload" or "manual"
            public string ManualContent { get; set; }
        }

        #region Helper Methods

        private string SlugifyClassName(string className)
        {
            if (string.IsNullOrWhiteSpace(className)) return "class";

            string slug = className.Trim().ToLowerInvariant();

            // Remove accents
            var sb = new StringBuilder(slug.Length);
            foreach (var ch in slug.Normalize(NormalizationForm.FormD))
            {
                var cat = CharUnicodeInfo.GetUnicodeCategory(ch);
                if (cat != UnicodeCategory.NonSpacingMark)
                    sb.Append(ch);
            }
            slug = sb.ToString().Normalize(NormalizationForm.FormC);

            // Replace non-alphanumeric with hyphen
            slug = Regex.Replace(slug, @"[^a-z0-9]+", "-");
            slug = slug.Trim('-');
            slug = Regex.Replace(slug, "-{2,}", "-");

            if (string.IsNullOrEmpty(slug))
                slug = "class";

            if (slug.Length > 40)
                slug = slug.Substring(0, 40).TrimEnd('-');

            return slug;
        }

        private string GenerateUniqueSlug(string baseSlug, string tableName, string columnName)
        {
            string slug = baseSlug;
            int counter = 1;

            using (var con = new SqlConnection(ConnStr))
            using (var cmd = con.CreateCommand())
            {
                con.Open();

                while (SlugExists(slug, tableName, columnName, con))
                {
                    slug = baseSlug + "-" + counter.ToString(CultureInfo.InvariantCulture);
                    counter++;

                    if (counter > 1000) // Safety break
                    {
                        slug = baseSlug + "-" + Guid.NewGuid().ToString("N").Substring(0, 8);
                        break;
                    }
                }
            }

            return slug;
        }

        private string GenerateUniqueSlug(string baseSlug, string tableName, string columnName, SqlConnection connection)
        {
            string slug = baseSlug;
            int counter = 1;

            while (SlugExists(slug, tableName, columnName, connection))
            {
                slug = baseSlug + "-" + counter.ToString(CultureInfo.InvariantCulture);
                counter++;

                if (counter > 1000) // Safety break
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

        public class ClassItem
        {
            public string ClassSlug { get; set; }
            public string ClassName { get; set; }
            public string ClassCode { get; set; }
            public DateTime CreatedAt { get; set; }
            public int StudentCount { get; set; }
            public string Icon { get; set; }
            public string Color { get; set; }
        }

        #endregion
    }
}



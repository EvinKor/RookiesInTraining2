using System;
using System.Collections.Generic;
using System.Configuration;
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
    public partial class teacher_create_class : System.Web.UI.Page
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
            string role = Convert.ToString(Session["Role"])?.ToLowerInvariant();
            if (role != "teacher" && role != "admin")
            {
                Response.Redirect("~/Pages/Login.aspx", false);
                return;
            }
        }

        protected void btnCreateClass_Click(object sender, EventArgs e)
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
            }
            catch (Exception ex)
            {
                lblError.Text = "Error parsing level data: " + Server.HtmlEncode(ex.Message);
                lblError.Visible = true;
                return;
            }

            // Validate minimum 3 levels
            if (levelsData == null || levelsData.Count < 3)
            {
                lblError.Text = "Minimum 3 levels required!";
                lblError.Visible = true;
                return;
            }

            // Validate all level titles are filled
            if (levelsData.Any(l => string.IsNullOrWhiteSpace(l.Title)))
            {
                lblError.Text = "All level titles are required!";
                lblError.Visible = true;
                return;
            }

            // Validate class name and code
            if (string.IsNullOrWhiteSpace(className))
            {
                lblError.Text = "Class name is required!";
                lblError.Visible = true;
                return;
            }

            if (string.IsNullOrWhiteSpace(classCode))
            {
                lblError.Text = "Class code is required!";
                lblError.Visible = true;
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
                            lblError.Text = "Class code already exists. Please use a different code.";
                            lblError.Visible = true;
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

                    // Success - redirect to browse page
                    Response.Redirect($"~/Pages/teacher_browse_classes.aspx?created=1", false);
                }
            }
            catch (Exception ex)
            {
                lblError.Text = "Error creating class: " + Server.HtmlEncode(ex.Message);
                lblError.Visible = true;
                System.Diagnostics.Debug.WriteLine($"[TeacherCreateClass] Error: {ex}");
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
                for (int i = 0; i < files.Count; i++)
                {
                    var file = files[i];
                    if (file != null && file.ContentLength > 0)
                    {
                        var result = HandleLevelFileUploadFromHttpFile(file, classSlug, levelSlug);
                        if (result.Item1 != null)
                        {
                            contentType = result.Item1;
                            contentUrl = result.Item2;
                            break;
                        }
                    }
                }
            }
            else if (levelData.MaterialType == "manual" && !string.IsNullOrWhiteSpace(levelData.ManualContent))
            {
                contentType = "html";
                contentUrl = null;
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

        private string GenerateUniqueSlug(string baseSlug, string tableName, string columnName, SqlConnection connection)
        {
            string slug = baseSlug;
            int counter = 1;

            while (SlugExists(slug, tableName, columnName, connection))
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

        // Data class for level information
        public class LevelData
        {
            public int LevelNumber { get; set; }
            public string Title { get; set; }
            public string MaterialType { get; set; } // "upload" or "manual"
            public string ManualContent { get; set; }
        }
    }
}


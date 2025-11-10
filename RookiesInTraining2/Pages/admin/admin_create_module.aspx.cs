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
    public partial class admin_create_module : System.Web.UI.Page
    {
        private static readonly string ConnStr = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Authorization check - only admin can access
            if (Session["UserSlug"] == null || Session["Role"]?.ToString() != "admin")
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
                // Get admin slug (acting as teacher)
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
                if (draft == null || draft.ClassInfo == null)
                {
                    ShowError("Invalid data format.");
                    return;
                }

                if (string.IsNullOrWhiteSpace(draft.ClassInfo.Name) || draft.ClassInfo.Name.Length < 3)
                {
                    ShowError("Class name must be at least 3 characters.");
                    return;
                }

                // Note: No level validation - levels will be added later in Story Mode

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

                            // Auto-enroll admin as teacher
                            using (var cmd = con.CreateCommand())
                            {
                                string enrollSlug = "enroll-" + Guid.NewGuid().ToString("N").Substring(0, 12);
                                cmd.Transaction = tx;
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

                            // Note: Levels will be added later in Story Mode
                            // No upload directory or level creation needed here

                            // Commit transaction
                            tx.Commit();
                            
                            System.Diagnostics.Debug.WriteLine($"[CreateClass] Class created successfully!");
                            System.Diagnostics.Debug.WriteLine($"[CreateClass] Class Slug: {classSlug}");
                            System.Diagnostics.Debug.WriteLine($"[CreateClass] Teacher Slug: {teacherSlug}");

                            // Redirect to admin Classes page
                            Response.Redirect($"~/Pages/admin/Classes.aspx", false);
                        }
                        catch (Exception ex)
                        {
                            tx.Rollback();
                            System.Diagnostics.Debug.WriteLine($"[CreateClass] ❌ ERROR during creation: {ex}");
                            System.Diagnostics.Debug.WriteLine($"[CreateClass] Stack trace: {ex.StackTrace}");
                            throw new Exception("Failed to create class: " + ex.Message, ex);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowError("Error creating class: " + ex.Message);
            }
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



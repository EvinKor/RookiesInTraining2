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
    public partial class teacher_modules : System.Web.UI.Page
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

            // Check role
            string role = Convert.ToString(Session["Role"])?.ToLowerInvariant();
            if (role != "teacher" && role != "admin")
            {
                Response.Redirect("~/Pages/Login.aspx", false);
                return;
            }

            if (!IsPostBack)
            {
                LoadModules();
            }
        }

        private void LoadModules()
        {
            string teacherSlug = Session["UserSlug"]?.ToString() ?? "";
            List<ModuleItem> modules = new List<ModuleItem>();

            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = con.CreateCommand())
                {
                    cmd.CommandText = "sp_GetTeacherModules";
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@teacher_slug", teacherSlug);

                    con.Open();
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            modules.Add(new ModuleItem
                            {
                                ModuleSlug = reader["module_slug"].ToString(),
                                Title = reader["title"].ToString(),
                                Summary = reader["summary"].ToString(),
                                Icon = reader["icon"].ToString(),
                                Color = reader["color"].ToString(),
                                OrderNo = Convert.ToInt32(reader["order_no"]),
                                IsActive = Convert.ToBoolean(reader["is_active"]),
                                QuizCount = Convert.ToInt32(reader["quiz_count"]),
                                PublishedQuizCount = Convert.ToInt32(reader["published_quiz_count"]),
                                CreatedAt = Convert.ToDateTime(reader["created_at"])
                            });
                        }
                    }
                }

                // Serialize to JSON
                var serializer = new JavaScriptSerializer();
                hfModulesJson.Value = serializer.Serialize(modules);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[TeacherModules] Error loading modules: {ex}");
                lblError.Text = "Error loading modules: " + Server.HtmlEncode(ex.Message);
                lblError.Visible = true;
            }
        }

        protected void btnSaveDraft_Click(object sender, EventArgs e)
        {
            CreateModule(false);
        }

        protected void btnCreateAndAddQuizzes_Click(object sender, EventArgs e)
        {
            CreateModule(true);
        }

        private void CreateModule(bool redirectToEdit)
        {
            Page.Validate("CreateModule");
            if (!Page.IsValid) return;

            string teacherSlug = Session["UserSlug"]?.ToString() ?? "";
            string title = txtTitle.Text.Trim();
            string summary = txtSummary.Text.Trim();
            string icon = hfSelectedIcon.Value;
            string color = hfSelectedColor.Value;
            int orderNo = int.TryParse(txtOrder.Text, out int o) ? o : 1;

            try
            {
                string moduleSlug = GenerateUniqueSlug(SlugifyTitle(title), "Modules", "module_slug");

                using (var con = new SqlConnection(ConnStr))
                using (var cmd = con.CreateCommand())
                {
                    cmd.CommandText = @"
                        INSERT INTO Modules 
                        (module_slug, title, summary, icon, color, order_no, is_active, 
                         created_by_slug, created_at, updated_at, is_deleted)
                        VALUES 
                        (@slug, @title, @summary, @icon, @color, @order, 0,
                         @creator, SYSUTCDATETIME(), SYSUTCDATETIME(), 0)";

                    cmd.Parameters.AddWithValue("@slug", moduleSlug);
                    cmd.Parameters.AddWithValue("@title", title);
                    cmd.Parameters.AddWithValue("@summary", (object)summary ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@icon", icon);
                    cmd.Parameters.AddWithValue("@color", color);
                    cmd.Parameters.AddWithValue("@order", orderNo);
                    cmd.Parameters.AddWithValue("@creator", teacherSlug);

                    con.Open();
                    cmd.ExecuteNonQuery();
                }

                // Clear form
                txtTitle.Text = "";
                txtSummary.Text = "";
                txtOrder.Text = "1";
                lblError.Visible = false;

                if (redirectToEdit)
                {
                    Response.Redirect($"~/Pages/teacher_module_edit.aspx?module={moduleSlug}", false);
                }
                else
                {
                    // Reload and show success
                    LoadModules();
                    ScriptManager.RegisterStartupScript(this, GetType(), "closeModal",
                        "closeNewModuleModal(); location.reload();", true);
                }
            }
            catch (Exception ex)
            {
                lblError.Text = "Error creating module: " + Server.HtmlEncode(ex.Message);
                lblError.Visible = true;
                System.Diagnostics.Debug.WriteLine($"[TeacherModules] Error: {ex}");
            }
        }

        #region Helper Methods

        private string SlugifyTitle(string title)
        {
            if (string.IsNullOrWhiteSpace(title)) return "module";

            string slug = title.Trim().ToLowerInvariant();

            // Remove accents
            var sb = new StringBuilder(slug.Length);
            foreach (var ch in slug.Normalize(NormalizationForm.FormD))
            {
                var cat = System.Globalization.CharUnicodeInfo.GetUnicodeCategory(ch);
                if (cat != System.Globalization.UnicodeCategory.NonSpacingMark)
                    sb.Append(ch);
            }
            slug = sb.ToString().Normalize(NormalizationForm.FormC);

            // Replace non-alphanumeric with hyphen
            slug = Regex.Replace(slug, @"[^a-z0-9]+", "-");
            slug = slug.Trim('-');
            slug = Regex.Replace(slug, "-{2,}", "-");

            if (string.IsNullOrEmpty(slug))
                slug = "module";

            if (slug.Length > 80)
                slug = slug.Substring(0, 80).TrimEnd('-');

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

                    if (counter > 1000)
                    {
                        slug = baseSlug + "-" + Guid.NewGuid().ToString("N").Substring(0, 8);
                        break;
                    }
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

        // Data class for module
        public class ModuleItem
        {
            public string ModuleSlug { get; set; }
            public string Title { get; set; }
            public string Summary { get; set; }
            public string Icon { get; set; }
            public string Color { get; set; }
            public int OrderNo { get; set; }
            public bool IsActive { get; set; }
            public int QuizCount { get; set; }
            public int PublishedQuizCount { get; set; }
            public DateTime CreatedAt { get; set; }
        }
    }
}


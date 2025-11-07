using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Text;
using System.Text.RegularExpressions;
using System.Web.UI;

namespace RookiesInTraining2.Pages.teacher
{
    public partial class create_forum_post : System.Web.UI.Page
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
                string classSlug = Request.QueryString["class"];
                if (string.IsNullOrWhiteSpace(classSlug))
                {
                    Response.Redirect("~/Pages/teacher/manage_classes.aspx", false);
                    return;
                }

                hfClassSlug.Value = classSlug;
                
                // Set back link
                lnkBack.NavigateUrl = $"~/Pages/teacher/manage_classes.aspx?class={classSlug}";
                lnkCancel.NavigateUrl = $"~/Pages/teacher/manage_classes.aspx?class={classSlug}";
            }
        }

        protected void btnCreatePost_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string classSlug = hfClassSlug.Value;
            string userSlug = Session["UserSlug"]?.ToString() ?? "";
            string title = txtTitle.Text.Trim();
            string content = txtContent.Text.Trim();

            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();
                    
                    string postSlug = GenerateUniqueSlug(SlugifyText(title), "ForumPosts", "post_slug", con);

                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            INSERT INTO ForumPosts 
                            (post_slug, class_slug, title, content, user_slug, created_at, updated_at, is_deleted)
                            VALUES 
                            (@postSlug, @classSlug, @title, @content, @userSlug, SYSUTCDATETIME(), SYSUTCDATETIME(), 0)";

                        cmd.Parameters.AddWithValue("@postSlug", postSlug);
                        cmd.Parameters.AddWithValue("@classSlug", classSlug);
                        cmd.Parameters.AddWithValue("@title", title);
                        cmd.Parameters.AddWithValue("@content", content);
                        cmd.Parameters.AddWithValue("@userSlug", userSlug);

                        cmd.ExecuteNonQuery();
                    }

                    System.Diagnostics.Debug.WriteLine($"[ForumPost] Post created: {postSlug}");

                    // Redirect back to forum
                    Response.Redirect($"~/Pages/teacher/manage_classes.aspx?class={classSlug}", false);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[ForumPost] Error: {ex}");
                lblError.Text = $"Error creating post: {Server.HtmlEncode(ex.Message)}";
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


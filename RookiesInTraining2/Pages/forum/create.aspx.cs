using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Globalization;
using System.Text;
using System.Text.RegularExpressions;
using System.Web.UI;

namespace RookiesInTraining2.Pages.forum
{
    public partial class create : System.Web.UI.Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserSlug"] == null)
            {
                Response.Redirect("~/Pages/Login.aspx", false);
                return;
            }

            System.Web.UI.ValidationSettings.UnobtrusiveValidationMode =
                System.Web.UI.UnobtrusiveValidationMode.None;
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            Page.Validate();
            if (!Page.IsValid) return;

            string userSlug = Session["UserSlug"]?.ToString() ?? "";
            string title = txtTitle.Text.Trim();
            string content = txtContent.Text.Trim();

            if (string.IsNullOrEmpty(title) || string.IsNullOrEmpty(content))
            {
                lblError.Text = "Please fill in all fields.";
                lblError.Visible = true;
                return;
            }

            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();
                    using (var cmd = con.CreateCommand())
                    {
                        string threadSlug = GenerateSlug(title);
                        
                        cmd.CommandText = @"
                            INSERT INTO ForumThreads (thread_slug, title, content, author_slug, created_at, is_deleted)
                            VALUES (@slug, @title, @content, @author, SYSUTCDATETIME(), 0)";

                        cmd.Parameters.AddWithValue("@slug", threadSlug);
                        cmd.Parameters.AddWithValue("@title", title);
                        cmd.Parameters.AddWithValue("@content", content);
                        cmd.Parameters.AddWithValue("@author", userSlug);
                        cmd.ExecuteNonQuery();

                        Response.Redirect($"thread.aspx?id={threadSlug}", false);
                    }
                }
            }
            catch (Exception ex)
            {
                lblError.Text = "Error creating thread: " + Server.HtmlEncode(ex.Message);
                lblError.Visible = true;
            }
        }

        private string GenerateSlug(string title)
        {
            if (string.IsNullOrWhiteSpace(title)) return "thread-" + Guid.NewGuid().ToString("N").Substring(0, 8);
            
            string s = title.Trim().ToLowerInvariant();
            var sb = new StringBuilder(s.Length);
            foreach (var ch in s.Normalize(System.Text.NormalizationForm.FormD))
            {
                var cat = CharUnicodeInfo.GetUnicodeCategory(ch);
                if (cat != System.Globalization.UnicodeCategory.NonSpacingMark) sb.Append(ch);
            }
            s = sb.ToString().Normalize(System.Text.NormalizationForm.FormC);
            s = Regex.Replace(s, @"[^a-z0-9]+", "-").Trim('-');
            s = Regex.Replace(s, "-{2,}", "-");
            if (s.Length == 0) s = "thread";
            if (s.Length > 80) s = s.Substring(0, 80).Trim('-');
            return s + "-" + Guid.NewGuid().ToString("N").Substring(0, 8);
        }
    }
}


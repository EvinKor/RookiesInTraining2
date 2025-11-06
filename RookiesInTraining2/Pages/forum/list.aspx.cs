using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace RookiesInTraining2.Pages.forum
{
    public partial class list : System.Web.UI.Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserSlug"] == null)
            {
                Response.Redirect("~/Pages/Login.aspx", false);
                return;
            }

            if (!IsPostBack)
            {
                LoadThreads();
            }
        }

        private void LoadThreads()
        {
            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            SELECT 
                                ft.thread_slug, ft.title, ft.content, ft.created_at,
                                u.display_name AS author_name,
                                (SELECT COUNT(*) FROM ForumPosts WHERE thread_slug = ft.thread_slug AND is_deleted = 0) AS post_count
                            FROM ForumThreads ft
                            INNER JOIN Users u ON ft.author_slug = u.user_slug
                            WHERE ft.is_deleted = 0
                            ORDER BY ft.created_at DESC";

                        var threads = new List<ThreadInfo>();
                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                threads.Add(new ThreadInfo
                                {
                                    ThreadSlug = reader["thread_slug"].ToString(),
                                    Title = reader["title"].ToString(),
                                    Content = reader["content"]?.ToString() ?? "",
                                    AuthorName = reader["author_name"].ToString(),
                                    CreatedAt = Convert.ToDateTime(reader["created_at"]).ToString("MMM dd, yyyy"),
                                    PostCount = Convert.ToInt32(reader["post_count"])
                                });
                            }
                        }

                        if (threads.Count > 0)
                        {
                            rptThreads.DataSource = threads;
                            rptThreads.DataBind();
                            lblNoThreads.Visible = false;
                        }
                        else
                        {
                            lblNoThreads.Visible = true;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[Forum] Error loading threads: {ex}");
                // If table doesn't exist, show message
                lblNoThreads.Visible = true;
                lblNoThreads.Text = "Forum feature coming soon!";
            }
        }

        public class ThreadInfo
        {
            public string ThreadSlug { get; set; }
            public string Title { get; set; }
            public string Content { get; set; }
            public string AuthorName { get; set; }
            public string CreatedAt { get; set; }
            public int PostCount { get; set; }
        }
    }
}


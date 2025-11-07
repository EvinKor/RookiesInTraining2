using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Text;
using System.Text.RegularExpressions;
using System.Web.UI;

namespace RookiesInTraining2.Pages.teacher
{
    public partial class view_forum_post : System.Web.UI.Page
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
            if (role != "teacher" && role != "admin" && role != "student")
            {
                Response.Redirect("~/Pages/Login.aspx", false);
                return;
            }

            if (!IsPostBack)
            {
                string postSlug = Request.QueryString["post"];
                string classSlug = Request.QueryString["class"];
                
                if (string.IsNullOrWhiteSpace(postSlug) || string.IsNullOrWhiteSpace(classSlug))
                {
                    Response.Redirect("~/Pages/teacher/manage_classes.aspx", false);
                    return;
                }

                hfPostSlug.Value = postSlug;
                hfClassSlug.Value = classSlug;
                
                // Set back link
                lnkBack.NavigateUrl = $"~/Pages/teacher/manage_classes.aspx?class={classSlug}";

                // Load post and replies
                LoadPost(postSlug, classSlug);
                LoadReplies(postSlug);
            }
        }

        private void LoadPost(string postSlug, string classSlug)
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
                                fp.title,
                                fp.content,
                                fp.created_at,
                                u.full_name AS author_name
                            FROM ForumPosts fp
                            LEFT JOIN Users u ON fp.user_slug = u.user_slug
                            WHERE fp.post_slug = @postSlug 
                              AND fp.class_slug = @classSlug 
                              AND fp.is_deleted = 0";

                        cmd.Parameters.AddWithValue("@postSlug", postSlug);
                        cmd.Parameters.AddWithValue("@classSlug", classSlug);

                        using (var reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                lblPostTitle.Text = reader["title"].ToString();
                                lblContent.Text = reader["content"].ToString();
                                lblAuthor.Text = reader["author_name"].ToString();
                                lblDate.Text = FormatDate(Convert.ToDateTime(reader["created_at"]));
                            }
                            else
                            {
                                Response.Redirect($"~/Pages/teacher/manage_classes.aspx?class={classSlug}", false);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[ViewPost] Error loading post: {ex.Message}");
                Response.Redirect($"~/Pages/teacher/manage_classes.aspx?class={classSlug}", false);
            }
        }

        private void LoadReplies(string postSlug)
        {
            List<dynamic> replies = new List<dynamic>();

            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            SELECT 
                                fr.reply_slug,
                                fr.content,
                                fr.created_at,
                                u.full_name AS author_name
                            FROM ForumReplies fr
                            LEFT JOIN Users u ON fr.user_slug = u.user_slug
                            WHERE fr.post_slug = @postSlug AND fr.is_deleted = 0
                            ORDER BY fr.created_at ASC";

                        cmd.Parameters.AddWithValue("@postSlug", postSlug);

                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                replies.Add(new
                                {
                                    ReplySlug = reader["reply_slug"].ToString(),
                                    Content = reader["content"].ToString(),
                                    CreatedAt = Convert.ToDateTime(reader["created_at"]),
                                    AuthorName = reader["author_name"].ToString()
                                });
                            }
                        }
                    }
                }

                lblReplyCount.Text = replies.Count.ToString();

                if (replies.Count > 0)
                {
                    rptReplies.DataSource = replies;
                    rptReplies.DataBind();
                    lblNoReplies.Visible = false;
                }
                else
                {
                    lblNoReplies.Visible = true;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[ViewPost] Error loading replies: {ex.Message}");
                lblNoReplies.Visible = true;
            }
        }

        protected void btnPostReply_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string postSlug = hfPostSlug.Value;
            string classSlug = hfClassSlug.Value;
            string userSlug = Session["UserSlug"]?.ToString() ?? "";
            string content = txtReply.Text.Trim();

            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();
                    
                    string replySlug = GenerateUniqueSlug(SlugifyText($"reply-{postSlug}"), "ForumReplies", "reply_slug", con);

                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            INSERT INTO ForumReplies 
                            (reply_slug, post_slug, content, user_slug, created_at, updated_at, is_deleted)
                            VALUES 
                            (@replySlug, @postSlug, @content, @userSlug, SYSUTCDATETIME(), SYSUTCDATETIME(), 0)";

                        cmd.Parameters.AddWithValue("@replySlug", replySlug);
                        cmd.Parameters.AddWithValue("@postSlug", postSlug);
                        cmd.Parameters.AddWithValue("@content", content);
                        cmd.Parameters.AddWithValue("@userSlug", userSlug);

                        cmd.ExecuteNonQuery();
                    }

                    System.Diagnostics.Debug.WriteLine($"[ViewPost] Reply created: {replySlug}");

                    // Redirect to refresh the page (GET request, no POST resubmission)
                    Response.Redirect($"~/Pages/teacher/view_forum_post.aspx?post={postSlug}&class={classSlug}", false);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[ViewPost] Error: {ex}");
                lblReplyError.Text = $"Error posting reply: {Server.HtmlEncode(ex.Message)}";
                lblReplyError.Visible = true;
            }
        }

        protected string FormatDate(DateTime date)
        {
            TimeSpan diff = DateTime.Now - date;
            
            if (diff.TotalMinutes < 1) return "Just now";
            if (diff.TotalMinutes < 60) return $"{(int)diff.TotalMinutes} minute{((int)diff.TotalMinutes > 1 ? "s" : "")} ago";
            if (diff.TotalHours < 24) return $"{(int)diff.TotalHours} hour{((int)diff.TotalHours > 1 ? "s" : "")} ago";
            if (diff.TotalDays < 7) return $"{(int)diff.TotalDays} day{((int)diff.TotalDays > 1 ? "s" : "")} ago";
            
            return date.ToString("MMM dd, yyyy");
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


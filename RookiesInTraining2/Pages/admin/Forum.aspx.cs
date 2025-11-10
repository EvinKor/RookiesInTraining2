using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;
using RookiesInTraining2.Helpers;

namespace RookiesInTraining2.Pages
{
    public partial class ManageForum : System.Web.UI.Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Check authentication - only admin can access
            if (Session["UserSlug"] == null || Session["Role"]?.ToString() != "admin")
            {
                Response.Redirect("~/Pages/Login.aspx", false);
                return;
            }

            if (!IsPostBack)
            {
                LoadPosts();
                LoadReplies();
            }
        }

        private void LoadPosts()
        {
            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = con.CreateCommand())
                {
                    con.Open();
                    cmd.CommandText = @"
                        SELECT 
                            fp.post_slug as PostSlug,
                            fp.title as Title,
                            fp.content as Content,
                            u.display_name as AuthorName,
                            c.class_name as ClassName,
                            (SELECT COUNT(*) FROM ForumReplies fr 
                             WHERE fr.post_slug = fp.post_slug AND fr.is_deleted = 0) as ReplyCount,
                            FORMAT(fp.created_at, 'yyyy-MM-dd HH:mm') as CreatedAt
                        FROM ForumPosts fp
                        LEFT JOIN Users u ON fp.user_slug = u.user_slug
                        LEFT JOIN Classes c ON fp.class_slug = c.class_slug
                        WHERE fp.is_deleted = 0
                        ORDER BY fp.created_at DESC";

                    var posts = new List<dynamic>();
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            posts.Add(new
                            {
                                PostSlug = reader["PostSlug"].ToString(),
                                Title = reader["Title"].ToString(),
                                Content = reader["Content"]?.ToString() ?? "",
                                AuthorName = reader["AuthorName"]?.ToString() ?? "Unknown",
                                ClassName = reader["ClassName"]?.ToString() ?? "Unknown",
                                ReplyCount = Convert.ToInt32(reader["ReplyCount"]),
                                CreatedAt = reader["CreatedAt"].ToString()
                            });
                        }
                    }

                    if (posts.Count > 0)
                    {
                        rptPosts.DataSource = posts;
                        rptPosts.DataBind();
                        lblNoPosts.Visible = false;
                    }
                    else
                    {
                        lblNoPosts.Visible = true;
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[Forum] Error loading posts: {ex.Message}");
                lblNoPosts.Visible = true;
                lblNoPosts.Text = "Error loading posts. Please try again.";
            }
        }

        private void LoadReplies()
        {
            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = con.CreateCommand())
                {
                    con.Open();
                    cmd.CommandText = @"
                        SELECT 
                            fr.reply_slug as ReplySlug,
                            fr.content as Content,
                            u.display_name as AuthorName,
                            fp.title as PostTitle,
                            FORMAT(fr.created_at, 'yyyy-MM-dd HH:mm') as CreatedAt
                        FROM ForumReplies fr
                        LEFT JOIN Users u ON fr.user_slug = u.user_slug
                        LEFT JOIN ForumPosts fp ON fr.post_slug = fp.post_slug
                        WHERE fr.is_deleted = 0
                        ORDER BY fr.created_at DESC";

                    var replies = new List<dynamic>();
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            replies.Add(new
                            {
                                ReplySlug = reader["ReplySlug"].ToString(),
                                Content = reader["Content"].ToString(),
                                AuthorName = reader["AuthorName"]?.ToString() ?? "Unknown",
                                PostTitle = reader["PostTitle"]?.ToString() ?? "Unknown",
                                CreatedAt = reader["CreatedAt"].ToString()
                            });
                        }
                    }

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
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[Forum] Error loading replies: {ex.Message}");
                lblNoReplies.Visible = true;
                lblNoReplies.Text = "Error loading replies. Please try again.";
            }
        }

        protected void rptPosts_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "DeletePost")
            {
                string adminSlug = Session["UserSlug"]?.ToString();
                string postSlug = e.CommandArgument.ToString();

                try
                {
                    using (var con = new SqlConnection(ConnStr))
                    {
                        con.Open();
                        using (var tx = con.BeginTransaction())
                        {
                            try
                            {
                                // Get post title for logging
                                string postTitle = "";
                                using (var cmd = con.CreateCommand())
                                {
                                    cmd.Transaction = tx;
                                    cmd.CommandText = "SELECT title FROM ForumPosts WHERE post_slug = @slug";
                                    cmd.Parameters.AddWithValue("@slug", postSlug);
                                    postTitle = cmd.ExecuteScalar()?.ToString() ?? "Unknown";
                                }

                                // Soft delete all replies first
                                using (var cmd = con.CreateCommand())
                                {
                                    cmd.Transaction = tx;
                                    cmd.CommandText = @"
                                        UPDATE ForumReplies 
                                        SET is_deleted = 1, updated_at = SYSUTCDATETIME()
                                        WHERE post_slug = @postSlug";
                                    cmd.Parameters.AddWithValue("@postSlug", postSlug);
                                    cmd.ExecuteNonQuery();
                                }

                                // Soft delete the post
                                using (var cmd = con.CreateCommand())
                                {
                                    cmd.Transaction = tx;
                                    cmd.CommandText = @"
                                        UPDATE ForumPosts 
                                        SET is_deleted = 1, updated_at = SYSUTCDATETIME()
                                        WHERE post_slug = @postSlug";
                                    cmd.Parameters.AddWithValue("@postSlug", postSlug);
                                    cmd.ExecuteNonQuery();
                                }

                                tx.Commit();

                                // Log admin action
                                AdminAuditLogger.LogAction(adminSlug, "delete_post", "post", postSlug, 
                                    $"Deleted post: {postTitle}");

                                LoadPosts();
                                LoadReplies();
                            }
                            catch (Exception ex)
                            {
                                tx.Rollback();
                                throw ex;
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"[Forum] Error deleting post: {ex.Message}");
                    ClientScript.RegisterStartupScript(this.GetType(), "showError",
                        $"alert('Error deleting post: {Server.HtmlEncode(ex.Message)}');", true);
                }
            }
        }

        protected void btnUpdatePost_Click(object sender, EventArgs e)
        {
            string adminSlug = Session["UserSlug"]?.ToString();
            string postSlug = hfEditPostSlug.Value;
            string title = txtEditPostTitle.Text.Trim();
            string content = txtEditPostContent.Text.Trim();

            if (string.IsNullOrWhiteSpace(title) || string.IsNullOrWhiteSpace(content))
            {
                lblEditPostError.Text = "Title and content are required.";
                lblEditPostError.Visible = true;
                return;
            }

            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = con.CreateCommand())
                {
                    con.Open();

                    // Get original post title for logging
                    string originalTitle = "";
                    cmd.CommandText = "SELECT title FROM ForumPosts WHERE post_slug = @slug";
                    cmd.Parameters.AddWithValue("@slug", postSlug);
                    var titleResult = cmd.ExecuteScalar();
                    if (titleResult != null)
                    {
                        originalTitle = titleResult.ToString();
                    }

                    // Update the post
                    cmd.Parameters.Clear();
                    cmd.CommandText = @"
                        UPDATE ForumPosts 
                        SET title = @title, 
                            content = @content, 
                            updated_at = SYSUTCDATETIME()
                        WHERE post_slug = @postSlug AND is_deleted = 0";
                    
                    cmd.Parameters.AddWithValue("@title", title);
                    cmd.Parameters.AddWithValue("@content", content);
                    cmd.Parameters.AddWithValue("@postSlug", postSlug);

                    int rowsAffected = cmd.ExecuteNonQuery();
                    if (rowsAffected > 0)
                    {
                        // Log admin action
                        AdminAuditLogger.LogAction(adminSlug, "edit_post", "post", postSlug, 
                            $"Edited post: {originalTitle}");

                        // Reload data
                        LoadPosts();
                        LoadReplies();

                        // Close modal via JavaScript
                        ClientScript.RegisterStartupScript(this.GetType(), "closeEditPostModal",
                            "setTimeout(function() { var modal = bootstrap.Modal.getInstance(document.getElementById('editPostModal')); if (modal) modal.hide(); }, 100);", true);
                    }
                    else
                    {
                        lblEditPostError.Text = "Post not found or could not be updated.";
                        lblEditPostError.Visible = true;
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[Forum] Error updating post: {ex.Message}");
                lblEditPostError.Text = $"Error updating post: {Server.HtmlEncode(ex.Message)}";
                lblEditPostError.Visible = true;
            }
        }

        protected void btnUpdateReply_Click(object sender, EventArgs e)
        {
            string adminSlug = Session["UserSlug"]?.ToString();
            string replySlug = hfEditReplySlug.Value;
            string content = txtEditReplyContent.Text.Trim();

            if (string.IsNullOrWhiteSpace(content))
            {
                lblEditReplyError.Text = "Content is required.";
                lblEditReplyError.Visible = true;
                return;
            }

            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = con.CreateCommand())
                {
                    con.Open();

                    // Get original reply content for logging
                    string originalContent = "";
                    cmd.CommandText = "SELECT content FROM ForumReplies WHERE reply_slug = @slug";
                    cmd.Parameters.AddWithValue("@slug", replySlug);
                    var contentResult = cmd.ExecuteScalar();
                    if (contentResult != null)
                    {
                        originalContent = contentResult.ToString();
                        if (originalContent.Length > 50) originalContent = originalContent.Substring(0, 50) + "...";
                    }

                    // Update the reply
                    cmd.Parameters.Clear();
                    cmd.CommandText = @"
                        UPDATE ForumReplies 
                        SET content = @content, 
                            updated_at = SYSUTCDATETIME()
                        WHERE reply_slug = @replySlug AND is_deleted = 0";
                    
                    cmd.Parameters.AddWithValue("@content", content);
                    cmd.Parameters.AddWithValue("@replySlug", replySlug);

                    int rowsAffected = cmd.ExecuteNonQuery();
                    if (rowsAffected > 0)
                    {
                        // Log admin action
                        AdminAuditLogger.LogAction(adminSlug, "edit_reply", "reply", replySlug, 
                            $"Edited reply: {originalContent}");

                        // Reload data
                        LoadReplies();

                        // Close modal via JavaScript
                        ClientScript.RegisterStartupScript(this.GetType(), "closeEditReplyModal",
                            "setTimeout(function() { var modal = bootstrap.Modal.getInstance(document.getElementById('editReplyModal')); if (modal) modal.hide(); }, 100);", true);
                    }
                    else
                    {
                        lblEditReplyError.Text = "Reply not found or could not be updated.";
                        lblEditReplyError.Visible = true;
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[Forum] Error updating reply: {ex.Message}");
                lblEditReplyError.Text = $"Error updating reply: {Server.HtmlEncode(ex.Message)}";
                lblEditReplyError.Visible = true;
            }
        }

        protected void rptReplies_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "DeleteReply")
            {
                string adminSlug = Session["UserSlug"]?.ToString();
                string replySlug = e.CommandArgument.ToString();

                try
                {
                    using (var con = new SqlConnection(ConnStr))
                    using (var cmd = con.CreateCommand())
                    {
                        con.Open();

                        // Get reply content for logging
                        string replyContent = "";
                        cmd.CommandText = "SELECT content FROM ForumReplies WHERE reply_slug = @slug";
                        cmd.Parameters.AddWithValue("@slug", replySlug);
                        var content = cmd.ExecuteScalar();
                        if (content != null)
                        {
                            replyContent = content.ToString();
                            if (replyContent.Length > 50) replyContent = replyContent.Substring(0, 50) + "...";
                        }

                        // Soft delete the reply
                        cmd.Parameters.Clear();
                        cmd.CommandText = @"
                            UPDATE ForumReplies 
                            SET is_deleted = 1, updated_at = SYSUTCDATETIME()
                            WHERE reply_slug = @replySlug";
                        cmd.Parameters.AddWithValue("@replySlug", replySlug);
                        cmd.ExecuteNonQuery();

                        // Log admin action
                        AdminAuditLogger.LogAction(adminSlug, "delete_reply", "reply", replySlug, 
                            $"Deleted reply: {replyContent}");

                        LoadReplies();
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"[Forum] Error deleting reply: {ex.Message}");
                    ClientScript.RegisterStartupScript(this.GetType(), "showError",
                        $"alert('Error deleting reply: {Server.HtmlEncode(ex.Message)}');", true);
                }
            }
        }
    }
}


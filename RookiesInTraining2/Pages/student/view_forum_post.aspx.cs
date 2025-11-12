using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Text;
using System.Text.RegularExpressions;
using System.Web.UI;
using System.Web.UI.WebControls;
using RookiesInTraining2.Helpers;

namespace RookiesInTraining2.Pages.student
{
    public partial class view_forum_post : System.Web.UI.Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
        private string CurrentUserSlug => Session["UserSlug"]?.ToString() ?? "";

        protected void Page_Load(object sender, EventArgs e)
        {
            // Check authentication
            if (Session["UserSlug"] == null)
            {
                Response.Redirect("~/Pages/Login.aspx", false);
                return;
            }

            // Check role - student only
            string role = Convert.ToString(Session["Role"])?.ToLowerInvariant();
            if (role != "student")
            {
                Response.Redirect("~/Pages/Login.aspx", false);
                return;
            }

            if (!IsPostBack)
            {
                string postSlug = Request.QueryString["post"];
                string classSlug = Request.QueryString["class"];
                
                System.Diagnostics.Debug.WriteLine($"[StudentViewPost] Page_Load: postSlug='{postSlug}', classSlug='{classSlug}'");
                
                if (string.IsNullOrWhiteSpace(postSlug) || string.IsNullOrWhiteSpace(classSlug))
                {
                    System.Diagnostics.Debug.WriteLine("[StudentViewPost] Page_Load: Missing postSlug or classSlug, redirecting to dashboard");
                    Response.Redirect("~/Pages/student/dashboard_student.aspx", false);
                    return;
                }

                // Verify student is enrolled in this class
                System.Diagnostics.Debug.WriteLine($"[StudentViewPost] Page_Load: Checking enrollment for studentSlug='{CurrentUserSlug}', classSlug='{classSlug}'");
                if (!IsStudentEnrolled(CurrentUserSlug, classSlug))
                {
                    System.Diagnostics.Debug.WriteLine("[StudentViewPost] Page_Load: Student not enrolled, redirecting to dashboard");
                    Response.Redirect("~/Pages/student/dashboard_student.aspx", false);
                    return;
                }
                
                System.Diagnostics.Debug.WriteLine("[StudentViewPost] Page_Load: Student enrolled, loading post");

                hfPostSlug.Value = postSlug;
                hfClassSlug.Value = classSlug;
                
                // Set back link
                lnkBack.NavigateUrl = $"~/Pages/student/student_class.aspx?class={classSlug}&tab=forum";

                // Load post and replies
                LoadPost(postSlug, classSlug);
                LoadReplies(postSlug);
                
                // Populate edit post modal fields if user owns the post
                if (pnlEditDeletePost.Visible)
                {
                    txtEditPostTitle.Text = lblPostTitle.Text;
                    txtEditPostContent.Text = lblContent.Text;
                }
            }
        }

        private bool IsStudentEnrolled(string studentSlug, string classSlug)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(studentSlug) || string.IsNullOrWhiteSpace(classSlug))
                {
                    System.Diagnostics.Debug.WriteLine($"[StudentViewPost] IsStudentEnrolled: Empty studentSlug or classSlug. studentSlug: '{studentSlug}', classSlug: '{classSlug}'");
                    return false;
                }

                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            SELECT COUNT(*) 
                            FROM Enrollments 
                            WHERE user_slug = @studentSlug 
                              AND class_slug = @classSlug 
                              AND is_deleted = 0";
                        cmd.Parameters.AddWithValue("@studentSlug", studentSlug);
                        cmd.Parameters.AddWithValue("@classSlug", classSlug);
                        int count = (int)cmd.ExecuteScalar();
                        System.Diagnostics.Debug.WriteLine($"[StudentViewPost] IsStudentEnrolled: studentSlug='{studentSlug}', classSlug='{classSlug}', count={count}");
                        return count > 0;
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[StudentViewPost] IsStudentEnrolled Error: {ex.Message}");
                return false;
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
                                fp.user_slug,
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
                                string postUserSlug = reader["user_slug"].ToString();
                                hfPostUserSlug.Value = postUserSlug;
                                
                                lblPostTitle.Text = reader["title"].ToString();
                                lblContent.Text = reader["content"].ToString();
                                lblAuthor.Text = reader["author_name"].ToString();
                                lblDate.Text = FormatDate(Convert.ToDateTime(reader["created_at"]));
                                
                                // Show edit/delete buttons only if student owns the post
                                pnlEditDeletePost.Visible = (postUserSlug == CurrentUserSlug);
                            }
                            else
                            {
                                Response.Redirect($"~/Pages/student/student_class.aspx?class={classSlug}&tab=forum", false);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[StudentViewPost] Error loading post: {ex.Message}");
                Response.Redirect($"~/Pages/student/student_class.aspx?class={classSlug}&tab=forum", false);
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
                                fr.user_slug,
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
                                    AuthorName = reader["author_name"].ToString(),
                                    UserSlug = reader["user_slug"].ToString()
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
                System.Diagnostics.Debug.WriteLine($"[StudentViewPost] Error loading replies: {ex.Message}");
                lblNoReplies.Visible = true;
            }
        }

        protected void rptReplies_ItemDataBound(object sender, System.Web.UI.WebControls.RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == System.Web.UI.WebControls.ListItemType.Item || 
                e.Item.ItemType == System.Web.UI.WebControls.ListItemType.AlternatingItem)
            {
                // Get the data item (it's a dynamic object)
                object dataItem = e.Item.DataItem;
                if (dataItem != null)
                {
                    // Use reflection to get UserSlug property
                    string replyUserSlug = "";
                    try
                    {
                        var userSlugProperty = dataItem.GetType().GetProperty("UserSlug");
                        if (userSlugProperty != null)
                        {
                            replyUserSlug = userSlugProperty.GetValue(dataItem)?.ToString() ?? "";
                        }
                    }
                    catch
                    {
                        // If reflection fails, try direct cast to dynamic
                        try
                        {
                            dynamic reply = dataItem;
                            replyUserSlug = reply.UserSlug?.ToString() ?? "";
                        }
                        catch { }
                    }
                    
                    Panel pnlReplyActions = (Panel)e.Item.FindControl("pnlReplyActions");
                    
                    if (pnlReplyActions != null)
                    {
                        // Only show edit/delete buttons if the current user owns this reply
                        pnlReplyActions.Visible = (replyUserSlug == CurrentUserSlug);
                    }
                }
            }
        }

        protected void btnDeletePost_Click(object sender, EventArgs e)
        {
            string studentSlug = CurrentUserSlug;
            string postSlug = hfPostSlug.Value;
            string classSlug = hfClassSlug.Value;

            // Verify student owns the post
            if (!VerifyPostOwnership(postSlug, studentSlug))
            {
                ClientScript.RegisterStartupScript(this.GetType(), "showError",
                    "alert('You do not have permission to delete this post.');", true);
                return;
            }

            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();
                    using (var tx = con.BeginTransaction())
                    {
                        try
                        {
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

                            // Redirect back to forum
                            Response.Redirect($"~/Pages/student/student_class.aspx?class={classSlug}&tab=forum", false);
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
                System.Diagnostics.Debug.WriteLine($"[StudentViewPost] Error deleting post: {ex.Message}");
                ClientScript.RegisterStartupScript(this.GetType(), "showError",
                    $"alert('Error deleting post: {Server.HtmlEncode(ex.Message)}');", true);
            }
        }

        protected void btnUpdatePost_Click(object sender, EventArgs e)
        {
            string studentSlug = CurrentUserSlug;
            string postSlug = hfPostSlug.Value;
            string classSlug = hfClassSlug.Value;
            string title = txtEditPostTitle.Text.Trim();
            string content = txtEditPostContent.Text.Trim();

            // Verify student owns the post
            if (!VerifyPostOwnership(postSlug, studentSlug))
            {
                lblEditPostError.Text = "You do not have permission to edit this post.";
                lblEditPostError.Visible = true;
                return;
            }

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

                    // Update the post (with ownership check in WHERE clause)
                    cmd.CommandText = @"
                        UPDATE ForumPosts 
                        SET title = @title, 
                            content = @content, 
                            updated_at = SYSUTCDATETIME()
                        WHERE post_slug = @postSlug 
                          AND user_slug = @userSlug 
                          AND is_deleted = 0";
                    
                    cmd.Parameters.AddWithValue("@title", title);
                    cmd.Parameters.AddWithValue("@content", content);
                    cmd.Parameters.AddWithValue("@postSlug", postSlug);
                    cmd.Parameters.AddWithValue("@userSlug", studentSlug);

                    int rowsAffected = cmd.ExecuteNonQuery();
                    if (rowsAffected > 0)
                    {
                        // Reload the page to show updated content
                        Response.Redirect($"~/Pages/student/view_forum_post.aspx?post={postSlug}&class={classSlug}", false);
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
                System.Diagnostics.Debug.WriteLine($"[StudentViewPost] Error updating post: {ex.Message}");
                lblEditPostError.Text = $"Error updating post: {Server.HtmlEncode(ex.Message)}";
                lblEditPostError.Visible = true;
            }
        }

        protected void btnUpdateReply_Click(object sender, EventArgs e)
        {
            string studentSlug = CurrentUserSlug;
            string replySlug = hfEditReplySlug.Value;
            string postSlug = hfPostSlug.Value;
            string classSlug = hfClassSlug.Value;
            string content = txtEditReplyContent.Text.Trim();

            // Verify student owns the reply
            if (!VerifyReplyOwnership(replySlug, studentSlug))
            {
                lblEditReplyError.Text = "You do not have permission to edit this reply.";
                lblEditReplyError.Visible = true;
                return;
            }

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

                    // Update the reply (with ownership check in WHERE clause)
                    cmd.CommandText = @"
                        UPDATE ForumReplies 
                        SET content = @content, 
                            updated_at = SYSUTCDATETIME()
                        WHERE reply_slug = @replySlug 
                          AND user_slug = @userSlug 
                          AND is_deleted = 0";
                    
                    cmd.Parameters.AddWithValue("@content", content);
                    cmd.Parameters.AddWithValue("@replySlug", replySlug);
                    cmd.Parameters.AddWithValue("@userSlug", studentSlug);

                    int rowsAffected = cmd.ExecuteNonQuery();
                    if (rowsAffected > 0)
                    {
                        // Reload the page to show updated content
                        Response.Redirect($"~/Pages/student/view_forum_post.aspx?post={postSlug}&class={classSlug}", false);
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
                System.Diagnostics.Debug.WriteLine($"[StudentViewPost] Error updating reply: {ex.Message}");
                lblEditReplyError.Text = $"Error updating reply: {Server.HtmlEncode(ex.Message)}";
                lblEditReplyError.Visible = true;
            }
        }

        protected void rptReplies_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "DeleteReply")
            {
                string studentSlug = CurrentUserSlug;
                string replySlug = e.CommandArgument.ToString();
                string postSlug = hfPostSlug.Value;
                string classSlug = hfClassSlug.Value;

                // Verify student owns the reply
                if (!VerifyReplyOwnership(replySlug, studentSlug))
                {
                    ClientScript.RegisterStartupScript(this.GetType(), "showError",
                        "alert('You do not have permission to delete this reply.');", true);
                    return;
                }

                try
                {
                    using (var con = new SqlConnection(ConnStr))
                    using (var cmd = con.CreateCommand())
                    {
                        con.Open();

                        // Soft delete the reply (with ownership check in WHERE clause)
                        cmd.CommandText = @"
                            UPDATE ForumReplies 
                            SET is_deleted = 1, updated_at = SYSUTCDATETIME()
                            WHERE reply_slug = @replySlug 
                              AND user_slug = @userSlug";
                        cmd.Parameters.AddWithValue("@replySlug", replySlug);
                        cmd.Parameters.AddWithValue("@userSlug", studentSlug);
                        cmd.ExecuteNonQuery();

                        // Reload the page
                        Response.Redirect($"~/Pages/student/view_forum_post.aspx?post={postSlug}&class={classSlug}", false);
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"[StudentViewPost] Error deleting reply: {ex.Message}");
                    ClientScript.RegisterStartupScript(this.GetType(), "showError",
                        $"alert('Error deleting reply: {Server.HtmlEncode(ex.Message)}');", true);
                }
            }
        }

        protected void btnPostReply_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string postSlug = hfPostSlug.Value;
            string classSlug = hfClassSlug.Value;
            string userSlug = CurrentUserSlug;
            string content = txtReply.Text.Trim();

            // Verify student is still enrolled
            if (!IsStudentEnrolled(userSlug, classSlug))
            {
                lblReplyError.Text = "You are not enrolled in this class.";
                lblReplyError.Visible = true;
                return;
            }

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

                    System.Diagnostics.Debug.WriteLine($"[StudentViewPost] Reply created: {replySlug}");

                    // Redirect to refresh the page (GET request, no POST resubmission)
                    Response.Redirect($"~/Pages/student/view_forum_post.aspx?post={postSlug}&class={classSlug}", false);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[StudentViewPost] Error: {ex}");
                lblReplyError.Text = $"Error posting reply: {Server.HtmlEncode(ex.Message)}";
                lblReplyError.Visible = true;
            }
        }

        private bool VerifyPostOwnership(string postSlug, string userSlug)
        {
            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            SELECT COUNT(*) 
                            FROM ForumPosts 
                            WHERE post_slug = @postSlug 
                              AND user_slug = @userSlug 
                              AND is_deleted = 0";
                        cmd.Parameters.AddWithValue("@postSlug", postSlug);
                        cmd.Parameters.AddWithValue("@userSlug", userSlug);
                        int count = (int)cmd.ExecuteScalar();
                        return count > 0;
                    }
                }
            }
            catch
            {
                return false;
            }
        }

        private bool VerifyReplyOwnership(string replySlug, string userSlug)
        {
            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            SELECT COUNT(*) 
                            FROM ForumReplies 
                            WHERE reply_slug = @replySlug 
                              AND user_slug = @userSlug 
                              AND is_deleted = 0";
                        cmd.Parameters.AddWithValue("@replySlug", replySlug);
                        cmd.Parameters.AddWithValue("@userSlug", userSlug);
                        int count = (int)cmd.ExecuteScalar();
                        return count > 0;
                    }
                }
            }
            catch
            {
                return false;
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


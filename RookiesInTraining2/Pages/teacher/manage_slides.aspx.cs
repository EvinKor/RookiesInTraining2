using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace RookiesInTraining2.Pages.teacher
{
    public partial class manage_slides : System.Web.UI.Page
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
                string levelSlug = Request.QueryString["level"];
                string classSlug = Request.QueryString["class"];
                string levelTitle = Request.QueryString["levelTitle"];
                
                if (string.IsNullOrWhiteSpace(levelSlug) || string.IsNullOrWhiteSpace(classSlug))
                {
                    Response.Redirect("~/Pages/teacher/manage_classes.aspx", false);
                    return;
                }

                hfLevelSlug.Value = levelSlug;
                hfClassSlug.Value = classSlug;
                lblLevelTitle.Text = levelTitle ?? "Level";
                
                // Set back link
                lnkBack.NavigateUrl = $"~/Pages/teacher/manage_classes.aspx?class={classSlug}&tab=storymode";

                // Load slides
                LoadSlides(levelSlug);
            }
        }

        private void LoadSlides(string levelSlug)
        {
            List<dynamic> slides = new List<dynamic>();

            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            SELECT slide_number, content_type, content_text, media_url
                            FROM LevelSlides
                            WHERE level_slug = @levelSlug AND is_deleted = 0
                            ORDER BY slide_number ASC";

                        cmd.Parameters.AddWithValue("@levelSlug", levelSlug);

                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                slides.Add(new
                                {
                                    SlideNumber = Convert.ToInt32(reader["slide_number"]),
                                    ContentType = reader["content_type"].ToString(),
                                    Content = reader["content_text"].ToString(),
                                    MediaUrl = reader["media_url"]?.ToString()
                                });
                            }
                        }
                    }
                }

                if (slides.Count > 0)
                {
                    rptSlides.DataSource = slides;
                    rptSlides.DataBind();
                    lblNoSlides.Visible = false;
                }
                else
                {
                    lblNoSlides.Visible = true;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[ManageSlides] Error loading slides: {ex.Message}");
                lblNoSlides.Visible = true;
            }
        }

        protected void btnSaveSlide_Click(object sender, EventArgs e)
        {
            string levelSlug = hfLevelSlug.Value;
            string classSlug = hfClassSlug.Value;
            
            lblSlideError.Visible = false;

            // Validate slide number from hidden field
            if (!int.TryParse(hfSlideNumber.Value, out int slideNumber) || slideNumber < 1)
            {
                lblSlideError.Text = "Invalid slide number.";
                lblSlideError.Visible = true;
                return;
            }

            string contentType = ddlContentType.SelectedValue;
            string content = txtContent.Text.Trim();
            string mediaUrl = txtMediaUrl.Text.Trim();
            
            if (!int.TryParse(hfEditingSlideNumber.Value, out int editingSlideNumber))
            {
                editingSlideNumber = 0;
            }

            if (string.IsNullOrWhiteSpace(content))
            {
                lblSlideError.Text = "Slide content is required.";
                lblSlideError.Visible = true;
                return;
            }

            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();

                    // Handle image upload if content type is 'image'
                    if (contentType == "image" && fileUploadImage.HasFile)
                    {
                        mediaUrl = HandleImageUpload(fileUploadImage, classSlug, levelSlug, slideNumber);
                    }
                    else if (contentType == "image" && !fileUploadImage.HasFile && editingSlideNumber == 0)
                    {
                        // New image slide requires upload
                        lblSlideError.Text = "Please upload an image for image slides.";
                        lblSlideError.Visible = true;
                        return;
                    }

                    if (editingSlideNumber > 0)
                    {
                        // Update existing slide
                        using (var cmd = con.CreateCommand())
                        {
                            cmd.CommandText = @"
                                UPDATE LevelSlides 
                                SET content_type = @contentType,
                                    content_text = @content,
                                    media_url = @mediaUrl
                                WHERE level_slug = @levelSlug 
                                  AND slide_number = @slideNumber
                                  AND is_deleted = 0";

                            cmd.Parameters.AddWithValue("@levelSlug", levelSlug);
                            cmd.Parameters.AddWithValue("@slideNumber", editingSlideNumber);
                            cmd.Parameters.AddWithValue("@contentType", contentType);
                            cmd.Parameters.AddWithValue("@content", content);
                            cmd.Parameters.AddWithValue("@mediaUrl", (object)mediaUrl ?? DBNull.Value);

                            cmd.ExecuteNonQuery();
                        }
                    }
                    else
                    {
                        // Insert new slide
                        // Generate unique slide_slug
                        string slideSlug = $"{levelSlug}-slide-{slideNumber}";
                        
                        using (var cmd = con.CreateCommand())
                        {
                            cmd.CommandText = @"
                                INSERT INTO LevelSlides 
                                (slide_slug, level_slug, slide_number, content_type, content_text, media_url, created_at, is_deleted)
                                VALUES 
                                (@slideSlug, @levelSlug, @slideNumber, @contentType, @content, @mediaUrl, SYSUTCDATETIME(), 0)";

                            cmd.Parameters.AddWithValue("@slideSlug", slideSlug);
                            cmd.Parameters.AddWithValue("@levelSlug", levelSlug);
                            cmd.Parameters.AddWithValue("@slideNumber", slideNumber);
                            cmd.Parameters.AddWithValue("@contentType", contentType);
                            cmd.Parameters.AddWithValue("@content", content);
                            cmd.Parameters.AddWithValue("@mediaUrl", (object)mediaUrl ?? DBNull.Value);

                            cmd.ExecuteNonQuery();
                        }
                    }

                    // Redirect to refresh
                    Response.Redirect($"~/Pages/teacher/manage_slides.aspx?level={levelSlug}&class={classSlug}&levelTitle={Request.QueryString["levelTitle"]}", false);
                }
            }
            catch (Exception ex)
            {
                lblSlideError.Text = $"Error saving slide: {Server.HtmlEncode(ex.Message)}";
                lblSlideError.Visible = true;
                System.Diagnostics.Debug.WriteLine($"[ManageSlides] Error: {ex}");
            }
        }

        protected void DeleteSlide_Command(object sender, CommandEventArgs e)
        {
            int slideNumber = int.Parse(e.CommandArgument.ToString());
            string levelSlug = hfLevelSlug.Value;
            string classSlug = hfClassSlug.Value;

            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            UPDATE LevelSlides 
                            SET is_deleted = 1
                            WHERE level_slug = @levelSlug AND slide_number = @slideNumber";

                        cmd.Parameters.AddWithValue("@levelSlug", levelSlug);
                        cmd.Parameters.AddWithValue("@slideNumber", slideNumber);

                        cmd.ExecuteNonQuery();
                    }
                }

                // Redirect to refresh
                Response.Redirect($"~/Pages/teacher/manage_slides.aspx?level={levelSlug}&class={classSlug}&levelTitle={Request.QueryString["levelTitle"]}", false);
            }
            catch (Exception ex)
            {
                ShowMessage("Error deleting slide: " + Server.HtmlEncode(ex.Message), "danger");
                System.Diagnostics.Debug.WriteLine($"[ManageSlides] Delete error: {ex}");
            }
        }

        protected string TruncateText(string text, int maxLength)
        {
            if (string.IsNullOrEmpty(text)) return "";
            if (text.Length <= maxLength) return text;
            return text.Substring(0, maxLength) + "...";
        }

        protected string GetBadgeColor(string contentType)
        {
            switch (contentType?.ToLower())
            {
                case "image": return "primary";
                case "video": return "danger";
                case "code": return "dark";
                case "text":
                default: return "secondary";
            }
        }

        protected string GetContentIcon(string contentType)
        {
            switch (contentType?.ToLower())
            {
                case "image": return "image";
                case "video": return "play-circle";
                case "code": return "code-slash";
                case "text":
                default: return "text-paragraph";
            }
        }

        private void ShowMessage(string message, string type)
        {
            lblMessage.Text = message;
            lblMessage.CssClass = $"alert alert-{type}";
            lblMessage.Visible = true;
        }

        private string HandleImageUpload(System.Web.UI.WebControls.FileUpload upload, string classSlug, string levelSlug, int slideNumber)
        {
            if (!upload.HasFile) return null;

            // Validate file type
            string extension = Path.GetExtension(upload.FileName).ToLowerInvariant();
            string[] allowedExtensions = { ".jpg", ".jpeg", ".png", ".gif", ".svg", ".webp" };
            
            if (Array.IndexOf(allowedExtensions, extension) == -1)
            {
                throw new Exception("Invalid image format. Allowed: JPG, PNG, GIF, SVG, WEBP");
            }

            // Validate file size (max 5MB)
            if (upload.PostedFile.ContentLength > 5 * 1024 * 1024)
            {
                throw new Exception("Image size must be less than 5MB");
            }

            // Create upload directory
            string uploadFolder = Server.MapPath($"~/Uploads/{classSlug}/{levelSlug}/slides/");
            if (!Directory.Exists(uploadFolder))
            {
                Directory.CreateDirectory(uploadFolder);
            }

            // Generate unique filename
            string fileName = $"slide-{slideNumber}-{DateTime.Now.Ticks}{extension}";
            string filePath = Path.Combine(uploadFolder, fileName);
            
            // Save file
            upload.SaveAs(filePath);

            // Return URL
            string imageUrl = $"/Uploads/{classSlug}/{levelSlug}/slides/{fileName}";
            System.Diagnostics.Debug.WriteLine($"[ManageSlides] Image uploaded: {imageUrl}");
            
            return imageUrl;
        }
    }
}


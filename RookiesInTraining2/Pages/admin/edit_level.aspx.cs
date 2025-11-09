using System;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using System.Web.UI;

namespace RookiesInTraining2.Pages.admin
{
    public partial class edit_level : System.Web.UI.Page
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

            // Check role - admin only
            string role = Convert.ToString(Session["Role"])?.ToLowerInvariant();
            if (role != "admin")
            {
                Response.Redirect("~/Pages/Login.aspx", false);
                return;
            }

            if (!IsPostBack)
            {
                string levelSlug = Request.QueryString["level"];
                string classSlug = Request.QueryString["class"];
                
                if (string.IsNullOrWhiteSpace(levelSlug) || string.IsNullOrWhiteSpace(classSlug))
                {
                    Response.Redirect("~/Pages/admin/manage_classes.aspx", false);
                    return;
                }

                hfLevelSlug.Value = levelSlug;
                hfClassSlug.Value = classSlug;
                
                // Set back link to storymode tab
                lnkBack.NavigateUrl = $"~/Pages/admin/manage_classes.aspx?class={classSlug}&tab=storymode";
                lnkCancel.NavigateUrl = $"~/Pages/admin/manage_classes.aspx?class={classSlug}&tab=storymode";

                // Load level data
                LoadLevel(levelSlug);
            }
        }

        private void LoadLevel(string levelSlug)
        {
            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            SELECT level_number, title, description, estimated_minutes, 
                                   xp_reward, is_published, content_url
                            FROM Levels
                            WHERE level_slug = @levelSlug AND is_deleted = 0";

                        cmd.Parameters.AddWithValue("@levelSlug", levelSlug);

                        using (var reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                lblLevelNumber.Text = reader["level_number"].ToString();
                                txtLevelTitle.Text = reader["title"].ToString();
                                txtDescription.Text = reader["description"]?.ToString() ?? "";
                                txtMinutes.Text = reader["estimated_minutes"]?.ToString() ?? "15";
                                txtXP.Text = reader["xp_reward"]?.ToString() ?? "50";
                                chkPublished.Checked = Convert.ToBoolean(reader["is_published"]);
                                
                                string contentUrl = reader["content_url"]?.ToString();
                                lblCurrentFile.Text = !string.IsNullOrEmpty(contentUrl) ? contentUrl : "None";
                            }
                            else
                            {
                                Response.Redirect($"~/Pages/admin/manage_classes.aspx?class={hfClassSlug.Value}", false);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[EditLevel] Error loading level: {ex.Message}");
                lblError.Text = "Error loading level data.";
                lblError.Visible = true;
            }
        }

        protected void btnSaveLevel_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string levelSlug = hfLevelSlug.Value;
            string classSlug = hfClassSlug.Value;
            
            string title = txtLevelTitle.Text.Trim();
            string description = txtDescription.Text.Trim();
            int minutes = int.Parse(txtMinutes.Text);
            int xp = int.Parse(txtXP.Text);
            bool published = chkPublished.Checked;

            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();

                    // Handle file upload if present
                    string contentType = null;
                    string contentUrl = null;

                    if (fileUpload.HasFile)
                    {
                        var result = HandleFileUpload(fileUpload, classSlug, levelSlug);
                        contentType = result.Item1;
                        contentUrl = result.Item2;
                    }

                    // Update level
                    using (var cmd = con.CreateCommand())
                    {
                        string sql = @"
                            UPDATE Levels 
                            SET title = @title,
                                description = @description,
                                estimated_minutes = @minutes,
                                xp_reward = @xp,
                                is_published = @published,
                                updated_at = SYSUTCDATETIME()";
                        
                        if (contentType != null)
                        {
                            sql += ", content_type = @contentType, content_url = @contentUrl";
                        }
                        
                        sql += " WHERE level_slug = @levelSlug AND is_deleted = 0";
                        
                        cmd.CommandText = sql;

                        cmd.Parameters.AddWithValue("@levelSlug", levelSlug);
                        cmd.Parameters.AddWithValue("@title", title);
                        cmd.Parameters.AddWithValue("@description", (object)description ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@minutes", minutes);
                        cmd.Parameters.AddWithValue("@xp", xp);
                        cmd.Parameters.AddWithValue("@published", published ? 1 : 0);
                        
                        if (contentType != null)
                        {
                            cmd.Parameters.AddWithValue("@contentType", contentType);
                            cmd.Parameters.AddWithValue("@contentUrl", contentUrl);
                        }

                        cmd.ExecuteNonQuery();
                    }

                    System.Diagnostics.Debug.WriteLine($"[EditLevel] Level updated: {levelSlug}");

                    // Redirect back to manage classes (storymode tab)
                    Response.Redirect($"~/Pages/admin/manage_classes.aspx?class={classSlug}&tab=storymode", false);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[EditLevel] Error: {ex}");
                lblError.Text = $"Error updating level: {Server.HtmlEncode(ex.Message)}";
                lblError.Visible = true;
            }
        }

        private Tuple<string, string> HandleFileUpload(System.Web.UI.WebControls.FileUpload upload, string classSlug, string levelSlug)
        {
            if (!upload.HasFile) return Tuple.Create<string, string>(null, null);

            string extension = Path.GetExtension(upload.FileName).ToLowerInvariant();
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
                default:
                    throw new Exception("Unsupported file type. Please upload PowerPoint or PDF.");
            }

            string uploadFolder = Server.MapPath($"~/Uploads/{classSlug}/{levelSlug}/");
            if (!Directory.Exists(uploadFolder))
            {
                Directory.CreateDirectory(uploadFolder);
            }

            // Create short, safe filename to avoid path length issues
            string safeFileName = $"material-{DateTime.Now.Ticks}{extension}";
            string filePath = Path.Combine(uploadFolder, safeFileName);
            
            // Validate path length (Windows limit is 260 chars)
            if (filePath.Length > 250)
            {
                throw new Exception("File path too long. Please use shorter class/level names.");
            }
            
            upload.SaveAs(filePath);

            string contentUrl = $"/Uploads/{classSlug}/{levelSlug}/{safeFileName}";
            return Tuple.Create(contentType, contentUrl);
        }
    }
}


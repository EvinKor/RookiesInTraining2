using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace RookiesInTraining2.Pages.student
{
    public partial class join_class : System.Web.UI.Page
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
            if (role != "student")
            {
                Response.Redirect("~/Pages/Login.aspx", false);
                return;
            }
        }

        protected void btnJoinClass_Click(object sender, EventArgs e)
        {
            string classCode = txtClassCode.Text.Trim().ToUpperInvariant();
            string studentSlug = Session["UserSlug"]?.ToString() ?? "";

            lblMessage.Visible = false;

            if (string.IsNullOrWhiteSpace(classCode) || classCode.Length != 6)
            {
                ShowMessage("Please enter a valid 6-digit class code.", "danger");
                return;
            }

            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();

                    // Find class by code
                    string classSlug = null;
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            SELECT class_slug, class_name 
                            FROM Classes 
                            WHERE class_code = @classCode AND is_deleted = 0";
                        cmd.Parameters.AddWithValue("@classCode", classCode);

                        using (var reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                classSlug = reader["class_slug"].ToString();
                            }
                        }
                    }

                    if (string.IsNullOrEmpty(classSlug))
                    {
                        ShowMessage("Invalid class code. Please check and try again.", "danger");
                        return;
                    }

                    // Check if already enrolled
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
                        if (count > 0)
                        {
                            ShowMessage("You are already enrolled in this class!", "warning");
                            return;
                        }
                    }

                    // Enroll student
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            INSERT INTO Enrollments 
                            (user_slug, class_slug, role_in_class, enrolled_at, is_deleted)
                            VALUES 
                            (@studentSlug, @classSlug, 'student', SYSUTCDATETIME(), 0)";
                        cmd.Parameters.AddWithValue("@studentSlug", studentSlug);
                        cmd.Parameters.AddWithValue("@classSlug", classSlug);

                        cmd.ExecuteNonQuery();
                    }

                    System.Diagnostics.Debug.WriteLine($"[JoinClass] Student {studentSlug} enrolled in {classSlug}");

                    // Redirect to student class view
                    Response.Redirect($"~/Pages/student/student_class.aspx?class={classSlug}", false);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[JoinClass] Error: {ex.Message}");
                ShowMessage($"Error joining class: {Server.HtmlEncode(ex.Message)}", "danger");
            }
        }

        private void ShowMessage(string message, string type)
        {
            lblMessage.Text = message;
            lblMessage.CssClass = $"alert alert-{type}";
            lblMessage.Visible = true;
        }
    }
}


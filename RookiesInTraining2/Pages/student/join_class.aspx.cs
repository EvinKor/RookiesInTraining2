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

            System.Diagnostics.Debug.WriteLine("[JoinClass] ===== JOIN CLASS BUTTON CLICKED =====");
            System.Diagnostics.Debug.WriteLine($"[JoinClass] Class Code entered: '{classCode}'");
            System.Diagnostics.Debug.WriteLine($"[JoinClass] Class Code length: {classCode.Length}");
            System.Diagnostics.Debug.WriteLine($"[JoinClass] Student Slug: '{studentSlug}'");

            lblMessage.Visible = false;

            if (string.IsNullOrWhiteSpace(classCode) || classCode.Length != 6)
            {
                System.Diagnostics.Debug.WriteLine($"[JoinClass] ❌ Invalid code format. Length: {classCode.Length}");
                ShowMessage("Please enter a valid 6-digit class code.", "danger");
                return;
            }

            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();
                    System.Diagnostics.Debug.WriteLine("[JoinClass] Database connection opened");

                    // Find class by code
                    string classSlug = null;
                    string className = null;
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            SELECT class_slug, class_name 
                            FROM Classes 
                            WHERE class_code = @classCode AND is_deleted = 0";
                        cmd.Parameters.AddWithValue("@classCode", classCode);

                        System.Diagnostics.Debug.WriteLine($"[JoinClass] Searching for class with code: '{classCode}'");

                        using (var reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                classSlug = reader["class_slug"].ToString();
                                className = reader["class_name"].ToString();
                                System.Diagnostics.Debug.WriteLine($"[JoinClass] ✅ Class found! Slug: '{classSlug}', Name: '{className}'");
                            }
                            else
                            {
                                System.Diagnostics.Debug.WriteLine($"[JoinClass] ❌ No class found with code: '{classCode}'");
                            }
                        }
                    }

                    if (string.IsNullOrEmpty(classSlug))
                    {
                        System.Diagnostics.Debug.WriteLine($"[JoinClass] Invalid class code, showing error to user");
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

                        System.Diagnostics.Debug.WriteLine($"[JoinClass] Checking if already enrolled...");
                        int count = (int)cmd.ExecuteScalar();
                        System.Diagnostics.Debug.WriteLine($"[JoinClass] Enrollment count: {count}");
                        
                        if (count > 0)
                        {
                            System.Diagnostics.Debug.WriteLine($"[JoinClass] ⚠️ Student already enrolled");
                            ShowMessage("You are already enrolled in this class!", "warning");
                            return;
                        }
                    }

                    // Enroll student
                    using (var cmd = con.CreateCommand())
                    {
                        // Generate enrollment slug (format: enroll-{32-char-guid})
                        string enrollmentSlug = $"enroll-{Guid.NewGuid():N}";
                        
                        cmd.CommandText = @"
                            INSERT INTO Enrollments 
                            (enrollment_slug, user_slug, class_slug, role_in_class, joined_at, is_deleted)
                            VALUES 
                            (@enrollmentSlug, @studentSlug, @classSlug, 'student', SYSUTCDATETIME(), 0)";
                        cmd.Parameters.AddWithValue("@enrollmentSlug", enrollmentSlug);
                        cmd.Parameters.AddWithValue("@studentSlug", studentSlug);
                        cmd.Parameters.AddWithValue("@classSlug", classSlug);

                        System.Diagnostics.Debug.WriteLine($"[JoinClass] Inserting enrollment record with slug: {enrollmentSlug}");
                        int rowsAffected = cmd.ExecuteNonQuery();
                        System.Diagnostics.Debug.WriteLine($"[JoinClass] INSERT completed. Rows affected: {rowsAffected}");
                    }

                    System.Diagnostics.Debug.WriteLine($"[JoinClass] ✅ SUCCESS! Student {studentSlug} enrolled in class {classSlug} ({className})");

                    // Redirect to student class view
                    System.Diagnostics.Debug.WriteLine($"[JoinClass] Redirecting to student_class.aspx?class={classSlug}");
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


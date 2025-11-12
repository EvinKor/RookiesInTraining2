using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Text.RegularExpressions;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace RookiesInTraining2.Pages.admin
{
    public partial class edit_class : System.Web.UI.Page
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
                string classSlug = Request.QueryString["class"];
                if (string.IsNullOrWhiteSpace(classSlug))
                {
                    Response.Redirect("~/Pages/admin/Classes.aspx", false);
                    return;
                }

                hfClassSlug.Value = classSlug;
                
                // Set back link
                lnkBack.NavigateUrl = "~/Pages/admin/Classes.aspx";
                lnkCancel.NavigateUrl = "~/Pages/admin/Classes.aspx";

                // Load teachers
                LoadTeachers();

                // Load class data
                LoadClassData(classSlug);
            }
        }

        private void LoadClassData(string classSlug)
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
                                class_name,
                                class_code,
                                description,
                                teacher_slug,
                                icon,
                                color
                            FROM Classes
                            WHERE class_slug = @classSlug AND is_deleted = 0";

                        cmd.Parameters.AddWithValue("@classSlug", classSlug);

                        using (var reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                txtClassName.Text = reader["class_name"].ToString();
                                txtClassCode.Text = reader["class_code"].ToString();
                                txtDescription.Text = reader["description"]?.ToString() ?? "";

                                // Set teacher dropdown
                                string teacherSlug = reader["teacher_slug"]?.ToString() ?? "";
                                if (ddlTeacher.Items.FindByValue(teacherSlug) != null)
                                {
                                    ddlTeacher.SelectedValue = teacherSlug;
                                }

                                // Set icon
                                string icon = reader["icon"]?.ToString() ?? "book";
                                hfIcon.Value = icon;

                                // Set color
                                string color = reader["color"]?.ToString() ?? "#667eea";
                                hfColor.Value = color;
                            }
                            else
                            {
                                // Class not found
                                lblError.Text = "Class not found or has been deleted.";
                                lblError.Visible = true;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[EditClass] Error loading class data: {ex.Message}");
                lblError.Text = $"Error loading class: {ex.Message}";
                lblError.Visible = true;
            }
        }



        private void LoadTeachers()
        {
            try
            {
                ddlTeacher.Items.Clear();
                ddlTeacher.Items.Add(new ListItem("-- Select a Teacher --", ""));

                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            SELECT 
                                user_slug,
                                ISNULL(display_name, full_name) AS display_name,
                                email
                            FROM Users
                            WHERE role = 'teacher' 
                              AND is_deleted = 0
                              AND ISNULL(is_blocked, 0) = 0
                            ORDER BY display_name, full_name";

                        using (var reader = cmd.ExecuteReader())
                        {
                            int teacherCount = 0;
                            while (reader.Read())
                            {
                                string userSlug = reader["user_slug"].ToString();
                                string displayName = reader["display_name"].ToString();
                                string email = reader["email"].ToString();
                                
                                ddlTeacher.Items.Add(new ListItem(
                                    $"{displayName} ({email})", 
                                    userSlug));
                                teacherCount++;
                            }

                            if (teacherCount == 0)
                            {
                                ddlTeacher.Items.Add(new ListItem("No teachers available", ""));
                                ddlTeacher.Enabled = false;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[LoadTeachers] Error: {ex.Message}");
                ddlTeacher.Items.Clear();
                ddlTeacher.Items.Add(new ListItem("-- Error loading teachers --", ""));
                ddlTeacher.Enabled = false;
            }
        }

        protected void btnUpdateClass_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string classSlug = hfClassSlug.Value;
            string adminSlug = Session["UserSlug"]?.ToString() ?? "";
            
            string className = txtClassName.Text.Trim();
            string description = txtDescription.Text.Trim();
            string teacherSlug = ddlTeacher.SelectedValue;
            string classCode = txtClassCode.Text.Trim();
            string icon = hfIcon.Value;
            string color = hfColor.Value;

            // Validation
            if (string.IsNullOrWhiteSpace(className) || className.Length < 3)
            {
                lblError.Text = "Class name must be at least 3 characters.";
                lblError.Visible = true;
                return;
            }

            if (string.IsNullOrWhiteSpace(teacherSlug))
            {
                lblError.Text = "Please select a teacher for this class.";
                lblError.Visible = true;
                return;
            }

            if (string.IsNullOrWhiteSpace(classCode))
            {
                lblError.Text = "Class code is required.";
                lblError.Visible = true;
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
                            // Check if class code is unique (if changed)
                            string currentClassCode = "";
                            using (var getCodeCmd = con.CreateCommand())
                            {
                                getCodeCmd.Transaction = tx;
                                getCodeCmd.CommandText = "SELECT class_code FROM Classes WHERE class_slug = @classSlug";
                                getCodeCmd.Parameters.AddWithValue("@classSlug", classSlug);
                                object result = getCodeCmd.ExecuteScalar();
                                if (result != null)
                                {
                                    currentClassCode = result.ToString();
                                }
                            }

                            // If class code changed, check uniqueness
                            if (classCode != currentClassCode)
                            {
                                using (var checkCodeCmd = con.CreateCommand())
                                {
                                    checkCodeCmd.Transaction = tx;
                                    checkCodeCmd.CommandText = @"
                                        SELECT COUNT(*) FROM Classes 
                                        WHERE class_code = @classCode 
                                          AND class_slug != @classSlug 
                                          AND is_deleted = 0";
                                    checkCodeCmd.Parameters.AddWithValue("@classCode", classCode);
                                    checkCodeCmd.Parameters.AddWithValue("@classSlug", classSlug);
                                    int count = (int)checkCodeCmd.ExecuteScalar();
                                    
                                    if (count > 0)
                                    {
                                        lblError.Text = "Class code already exists. Please use a different code.";
                                        lblError.Visible = true;
                                        tx.Rollback();
                                        return;
                                    }
                                }
                            }

                            // Get old teacher slug to update enrollments if teacher changed
                            string oldTeacherSlug = "";
                            using (var getOldTeacherCmd = con.CreateCommand())
                            {
                                getOldTeacherCmd.Transaction = tx;
                                getOldTeacherCmd.CommandText = "SELECT teacher_slug FROM Classes WHERE class_slug = @classSlug";
                                getOldTeacherCmd.Parameters.AddWithValue("@classSlug", classSlug);
                                object result = getOldTeacherCmd.ExecuteScalar();
                                if (result != null)
                                {
                                    oldTeacherSlug = result.ToString();
                                }
                            }

                            // Update class
                            using (var cmd = con.CreateCommand())
                            {
                                cmd.Transaction = tx;
                                cmd.CommandText = @"
                                    UPDATE Classes 
                                    SET class_name = @className,
                                        description = @description,
                                        teacher_slug = @teacherSlug,
                                        class_code = @classCode,
                                        icon = @icon,
                                        color = @color,
                                        updated_at = SYSUTCDATETIME()
                                    WHERE class_slug = @classSlug AND is_deleted = 0";

                                cmd.Parameters.AddWithValue("@classSlug", classSlug);
                                cmd.Parameters.AddWithValue("@className", className);
                                cmd.Parameters.AddWithValue("@description", (object)description ?? DBNull.Value);
                                cmd.Parameters.AddWithValue("@teacherSlug", teacherSlug);
                                cmd.Parameters.AddWithValue("@classCode", classCode);
                                cmd.Parameters.AddWithValue("@icon", icon ?? "book");
                                cmd.Parameters.AddWithValue("@color", color ?? "#667eea");

                                int rowsAffected = cmd.ExecuteNonQuery();
                                
                                if (rowsAffected == 0)
                                {
                                    lblError.Text = "Class not found or could not be updated.";
                                    lblError.Visible = true;
                                    tx.Rollback();
                                    return;
                                }
                            }

                            // If teacher changed, update enrollments
                            if (oldTeacherSlug != teacherSlug && !string.IsNullOrEmpty(oldTeacherSlug))
                            {
                                // Remove old teacher enrollment
                                using (var cmd = con.CreateCommand())
                                {
                                    cmd.Transaction = tx;
                                    cmd.CommandText = @"
                                        UPDATE Enrollments 
                                        SET is_deleted = 1
                                        WHERE class_slug = @classSlug 
                                          AND user_slug = @oldTeacherSlug 
                                          AND role_in_class = 'teacher'";
                                    cmd.Parameters.AddWithValue("@classSlug", classSlug);
                                    cmd.Parameters.AddWithValue("@oldTeacherSlug", oldTeacherSlug);
                                    cmd.ExecuteNonQuery();
                                }

                                // Add new teacher enrollment (if not already exists)
                                using (var checkEnrollCmd = con.CreateCommand())
                                {
                                    checkEnrollCmd.Transaction = tx;
                                    checkEnrollCmd.CommandText = @"
                                        SELECT COUNT(*) FROM Enrollments 
                                        WHERE class_slug = @classSlug 
                                          AND user_slug = @teacherSlug 
                                          AND role_in_class = 'teacher' 
                                          AND is_deleted = 0";
                                    checkEnrollCmd.Parameters.AddWithValue("@classSlug", classSlug);
                                    checkEnrollCmd.Parameters.AddWithValue("@teacherSlug", teacherSlug);
                                    int enrollCount = (int)checkEnrollCmd.ExecuteScalar();

                                    if (enrollCount == 0)
                                    {
                                        using (var enrollCmd = con.CreateCommand())
                                        {
                                            enrollCmd.Transaction = tx;
                                            string enrollSlug = "enroll-" + Guid.NewGuid().ToString("N").Substring(0, 12);
                                            enrollCmd.CommandText = @"
                                                INSERT INTO Enrollments
                                                (enrollment_slug, class_slug, user_slug, role_in_class, joined_at, is_deleted)
                                                VALUES
                                                (@enrollSlug, @classSlug, @teacherSlug, 'teacher', SYSUTCDATETIME(), 0)";
                                            enrollCmd.Parameters.AddWithValue("@enrollSlug", enrollSlug);
                                            enrollCmd.Parameters.AddWithValue("@classSlug", classSlug);
                                            enrollCmd.Parameters.AddWithValue("@teacherSlug", teacherSlug);
                                            enrollCmd.ExecuteNonQuery();
                                        }
                                    }
                                }
                            }

                            tx.Commit();

                            // Log admin action
                            Helpers.AdminAuditLogger.LogAction(adminSlug, "edit_class", "class", classSlug,
                                $"Updated class: {className}");

                            // Redirect back to classes page
                            Response.Redirect("~/Pages/admin/Classes.aspx", false);
                        }
                        catch (Exception ex)
                        {
                            tx.Rollback();
                            System.Diagnostics.Debug.WriteLine($"[EditClass] Error: {ex.Message}");
                            lblError.Text = $"Error updating class: {ex.Message}";
                            lblError.Visible = true;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[EditClass] Error: {ex.Message}");
                lblError.Text = $"Error updating class: {ex.Message}";
                lblError.Visible = true;
            }
        }
    }
}


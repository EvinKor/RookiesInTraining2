using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace RookiesInTraining2.Pages.admin
{
    public partial class add_students : System.Web.UI.Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            System.Diagnostics.Debug.WriteLine($"[AddStudents][Page_Load] IsPostBack: {IsPostBack}");
            
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

            string classSlug = Request.QueryString["class"];
            System.Diagnostics.Debug.WriteLine($"[AddStudents][Page_Load] Class slug from query string: '{classSlug}'");
            
            if (!IsPostBack)
            {
                if (string.IsNullOrWhiteSpace(classSlug))
                {
                    Response.Redirect("~/Pages/admin/manage_classes.aspx", false);
                    return;
                }

                ViewState["ClassSlug"] = classSlug;
                
                // Set back link to students tab
                lnkBack.NavigateUrl = $"~/Pages/admin/manage_classes.aspx?class={classSlug}&tab=students";

                // Load class info
                LoadClassInfo(classSlug);
                
                // Load students
                LoadAvailableStudents(classSlug, "");
                LoadEnrolledStudents(classSlug);
            }
            else
            {
                // On postback, restore classSlug from ViewState or QueryString
                if (ViewState["ClassSlug"] == null && !string.IsNullOrWhiteSpace(classSlug))
                {
                    ViewState["ClassSlug"] = classSlug;
                }
                System.Diagnostics.Debug.WriteLine($"[AddStudents] Postback - ClassSlug from ViewState: {ViewState["ClassSlug"]}");
            }
        }

        private void LoadClassInfo(string classSlug)
        {
            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            SELECT class_name, class_code
                            FROM Classes
                            WHERE class_slug = @classSlug AND is_deleted = 0";
                        cmd.Parameters.AddWithValue("@classSlug", classSlug);

                        using (var reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                lblClassName.Text = reader["class_name"].ToString();
                                lblClassCode.Text = reader["class_code"].ToString();
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[AddStudents] Error loading class info: {ex.Message}");
            }
        }

        private void LoadAvailableStudents(string classSlug, string searchTerm)
        {
            List<dynamic> students = new List<dynamic>();

            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();
                    using (var cmd = con.CreateCommand())
                    {
                        string sql = @"
                            SELECT u.user_slug, u.full_name, u.email
                            FROM Users u
                            WHERE u.role = 'student' 
                              AND u.is_deleted = 0
                              AND u.user_slug NOT IN (
                                  SELECT user_slug 
                                  FROM Enrollments 
                                  WHERE class_slug = @classSlug AND is_deleted = 0
                              )";
                        
                        if (!string.IsNullOrWhiteSpace(searchTerm))
                        {
                            sql += " AND (u.full_name LIKE @search OR u.email LIKE @search)";
                        }
                        
                        sql += " ORDER BY u.full_name ASC";
                        
                        cmd.CommandText = sql;
                        cmd.Parameters.AddWithValue("@classSlug", classSlug);
                        
                        if (!string.IsNullOrWhiteSpace(searchTerm))
                        {
                            cmd.Parameters.AddWithValue("@search", "%" + searchTerm + "%");
                        }

                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                students.Add(new
                                {
                                    UserSlug = reader["user_slug"].ToString(),
                                    FullName = reader["full_name"].ToString(),
                                    Email = reader["email"].ToString()
                                });
                            }
                        }
                    }
                }

                lblAvailableCount.Text = students.Count.ToString();

                if (students.Count > 0)
                {
                    rptAvailableStudents.DataSource = students;
                    rptAvailableStudents.DataBind();
                    lblNoAvailable.Visible = false;
                }
                else
                {
                    lblNoAvailable.Visible = true;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[AddStudents] Error loading available students: {ex.Message}");
                lblNoAvailable.Visible = true;
            }
        }

        private void LoadEnrolledStudents(string classSlug)
        {
            List<dynamic> students = new List<dynamic>();

            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            SELECT u.user_slug, u.full_name, u.email, e.joined_at
                            FROM Enrollments e
                            INNER JOIN Users u ON e.user_slug = u.user_slug
                            WHERE e.class_slug = @classSlug 
                              AND e.role_in_class = 'student'
                              AND e.is_deleted = 0
                            ORDER BY e.joined_at DESC";

                        cmd.Parameters.AddWithValue("@classSlug", classSlug);

                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                students.Add(new
                                {
                                    UserSlug = reader["user_slug"].ToString(),
                                    FullName = reader["full_name"].ToString(),
                                    Email = reader["email"].ToString(),
                                    EnrolledAt = Convert.ToDateTime(reader["joined_at"])
                                });
                            }
                        }
                    }
                }

                lblEnrolledCount.Text = students.Count.ToString();

                if (students.Count > 0)
                {
                    rptEnrolledStudents.DataSource = students;
                    rptEnrolledStudents.DataBind();
                    lblNoEnrolled.Visible = false;
                }
                else
                {
                    lblNoEnrolled.Visible = true;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[AddStudents] Error loading enrolled students: {ex.Message}");
                lblNoEnrolled.Visible = true;
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            string classSlug = ViewState["ClassSlug"]?.ToString() ?? "";
            string searchTerm = txtSearch.Text.Trim();
            
            LoadAvailableStudents(classSlug, searchTerm);
        }

        protected void rptAvailableStudents_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            System.Diagnostics.Debug.WriteLine("[AddStudents] ===== rptAvailableStudents_ItemCommand TRIGGERED =====");
            System.Diagnostics.Debug.WriteLine($"[AddStudents] CommandName: {e.CommandName}");
            System.Diagnostics.Debug.WriteLine($"[AddStudents] CommandArgument: {e.CommandArgument}");
            
            if (e.CommandName == "Add")
            {
                string studentSlug = e.CommandArgument?.ToString() ?? "";
                string classSlug = ViewState["ClassSlug"]?.ToString() ?? "";
                
                System.Diagnostics.Debug.WriteLine($"[AddStudents] Student Slug: '{studentSlug}'");
                System.Diagnostics.Debug.WriteLine($"[AddStudents] Class Slug: '{classSlug}'");
                
                if (string.IsNullOrWhiteSpace(studentSlug) || string.IsNullOrWhiteSpace(classSlug))
                {
                    System.Diagnostics.Debug.WriteLine("[AddStudents] ERROR: Student slug or class slug is empty!");
                    return;
                }

                try
                {
                    using (var con = new SqlConnection(ConnStr))
                    {
                        con.Open();
                        
                        // First check if already enrolled
                        using (var checkCmd = con.CreateCommand())
                        {
                            checkCmd.CommandText = @"
                                SELECT COUNT(*) 
                                FROM Enrollments 
                                WHERE user_slug = @studentSlug 
                                  AND class_slug = @classSlug 
                                  AND is_deleted = 0";
                            checkCmd.Parameters.AddWithValue("@studentSlug", studentSlug);
                            checkCmd.Parameters.AddWithValue("@classSlug", classSlug);
                            
                            int existingCount = Convert.ToInt32(checkCmd.ExecuteScalar());
                            if (existingCount > 0)
                            {
                                System.Diagnostics.Debug.WriteLine("[AddStudents] Student is already enrolled!");
                                return;
                            }
                        }
                        
                        // Insert new enrollment
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

                            System.Diagnostics.Debug.WriteLine($"[AddStudents] Inserting with enrollment slug: {enrollmentSlug}");
                            int rowsAffected = cmd.ExecuteNonQuery();
                            System.Diagnostics.Debug.WriteLine($"[AddStudents] INSERT completed. Rows affected: {rowsAffected}");
                        }
                    }

                    System.Diagnostics.Debug.WriteLine($"[AddStudents] ✅ SUCCESS! Student {studentSlug} added to class {classSlug}");

                    // Reload both lists
                    LoadAvailableStudents(classSlug, txtSearch.Text.Trim());
                    LoadEnrolledStudents(classSlug);
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"[AddStudents] ❌ ERROR adding student: {ex.Message}");
                    System.Diagnostics.Debug.WriteLine($"[AddStudents] Stack trace: {ex.StackTrace}");
                    if (ex.InnerException != null)
                    {
                        System.Diagnostics.Debug.WriteLine($"[AddStudents] Inner exception: {ex.InnerException.Message}");
                    }
                }
            }
            else
            {
                System.Diagnostics.Debug.WriteLine($"[AddStudents] Command name '{e.CommandName}' does not match 'Add'");
            }
        }

        protected void rptEnrolledStudents_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            System.Diagnostics.Debug.WriteLine("[AddStudents] rptEnrolledStudents_ItemCommand triggered!");
            
            if (e.CommandName == "Remove")
            {
                string studentSlug = e.CommandArgument.ToString();
                string classSlug = ViewState["ClassSlug"]?.ToString() ?? "";
                
                System.Diagnostics.Debug.WriteLine($"[AddStudents] Attempting to remove student {studentSlug} from class {classSlug}");

                try
                {
                    using (var con = new SqlConnection(ConnStr))
                    {
                        con.Open();
                        using (var cmd = con.CreateCommand())
                        {
                            cmd.CommandText = @"
                                UPDATE Enrollments 
                                SET is_deleted = 1
                                WHERE user_slug = @studentSlug 
                                  AND class_slug = @classSlug";

                            cmd.Parameters.AddWithValue("@studentSlug", studentSlug);
                            cmd.Parameters.AddWithValue("@classSlug", classSlug);

                            cmd.ExecuteNonQuery();
                        }
                    }

                    System.Diagnostics.Debug.WriteLine($"[AddStudents] Student {studentSlug} removed from class {classSlug}");

                    // Reload both lists
                    LoadAvailableStudents(classSlug, txtSearch.Text.Trim());
                    LoadEnrolledStudents(classSlug);
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"[AddStudents] Error removing student: {ex.Message}");
                }
            }
        }
    }
}


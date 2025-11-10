using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace RookiesInTraining2.Pages.teacher
{
    public partial class students : System.Web.UI.Page
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
                LoadClassFilter();
                LoadStudents();
            }
        }

        private void LoadClassFilter()
        {
            try
            {
                string teacherSlug = Session["UserSlug"]?.ToString();
                if (string.IsNullOrEmpty(teacherSlug))
                {
                    return;
                }

                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            SELECT DISTINCT c.class_slug, c.class_name
                            FROM Classes c
                            WHERE c.teacher_slug = @teacherSlug 
                              AND c.is_deleted = 0
                            ORDER BY c.class_name";

                        cmd.Parameters.AddWithValue("@teacherSlug", teacherSlug);

                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                string classSlug = reader["class_slug"].ToString();
                                string className = reader["class_name"].ToString();
                                
                                ddlClassFilter.Items.Add(new System.Web.UI.WebControls.ListItem(className, classSlug));
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[Students] Error loading class filter: {ex.Message}");
            }
        }

        private void LoadStudents()
        {
            try
            {
                string teacherSlug = Session["UserSlug"]?.ToString();
                if (string.IsNullOrEmpty(teacherSlug))
                {
                    return;
                }

                string searchTerm = txtSearch.Text.Trim();
                string classFilter = ddlClassFilter.SelectedValue;

                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();
                    using (var cmd = con.CreateCommand())
                    {
                        var query = new System.Text.StringBuilder(@"
                            SELECT 
                                u.user_slug,
                                u.full_name,
                                ISNULL(u.display_name, u.full_name) AS display_name,
                                u.email,
                                COUNT(DISTINCT e.class_slug) AS class_count,
                                MIN(e.joined_at) AS first_joined
                            FROM Enrollments e
                            INNER JOIN Users u ON e.user_slug = u.user_slug
                            INNER JOIN Classes c ON e.class_slug = c.class_slug
                            WHERE c.teacher_slug = @teacherSlug
                              AND e.role_in_class = 'student'
                              AND e.is_deleted = 0
                              AND c.is_deleted = 0
                              AND u.is_deleted = 0");

                        // Add class filter
                        if (!string.IsNullOrEmpty(classFilter))
                        {
                            query.Append(" AND e.class_slug = @classSlug");
                            cmd.Parameters.AddWithValue("@classSlug", classFilter);
                        }

                        // Add search filter
                        if (!string.IsNullOrEmpty(searchTerm))
                        {
                            query.Append(" AND (LOWER(u.full_name) LIKE @search OR LOWER(u.email) LIKE @search OR LOWER(ISNULL(u.display_name, '')) LIKE @search)");
                            cmd.Parameters.AddWithValue("@search", "%" + searchTerm.ToLower() + "%");
                        }

                        query.Append(@"
                            GROUP BY u.user_slug, u.full_name, u.display_name, u.email
                            ORDER BY MIN(e.joined_at) DESC");

                        cmd.CommandText = query.ToString();
                        cmd.Parameters.AddWithValue("@teacherSlug", teacherSlug);

                        var students = new List<dynamic>();

                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                DateTime firstJoined = Convert.ToDateTime(reader["first_joined"]);
                                students.Add(new
                                {
                                    UserSlug = reader["user_slug"].ToString(),
                                    FullName = reader["full_name"].ToString(),
                                    DisplayName = reader["display_name"].ToString(),
                                    Email = reader["email"].ToString(),
                                    ClassCount = Convert.ToInt32(reader["class_count"]),
                                    FirstJoined = firstJoined.ToString("MMM dd, yyyy")
                                });
                            }
                        }

                        rptStudents.DataSource = students;
                        rptStudents.DataBind();

                        lblStudentCount.Text = $"{students.Count} student{(students.Count != 1 ? "s" : "")}";
                        lblNoStudents.Visible = students.Count == 0;
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[Students] Error loading students: {ex.Message}");
                lblError.Text = "Error loading students: " + ex.Message;
                lblError.Visible = true;
            }
        }

        protected void txtSearch_TextChanged(object sender, EventArgs e)
        {
            LoadStudents();
        }

        protected void ddlClassFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadStudents();
        }
    }
}


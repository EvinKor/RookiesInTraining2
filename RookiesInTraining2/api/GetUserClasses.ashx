<%@ WebHandler Language="C#" Class="GetUserClasses" %>

using System;
using System.Web;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Web.Script.Serialization;

public class GetUserClasses : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json";
        
        try
        {
            string userSlug = context.Request.QueryString["userSlug"];
            
            if (string.IsNullOrEmpty(userSlug))
            {
                context.Response.Write("[]");
                return;
            }

            var classes = new List<object>();
            var connStringConfig = System.Configuration.ConfigurationManager.ConnectionStrings["ConnectionString"];
            if (connStringConfig == null)
            {
                throw new Exception("Connection string 'ConnectionString' not found in web.config");
            }
            string connectionString = connStringConfig.ConnectionString;

            using (var con = new SqlConnection(connectionString))
            {
                con.Open();

                // Check if user is admin
                bool isAdmin = false;
                using (var roleCmd = new SqlCommand("SELECT role_global FROM dbo.Users WHERE user_slug = @userSlug AND is_deleted = 0", con))
                {
                    roleCmd.Parameters.AddWithValue("@userSlug", userSlug);
                    object roleResult = roleCmd.ExecuteScalar();
                    if (roleResult != null && roleResult.ToString().ToLowerInvariant() == "admin")
                    {
                        isAdmin = true;
                    }
                }

                string query;
                if (isAdmin)
                {
                    // Admin can see all classes
                    query = @"
                        SELECT DISTINCT c.class_slug, c.class_name, c.description
                        FROM Classes c
                        WHERE c.is_deleted = 0
                        ORDER BY c.class_name";
                }
                else
                {
                    // Regular users see only classes they teach or are enrolled in
                    query = @"
                        SELECT DISTINCT c.class_slug, c.class_name, c.description
                        FROM Classes c
                        LEFT JOIN Enrollments e ON c.class_slug = e.class_slug
                        WHERE c.is_deleted = 0 
                          AND (c.teacher_slug = @userSlug OR e.user_slug = @userSlug)
                        ORDER BY c.class_name";
                }

                using (var cmd = new SqlCommand(query, con))
                {
                    if (!isAdmin)
                    {
                        cmd.Parameters.AddWithValue("@userSlug", userSlug);
                    }

                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            classes.Add(new
                            {
                                class_slug = reader["class_slug"].ToString(),
                                class_name = reader["class_name"].ToString(),
                                description = reader["description"].ToString()
                            });
                        }
                    }
                }
            }

            var serializer = new JavaScriptSerializer();
            context.Response.Write(serializer.Serialize(classes));
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("[GetUserClasses] Error: " + ex.Message);
            context.Response.Write("[]");
        }
    }

    public bool IsReusable
    {
        get { return false; }
    }
}


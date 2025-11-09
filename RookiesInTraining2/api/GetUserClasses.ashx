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
            string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["RookiesConnectionString"].ConnectionString;

            using (var con = new SqlConnection(connectionString))
            {
                con.Open();

                // Get classes based on user role
                string query = @"
                    SELECT DISTINCT c.class_slug, c.class_name, c.description
                    FROM Classes c
                    LEFT JOIN Enrollments e ON c.class_slug = e.class_slug
                    WHERE c.is_deleted = 0 
                      AND (c.teacher_slug = @userSlug OR e.user_slug = @userSlug)
                    ORDER BY c.class_name";

                using (var cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@userSlug", userSlug);

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


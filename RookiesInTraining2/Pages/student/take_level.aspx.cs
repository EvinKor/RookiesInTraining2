using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.Script.Serialization;
using System.Web.UI;

namespace RookiesInTraining2.Pages.student
{
    public partial class take_level : System.Web.UI.Page
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

            if (!IsPostBack)
            {
                string levelSlug = Request.QueryString["level"];
                string classSlug = Request.QueryString["class"];
                
                if (string.IsNullOrWhiteSpace(levelSlug) || string.IsNullOrWhiteSpace(classSlug))
                {
                    Response.Redirect("~/Pages/student/dashboard_student.aspx", false);
                    return;
                }

                hfLevelSlug.Value = levelSlug;
                hfClassSlug.Value = classSlug;
                
                lnkBack.NavigateUrl = $"~/Pages/student/student_class.aspx?class={classSlug}";

                // Load level data
                LoadLevel(levelSlug, classSlug);
            }
        }

        private void LoadLevel(string levelSlug, string classSlug)
        {
            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();

                    // Load level info
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            SELECT 
                                l.title, 
                                l.description, 
                                l.quiz_slug,
                                q.title AS quiz_title,
                                q.time_limit_minutes,
                                q.passing_score
                            FROM Levels l
                            LEFT JOIN Quizzes q ON l.quiz_slug = q.quiz_slug
                            WHERE l.level_slug = @levelSlug 
                              AND l.class_slug = @classSlug 
                              AND l.is_deleted = 0";

                        cmd.Parameters.AddWithValue("@levelSlug", levelSlug);
                        cmd.Parameters.AddWithValue("@classSlug", classSlug);

                        using (var reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                lblLevelTitle.Text = reader["title"].ToString();
                                lblDescription.Text = reader["description"].ToString();
                                
                                string quizSlug = reader["quiz_slug"]?.ToString();
                                if (!string.IsNullOrEmpty(quizSlug))
                                {
                                    lblQuizTitle.Text = reader["quiz_title"].ToString();
                                    lblTimeLimit.Text = reader["time_limit_minutes"].ToString();
                                    lblPassingScore.Text = reader["passing_score"].ToString();
                                    lnkTakeQuiz.NavigateUrl = $"~/Pages/student/take_quiz.aspx?quiz={quizSlug}&level={levelSlug}&class={classSlug}";
                                }
                            }
                        }
                    }

                    // Load slides
                    List<dynamic> slides = new List<dynamic>();
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

                    var serializer = new JavaScriptSerializer();
                    hfSlidesJson.Value = serializer.Serialize(slides);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[TakeLevel] Error: {ex.Message}");
            }
        }
    }
}


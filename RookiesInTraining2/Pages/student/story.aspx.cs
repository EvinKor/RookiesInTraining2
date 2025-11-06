using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.HtmlControls;

namespace RookiesInTraining2.Pages
{
    public partial class story : System.Web.UI.Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Guard: Check authentication
            if (Session["UserSlug"] == null)
            {
                Response.Redirect("~/Pages/Login.aspx", false);
                return;
            }

            // Guard: Check role
            string role = Session["Role"]?.ToString()?.ToLowerInvariant() ?? "";
            if (role != "student")
            {
                Response.Redirect("~/Pages/Login.aspx", false);
                return;
            }

            if (!IsPostBack)
            {
                LoadStages();
            }
        }

        private void LoadStages()
        {
            string userSlug = Session["UserSlug"]?.ToString() ?? "";

            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();

                    // Get all published levels ordered by level_number
                    var stages = new List<StageInfo>();
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            SELECT 
                                l.level_slug, l.class_slug, l.level_number, l.title, 
                                l.description, l.xp_reward, l.estimated_minutes,
                                c.class_name
                            FROM Levels l
                            INNER JOIN Classes c ON l.class_slug = c.class_slug
                            WHERE l.is_published = 1 AND l.is_deleted = 0
                            ORDER BY l.level_number";

                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                stages.Add(new StageInfo
                                {
                                    LevelSlug = reader["level_slug"].ToString(),
                                    ClassSlug = reader["class_slug"].ToString(),
                                    ClassName = reader["class_name"].ToString(),
                                    LevelNumber = Convert.ToInt32(reader["level_number"]),
                                    Title = reader["title"].ToString(),
                                    Description = reader["description"]?.ToString() ?? "",
                                    XpReward = Convert.ToInt32(reader["xp_reward"]),
                                    EstimatedMinutes = Convert.ToInt32(reader["estimated_minutes"])
                                });
                            }
                        }
                    }

                    // Check progress for each stage
                    foreach (var stage in stages)
                    {
                        // Check if previous stage is completed (if not first stage)
                        if (stage.LevelNumber > 1)
                        {
                            var previousStage = stages.Find(s => s.LevelNumber == stage.LevelNumber - 1);
                            if (previousStage != null)
                            {
                                stage.IsLocked = !IsStageCompleted(userSlug, previousStage.LevelSlug, con);
                            }
                        }

                        // Check if current stage is completed
                        stage.IsCompleted = IsStageCompleted(userSlug, stage.LevelSlug, con);
                    }

                    // Serialize to JSON
                    var serializer = new JavaScriptSerializer();
                    hfStagesJson.Value = serializer.Serialize(stages);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[Story] Error: {ex}");
            }
        }

        private bool IsStageCompleted(string userSlug, string levelSlug, SqlConnection con)
        {
            using (var cmd = con.CreateCommand())
            {
                cmd.CommandText = @"
                    SELECT TOP 1 1
                    FROM StudentLevelProgress
                    WHERE student_slug = @userSlug 
                    AND level_slug = @levelSlug 
                    AND status = 'completed'";

                cmd.Parameters.AddWithValue("@userSlug", userSlug);
                cmd.Parameters.AddWithValue("@levelSlug", levelSlug);

                return cmd.ExecuteScalar() != null;
            }
        }

        public class StageInfo
        {
            public string LevelSlug { get; set; }
            public string ClassSlug { get; set; }
            public string ClassName { get; set; }
            public int LevelNumber { get; set; }
            public string Title { get; set; }
            public string Description { get; set; }
            public int XpReward { get; set; }
            public int EstimatedMinutes { get; set; }
            public bool IsLocked { get; set; }
            public bool IsCompleted { get; set; }
        }
    }
}


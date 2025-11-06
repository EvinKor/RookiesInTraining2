using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;

namespace RookiesInTraining2.Pages
{
    public partial class dashboard_student : System.Web.UI.Page
    {
        // Set to true if you want admins to also view this page
        private const bool ALLOW_ADMIN_VIEW = true;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Guard: Check if user is logged in
            if (Session["UserSlug"] == null)
            {
                Response.Redirect("~/Pages/Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            // Guard: Check role
            string role = Convert.ToString(Session["Role"])?.ToLowerInvariant() ?? "";
            if (role != "student" && !(ALLOW_ADMIN_VIEW && role == "admin"))
            {
                Response.Redirect("~/Pages/Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (!IsPostBack)
            {
                LoadStudentData();
            }
        }

        private void LoadStudentData()
        {
            string userSlug = Session["UserSlug"]?.ToString() ?? "";
            string fullName = Session["FullName"]?.ToString() ?? "Student";

            // Load real data using ProgressService
            var progressService = new Services.ProgressService();
            var progress = progressService.GetProgress(userSlug);

            // Load modules and quizzes from database
            var modules = LoadModules(userSlug);
            var quizzes = LoadQuizzes(userSlug);
            
            // Convert badges to dashboard format
            var badges = progress.Badges.Select(b => new Badge
            {
                Id = b.BadgeSlug,
                Name = b.Name,
                Icon = b.Icon,
                Description = b.Description
            }).ToList();

            // Create summary
            var summary = new ProgressSummary
            {
                StudentName = fullName,
                Xp = progress.TotalXP,
                Level = progress.Level,
                Streak = 0, // TODO: Implement streak tracking
                Completed = progress.CompletedQuizzes,
                Total = progress.TotalQuizzes
            };

            // Serialize to JSON
            var serializer = new JavaScriptSerializer();
            hfModulesJson.Value = serializer.Serialize(modules);
            hfQuizzesJson.Value = serializer.Serialize(quizzes);
            hfSummaryJson.Value = serializer.Serialize(summary);
            hfBadgesJson.Value = serializer.Serialize(badges);
        }

        private List<Module> LoadModules(string userSlug)
        {
            var modules = new List<Module>();
            var connStr = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

            try
            {
                using (var con = new SqlConnection(connStr))
                {
                    con.Open();
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            SELECT m.module_slug, m.title, m.summary, m.icon, m.color, m.order_no, m.total_xp,
                                   (SELECT COUNT(*) FROM ModuleQuizzes mq WHERE mq.module_slug = m.module_slug AND mq.is_deleted = 0) AS total_quizzes,
                                   (SELECT COUNT(DISTINCT up.quiz_slug) 
                                    FROM ModuleQuizzes mq
                                    INNER JOIN UserProgress up ON mq.quiz_slug = up.quiz_slug
                                    WHERE mq.module_slug = m.module_slug 
                                    AND up.user_slug = @userSlug 
                                    AND up.status = 'completed') AS completed_quizzes
                            FROM Modules m
                            WHERE m.is_active = 1 AND m.is_deleted = 0
                            ORDER BY m.order_no";

                        cmd.Parameters.AddWithValue("@userSlug", userSlug);

                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                modules.Add(new Module
                                {
                                    ModuleSlug = reader["module_slug"].ToString(),
                                    Title = reader["title"].ToString(),
                                    Summary = reader["summary"]?.ToString() ?? "",
                                    Icon = reader["icon"]?.ToString() ?? "bi-book",
                                    Color = reader["color"]?.ToString() ?? "#667eea",
                                    OrderNo = Convert.ToInt32(reader["order_no"]),
                                    TotalXp = Convert.ToInt32(reader["total_xp"] ?? 0),
                                    Total = Convert.ToInt32(reader["total_quizzes"]),
                                    Completed = Convert.ToInt32(reader["completed_quizzes"])
                                });
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[Dashboard] Error loading modules: {ex}");
            }

            return modules;
        }

        private List<Quiz> LoadQuizzes(string userSlug)
        {
            var quizzes = new List<Quiz>();
            var connStr = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

            try
            {
                using (var con = new SqlConnection(connStr))
                {
                    con.Open();
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            SELECT mq.module_quiz_slug, mq.module_slug, mq.quiz_slug, mq.title, 
                                   mq.minutes, mq.xp_reward, mq.order_no,
                                   ISNULL(up.status, 'available') AS status,
                                   ISNULL(up.progress_pct, 0) AS progress_pct
                            FROM ModuleQuizzes mq
                            LEFT JOIN UserProgress up ON mq.quiz_slug = up.quiz_slug AND up.user_slug = @userSlug
                            WHERE mq.is_deleted = 0
                            ORDER BY mq.module_slug, mq.order_no";

                        cmd.Parameters.AddWithValue("@userSlug", userSlug);

                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                var status = reader["status"].ToString();
                                quizzes.Add(new Quiz
                                {
                                    ModuleQuizSlug = reader["module_quiz_slug"].ToString(),
                                    ModuleSlug = reader["module_slug"].ToString(),
                                    QuizSlug = reader["quiz_slug"].ToString(),
                                    Title = reader["title"].ToString(),
                                    Minutes = Convert.ToInt32(reader["minutes"]),
                                    XpReward = Convert.ToInt32(reader["xp_reward"]),
                                    OrderNo = Convert.ToInt32(reader["order_no"]),
                                    Status = status == "completed" ? "completed" : 
                                             status == "in_progress" ? "in_progress" : "available",
                                    ProgressPct = Convert.ToInt32(reader["progress_pct"])
                                });
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[Dashboard] Error loading quizzes: {ex}");
            }

            return quizzes;
        }

        #region Mock Data

        private List<Module> GetMockModules()
        {
            return new List<Module>
            {
                new Module
                {
                    ModuleSlug = "intro-programming",
                    Title = "Introduction to Programming",
                    Summary = "Learn the basics of programming and problem-solving",
                    Icon = "bi-code-square",
                    Color = "#6c5ce7",
                    OrderNo = 1,
                    TotalXp = 300,
                    Completed = 3,
                    Total = 5
                },
                new Module
                {
                    ModuleSlug = "data-structures",
                    Title = "Data Structures",
                    Summary = "Master arrays, lists, and collections",
                    Icon = "bi-diagram-3",
                    Color = "#00b894",
                    OrderNo = 2,
                    TotalXp = 450,
                    Completed = 2,
                    Total = 6
                },
                new Module
                {
                    ModuleSlug = "algorithms",
                    Title = "Algorithms",
                    Summary = "Sorting, searching, and optimization",
                    Icon = "bi-lightning",
                    Color = "#fdcb6e",
                    OrderNo = 3,
                    TotalXp = 500,
                    Completed = 0,
                    Total = 7
                },
                new Module
                {
                    ModuleSlug = "web-development",
                    Title = "Web Development",
                    Summary = "Build modern web applications",
                    Icon = "bi-globe",
                    Color = "#0984e3",
                    OrderNo = 4,
                    TotalXp = 600,
                    Completed = 0,
                    Total = 8
                },
                new Module
                {
                    ModuleSlug = "databases",
                    Title = "Database Fundamentals",
                    Summary = "SQL, queries, and database design",
                    Icon = "bi-server",
                    Color = "#d63031",
                    OrderNo = 5,
                    TotalXp = 400,
                    Completed = 0,
                    Total = 5
                },
                new Module
                {
                    ModuleSlug = "oop",
                    Title = "Object-Oriented Programming",
                    Summary = "Classes, objects, and inheritance",
                    Icon = "bi-boxes",
                    Color = "#e17055",
                    OrderNo = 6,
                    TotalXp = 550,
                    Completed = 0,
                    Total = 7
                }
            };
        }

        private List<Quiz> GetMockQuizzes()
        {
            return new List<Quiz>
            {
                // Module 1 Quizzes
                new Quiz { ModuleQuizSlug = "mq-intro-1", ModuleSlug = "intro-programming", QuizSlug = "what-is-programming", Title = "What is Programming?", Minutes = 5, XpReward = 50, OrderNo = 1, Status = "completed", ProgressPct = 100 },
                new Quiz { ModuleQuizSlug = "mq-intro-2", ModuleSlug = "intro-programming", QuizSlug = "variables-basics", Title = "Variables Basics", Minutes = 7, XpReward = 60, OrderNo = 2, Status = "completed", ProgressPct = 100 },
                new Quiz { ModuleQuizSlug = "mq-intro-3", ModuleSlug = "intro-programming", QuizSlug = "data-types", Title = "Data Types", Minutes = 8, XpReward = 70, OrderNo = 3, Status = "completed", ProgressPct = 100 },
                new Quiz { ModuleQuizSlug = "mq-intro-4", ModuleSlug = "intro-programming", QuizSlug = "operators", Title = "Operators", Minutes = 6, XpReward = 60, OrderNo = 4, Status = "in_progress", ProgressPct = 45 },
                new Quiz { ModuleQuizSlug = "mq-intro-5", ModuleSlug = "intro-programming", QuizSlug = "control-flow", Title = "Control Flow", Minutes = 10, XpReward = 80, OrderNo = 5, Status = "locked", ProgressPct = 0 },
                
                // Module 2 Quizzes
                new Quiz { ModuleQuizSlug = "mq-ds-1", ModuleSlug = "data-structures", QuizSlug = "arrays-intro", Title = "Introduction to Arrays", Minutes = 8, XpReward = 70, OrderNo = 1, Status = "completed", ProgressPct = 100 },
                new Quiz { ModuleQuizSlug = "mq-ds-2", ModuleSlug = "data-structures", QuizSlug = "array-operations", Title = "Array Operations", Minutes = 10, XpReward = 80, OrderNo = 2, Status = "completed", ProgressPct = 100 },
                new Quiz { ModuleQuizSlug = "mq-ds-3", ModuleSlug = "data-structures", QuizSlug = "lists", Title = "Working with Lists", Minutes = 9, XpReward = 75, OrderNo = 3, Status = "available", ProgressPct = 0 },
                new Quiz { ModuleQuizSlug = "mq-ds-4", ModuleSlug = "data-structures", QuizSlug = "dictionaries", Title = "Dictionaries & Maps", Minutes = 12, XpReward = 90, OrderNo = 4, Status = "locked", ProgressPct = 0 },
                new Quiz { ModuleQuizSlug = "mq-ds-5", ModuleSlug = "data-structures", QuizSlug = "stacks-queues", Title = "Stacks and Queues", Minutes = 11, XpReward = 85, OrderNo = 5, Status = "locked", ProgressPct = 0 },
                new Quiz { ModuleQuizSlug = "mq-ds-6", ModuleSlug = "data-structures", QuizSlug = "sets", Title = "Sets", Minutes = 8, XpReward = 70, OrderNo = 6, Status = "locked", ProgressPct = 0 },
                
                // Module 3 Quizzes (all locked - previous module not complete)
                new Quiz { ModuleQuizSlug = "mq-algo-1", ModuleSlug = "algorithms", QuizSlug = "sorting-basics", Title = "Sorting Basics", Minutes = 10, XpReward = 80, OrderNo = 1, Status = "locked", ProgressPct = 0 },
                new Quiz { ModuleQuizSlug = "mq-algo-2", ModuleSlug = "algorithms", QuizSlug = "bubble-sort", Title = "Bubble Sort", Minutes = 8, XpReward = 70, OrderNo = 2, Status = "locked", ProgressPct = 0 },
                new Quiz { ModuleQuizSlug = "mq-algo-3", ModuleSlug = "algorithms", QuizSlug = "merge-sort", Title = "Merge Sort", Minutes = 12, XpReward = 90, OrderNo = 3, Status = "locked", ProgressPct = 0 },
                new Quiz { ModuleQuizSlug = "mq-algo-4", ModuleSlug = "algorithms", QuizSlug = "quick-sort", Title = "Quick Sort", Minutes = 12, XpReward = 90, OrderNo = 4, Status = "locked", ProgressPct = 0 },
                new Quiz { ModuleQuizSlug = "mq-algo-5", ModuleSlug = "algorithms", QuizSlug = "search-algorithms", Title = "Search Algorithms", Minutes = 10, XpReward = 80, OrderNo = 5, Status = "locked", ProgressPct = 0 },
                new Quiz { ModuleQuizSlug = "mq-algo-6", ModuleSlug = "algorithms", QuizSlug = "binary-search", Title = "Binary Search", Minutes = 9, XpReward = 75, OrderNo = 6, Status = "locked", ProgressPct = 0 },
                new Quiz { ModuleQuizSlug = "mq-algo-7", ModuleSlug = "algorithms", QuizSlug = "complexity", Title = "Algorithm Complexity", Minutes = 11, XpReward = 85, OrderNo = 7, Status = "locked", ProgressPct = 0 }
            };
        }

        private List<Badge> GetMockBadges()
        {
            return new List<Badge>
            {
                new Badge { Id = "first-quiz", Name = "First Steps", Icon = "bi-star-fill", Description = "Completed your first quiz" },
                new Badge { Id = "module-complete", Name = "Module Master", Icon = "bi-trophy-fill", Description = "Completed an entire module" },
                new Badge { Id = "streak-7", Name = "Week Warrior", Icon = "bi-fire", Description = "7 day learning streak" }
            };
        }

        private ProgressSummary GetMockSummary(string studentName, List<Quiz> quizzes)
        {
            int completed = quizzes.Count(q => q.Status == "completed");
            int total = quizzes.Count;
            int xp = quizzes.Where(q => q.Status == "completed").Sum(q => q.XpReward);

            return new ProgressSummary
            {
                StudentName = studentName,
                Xp = xp,
                Streak = 5,
                Completed = completed,
                Total = total
            };
        }

        #endregion

        #region Data Classes

        public class Module
        {
            public string ModuleSlug { get; set; }
            public string Title { get; set; }
            public string Summary { get; set; }
            public string Icon { get; set; }
            public string Color { get; set; }
            public int OrderNo { get; set; }
            public int TotalXp { get; set; }
            public int Completed { get; set; }
            public int Total { get; set; }
        }

        public class Quiz
        {
            public string ModuleQuizSlug { get; set; }
            public string ModuleSlug { get; set; }
            public string QuizSlug { get; set; }
            public string Title { get; set; }
            public int Minutes { get; set; }
            public int XpReward { get; set; }
            public int OrderNo { get; set; }
            public string Status { get; set; } // locked, available, in_progress, completed
            public int ProgressPct { get; set; } // 0-100
        }

        public class Badge
        {
            public string Id { get; set; }
            public string Name { get; set; }
            public string Icon { get; set; }
            public string Description { get; set; }
        }

        public class ProgressSummary
        {
            public string StudentName { get; set; }
            public int Xp { get; set; }
            public int Streak { get; set; }
            public int Completed { get; set; }
            public int Total { get; set; }
        }

        #endregion

        /// <summary>
        /// Logout button click - Clear session and redirect to login
        /// </summary>
        protected void btnLogout_Click(object sender, EventArgs e)
        {
            // Clear all session data
            Session.Clear();
            Session.Abandon();
            
            // Redirect to login page
            Response.Redirect("~/Pages/Login.aspx", false);
        }
    }
}

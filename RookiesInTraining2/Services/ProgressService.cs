using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;

namespace RookiesInTraining2.Services
{
    /// <summary>
    /// Service for managing XP, levels, badges, and progress tracking
    /// </summary>
    public class ProgressService
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

        // XP thresholds for levels (Level 1: 0-100, Level 2: 101-250, etc.)
        private readonly int[] LevelThresholds = { 0, 100, 250, 500, 1000, 2000, 3500, 5000, 7000, 10000 };

        /// <summary>
        /// Calculate and award XP for completing a quiz
        /// </summary>
        public int AwardXP(string userSlug, string quizSlug, int score, int baseXpReward)
        {
            // Calculate XP based on score (e.g., 100% = full XP, 50% = half XP)
            int xpEarned = (int)Math.Round(baseXpReward * (score / 100.0));

            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();

                    // Update or create UserProgress
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            IF EXISTS (SELECT 1 FROM UserProgress WHERE user_slug = @userSlug AND quiz_slug = @quizSlug)
                            BEGIN
                                UPDATE UserProgress
                                SET score = @score, attempts = attempts + 1, 
                                    last_attempt_at = SYSUTCDATETIME(),
                                    updated_at = SYSUTCDATETIME(),
                                    status = CASE WHEN @score >= 70 THEN 'completed' ELSE status END,
                                    completed_at = CASE WHEN @score >= 70 AND completed_at IS NULL THEN SYSUTCDATETIME() ELSE completed_at END
                                WHERE user_slug = @userSlug AND quiz_slug = @quizSlug
                            END
                            ELSE
                            BEGIN
                                INSERT INTO UserProgress (progress_slug, user_slug, quiz_slug, status, score, attempts, last_attempt_at, created_at, updated_at)
                                VALUES (NEWID(), @userSlug, @quizSlug, 
                                        CASE WHEN @score >= 70 THEN 'completed' ELSE 'in_progress' END,
                                        @score, 1, SYSUTCDATETIME(), SYSUTCDATETIME(), SYSUTCDATETIME())
                            END";

                        cmd.Parameters.AddWithValue("@userSlug", userSlug);
                        cmd.Parameters.AddWithValue("@quizSlug", quizSlug);
                        cmd.Parameters.AddWithValue("@score", score);
                        cmd.ExecuteNonQuery();
                    }

                    // TODO: Store XP in a dedicated table (XPEvents) for better tracking
                    // For now, we'll calculate total XP from completed quizzes
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[ProgressService] Error awarding XP: {ex}");
            }

            return xpEarned;
        }

        /// <summary>
        /// Get total XP for a user
        /// </summary>
        public int GetTotalXP(string userSlug)
        {
            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();

                    using (var cmd = con.CreateCommand())
                    {
                        // Calculate XP from completed quizzes and levels
                        cmd.CommandText = @"
                            SELECT 
                                ISNULL(SUM(q.xp_reward), 0) AS quiz_xp
                            FROM UserProgress up
                            INNER JOIN Quizzes q ON up.quiz_slug = q.quiz_slug
                            WHERE up.user_slug = @userSlug 
                            AND up.status = 'completed'
                            AND up.score >= 70

                            UNION ALL

                            SELECT 
                                ISNULL(SUM(l.xp_reward), 0) AS level_xp
                            FROM StudentLevelProgress slp
                            INNER JOIN Levels l ON slp.level_slug = l.level_slug
                            WHERE slp.student_slug = @userSlug
                            AND slp.status = 'completed'";

                        cmd.Parameters.AddWithValue("@userSlug", userSlug);

                        int totalXP = 0;
                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                totalXP += Convert.ToInt32(reader[0]);
                            }
                        }

                        return totalXP;
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[ProgressService] Error getting XP: {ex}");
                return 0;
            }
        }

        /// <summary>
        /// Calculate level from total XP
        /// </summary>
        public int GetLevel(int totalXP)
        {
            for (int i = LevelThresholds.Length - 1; i >= 0; i--)
            {
                if (totalXP >= LevelThresholds[i])
                {
                    return i + 1;
                }
            }
            return 1;
        }

        /// <summary>
        /// Get progress summary for a user
        /// </summary>
        public ProgressSummary GetProgress(string userSlug)
        {
            int totalXP = GetTotalXP(userSlug);
            int level = GetLevel(totalXP);

            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();

                    // Get completed quizzes count
                    int completedQuizzes = 0;
                    int totalQuizzes = 0;
                    using (var cmd = con.CreateCommand())
                    {
                        cmd.CommandText = @"
                            SELECT 
                                COUNT(DISTINCT up.quiz_slug) AS completed,
                                (SELECT COUNT(DISTINCT quiz_slug) FROM Quizzes WHERE is_deleted = 0 AND published = 1) AS total
                            FROM UserProgress up
                            WHERE up.user_slug = @userSlug AND up.status = 'completed'";

                        cmd.Parameters.AddWithValue("@userSlug", userSlug);

                        using (var reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                completedQuizzes = Convert.ToInt32(reader["completed"]);
                                totalQuizzes = Convert.ToInt32(reader["total"]);
                            }
                        }
                    }

                    // Get badges
                    var badges = GetBadges(userSlug, con);

                    return new ProgressSummary
                    {
                        UserSlug = userSlug,
                        TotalXP = totalXP,
                        Level = level,
                        CompletedQuizzes = completedQuizzes,
                        TotalQuizzes = totalQuizzes,
                        Badges = badges
                    };
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[ProgressService] Error getting progress: {ex}");
                return new ProgressSummary
                {
                    UserSlug = userSlug,
                    TotalXP = totalXP,
                    Level = level
                };
            }
        }

        /// <summary>
        /// Get badges for a user
        /// </summary>
        private List<BadgeInfo> GetBadges(string userSlug, SqlConnection con)
        {
            var badges = new List<BadgeInfo>();

            using (var cmd = con.CreateCommand())
            {
                cmd.CommandText = @"
                    SELECT b.badge_slug, b.name, b.description, b.icon, ub.earned_at
                    FROM UserBadges ub
                    INNER JOIN Badges b ON ub.badge_slug = b.badge_slug
                    WHERE ub.user_slug = @userSlug
                    ORDER BY ub.earned_at DESC";

                cmd.Parameters.AddWithValue("@userSlug", userSlug);

                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        badges.Add(new BadgeInfo
                        {
                            BadgeSlug = reader["badge_slug"].ToString(),
                            Name = reader["name"].ToString(),
                            Description = reader["description"]?.ToString() ?? "",
                            Icon = reader["icon"]?.ToString() ?? "bi-star",
                            EarnedAt = Convert.ToDateTime(reader["earned_at"])
                        });
                    }
                }
            }

            return badges;
        }

        /// <summary>
        /// Check and award badges based on achievements
        /// </summary>
        public void CheckAndAwardBadges(string userSlug)
        {
            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();

                    var progress = GetProgress(userSlug);

                    // Badge: First Quiz
                    if (progress.CompletedQuizzes >= 1)
                    {
                        AwardBadgeIfNotEarned(userSlug, "first-quiz", con);
                    }

                    // Badge: Module Master (completed 5 quizzes)
                    if (progress.CompletedQuizzes >= 5)
                    {
                        AwardBadgeIfNotEarned(userSlug, "module-master", con);
                    }

                    // Badge: Level 5
                    if (progress.Level >= 5)
                    {
                        AwardBadgeIfNotEarned(userSlug, "level-5", con);
                    }

                    // Badge: XP Master (1000+ XP)
                    if (progress.TotalXP >= 1000)
                    {
                        AwardBadgeIfNotEarned(userSlug, "xp-master", con);
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[ProgressService] Error checking badges: {ex}");
            }
        }

        private void AwardBadgeIfNotEarned(string userSlug, string badgeSlug, SqlConnection con)
        {
            using (var cmd = con.CreateCommand())
            {
                cmd.CommandText = @"
                    IF NOT EXISTS (SELECT 1 FROM UserBadges WHERE user_slug = @userSlug AND badge_slug = @badgeSlug)
                    BEGIN
                        INSERT INTO UserBadges (user_badge_slug, user_slug, badge_slug, earned_at)
                        VALUES (NEWID(), @userSlug, @badgeSlug, SYSUTCDATETIME())
                    END";

                cmd.Parameters.AddWithValue("@userSlug", userSlug);
                cmd.Parameters.AddWithValue("@badgeSlug", badgeSlug);
                cmd.ExecuteNonQuery();
            }
        }

        public class ProgressSummary
        {
            public string UserSlug { get; set; }
            public int TotalXP { get; set; }
            public int Level { get; set; }
            public int CompletedQuizzes { get; set; }
            public int TotalQuizzes { get; set; }
            public List<BadgeInfo> Badges { get; set; } = new List<BadgeInfo>();
        }

        public class BadgeInfo
        {
            public string BadgeSlug { get; set; }
            public string Name { get; set; }
            public string Description { get; set; }
            public string Icon { get; set; }
            public DateTime EarnedAt { get; set; }
        }
    }
}


-- =============================================
-- ALL TABLES FOR ROOKIES IN TRAINING 2
-- Database: RookiesDatabase
-- Format: User's preferred style
-- =============================================

USE [RookiesDatabase];
GO

-- =============================================
-- TABLE 1: Users (You already have this)
-- =============================================
CREATE TABLE [dbo].[Users]
(
	[user_slug] NVARCHAR(100) NOT NULL PRIMARY KEY,
	[full_name] NVARCHAR(200) NOT NULL,
	[display_name] NVARCHAR(200) NULL,
	[email] NVARCHAR(255) NOT NULL UNIQUE,
	[password_hash] NVARCHAR(255) NOT NULL,
	[role] NVARCHAR(20) NOT NULL DEFAULT 'student',
	[role_global] NVARCHAR(20) NULL,
	[created_at] DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
	[updated_at] DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
	[is_deleted] BIT NOT NULL DEFAULT 0,
	[deleted_at] DATETIME2 NULL,
	[deleted_by_slug] NVARCHAR(100) NULL,
	[avatar_url] NCHAR(200) NULL
);
GO

-- =============================================
-- TABLE 2: Classes (You already have this)
-- =============================================
CREATE TABLE [dbo].[Classes]
(
	[class_slug] NVARCHAR(100) NOT NULL PRIMARY KEY,
	[class_name] NVARCHAR(200) NOT NULL,
	[class_code] NVARCHAR(50) NOT NULL UNIQUE,
	[description] NVARCHAR(500) NULL,
	[teacher_slug] NVARCHAR(100) NOT NULL,
	[icon] NVARCHAR(50) NULL DEFAULT 'bi-collection',
	[color] NVARCHAR(20) NULL DEFAULT '#667eea',
	[created_at] DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
	[updated_at] DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
	[is_deleted] BIT NOT NULL DEFAULT 0,
	[deleted_at] DATETIME2 NULL,
	[deleted_by_slug] NVARCHAR(100) NULL
);
GO

-- =============================================
-- TABLE 3: Enrollments (Student joins class)
-- =============================================
CREATE TABLE [dbo].[Enrollments]
(
	[enrollment_slug] NVARCHAR(100) NOT NULL PRIMARY KEY,
	[class_slug] NVARCHAR(100) NOT NULL,
	[user_slug] NVARCHAR(100) NOT NULL,
	[role_in_class] NVARCHAR(20) NOT NULL DEFAULT 'student',
	[joined_at] DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
	[is_deleted] BIT NOT NULL DEFAULT 0
);
GO

-- =============================================
-- TABLE 4: Levels (Learning stages in a class)
-- =============================================
CREATE TABLE [dbo].[Levels]
(
	[level_slug] NVARCHAR(100) NOT NULL PRIMARY KEY,
	[class_slug] NVARCHAR(100) NOT NULL,
	[level_number] INT NOT NULL,
	[title] NVARCHAR(200) NOT NULL,
	[description] NVARCHAR(MAX) NULL,
	[content_type] NVARCHAR(50) NULL,
	[content_url] NVARCHAR(500) NULL,
	[xp_reward] INT NOT NULL DEFAULT 50,
	[estimated_minutes] INT NOT NULL DEFAULT 15,
	[is_published] BIT NOT NULL DEFAULT 1,
	[created_at] DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
	[updated_at] DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
	[is_deleted] BIT NOT NULL DEFAULT 0
);
GO

-- =============================================
-- TABLE 5: Quizzes
-- =============================================
CREATE TABLE [dbo].[Quizzes]
(
	[quiz_slug] NVARCHAR(100) NOT NULL PRIMARY KEY,
	[title] NVARCHAR(200) NOT NULL,
	[class_slug] NVARCHAR(100) NULL,
	[level_slug] NVARCHAR(100) NULL,
	[module_slug] NVARCHAR(100) NULL,
	[quiz_type] NVARCHAR(50) NOT NULL DEFAULT 'multiple_choice',
	[time_limit_minutes] INT NULL DEFAULT 30,
	[passing_score] INT NULL DEFAULT 70,
	[estimated_minutes] INT NULL DEFAULT 10,
	[xp_reward] INT NULL DEFAULT 50,
	[order_no] INT NULL DEFAULT 0,
	[published] BIT NOT NULL DEFAULT 0,
	[created_by_slug] NVARCHAR(100) NULL,
	[created_at] DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
	[updated_at] DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
	[is_deleted] BIT NOT NULL DEFAULT 0
);
GO

-- =============================================
-- TABLE 6: Questions (Quiz questions)
-- =============================================
CREATE TABLE [dbo].[Questions]
(
	[question_slug] NVARCHAR(100) NOT NULL PRIMARY KEY,
	[quiz_slug] NVARCHAR(100) NOT NULL,
	[body_text] NVARCHAR(MAX) NOT NULL,
	[question_type] NVARCHAR(50) NOT NULL DEFAULT 'multiple_choice',
	[options_json] NVARCHAR(MAX) NULL,
	[answer_idx] INT NULL,
	[explanation] NVARCHAR(MAX) NULL,
	[difficulty] INT NULL DEFAULT 1,
	[order_no] INT NULL DEFAULT 0,
	[created_at] DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
	[updated_at] DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
	[is_deleted] BIT NOT NULL DEFAULT 0
);
GO

-- =============================================
-- TABLE 7: Modules (For student dashboard)
-- =============================================
CREATE TABLE [dbo].[Modules]
(
	[module_id] INT IDENTITY(1,1),
	[module_slug] NVARCHAR(100) NOT NULL PRIMARY KEY,
	[title] NVARCHAR(200) NOT NULL,
	[summary] NVARCHAR(500) NULL,
	[description] NVARCHAR(500) NULL,
	[icon] NVARCHAR(50) NULL DEFAULT 'book',
	[color] NVARCHAR(20) NULL DEFAULT '#667eea',
	[order_no] INT NULL DEFAULT 0,
	[total_xp] INT NULL,
	[is_active] BIT NULL DEFAULT 1,
	[created_by_slug] NVARCHAR(100) NULL,
	[created_at] DATETIME2 NULL DEFAULT SYSUTCDATETIME(),
	[updated_at] DATETIME2 NULL DEFAULT SYSUTCDATETIME(),
	[is_deleted] BIT NOT NULL DEFAULT 0
);
GO

-- =============================================
-- TABLE 8: ModuleQuizzes (Quizzes in modules)
-- =============================================
CREATE TABLE [dbo].[ModuleQuizzes]
(
	[module_quiz_slug] NVARCHAR(100) NOT NULL PRIMARY KEY,
	[module_slug] NVARCHAR(100) NOT NULL,
	[quiz_slug] NVARCHAR(100) NOT NULL,
	[title] NVARCHAR(200) NOT NULL,
	[minutes] INT NULL DEFAULT 10,
	[xp_reward] INT NULL DEFAULT 50,
	[order_no] INT NULL DEFAULT 0,
	[created_at] DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
	[updated_at] DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
	[is_deleted] BIT NOT NULL DEFAULT 0
);
GO

-- =============================================
-- TABLE 9: Badges (Achievements)
-- =============================================
CREATE TABLE [dbo].[Badges]
(
	[badge_slug] NVARCHAR(100) NOT NULL PRIMARY KEY,
	[name] NVARCHAR(100) NOT NULL,
	[description] NVARCHAR(500) NULL,
	[icon] NVARCHAR(50) NULL DEFAULT 'bi-star',
	[created_at] DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
	[is_deleted] BIT NOT NULL DEFAULT 0
);
GO

-- =============================================
-- TABLE 10: UserBadges (User earned badges)
-- =============================================
CREATE TABLE [dbo].[UserBadges]
(
	[user_badge_slug] NVARCHAR(100) NOT NULL PRIMARY KEY,
	[user_slug] NVARCHAR(100) NOT NULL,
	[badge_slug] NVARCHAR(100) NOT NULL,
	[earned_at] DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

-- =============================================
-- TABLE 11: UserProgress (Quiz progress tracking)
-- =============================================
CREATE TABLE [dbo].[UserProgress]
(
	[progress_slug] NVARCHAR(100) NOT NULL PRIMARY KEY,
	[user_slug] NVARCHAR(100) NOT NULL,
	[quiz_slug] NVARCHAR(100) NOT NULL,
	[status] NVARCHAR(20) NOT NULL DEFAULT 'not_started',
	[progress_pct] INT NOT NULL DEFAULT 0,
	[score] INT NULL,
	[attempts] INT NOT NULL DEFAULT 0,
	[last_attempt_at] DATETIME2 NULL,
	[completed_at] DATETIME2 NULL,
	[created_at] DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
	[updated_at] DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

-- =============================================
-- TABLE 12: LevelSlides (Learning material slides)
-- =============================================
CREATE TABLE [dbo].[LevelSlides]
(
	[slide_slug] NVARCHAR(100) NOT NULL PRIMARY KEY,
	[level_slug] NVARCHAR(100) NOT NULL,
	[slide_number] INT NOT NULL,
	[content_type] NVARCHAR(50) NOT NULL,
	[content_text] NVARCHAR(MAX) NULL,
	[media_url] NVARCHAR(500) NULL,
	[created_at] DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
	[is_deleted] BIT NOT NULL DEFAULT 0
);
GO

-- =============================================
-- TABLE 13: StudentLevelProgress (Student progress in levels)
-- =============================================
CREATE TABLE [dbo].[StudentLevelProgress]
(
	[progress_slug] NVARCHAR(100) NOT NULL PRIMARY KEY,
	[student_slug] NVARCHAR(100) NOT NULL,
	[level_slug] NVARCHAR(100) NOT NULL,
	[status] NVARCHAR(20) NOT NULL DEFAULT 'not_started',
	[current_slide] INT NULL DEFAULT 1,
	[completed_at] DATETIME2 NULL,
	[created_at] DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
	[updated_at] DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

-- =============================================
-- TABLE 14: QuizAssignments (Class-Quiz mapping)
-- =============================================
CREATE TABLE [dbo].[QuizAssignments]
(
	[assignment_slug] NVARCHAR(100) NOT NULL PRIMARY KEY,
	[class_slug] NVARCHAR(100) NOT NULL,
	[quiz_slug] NVARCHAR(100) NOT NULL,
	[assigned_at] DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
	[is_deleted] BIT NOT NULL DEFAULT 0
);
GO

PRINT '✅ All 14 tables created!';
PRINT '';
PRINT 'Tables:';
PRINT '  1. Users';
PRINT '  2. Classes';
PRINT '  3. Enrollments';
PRINT '  4. Levels';
PRINT '  5. Quizzes';
PRINT '  6. Questions';
PRINT '  7. Modules';
PRINT '  8. ModuleQuizzes';
PRINT '  9. Badges';
PRINT '  10. UserBadges';
PRINT '  11. UserProgress';
PRINT '  12. LevelSlides';
PRINT '  13. StudentLevelProgress';
PRINT '  14. QuizAssignments';
PRINT '';
PRINT '🚀 Now run: SEED_Test_Accounts.sql';
GO


-- =============================================
-- FORUM TABLES FOR ROOKIES IN TRAINING
-- Run this script to create forum functionality
-- =============================================

USE [RookiesDatabase];
GO

-- =============================================
-- TABLE: ForumThreads
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ForumThreads')
BEGIN
    CREATE TABLE [dbo].[ForumThreads]
    (
        [thread_slug] NVARCHAR(100) NOT NULL PRIMARY KEY,
        [title] NVARCHAR(200) NOT NULL,
        [content] NVARCHAR(MAX) NOT NULL,
        [author_slug] NVARCHAR(100) NOT NULL,
        [created_at] DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        [updated_at] DATETIME2 NULL,
        [is_deleted] BIT NOT NULL DEFAULT 0,
        [deleted_at] DATETIME2 NULL,
        CONSTRAINT FK_ForumThreads_Users FOREIGN KEY ([author_slug]) REFERENCES [Users]([user_slug])
    );
    PRINT '✅ ForumThreads table created';
END
ELSE
BEGIN
    PRINT '⚠️ ForumThreads table already exists';
END
GO

-- =============================================
-- TABLE: ForumPosts
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ForumPosts')
BEGIN
    CREATE TABLE [dbo].[ForumPosts]
    (
        [post_slug] NVARCHAR(100) NOT NULL PRIMARY KEY,
        [thread_slug] NVARCHAR(100) NOT NULL,
        [author_slug] NVARCHAR(100) NOT NULL,
        [content] NVARCHAR(MAX) NOT NULL,
        [created_at] DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        [updated_at] DATETIME2 NULL,
        [is_deleted] BIT NOT NULL DEFAULT 0,
        [deleted_at] DATETIME2 NULL,
        CONSTRAINT FK_ForumPosts_Threads FOREIGN KEY ([thread_slug]) REFERENCES [ForumThreads]([thread_slug]),
        CONSTRAINT FK_ForumPosts_Users FOREIGN KEY ([author_slug]) REFERENCES [Users]([user_slug])
    );
    PRINT '✅ ForumPosts table created';
END
ELSE
BEGIN
    PRINT '⚠️ ForumPosts table already exists';
END
GO

-- =============================================
-- INDEXES for Performance
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ForumThreads_CreatedAt')
BEGIN
    CREATE INDEX IX_ForumThreads_CreatedAt ON [ForumThreads]([created_at] DESC);
    PRINT '✅ Index IX_ForumThreads_CreatedAt created';
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ForumPosts_ThreadSlug')
BEGIN
    CREATE INDEX IX_ForumPosts_ThreadSlug ON [ForumPosts]([thread_slug], [created_at]);
    PRINT '✅ Index IX_ForumPosts_ThreadSlug created';
END
GO

PRINT '';
PRINT '🎉 Forum tables setup complete!';
PRINT '';
PRINT 'Next steps:';
PRINT '  1. Test forum by creating a thread';
PRINT '  2. Add seed data if needed';
GO


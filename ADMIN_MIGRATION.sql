-- =============================================
-- ADMIN SYSTEM MIGRATION
-- Adds IsBlocked field and AdminLogs table
-- =============================================

USE [RookiesDatabase];
GO

-- Add IsBlocked field to Users table if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Users]') AND name = 'is_blocked')
BEGIN
    ALTER TABLE [dbo].[Users]
    ADD [is_blocked] BIT NOT NULL DEFAULT 0;
    PRINT '✅ Added is_blocked column to Users table';
END
ELSE
BEGIN
    PRINT '⚠️ is_blocked column already exists in Users table';
END
GO

-- Create AdminLogs table for audit trail
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'AdminLogs')
BEGIN
    CREATE TABLE [dbo].[AdminLogs]
    (
        [log_id] BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [admin_slug] NVARCHAR(100) NOT NULL,
        [action_type] NVARCHAR(50) NOT NULL, -- 'create_user', 'delete_user', 'block_user', 'unblock_user', 'reset_password', 'change_role', 'delete_class', 'delete_post', etc.
        [target_type] NVARCHAR(50) NULL, -- 'user', 'class', 'post', 'reply'
        [target_slug] NVARCHAR(100) NULL,
        [details] NVARCHAR(MAX) NULL, -- JSON or text description
        [ip_address] NVARCHAR(50) NULL,
        [created_at] DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_AdminLogs_Users FOREIGN KEY (admin_slug) REFERENCES Users(user_slug)
    );
    
    CREATE INDEX IX_AdminLogs_AdminSlug ON AdminLogs(admin_slug);
    CREATE INDEX IX_AdminLogs_ActionType ON AdminLogs(action_type);
    CREATE INDEX IX_AdminLogs_CreatedAt ON AdminLogs(created_at);
    
    PRINT '✅ Created AdminLogs table';
END
ELSE
BEGIN
    PRINT '⚠️ AdminLogs table already exists';
END
GO

PRINT '';
PRINT '✅ Admin system migration completed!';
GO


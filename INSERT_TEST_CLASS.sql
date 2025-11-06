USE [RookiesDatabase];
GO

-- Insert a test class for teacher-admin
-- Make sure you've created your test accounts first!

DECLARE @TeacherSlug NVARCHAR(100) = 'teacher-admin';
DECLARE @ClassSlug NVARCHAR(100) = 'intro-programming-101';

-- Insert test class
IF NOT EXISTS (SELECT * FROM Classes WHERE class_slug = @ClassSlug)
BEGIN
    INSERT INTO Classes 
    (
        class_slug, 
        class_name, 
        class_code, 
        description, 
        teacher_slug, 
        icon, 
        color,
        created_at, 
        updated_at, 
        is_deleted
    )
    VALUES 
    (
        @ClassSlug,
        'Introduction to Programming',
        'CS101',
        'Learn the fundamentals of programming with hands-on examples',
        @TeacherSlug,
        'code-square',
        '#667eea',
        SYSUTCDATETIME(),
        SYSUTCDATETIME(),
        0
    );
    PRINT '✅ Created test class: Introduction to Programming (CS101)';
END
ELSE
    PRINT '✓ Test class already exists';
GO

-- Auto-enroll teacher in the class
DECLARE @TeacherSlug NVARCHAR(100) = 'teacher-admin';
DECLARE @ClassSlug NVARCHAR(100) = 'intro-programming-101';
DECLARE @EnrollSlug NVARCHAR(100) = 'enroll-teacher-intro-prog';

IF NOT EXISTS (SELECT * FROM Enrollments WHERE enrollment_slug = @EnrollSlug)
BEGIN
    INSERT INTO Enrollments
    (
        enrollment_slug,
        class_slug,
        user_slug,
        role_in_class,
        joined_at,
        is_deleted
    )
    VALUES
    (
        @EnrollSlug,
        @ClassSlug,
        @TeacherSlug,
        'teacher',
        SYSUTCDATETIME(),
        0
    );
    PRINT '✅ Enrolled teacher in class';
END
GO

-- Insert 3 test levels
DECLARE @ClassSlug NVARCHAR(100) = 'intro-programming-101';

-- Level 1
IF NOT EXISTS (SELECT * FROM Levels WHERE level_slug = @ClassSlug + '-level-1')
BEGIN
    INSERT INTO Levels
    (
        level_slug,
        class_slug,
        level_number,
        title,
        description,
        content_type,
        content_url,
        xp_reward,
        estimated_minutes,
        is_published,
        created_at,
        updated_at,
        is_deleted
    )
    VALUES
    (
        @ClassSlug + '-level-1',
        @ClassSlug,
        1,
        'Introduction to Variables',
        'Learn about variables and data storage',
        'html',
        NULL,
        50,
        15,
        1,
        SYSUTCDATETIME(),
        SYSUTCDATETIME(),
        0
    );
    PRINT '✅ Created Level 1';
END
GO

-- Level 2
DECLARE @ClassSlug NVARCHAR(100) = 'intro-programming-101';

IF NOT EXISTS (SELECT * FROM Levels WHERE level_slug = @ClassSlug + '-level-2')
BEGIN
    INSERT INTO Levels
    (
        level_slug,
        class_slug,
        level_number,
        title,
        description,
        xp_reward,
        estimated_minutes,
        is_published,
        created_at,
        updated_at,
        is_deleted
    )
    VALUES
    (
        @ClassSlug + '-level-2',
        @ClassSlug,
        2,
        'Data Types and Operators',
        'Understanding different data types',
        50,
        15,
        1,
        SYSUTCDATETIME(),
        SYSUTCDATETIME(),
        0
    );
    PRINT '✅ Created Level 2';
END
GO

-- Level 3
DECLARE @ClassSlug NVARCHAR(100) = 'intro-programming-101';

IF NOT EXISTS (SELECT * FROM Levels WHERE level_slug = @ClassSlug + '-level-3')
BEGIN
    INSERT INTO Levels
    (
        level_slug,
        class_slug,
        level_number,
        title,
        description,
        xp_reward,
        estimated_minutes,
        is_published,
        created_at,
        updated_at,
        is_deleted
    )
    VALUES
    (
        @ClassSlug + '-level-3',
        @ClassSlug,
        3,
        'Control Flow Statements',
        'Learn about if/else and loops',
        50,
        15,
        1,
        SYSUTCDATETIME(),
        SYSUTCDATETIME(),
        0
    );
    PRINT '✅ Created Level 3';
END
GO

PRINT '';
PRINT '========================================';
PRINT '✅ TEST CLASS READY!';
PRINT '========================================';
PRINT '';
PRINT 'Test class details:';
PRINT '  Slug: intro-programming-101';
PRINT '  Name: Introduction to Programming';
PRINT '  Code: CS101';
PRINT '  Levels: 3';
PRINT '';
PRINT 'Test URL:';
PRINT '  https://localhost:44379/Pages/class_detail.aspx?slug=intro-programming-101';
PRINT '';
GO


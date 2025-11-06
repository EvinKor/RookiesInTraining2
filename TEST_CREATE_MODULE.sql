-- ================================================
-- 测试"创建模块"功能的数据验证脚本
-- Test Script for "Create Module" Feature
-- ================================================
-- 运行此脚本以验证模块创建成功
-- Run this script to verify successful module creation

USE [RookiesDatabase];
GO

PRINT '================================================';
PRINT '测试"创建模块"功能';
PRINT 'Testing "Create Module" Feature';
PRINT '================================================';
PRINT '';

-- 1. 检查最近创建的课程
PRINT '1. 最近创建的课程 (Recent Classes):';
PRINT '-----------------------------------';
SELECT TOP 5
    class_slug,
    class_name,
    class_code,
    teacher_slug,
    icon,
    color,
    created_at,
    is_deleted
FROM dbo.Classes
WHERE is_deleted = 0
ORDER BY created_at DESC;
PRINT '';

-- 2. 检查每个课程的关卡数量
PRINT '2. 每个课程的关卡数量 (Levels per Class):';
PRINT '-------------------------------------------';
SELECT 
    c.class_slug,
    c.class_name,
    COUNT(l.level_slug) AS total_levels,
    SUM(CASE WHEN l.is_published = 1 THEN 1 ELSE 0 END) AS published_levels,
    SUM(l.xp_reward) AS total_xp
FROM dbo.Classes c
LEFT JOIN dbo.Levels l ON c.class_slug = l.class_slug AND l.is_deleted = 0
WHERE c.is_deleted = 0
GROUP BY c.class_slug, c.class_name
ORDER BY c.created_at DESC;
PRINT '';

-- 3. 检查最近创建的关卡
PRINT '3. 最近创建的关卡 (Recent Levels):';
PRINT '-----------------------------------';
SELECT TOP 10
    l.level_slug,
    l.class_slug,
    l.level_number,
    l.title,
    l.content_type,
    CASE 
        WHEN l.content_url IS NOT NULL THEN 'YES'
        ELSE 'NO'
    END AS has_file,
    l.xp_reward,
    l.estimated_minutes,
    l.is_published,
    l.created_at
FROM dbo.Levels l
WHERE l.is_deleted = 0
ORDER BY l.created_at DESC;
PRINT '';

-- 4. 检查课程代码唯一性
PRINT '4. 课程代码唯一性检查 (Class Code Uniqueness):';
PRINT '------------------------------------------------';
SELECT 
    class_code,
    COUNT(*) AS count
FROM dbo.Classes
WHERE is_deleted = 0
GROUP BY class_code
HAVING COUNT(*) > 1;

IF @@ROWCOUNT = 0
BEGIN
    PRINT '✓ 所有课程代码唯一 (All class codes are unique)';
END
ELSE
BEGIN
    PRINT '✗ 发现重复的课程代码 (Duplicate class codes found)';
END
PRINT '';

-- 5. 检查关卡完整性
PRINT '5. 关卡完整性检查 (Level Integrity Check):';
PRINT '-------------------------------------------';
SELECT 
    class_slug,
    class_name,
    CASE 
        WHEN (SELECT COUNT(*) FROM dbo.Levels WHERE class_slug = c.class_slug AND is_deleted = 0) < 3
        THEN '✗ 关卡少于3个 (Less than 3 levels)'
        ELSE '✓ 符合要求 (Valid)'
    END AS status,
    (SELECT COUNT(*) FROM dbo.Levels WHERE class_slug = c.class_slug AND is_deleted = 0) AS level_count
FROM dbo.Classes c
WHERE c.is_deleted = 0
ORDER BY c.created_at DESC;
PRINT '';

-- 6. 检查文件上传
PRINT '6. 文件上传统计 (File Upload Statistics):';
PRINT '-------------------------------------------';
SELECT 
    content_type,
    COUNT(*) AS count
FROM dbo.Levels
WHERE is_deleted = 0 AND content_url IS NOT NULL
GROUP BY content_type;

IF @@ROWCOUNT = 0
BEGIN
    PRINT '(没有上传的文件 / No uploaded files)';
END
PRINT '';

-- 7. 汇总统计
PRINT '7. 汇总统计 (Summary Statistics):';
PRINT '-----------------------------------';
SELECT 
    (SELECT COUNT(*) FROM dbo.Classes WHERE is_deleted = 0) AS total_classes,
    (SELECT COUNT(*) FROM dbo.Levels WHERE is_deleted = 0) AS total_levels,
    (SELECT COUNT(*) FROM dbo.Levels WHERE is_deleted = 0 AND content_url IS NOT NULL) AS levels_with_files,
    (SELECT COUNT(*) FROM dbo.Levels WHERE is_deleted = 0 AND is_published = 1) AS published_levels,
    (SELECT SUM(xp_reward) FROM dbo.Levels WHERE is_deleted = 0) AS total_xp_available;
PRINT '';

-- 8. 验证最新创建的模块
PRINT '8. 最新创建模块的详细信息 (Latest Module Details):';
PRINT '----------------------------------------------------';
DECLARE @latestClass NVARCHAR(100);
SELECT TOP 1 @latestClass = class_slug FROM dbo.Classes WHERE is_deleted = 0 ORDER BY created_at DESC;

IF @latestClass IS NOT NULL
BEGIN
    PRINT 'Class Slug: ' + @latestClass;
    PRINT '';
    
    SELECT 
        'CLASS INFO' AS [Type],
        class_name AS [Name],
        class_code AS [Code],
        description AS [Description],
        icon AS [Icon],
        color AS [Color],
        teacher_slug AS [Creator],
        CONVERT(VARCHAR, created_at, 120) AS [Created At]
    FROM dbo.Classes
    WHERE class_slug = @latestClass;
    
    PRINT '';
    PRINT 'Levels:';
    SELECT 
        level_number AS [#],
        title AS [Title],
        content_type AS [Type],
        xp_reward AS [XP],
        estimated_minutes AS [Minutes],
        CASE WHEN is_published = 1 THEN 'Yes' ELSE 'No' END AS [Published]
    FROM dbo.Levels
    WHERE class_slug = @latestClass AND is_deleted = 0
    ORDER BY level_number;
END
ELSE
BEGIN
    PRINT '(没有找到课程 / No classes found)';
END
PRINT '';

PRINT '================================================';
PRINT '测试完成 / Testing Complete';
PRINT '================================================';

-- 测试账户信息
PRINT '';
PRINT '测试账户 (Test Accounts):';
PRINT '-------------------------';
PRINT 'Teacher: teacher@example.com / password123';
PRINT 'Student: student@example.com / password123';
PRINT 'Admin:   admin@example.com / password123';
PRINT '';

-- 访问链接
PRINT '访问链接 (URLs):';
PRINT '----------------';
PRINT '创建模块: https://localhost:44379/Pages/teacher_create_module.aspx';
PRINT '浏览课程: https://localhost:44379/Pages/teacher_browse_classes.aspx';
PRINT '课程详情: https://localhost:44379/Pages/class_detail.aspx?slug=YOUR_CLASS_SLUG';
PRINT '';

GO



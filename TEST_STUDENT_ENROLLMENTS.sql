-- =====================================================
-- DEBUG QUERIES FOR STUDENT ENROLLMENTS
-- =====================================================
-- Run these queries to diagnose why classes aren't showing on student dashboard
-- The enrollment table is: Enrollments
-- =====================================================

-- 1. Check ALL enrollments (including deleted)
SELECT 
    e.enrollment_slug,
    e.user_slug,
    e.class_slug,
    e.role_in_class,
    e.joined_at,
    e.is_deleted,
    u.full_name AS StudentName,
    u.email AS StudentEmail,
    c.class_name AS ClassName,
    c.class_code AS ClassCode
FROM Enrollments e
LEFT JOIN Users u ON e.user_slug = u.user_slug
LEFT JOIN Classes c ON e.class_slug = c.class_slug
ORDER BY e.joined_at DESC;

-- 2. Check ONLY STUDENT enrollments (not deleted)
SELECT 
    e.enrollment_slug,
    e.user_slug,
    e.class_slug,
    e.role_in_class,
    e.joined_at,
    e.is_deleted,
    u.full_name AS StudentName,
    c.class_name AS ClassName
FROM Enrollments e
INNER JOIN Users u ON e.user_slug = u.user_slug
INNER JOIN Classes c ON e.class_slug = c.class_slug
WHERE e.role_in_class = 'student' 
  AND e.is_deleted = 0
  AND c.is_deleted = 0
ORDER BY e.joined_at DESC;

-- 3. Check all student accounts
SELECT user_slug, full_name, email, role, is_deleted
FROM Users
WHERE role = 'student'
ORDER BY is_deleted, user_slug;

-- 4. Check what classes exist
SELECT class_slug, class_name, class_code, teacher_slug, is_deleted
FROM Classes
ORDER BY is_deleted, class_slug;

-- 5. EXACT QUERY THE DASHBOARD USES (Replace 'YOUR-STUDENT-SLUG' with actual student slug)
-- Copy this and replace the student slug, then run it:
/*
DECLARE @studentSlug NVARCHAR(100) = 'student'; -- CHANGE THIS TO YOUR ACTUAL STUDENT SLUG

SELECT 
    c.class_slug,
    c.class_name,
    c.class_code,
    c.description,
    c.icon,
    c.color,
    COUNT(DISTINCT l.level_slug) AS LevelCount,
    COUNT(DISTINCT CASE WHEN slp.is_completed = 1 THEN l.level_slug END) AS CompletedCount
FROM Enrollments e
INNER JOIN Classes c ON e.class_slug = c.class_slug
LEFT JOIN Levels l ON c.class_slug = l.class_slug AND l.is_deleted = 0 AND l.is_published = 1
LEFT JOIN StudentLevelProgress slp ON l.level_slug = slp.level_slug AND slp.student_slug = @studentSlug
WHERE e.user_slug = @studentSlug 
  AND e.is_deleted = 0 
  AND c.is_deleted = 0
GROUP BY c.class_slug, c.class_name, c.class_code, c.description, c.icon, c.color
ORDER BY e.joined_at DESC;
*/


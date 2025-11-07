-- =====================================================
-- CHECK WHAT TABLES EXIST IN YOUR DATABASE
-- =====================================================
-- Run this query to see all tables in your current database
-- =====================================================

-- 1. List ALL tables in the database
SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
ORDER BY TABLE_NAME;

-- 2. Check specifically for Enrollments table
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Enrollments'
ORDER BY ORDINAL_POSITION;

-- 3. If Enrollments table exists, check its data
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Enrollments')
BEGIN
    SELECT 'Enrollments table EXISTS' AS Status;
    SELECT COUNT(*) AS TotalRows FROM Enrollments;
    SELECT COUNT(*) AS StudentEnrollments FROM Enrollments WHERE role_in_class = 'student';
END
ELSE
BEGIN
    SELECT 'Enrollments table DOES NOT EXIST' AS Status;
END

-- 4. Check what database you're connected to
SELECT 
    DB_NAME() AS CurrentDatabase,
    @@SERVERNAME AS ServerName,
    GETDATE() AS CurrentTime;


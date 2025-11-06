-- ================================================
-- Clean Up Duplicate Quizzes - Final Version
-- ================================================
-- Run this directly on RookiesDatabase.mdf
-- NO "USE" statement needed for LocalDB

-- Step 1: Show current state
PRINT '=== Current Quizzes ===';
SELECT 
    quiz_slug, 
    title, 
    level_slug, 
    mode,
    created_at,
    is_deleted
FROM Quizzes
ORDER BY level_slug, created_at DESC;
PRINT '';

-- Step 2: Find and show duplicates
PRINT '=== Duplicate Level Assignments ===';
SELECT 
    level_slug, 
    COUNT(*) as quiz_count,
    STRING_AGG(quiz_slug, ', ') as quiz_slugs
FROM Quizzes
WHERE is_deleted = 0 AND level_slug IS NOT NULL
GROUP BY level_slug
HAVING COUNT(*) > 1;
PRINT '';

-- Step 3: Delete ALL duplicates, keeping only the FIRST created one
-- (Usually the one created with the module)
PRINT '=== Removing Duplicates (Keeping First Created) ===';

DELETE FROM Quizzes
WHERE quiz_slug IN (
    SELECT quiz_slug
    FROM (
        SELECT 
            quiz_slug,
            level_slug,
            ROW_NUMBER() OVER (
                PARTITION BY level_slug 
                ORDER BY created_at ASC  -- Keep FIRST created
            ) as rn
        FROM Quizzes
        WHERE is_deleted = 0 AND level_slug IS NOT NULL
    ) ranked
    WHERE rn > 1  -- Delete all except first
);

PRINT CAST(@@ROWCOUNT AS VARCHAR) + ' duplicate quizzes permanently deleted.';
PRINT '';

-- Step 4: Handle quizzes with NULL level_slug
PRINT '=== Handling Orphan Quizzes (NULL level_slug) ===';
SELECT COUNT(*) as orphan_count 
FROM Quizzes 
WHERE level_slug IS NULL AND is_deleted = 0;

-- Optionally delete orphan quizzes (uncomment if you want)
-- DELETE FROM Quizzes WHERE level_slug IS NULL;
-- PRINT 'Orphan quizzes deleted.';

PRINT '';

-- Step 5: Show final state before adding constraint
PRINT '=== Final Quiz List (Should be 1 per level) ===';
SELECT 
    level_slug, 
    COUNT(*) as quiz_count
FROM Quizzes
WHERE is_deleted = 0 AND level_slug IS NOT NULL
GROUP BY level_slug
ORDER BY level_slug;
PRINT '';

-- Step 6: Add unique constraint
PRINT '=== Adding Unique Constraint ===';
BEGIN TRY
    ALTER TABLE [dbo].[Quizzes]
    ADD CONSTRAINT UQ_Quizzes_LevelSlug UNIQUE (level_slug);
    PRINT '✅ Unique constraint added successfully!';
END TRY
BEGIN CATCH
    PRINT '❌ Error adding constraint: ' + ERROR_MESSAGE();
    PRINT 'There may still be duplicates. Check the output above.';
END CATCH
PRINT '';

-- Step 7: Add quiz_slug to Levels table
PRINT '=== Adding quiz_slug to Levels ===';
IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID(N'[dbo].[Levels]') 
    AND name = 'quiz_slug'
)
BEGIN
    ALTER TABLE [dbo].[Levels]
    ADD [quiz_slug] NVARCHAR(100) NULL;
    PRINT '✅ Added quiz_slug column to Levels table';
END
ELSE
BEGIN
    PRINT 'ℹ️ quiz_slug column already exists';
END
GO

-- Step 8: Link levels to quizzes (separate batch)
PRINT '=== Linking Levels to Quizzes ===';
UPDATE l
SET l.quiz_slug = q.quiz_slug
FROM Levels l
INNER JOIN Quizzes q ON q.level_slug = l.level_slug
WHERE l.is_deleted = 0 AND q.is_deleted = 0;

PRINT '✅ Linked ' + CAST(@@ROWCOUNT AS VARCHAR) + ' levels to their quizzes';

PRINT '';
PRINT '🎉 DONE! Your database is ready for the one-quiz-per-level structure.';
PRINT 'You can now create modules with 1 quiz per level.';
GO


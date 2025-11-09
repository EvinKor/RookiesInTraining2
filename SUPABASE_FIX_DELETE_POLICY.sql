-- ============================================
-- FIX: Add DELETE Policy for game_participants
-- ============================================
-- Run this in Supabase SQL Editor
-- ============================================

-- Allow users to delete their own participant record (leave lobby)
CREATE POLICY "Allow users to leave lobby"
    ON game_participants FOR DELETE
    USING (true);

-- ============================================
-- VERIFICATION QUERY
-- ============================================
-- After running the above, run this to verify:

SELECT 
    schemaname,
    tablename,
    policyname,
    cmd
FROM pg_policies
WHERE tablename = 'game_participants'
ORDER BY cmd;

-- You should see 4 policies:
-- 1. SELECT - Allow public read
-- 2. INSERT - Allow users to join
-- 3. UPDATE - Allow users to update own record
-- 4. DELETE - Allow users to leave lobby (NEW!)


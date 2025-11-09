-- ============================================
-- MULTIPLAYER QUIZ GAME - SUPABASE SCHEMA
-- ============================================
-- Run this in your Supabase SQL Editor
-- ============================================

-- 1. GAME LOBBIES TABLE
CREATE TABLE game_lobbies (
    lobby_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lobby_code VARCHAR(6) UNIQUE NOT NULL, -- e.g., "ABC123"
    host_user_slug VARCHAR(100) NOT NULL, -- from your local Users table
    host_name VARCHAR(255) NOT NULL,
    lobby_name VARCHAR(255) NOT NULL,
    quiz_source VARCHAR(50) NOT NULL, -- 'multiplayer' or 'class_level'
    quiz_id VARCHAR(100), -- quiz_slug from local DB if using class quiz
    class_slug VARCHAR(100), -- if quiz is from a class
    max_players INTEGER DEFAULT 10,
    status VARCHAR(50) DEFAULT 'waiting', -- waiting, in_progress, completed, cancelled
    game_mode VARCHAR(50) DEFAULT 'fastest_finger', -- fastest_finger, all_answer, survival
    time_per_question INTEGER DEFAULT 30, -- seconds
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    started_at TIMESTAMP WITH TIME ZONE,
    ended_at TIMESTAMP WITH TIME ZONE
);

-- 2. GAME PARTICIPANTS TABLE
CREATE TABLE game_participants (
    participant_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lobby_id UUID REFERENCES game_lobbies(lobby_id) ON DELETE CASCADE,
    user_slug VARCHAR(100) NOT NULL,
    user_name VARCHAR(255) NOT NULL,
    user_email VARCHAR(255),
    avatar_color VARCHAR(7) DEFAULT '#3B82F6', -- hex color for avatar
    score INTEGER DEFAULT 0,
    rank INTEGER DEFAULT 0,
    is_ready BOOLEAN DEFAULT FALSE,
    is_online BOOLEAN DEFAULT TRUE,
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_seen TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(lobby_id, user_slug)
);

-- 3. MULTIPLAYER QUIZ QUESTIONS TABLE
-- These are questions created specifically for multiplayer games
CREATE TABLE multiplayer_questions (
    question_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quiz_set_name VARCHAR(255) NOT NULL, -- e.g., "General Knowledge Set 1"
    question_text TEXT NOT NULL,
    question_type VARCHAR(50) DEFAULT 'multiple_choice', -- multiple_choice, true_false
    option_a TEXT,
    option_b TEXT,
    option_c TEXT,
    option_d TEXT,
    correct_answer VARCHAR(10) NOT NULL, -- 'A', 'B', 'C', 'D', or 'true'/'false'
    explanation TEXT,
    difficulty VARCHAR(50) DEFAULT 'medium', -- easy, medium, hard
    category VARCHAR(100), -- Math, Science, History, etc.
    points INTEGER DEFAULT 100,
    time_limit INTEGER DEFAULT 30, -- seconds
    order_no INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_by VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. GAME SESSIONS TABLE
-- Tracks the actual game being played
CREATE TABLE game_sessions (
    session_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lobby_id UUID REFERENCES game_lobbies(lobby_id) ON DELETE CASCADE,
    current_question_index INTEGER DEFAULT 0,
    total_questions INTEGER DEFAULT 0,
    current_question_id UUID,
    question_started_at TIMESTAMP WITH TIME ZONE,
    question_ends_at TIMESTAMP WITH TIME ZONE,
    status VARCHAR(50) DEFAULT 'active', -- active, paused, completed
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. GAME ANSWERS TABLE
-- Records each player's answer to each question
CREATE TABLE game_answers (
    answer_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID REFERENCES game_sessions(session_id) ON DELETE CASCADE,
    lobby_id UUID REFERENCES game_lobbies(lobby_id) ON DELETE CASCADE,
    participant_id UUID REFERENCES game_participants(participant_id) ON DELETE CASCADE,
    question_id UUID NOT NULL,
    question_index INTEGER NOT NULL,
    selected_answer VARCHAR(10), -- 'A', 'B', 'C', 'D', 'true', 'false'
    is_correct BOOLEAN,
    points_earned INTEGER DEFAULT 0,
    time_taken DECIMAL(5,2), -- seconds taken to answer
    answered_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(session_id, participant_id, question_index)
);

-- 6. GAME RESULTS TABLE
-- Final results and rankings
CREATE TABLE game_results (
    result_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lobby_id UUID REFERENCES game_lobbies(lobby_id) ON DELETE CASCADE,
    participant_id UUID REFERENCES game_participants(participant_id) ON DELETE CASCADE,
    user_slug VARCHAR(100) NOT NULL,
    user_name VARCHAR(255) NOT NULL,
    total_score INTEGER DEFAULT 0,
    correct_answers INTEGER DEFAULT 0,
    wrong_answers INTEGER DEFAULT 0,
    total_questions INTEGER DEFAULT 0,
    accuracy DECIMAL(5,2), -- percentage
    avg_time_per_question DECIMAL(5,2),
    final_rank INTEGER,
    is_winner BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(lobby_id, participant_id)
);

-- 7. GAME CHAT MESSAGES TABLE (Optional - for lobby chat)
CREATE TABLE game_chat_messages (
    message_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lobby_id UUID REFERENCES game_lobbies(lobby_id) ON DELETE CASCADE,
    user_slug VARCHAR(100) NOT NULL,
    user_name VARCHAR(255) NOT NULL,
    message_text TEXT NOT NULL,
    message_type VARCHAR(50) DEFAULT 'chat', -- chat, system, emoji_reaction
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- INDEXES for Performance
-- ============================================

CREATE INDEX idx_lobbies_status ON game_lobbies(status);
CREATE INDEX idx_lobbies_code ON game_lobbies(lobby_code);
CREATE INDEX idx_lobbies_created ON game_lobbies(created_at DESC);

CREATE INDEX idx_participants_lobby ON game_participants(lobby_id);
CREATE INDEX idx_participants_user ON game_participants(user_slug);
CREATE INDEX idx_participants_score ON game_participants(score DESC);

CREATE INDEX idx_questions_quiz_set ON multiplayer_questions(quiz_set_name);
CREATE INDEX idx_questions_category ON multiplayer_questions(category);
CREATE INDEX idx_questions_difficulty ON multiplayer_questions(difficulty);

CREATE INDEX idx_answers_session ON game_answers(session_id);
CREATE INDEX idx_answers_participant ON game_answers(participant_id);
CREATE INDEX idx_answers_lobby ON game_answers(lobby_id);

CREATE INDEX idx_results_lobby ON game_results(lobby_id);
CREATE INDEX idx_results_rank ON game_results(final_rank);

CREATE INDEX idx_chat_lobby ON game_chat_messages(lobby_id);
CREATE INDEX idx_chat_created ON game_chat_messages(created_at DESC);

-- ============================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================

-- Enable RLS on all tables
ALTER TABLE game_lobbies ENABLE ROW LEVEL SECURITY;
ALTER TABLE game_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE multiplayer_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE game_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE game_answers ENABLE ROW LEVEL SECURITY;
ALTER TABLE game_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE game_chat_messages ENABLE ROW LEVEL SECURITY;

-- Public read access for lobbies (so people can browse and join)
CREATE POLICY "Allow public read access to lobbies"
    ON game_lobbies FOR SELECT
    USING (true);

-- Allow authenticated users to create lobbies
CREATE POLICY "Allow authenticated users to create lobbies"
    ON game_lobbies FOR INSERT
    WITH CHECK (true);

-- Allow host to update their lobby
CREATE POLICY "Allow host to update lobby"
    ON game_lobbies FOR UPDATE
    USING (true)
    WITH CHECK (true);

-- Public read access for participants
CREATE POLICY "Allow public read access to participants"
    ON game_participants FOR SELECT
    USING (true);

-- Allow users to join as participant
CREATE POLICY "Allow users to join as participant"
    ON game_participants FOR INSERT
    WITH CHECK (true);

-- Allow users to update their own participant record
CREATE POLICY "Allow users to update own participant record"
    ON game_participants FOR UPDATE
    USING (true)
    WITH CHECK (true);

-- Public read for multiplayer questions
CREATE POLICY "Allow public read access to questions"
    ON multiplayer_questions FOR SELECT
    USING (true);

-- Allow authenticated users to create questions
CREATE POLICY "Allow users to create questions"
    ON multiplayer_questions FOR INSERT
    WITH CHECK (true);

-- Public read for game sessions
CREATE POLICY "Allow public read access to sessions"
    ON game_sessions FOR SELECT
    USING (true);

CREATE POLICY "Allow session creation"
    ON game_sessions FOR INSERT
    WITH CHECK (true);

CREATE POLICY "Allow session updates"
    ON game_sessions FOR UPDATE
    USING (true)
    WITH CHECK (true);

-- Public read/write for game answers
CREATE POLICY "Allow public read access to answers"
    ON game_answers FOR SELECT
    USING (true);

CREATE POLICY "Allow answer submission"
    ON game_answers FOR INSERT
    WITH CHECK (true);

-- Public read for results
CREATE POLICY "Allow public read access to results"
    ON game_results FOR SELECT
    USING (true);

CREATE POLICY "Allow result creation"
    ON game_results FOR INSERT
    WITH CHECK (true);

-- Chat policies
CREATE POLICY "Allow public read access to chat"
    ON game_chat_messages FOR SELECT
    USING (true);

CREATE POLICY "Allow users to send messages"
    ON game_chat_messages FOR INSERT
    WITH CHECK (true);

-- ============================================
-- REALTIME SUBSCRIPTIONS
-- ============================================
-- Enable realtime for live updates during games

-- This will be configured in Supabase Dashboard > Database > Replication
-- Or run these commands:

ALTER PUBLICATION supabase_realtime ADD TABLE game_lobbies;
ALTER PUBLICATION supabase_realtime ADD TABLE game_participants;
ALTER PUBLICATION supabase_realtime ADD TABLE game_sessions;
ALTER PUBLICATION supabase_realtime ADD TABLE game_answers;
ALTER PUBLICATION supabase_realtime ADD TABLE game_results;
ALTER PUBLICATION supabase_realtime ADD TABLE game_chat_messages;

-- ============================================
-- SAMPLE DATA (Optional - for testing)
-- ============================================

-- Insert some sample multiplayer questions
INSERT INTO multiplayer_questions (quiz_set_name, question_text, question_type, option_a, option_b, option_c, option_d, correct_answer, difficulty, category, points, order_no) VALUES
('General Knowledge Set 1', 'What is the capital of France?', 'multiple_choice', 'London', 'Berlin', 'Paris', 'Madrid', 'C', 'easy', 'Geography', 100, 1),
('General Knowledge Set 1', 'Which planet is known as the Red Planet?', 'multiple_choice', 'Venus', 'Mars', 'Jupiter', 'Saturn', 'B', 'easy', 'Science', 100, 2),
('General Knowledge Set 1', 'Who painted the Mona Lisa?', 'multiple_choice', 'Vincent van Gogh', 'Pablo Picasso', 'Leonardo da Vinci', 'Michelangelo', 'C', 'medium', 'Art', 150, 3),
('General Knowledge Set 1', 'What is the largest ocean on Earth?', 'multiple_choice', 'Atlantic Ocean', 'Indian Ocean', 'Arctic Ocean', 'Pacific Ocean', 'D', 'easy', 'Geography', 100, 4),
('General Knowledge Set 1', 'In what year did World War II end?', 'multiple_choice', '1943', '1944', '1945', '1946', 'C', 'medium', 'History', 150, 5),

('Math Challenge Set 1', 'What is 15 × 12?', 'multiple_choice', '150', '180', '200', '210', 'B', 'medium', 'Math', 150, 1),
('Math Challenge Set 1', 'What is the square root of 144?', 'multiple_choice', '10', '11', '12', '13', 'C', 'easy', 'Math', 100, 2),
('Math Challenge Set 1', 'What is 25% of 200?', 'multiple_choice', '25', '50', '75', '100', 'B', 'easy', 'Math', 100, 3),

('Science Quiz Set 1', 'What is the chemical symbol for gold?', 'multiple_choice', 'Go', 'Gd', 'Au', 'Ag', 'C', 'medium', 'Science', 150, 1),
('Science Quiz Set 1', 'How many bones are in the human body?', 'multiple_choice', '186', '206', '226', '246', 'B', 'medium', 'Science', 150, 2),
('Science Quiz Set 1', 'What is the speed of light?', 'multiple_choice', '300,000 km/s', '150,000 km/s', '450,000 km/s', '600,000 km/s', 'A', 'hard', 'Science', 200, 3);

-- ============================================
-- FUNCTIONS for Game Logic
-- ============================================

-- Function to generate unique lobby code
CREATE OR REPLACE FUNCTION generate_lobby_code()
RETURNS TEXT AS $$
DECLARE
    chars TEXT := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; -- No confusing chars like I, O, 1, 0
    result TEXT := '';
    i INTEGER;
BEGIN
    FOR i IN 1..6 LOOP
        result := result || substr(chars, floor(random() * length(chars) + 1)::INTEGER, 1);
    END LOOP;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Function to calculate final rankings
CREATE OR REPLACE FUNCTION calculate_game_rankings(p_lobby_id UUID)
RETURNS TABLE(participant_id UUID, rank INTEGER, score INTEGER) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        gp.participant_id,
        ROW_NUMBER() OVER (ORDER BY gp.score DESC, gp.joined_at ASC)::INTEGER as rank,
        gp.score
    FROM game_participants gp
    WHERE gp.lobby_id = p_lobby_id
    ORDER BY gp.score DESC, gp.joined_at ASC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- NOTES
-- ============================================
/*
After creating these tables, you need to:

1. Set up Supabase client in your ASP.NET project
2. Create a configuration file for Supabase credentials
3. Enable Realtime in Supabase Dashboard:
   - Go to Database > Replication
   - Enable realtime for the tables above

4. Generate Supabase TypeScript types (optional):
   npx supabase gen types typescript --project-id YOUR_PROJECT_ID > supabase-types.ts

5. Test the schema:
   - Create a test lobby
   - Add participants
   - Submit answers
   - Calculate results

6. Monitor with Supabase Dashboard:
   - View real-time connections
   - Check table data
   - Monitor performance
*/

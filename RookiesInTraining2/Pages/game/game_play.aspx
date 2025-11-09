<%@ Page Title="Game Play" Language="C#" MasterPageFile="~/MasterPages/GameMaster.Master" AutoEventWireup="true" CodeBehind="game_play.aspx.cs" Inherits="RookiesInTraining2.Pages.game.game_play" Async="true" EnableSessionState="True" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        body {
            overflow: hidden;
        }

        .game-container {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100vh;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex;
            padding: 2rem;
            gap: 2rem;
        }

        .main-game-area {
            flex: 1;
            display: flex;
            flex-direction: column;
            gap: 1.5rem;
        }

        .game-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            color: white;
        }

        .question-progress {
            font-size: 1.2rem;
            font-weight: 600;
        }

        .timer-display {
            font-size: 2.5rem;
            font-weight: 700;
            padding: 1rem 2rem;
            background: rgba(255,255,255,0.2);
            border-radius: 15px;
            min-width: 120px;
            text-align: center;
        }

        .timer-display.warning {
            background: #ff6b6b;
            animation: pulse-timer 0.5s infinite;
        }

        @keyframes pulse-timer {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.1); }
        }

        .question-card {
            background: white;
            border-radius: 20px;
            padding: 3rem;
            flex: 1;
            display: flex;
            flex-direction: column;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        }

        .question-text {
            font-size: 2rem;
            font-weight: 700;
            color: #333;
            margin-bottom: 2rem;
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            text-align: center;
        }

        .answers-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1.5rem;
        }

        .answer-button {
            padding: 2rem;
            border: 3px solid #e0e0e0;
            background: #f8f9fa;
            border-radius: 15px;
            font-size: 1.3rem;
            font-weight: 600;
            color: #333;
            cursor: pointer;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            gap: 1rem;
        }

        .answer-button:hover:not(.selected):not(.correct):not(.wrong):not(:disabled) {
            border-color: #667eea;
            background: #f3f4ff;
            transform: translateY(-5px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.3);
        }

        .answer-button.selected {
            border-color: #667eea;
            background: #667eea;
            color: white;
        }

        .answer-button.correct {
            border-color: #28a745;
            background: #28a745;
            color: white;
        }

        .answer-button.wrong {
            border-color: #dc3545;
            background: #dc3545;
            color: white;
        }

        .answer-button:disabled {
            cursor: not-allowed;
            opacity: 0.7;
        }

        .answer-letter {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            background: white;
            color: #667eea;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            font-weight: 700;
            flex-shrink: 0;
        }

        .answer-button.selected .answer-letter,
        .answer-button.correct .answer-letter {
            background: rgba(255,255,255,0.3);
            color: white;
        }

        .answer-button.wrong .answer-letter {
            background: rgba(255,255,255,0.3);
            color: white;
        }

        .leaderboard-sidebar {
            width: 350px;
            background: white;
            border-radius: 20px;
            padding: 2rem;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            overflow-y: auto;
        }

        .leaderboard-title {
            font-size: 1.5rem;
            font-weight: 700;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            color: #333;
        }

        .leaderboard-list {
            display: flex;
            flex-direction: column;
            gap: 0.8rem;
        }

        .leaderboard-item {
            display: flex;
            align-items: center;
            gap: 1rem;
            padding: 1rem;
            background: #f8f9fa;
            border-radius: 12px;
            transition: all 0.3s;
        }

        .leaderboard-item.me {
            background: #e3f2fd;
            border: 2px solid #2196f3;
        }

        .rank-badge {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 1.1rem;
            flex-shrink: 0;
        }

        .rank-1 {
            background: linear-gradient(135deg, #ffd700, #ffed4e);
            color: #333;
        }

        .rank-2 {
            background: linear-gradient(135deg, #c0c0c0, #e8e8e8);
            color: #333;
        }

        .rank-3 {
            background: linear-gradient(135deg, #cd7f32, #daa520);
            color: white;
        }

        .rank-other {
            background: #e0e0e0;
            color: #666;
        }

        .player-name {
            flex: 1;
            font-weight: 600;
            color: #333;
        }

        .player-score {
            font-weight: 700;
            font-size: 1.1rem;
            color: #667eea;
        }

        .waiting-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.9);
            display: none;
            align-items: center;
            justify-content: center;
            z-index: 9999;
            color: white;
            text-align: center;
        }

        .waiting-overlay.show {
            display: flex;
        }

        .waiting-content {
            animation: fadeIn 0.5s;
        }

        .waiting-content h2 {
            font-size: 3rem;
            margin-bottom: 1rem;
        }

        .waiting-content p {
            font-size: 1.5rem;
            opacity: 0.8;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .answer-feedback {
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background: white;
            padding: 3rem;
            border-radius: 20px;
            box-shadow: 0 10px 50px rgba(0,0,0,0.3);
            display: none;
            z-index: 9998;
            text-align: center;
            min-width: 400px;
        }

        .answer-feedback.show {
            display: block;
            animation: scaleIn 0.3s;
        }

        @keyframes scaleIn {
            from { transform: translate(-50%, -50%) scale(0.8); }
            to { transform: translate(-50%, -50%) scale(1); }
        }

        .feedback-icon {
            font-size: 5rem;
            margin-bottom: 1rem;
        }

        .feedback-correct {
            color: #28a745;
        }

        .feedback-wrong {
            color: #dc3545;
        }

        .feedback-title {
            font-size: 2rem;
            font-weight: 700;
            margin-bottom: 1rem;
        }

        .feedback-points {
            font-size: 1.5rem;
            color: #667eea;
            font-weight: 600;
        }

        .loading-spinner {
            border: 4px solid rgba(255,255,255,0.3);
            border-radius: 50%;
            border-top: 4px solid white;
            width: 60px;
            height: 60px;
            animation: spin 1s linear infinite;
            margin: 2rem auto;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="game-container">
        <!-- Main Game Area -->
        <div class="main-game-area">
            <!-- Header -->
            <div class="game-header">
                <div class="question-progress">
                    Question <span id="currentQuestion">1</span> of <span id="totalQuestions">10</span>
                </div>
                <div class="timer-display" id="timer">30</div>
            </div>

            <!-- Question Card -->
            <div class="question-card">
                <div class="question-text" id="questionText">
                    Loading question...
                </div>

                <div class="answers-grid" id="answersGrid">
                    <!-- Answers will be loaded here -->
                </div>
            </div>
        </div>

        <!-- Leaderboard Sidebar -->
        <div class="leaderboard-sidebar">
            <div class="leaderboard-title">
                <i class="fas fa-trophy"></i>
                Live Rankings
            </div>
            <div class="leaderboard-list" id="leaderboardList">
                <!-- Leaderboard will be updated here -->
            </div>
        </div>
    </div>

    <!-- Waiting Overlay -->
    <div id="waitingOverlay" class="waiting-overlay show">
        <div class="waiting-content">
            <div class="loading-spinner"></div>
            <h2>Loading Game...</h2>
            <p>Preparing questions</p>
        </div>
    </div>

    <!-- Answer Feedback -->
    <div id="answerFeedback" class="answer-feedback">
        <div class="feedback-icon" id="feedbackIcon">✓</div>
        <div class="feedback-title" id="feedbackTitle">Correct!</div>
        <div class="feedback-points" id="feedbackPoints">+100 points</div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
    <script>
        // Initialize Supabase
        const SUPABASE_URL = '<%= GetSupabaseUrl() %>';
        const SUPABASE_KEY = '<%= GetSupabaseKey() %>';
        const supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_KEY);

        // Current user
        const currentUser = {
            userSlug: '<%= GetUserSlug() %>',
            userName: '<%= GetUserName() %>'
        };

        // Get lobby ID from URL
        const urlParams = new URLSearchParams(window.location.search);
        const lobbyId = urlParams.get('lobby');

        // Game state
        let lobby = null;
        let questions = [];
        let currentQuestionIndex = 0;
        let timerInterval = null;
        let timeRemaining = 30;
        let hasAnswered = false;
        let gameSession = null;
        let myParticipant = null;

        console.log('[GamePlay] Initializing game for lobby:', lobbyId);

        // Initialize game
        document.addEventListener('DOMContentLoaded', function() {
            if (!currentUser.userSlug) {
                alert('Please login');
                window.location.href = '/Pages/Login.aspx';
                return;
            }

            if (!lobbyId) {
                alert('Invalid game session');
                window.location.href = 'game_dashboard.aspx';
                return;
            }

            initializeGame();
        });

        // Initialize game
        async function initializeGame() {
            try {
                // Load lobby
                const { data: lobbyData, error: lobbyError } = await supabase
                    .from('game_lobbies')
                    .select('*')
                    .eq('lobby_id', lobbyId)
                    .single();

                if (lobbyError) throw lobbyError;
                lobby = lobbyData;

                console.log('[GamePlay] Lobby loaded:', lobby);

                // Load questions
                await loadQuestions();

                // Get my participant record
                const { data: participant } = await supabase
                    .from('game_participants')
                    .select('*')
                    .eq('lobby_id', lobbyId)
                    .eq('user_slug', currentUser.userSlug)
                    .single();

                myParticipant = participant;

                // Create or get game session
                await createGameSession();

                // Setup realtime
                setupRealtimeSubscriptions();

                // Start first question
                setTimeout(() => {
                    showQuestion(0);
                }, 1000);

            } catch (error) {
                console.error('[GamePlay] Error initializing game:', error);
                alert('Failed to load game: ' + error.message);
                window.location.href = 'game_dashboard.aspx';
            }
        }

        // Load questions
        async function loadQuestions() {
            try {
                if (lobby.quiz_source === 'multiplayer') {
                    // Load from multiplayer questions
                    const { data, error } = await supabase
                        .from('multiplayer_questions')
                        .select('*')
                        .eq('quiz_set_name', lobby.quiz_id)
                        .eq('is_active', true)
                        .order('order_no');

                    if (error) throw error;
                    questions = data;
                } else {
                    // Load from class quiz (local database)
                    const response = await fetch(`/api/GetQuizQuestions.ashx?quizSlug=${lobby.quiz_id}`);
                    questions = await response.json();
                }

                document.getElementById('totalQuestions').textContent = questions.length;
                console.log('[GamePlay] Loaded questions:', questions.length);
            } catch (error) {
                console.error('[GamePlay] Error loading questions:', error);
                throw error;
            }
        }

        // Create game session
        async function createGameSession() {
            try {
                // Check if session exists
                const { data: existing } = await supabase
                    .from('game_sessions')
                    .select('*')
                    .eq('lobby_id', lobbyId)
                    .single();

                if (existing) {
                    gameSession = existing;
                } else {
                    // Create new session
                    const { data, error } = await supabase
                        .from('game_sessions')
                        .insert({
                            lobby_id: lobbyId,
                            current_question_index: 0,
                            total_questions: questions.length,
                            status: 'active'
                        })
                        .select()
                        .single();

                    if (error) throw error;
                    gameSession = data;
                }

                console.log('[GamePlay] Game session:', gameSession);
            } catch (error) {
                console.error('[GamePlay] Error creating session:', error);
            }
        }

        // Show question
        function showQuestion(index) {
            if (index >= questions.length) {
                endGame();
                return;
            }

            currentQuestionIndex = index;
            hasAnswered = false;

            const question = questions[index];
            
            // Update UI
            document.getElementById('currentQuestion').textContent = index + 1;
            document.getElementById('questionText').textContent = question.question_text || question.body_text;

            // Render answers
            const answersGrid = document.getElementById('answersGrid');
            const answers = [
                { letter: 'A', text: question.option_a },
                { letter: 'B', text: question.option_b },
                { letter: 'C', text: question.option_c },
                { letter: 'D', text: question.option_d }
            ].filter(a => a.text);

            answersGrid.innerHTML = answers.map(answer => `
                <button class="answer-button" onclick="selectAnswer('${answer.letter}')">
                    <div class="answer-letter">${answer.letter}</div>
                    <div>${answer.text}</div>
                </button>
            `).join('');

            // Hide overlay
            document.getElementById('waitingOverlay').classList.remove('show');

            // Start timer
            startTimer();

            // Load leaderboard
            loadLeaderboard();
        }

        // Start timer
        function startTimer() {
            timeRemaining = lobby.time_per_question;
            const timerEl = document.getElementById('timer');
            timerEl.textContent = timeRemaining;
            timerEl.classList.remove('warning');

            if (timerInterval) clearInterval(timerInterval);

            timerInterval = setInterval(() => {
                timeRemaining--;
                timerEl.textContent = timeRemaining;

                if (timeRemaining <= 5) {
                    timerEl.classList.add('warning');
                }

                if (timeRemaining <= 0) {
                    clearInterval(timerInterval);
                    if (!hasAnswered) {
                        submitAnswer(null); // No answer
                    }
                }
            }, 1000);
        }

        // Select answer
        function selectAnswer(letter) {
            if (hasAnswered) return;

            // Visual feedback
            document.querySelectorAll('.answer-button').forEach(btn => {
                btn.classList.remove('selected');
            });
            event.target.closest('.answer-button').classList.add('selected');

            // Submit answer
            submitAnswer(letter);
        }

        // Submit answer
        async function submitAnswer(selectedAnswer) {
            if (hasAnswered) return;
            hasAnswered = true;

            clearInterval(timerInterval);

            const question = questions[currentQuestionIndex];
            const correctAnswer = question.correct_answer;
            const isCorrect = selectedAnswer === correctAnswer;
            const timeTaken = lobby.time_per_question - timeRemaining;

            // Calculate points
            let points = 0;
            if (isCorrect) {
                const basePoints = question.points || 100;
                // Bonus for speed
                const speedBonus = Math.floor((timeRemaining / lobby.time_per_question) * 50);
                points = basePoints + speedBonus;
            }

            console.log('[GamePlay] Answer submitted:', { selectedAnswer, correctAnswer, isCorrect, points });

            try {
                // Save answer
                await supabase
                    .from('game_answers')
                    .insert({
                        session_id: gameSession.session_id,
                        lobby_id: lobbyId,
                        participant_id: myParticipant.participant_id,
                        question_id: question.question_id || question.question_slug,
                        question_index: currentQuestionIndex,
                        selected_answer: selectedAnswer,
                        is_correct: isCorrect,
                        points_earned: points,
                        time_taken: timeTaken
                    });

                // Update participant score
                await supabase
                    .from('game_participants')
                    .update({
                        score: myParticipant.score + points
                    })
                    .eq('participant_id', myParticipant.participant_id);

                myParticipant.score += points;

                // Show feedback
                showAnswerFeedback(isCorrect, points, correctAnswer);

                // Highlight correct/wrong answers
                highlightAnswers(selectedAnswer, correctAnswer);

                // Wait then next question
                setTimeout(() => {
                    showQuestion(currentQuestionIndex + 1);
                }, 3000);

            } catch (error) {
                console.error('[GamePlay] Error submitting answer:', error);
            }
        }

        // Show answer feedback
        function showAnswerFeedback(isCorrect, points, correctAnswer) {
            const feedback = document.getElementById('answerFeedback');
            const icon = document.getElementById('feedbackIcon');
            const title = document.getElementById('feedbackTitle');
            const pointsEl = document.getElementById('feedbackPoints');

            if (isCorrect) {
                icon.textContent = '✓';
                icon.className = 'feedback-icon feedback-correct';
                title.textContent = 'Correct!';
                pointsEl.textContent = `+${points} points`;
            } else {
                icon.textContent = '✗';
                icon.className = 'feedback-icon feedback-wrong';
                title.textContent = 'Wrong!';
                pointsEl.textContent = `Correct answer: ${correctAnswer}`;
            }

            feedback.classList.add('show');
            setTimeout(() => {
                feedback.classList.remove('show');
            }, 2500);
        }

        // Highlight answers
        function highlightAnswers(selected, correct) {
            document.querySelectorAll('.answer-button').forEach(btn => {
                const letter = btn.querySelector('.answer-letter').textContent;
                btn.disabled = true;

                if (letter === correct) {
                    btn.classList.add('correct');
                } else if (letter === selected) {
                    btn.classList.add('wrong');
                }
            });
        }

        // Load leaderboard
        async function loadLeaderboard() {
            try {
                const { data, error } = await supabase
                    .from('game_participants')
                    .select('*')
                    .eq('lobby_id', lobbyId)
                    .order('score', { ascending: false });

                if (error) throw error;

                renderLeaderboard(data);
            } catch (error) {
                console.error('[GamePlay] Error loading leaderboard:', error);
            }
        }

        // Render leaderboard
        function renderLeaderboard(participants) {
            const list = document.getElementById('leaderboardList');
            
            list.innerHTML = participants.map((p, index) => {
                const rank = index + 1;
                const rankClass = rank === 1 ? 'rank-1' : rank === 2 ? 'rank-2' : rank === 3 ? 'rank-3' : 'rank-other';
                const isMe = p.user_slug === currentUser.userSlug;

                return `
                    <div class="leaderboard-item ${isMe ? 'me' : ''}">
                        <div class="rank-badge ${rankClass}">${rank}</div>
                        <div class="player-name">${p.user_name}</div>
                        <div class="player-score">${p.score}</div>
                    </div>
                `;
            }).join('');
        }

        // End game
        async function endGame() {
            console.log('[GamePlay] Game ended');

            // Update lobby status
            await supabase
                .from('game_lobbies')
                .update({
                    status: 'completed',
                    ended_at: new Date().toISOString()
                })
                .eq('lobby_id', lobbyId);

            // Calculate final results
            await calculateResults();

            // Redirect to results
            window.location.href = `game_results.aspx?lobby=${lobbyId}`;
        }

        // Calculate results
        async function calculateResults() {
            try {
                const { data: participants } = await supabase
                    .from('game_participants')
                    .select('*')
                    .eq('lobby_id', lobbyId)
                    .order('score', { ascending: false });

                // Save results for each participant
                for (let i = 0; i < participants.length; i++) {
                    const p = participants[i];
                    
                    // Get their answers
                    const { data: answers } = await supabase
                        .from('game_answers')
                        .select('*')
                        .eq('participant_id', p.participant_id);

                    const correctCount = answers.filter(a => a.is_correct).length;
                    const wrongCount = answers.length - correctCount;
                    const accuracy = (correctCount / answers.length) * 100;
                    const avgTime = answers.reduce((sum, a) => sum + a.time_taken, 0) / answers.length;

                    await supabase
                        .from('game_results')
                        .insert({
                            lobby_id: lobbyId,
                            participant_id: p.participant_id,
                            user_slug: p.user_slug,
                            user_name: p.user_name,
                            total_score: p.score,
                            correct_answers: correctCount,
                            wrong_answers: wrongCount,
                            total_questions: questions.length,
                            accuracy: accuracy,
                            avg_time_per_question: avgTime,
                            final_rank: i + 1,
                            is_winner: i === 0
                        });
                }
            } catch (error) {
                console.error('[GamePlay] Error calculating results:', error);
            }
        }

        // Setup realtime subscriptions
        function setupRealtimeSubscriptions() {
            // Listen for score updates
            supabase
                .channel('scores')
                .on('postgres_changes', {
                    event: 'UPDATE',
                    schema: 'public',
                    table: 'game_participants',
                    filter: `lobby_id=eq.${lobbyId}`
                }, payload => {
                    console.log('[GamePlay] Score update:', payload);
                    loadLeaderboard();
                })
                .subscribe();
        }
    </script>
</asp:Content>


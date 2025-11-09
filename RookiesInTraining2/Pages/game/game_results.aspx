<%@ Page Title="Game Results" Language="C#" MasterPageFile="~/MasterPages/GameMaster.Master" AutoEventWireup="true" CodeBehind="game_results.aspx.cs" Inherits="RookiesInTraining2.Pages.game.game_results" Async="true" EnableSessionState="True" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .results-container {
            min-height: 100vh;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 2rem;
        }

        .results-content {
            max-width: 1200px;
            margin: 0 auto;
        }

        .winner-section {
            text-align: center;
            color: white;
            margin-bottom: 3rem;
            animation: fadeIn 0.8s;
        }

        .trophy-icon {
            font-size: 8rem;
            animation: bounce 1s infinite;
            margin-bottom: 1rem;
        }

        @keyframes bounce {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-20px); }
        }

        .winner-title {
            font-size: 3rem;
            font-weight: 700;
            margin-bottom: 0.5rem;
        }

        .winner-name {
            font-size: 2rem;
            opacity: 0.9;
            margin-bottom: 1rem;
        }

        .winner-score {
            font-size: 4rem;
            font-weight: 700;
            background: rgba(255,255,255,0.2);
            padding: 1rem 2rem;
            border-radius: 20px;
            display: inline-block;
        }

        .results-grid {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 2rem;
            margin-bottom: 2rem;
        }

        .leaderboard-card {
            background: white;
            border-radius: 20px;
            padding: 2rem;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        }

        .card-title {
            font-size: 1.8rem;
            font-weight: 700;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            color: #333;
        }

        .result-item {
            display: flex;
            align-items: center;
            padding: 1.5rem;
            background: #f8f9fa;
            border-radius: 15px;
            margin-bottom: 1rem;
            transition: all 0.3s;
        }

        .result-item:hover {
            transform: translateX(10px);
            box-shadow: 0 4px 10px rgba(0,0,0,0.1);
        }

        .result-item.first {
            background: linear-gradient(135deg, #ffd700, #ffed4e);
            transform: scale(1.05);
        }

        .result-item.second {
            background: linear-gradient(135deg, #c0c0c0, #e8e8e8);
        }

        .result-item.third {
            background: linear-gradient(135deg, #cd7f32, #daa520);
            color: white;
        }

        .result-item.me {
            border: 3px solid #2196f3;
        }

        .rank-number {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            background: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.8rem;
            font-weight: 700;
            margin-right: 1.5rem;
            flex-shrink: 0;
        }

        .result-item.first .rank-number {
            color: #ffd700;
        }

        .result-item.second .rank-number {
            color: #c0c0c0;
        }

        .result-item.third .rank-number {
            color: #cd7f32;
        }

        .player-details {
            flex: 1;
        }

        .player-name-result {
            font-size: 1.3rem;
            font-weight: 700;
            color: #333;
            margin-bottom: 0.3rem;
        }

        .result-item.third .player-name-result {
            color: white;
        }

        .player-stats {
            font-size: 0.9rem;
            color: #666;
            display: flex;
            gap: 1rem;
        }

        .result-item.third .player-stats {
            color: rgba(255,255,255,0.9);
        }

        .final-score {
            font-size: 2rem;
            font-weight: 700;
            color: #667eea;
        }

        .result-item.first .final-score,
        .result-item.second .final-score,
        .result-item.third .final-score {
            color: inherit;
        }

        .my-stats-card {
            background: white;
            border-radius: 20px;
            padding: 2rem;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        }

        .stat-box {
            background: #f8f9fa;
            border-radius: 12px;
            padding: 1.5rem;
            text-align: center;
            margin-bottom: 1rem;
        }

        .stat-value {
            font-size: 2.5rem;
            font-weight: 700;
            color: #667eea;
            margin-bottom: 0.3rem;
        }

        .stat-label {
            font-size: 0.9rem;
            color: #666;
            text-transform: uppercase;
        }

        .accuracy-circle {
            width: 150px;
            height: 150px;
            border-radius: 50%;
            background: conic-gradient(#667eea 0deg, #667eea var(--accuracy), #e0e0e0 var(--accuracy), #e0e0e0 360deg);
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 1rem auto;
            position: relative;
        }

        .accuracy-inner {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            background: white;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-direction: column;
        }

        .accuracy-percent {
            font-size: 2rem;
            font-weight: 700;
            color: #667eea;
        }

        .action-buttons {
            display: flex;
            gap: 1rem;
            margin-top: 2rem;
        }

        .btn-action {
            flex: 1;
            padding: 1rem;
            border: none;
            border-radius: 12px;
            font-size: 1.1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
        }

        .btn-primary {
            background: #667eea;
            color: white;
        }

        .btn-primary:hover {
            background: #5568d3;
            transform: translateY(-2px);
        }

        .btn-secondary {
            background: white;
            color: #667eea;
            border: 2px solid #667eea;
        }

        .btn-secondary:hover {
            background: #f3f4ff;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(30px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .confetti {
            position: fixed;
            width: 10px;
            height: 10px;
            background: #ffd700;
            position: absolute;
            animation: fall 3s linear infinite;
        }

        @keyframes fall {
            to { transform: translateY(100vh) rotate(360deg); }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="results-container">
        <div class="results-content">
            <!-- Winner Section -->
            <div class="winner-section" id="winnerSection">
                <div class="trophy-icon">🏆</div>
                <div class="winner-title">Winner!</div>
                <div class="winner-name" id="winnerName">Loading...</div>
                <div class="winner-score" id="winnerScore">0 pts</div>
            </div>

            <!-- Results Grid -->
            <div class="results-grid">
                <!-- Final Leaderboard -->
                <div class="leaderboard-card">
                    <div class="card-title">
                        <i class="fas fa-trophy"></i>
                        Final Rankings
                    </div>
                    <div id="finalLeaderboard">
                        <!-- Results will be loaded here -->
                    </div>
                </div>

                <!-- My Stats -->
                <div class="my-stats-card">
                    <div class="card-title">
                        <i class="fas fa-chart-bar"></i>
                        Your Performance
                    </div>

                    <div class="stat-box">
                        <div class="stat-value" id="myRank">-</div>
                        <div class="stat-label">Your Rank</div>
                    </div>

                    <div class="stat-box">
                        <div class="stat-value" id="myScore">0</div>
                        <div class="stat-label">Total Score</div>
                    </div>

                    <div class="accuracy-circle" id="accuracyCircle">
                        <div class="accuracy-inner">
                            <div class="accuracy-percent" id="accuracyPercent">0%</div>
                            <div class="stat-label">Accuracy</div>
                        </div>
                    </div>

                    <div class="stat-box">
                        <div class="stat-value" id="correctAnswers">0</div>
                        <div class="stat-label">Correct Answers</div>
                    </div>

                    <div class="stat-box">
                        <div class="stat-value" id="avgTime">0s</div>
                        <div class="stat-label">Avg Time / Question</div>
                    </div>
                </div>
            </div>

            <!-- Action Buttons -->
            <div class="action-buttons">
                <button class="btn-action btn-secondary" onclick="window.location.href='game_dashboard.aspx'">
                    <i class="fas fa-home"></i> Back to Dashboard
                </button>
                <button class="btn-action btn-primary" onclick="shareResults()">
                    <i class="fas fa-share"></i> Share Results
                </button>
            </div>
        </div>
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

        let myResult = null;
        let allResults = [];

        console.log('[GameResults] Loading results for lobby:', lobbyId);

        // Load results on page load
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

            loadResults();
            createConfetti();
        });

        // Load results
        async function loadResults() {
            try {
                const { data, error } = await supabase
                    .from('game_results')
                    .select('*')
                    .eq('lobby_id', lobbyId)
                    .order('final_rank');

                if (error) throw error;

                allResults = data;
                console.log('[GameResults] Results loaded:', data);

                // Find winner and my result
                const winner = data.find(r => r.is_winner);
                myResult = data.find(r => r.user_slug === currentUser.userSlug);

                // Update UI
                if (winner) {
                    document.getElementById('winnerName').textContent = winner.user_name;
                    document.getElementById('winnerScore').textContent = winner.total_score + ' pts';
                }

                if (myResult) {
                    updateMyStats(myResult);
                }

                renderLeaderboard(data);

            } catch (error) {
                console.error('[GameResults] Error loading results:', error);
                alert('Failed to load results: ' + error.message);
            }
        }

        // Render leaderboard
        function renderLeaderboard(results) {
            const container = document.getElementById('finalLeaderboard');
            
            container.innerHTML = results.map(result => {
                const rankClass = result.final_rank === 1 ? 'first' : 
                                 result.final_rank === 2 ? 'second' : 
                                 result.final_rank === 3 ? 'third' : '';
                const isMe = result.user_slug === currentUser.userSlug;

                return `
                    <div class="result-item ${rankClass} ${isMe ? 'me' : ''}">
                        <div class="rank-number">${result.final_rank}</div>
                        <div class="player-details">
                            <div class="player-name-result">
                                ${result.user_name}
                                ${isMe ? '<span style="color: #2196f3; margin-left: 0.5rem;">(You)</span>' : ''}
                            </div>
                            <div class="player-stats">
                                <span>✓ ${result.correct_answers}/${result.total_questions}</span>
                                <span>📊 ${result.accuracy.toFixed(1)}%</span>
                                <span>⏱️ ${result.avg_time_per_question.toFixed(1)}s</span>
                            </div>
                        </div>
                        <div class="final-score">${result.total_score}</div>
                    </div>
                `;
            }).join('');
        }

        // Update my stats
        function updateMyStats(result) {
            document.getElementById('myRank').textContent = '#' + result.final_rank;
            document.getElementById('myScore').textContent = result.total_score;
            document.getElementById('accuracyPercent').textContent = result.accuracy.toFixed(1) + '%';
            document.getElementById('correctAnswers').textContent = `${result.correct_answers}/${result.total_questions}`;
            document.getElementById('avgTime').textContent = result.avg_time_per_question.toFixed(1) + 's';

            // Update accuracy circle
            const accuracyDeg = (result.accuracy / 100) * 360;
            document.getElementById('accuracyCircle').style.setProperty('--accuracy', accuracyDeg + 'deg');
        }

        // Create confetti animation
        function createConfetti() {
            const colors = ['#ffd700', '#ff6b6b', '#4ecdc4', '#45b7d1', '#f9ca24'];
            
            for (let i = 0; i < 50; i++) {
                setTimeout(() => {
                    const confetti = document.createElement('div');
                    confetti.className = 'confetti';
                    confetti.style.left = Math.random() * 100 + '%';
                    confetti.style.background = colors[Math.floor(Math.random() * colors.length)];
                    confetti.style.animationDelay = Math.random() * 3 + 's';
                    confetti.style.animationDuration = (Math.random() * 2 + 3) + 's';
                    document.body.appendChild(confetti);

                    setTimeout(() => confetti.remove(), 6000);
                }, i * 100);
            }
        }

        // Share results
        function shareResults() {
            if (!myResult) return;

            const text = `I scored ${myResult.total_score} points and ranked #${myResult.final_rank} in the quiz game! 🎮🏆`;
            
            if (navigator.share) {
                navigator.share({
                    title: 'Quiz Game Results',
                    text: text
                }).catch(err => console.log('Share canceled'));
            } else {
                // Fallback: copy to clipboard
                navigator.clipboard.writeText(text);
                alert('Results copied to clipboard!');
            }
        }
    </script>
</asp:Content>


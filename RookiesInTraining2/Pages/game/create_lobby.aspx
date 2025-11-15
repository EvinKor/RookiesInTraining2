<%@ Page Title="Create Lobby" Language="C#" MasterPageFile="~/MasterPages/GameMaster.Master" AutoEventWireup="true" CodeBehind="create_lobby.aspx.cs" Inherits="RookiesInTraining2.Pages.game.create_lobby" Async="true" EnableSessionState="True" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .create-lobby-container {
            max-width: 800px;
            margin: 2rem auto;
            padding: 2rem;
        }

        .page-header {
            text-align: center;
            margin-bottom: 2rem;
        }

        .page-header h1 {
            font-size: 2.5rem;
            font-weight: 700;
            color: #333;
            margin-bottom: 0.5rem;
        }

        .page-header p {
            color: #666;
            font-size: 1.1rem;
        }

        .create-form {
            background: white;
            padding: 2rem;
            border-radius: 20px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }

        .form-section {
            margin-bottom: 2rem;
        }

        .section-title {
            font-size: 1.3rem;
            font-weight: 700;
            color: #333;
            margin-bottom: 1rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .form-group {
            margin-bottom: 1.5rem;
        }

        .form-label {
            display: block;
            font-weight: 600;
            color: #555;
            margin-bottom: 0.5rem;
        }

        .form-input,
        .form-select {
            width: 100%;
            padding: 0.8rem 1rem;
            border: 2px solid #e0e0e0;
            border-radius: 10px;
            font-size: 1rem;
            transition: all 0.3s;
        }

        .form-input:focus,
        .form-select:focus {
            border-color: #667eea;
            outline: none;
        }

        .form-description {
            font-size: 0.9rem;
            color: #999;
            margin-top: 0.3rem;
        }

        .form-description i {
            color: #667eea;
            margin-right: 0.5rem;
            width: 16px;
        }

        .quiz-source-options {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem;
            margin-bottom: 1rem;
        }

        .quiz-option {
            padding: 1.5rem;
            border: 2px solid #e0e0e0;
            border-radius: 12px;
            cursor: pointer;
            transition: all 0.3s;
            text-align: center;
        }

        .quiz-option:hover {
            border-color: #667eea;
        }

        .quiz-option.selected {
            border-color: #667eea;
            background: #f3f4ff;
        }

        .quiz-option i {
            font-size: 2rem;
            color: #667eea;
            margin-bottom: 0.5rem;
        }

        .quiz-option .option-title {
            font-weight: 700;
            color: #333;
            margin-bottom: 0.3rem;
        }

        .quiz-option .option-desc {
            font-size: 0.85rem;
            color: #666;
        }

        .game-mode-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
        }

        .mode-card {
            padding: 1rem;
            border: 2px solid #e0e0e0;
            border-radius: 10px;
            cursor: pointer;
            transition: all 0.3s;
            text-align: center;
        }

        .mode-card:hover {
            border-color: #667eea;
        }

        .mode-card.selected {
            border-color: #667eea;
            background: #f3f4ff;
        }

        .mode-icon {
            font-size: 2rem;
            margin-bottom: 0.5rem;
            color: #667eea;
        }

        .page-header h1 i {
            margin-right: 0.5rem;
            color: #667eea;
        }

        .mode-name {
            font-weight: 700;
            color: #333;
        }

        .btn-create {
            width: 100%;
            padding: 1rem;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 12px;
            font-size: 1.2rem;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s;
        }

        .btn-create:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(102, 126, 234, 0.4);
        }

        .btn-create:disabled {
            opacity: 0.6;
            cursor: not-allowed;
        }

        .hidden {
            display: none;
        }

        .class-select-container {
            margin-top: 1rem;
        }

        .btn-back {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            color: #667eea;
            text-decoration: none;
            font-weight: 600;
            padding: 0.75rem 1.5rem;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            transition: all 0.3s;
            margin-bottom: 2rem;
        }

        .btn-back:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.15);
            background: #f8f9fa;
        }

        .mb-4 {
            margin-bottom: 1.5rem;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="create-lobby-container">
        <!-- Back Button -->
        <div class="mb-4">
            <a href="<%= ResolveUrl("~/Pages/game/game_dashboard.aspx") %>" class="btn-back">
                <i class="fas fa-arrow-left"></i>
                Back to Game Dashboard
            </a>
        </div>

        <div class="page-header">
            <h1><i class="fas fa-gamepad"></i> Create Game Lobby</h1>
            <p>Set up your multiplayer quiz battle</p>
        </div>

        <div class="create-form">
            <!-- Lobby Info Section -->
            <div class="form-section">
                <div class="section-title">
                    <i class="fas fa-info-circle"></i>
                    Lobby Information
                </div>

                <div class="form-group">
                    <label class="form-label">Lobby Name *</label>
                    <input type="text" id="lobbyName" class="form-input" placeholder="e.g., Friday Night Quiz Battle" maxlength="100" />
                    <div class="form-description">Give your lobby a catchy name</div>
                </div>

                <div class="form-group">
                    <label class="form-label">Max Players</label>
                    <select id="maxPlayers" class="form-select">
                        <option value="5">5 Players</option>
                        <option value="10" selected>10 Players</option>
                        <option value="15">15 Players</option>
                        <option value="20">20 Players</option>
                        <option value="30">30 Players</option>
                    </select>
                </div>
            </div>

            <!-- Quiz Selection Section -->
            <div class="form-section">
                <div class="section-title">
                    <i class="fas fa-question-circle"></i>
                    Quiz Source
                </div>

                <div class="quiz-source-options">
                    <div class="quiz-option selected" data-source="multiplayer" onclick="selectQuizSource('multiplayer')">
                        <i class="fas fa-gamepad"></i>
                        <div class="option-title">Multiplayer Quiz</div>
                        <div class="option-desc">Use pre-made quiz sets</div>
                    </div>
                    <div class="quiz-option" data-source="class_level" onclick="selectQuizSource('class_level')">
                        <i class="fas fa-graduation-cap"></i>
                        <div class="option-title">Class Quiz</div>
                        <div class="option-desc">Use quiz from your classes</div>
                    </div>
                </div>

                <!-- Multiplayer Quiz Selection -->
                <div id="multiplayerQuizSection" class="form-group">
                    <label class="form-label">Select Quiz Set</label>
                    <select id="multiplayerQuizSet" class="form-select">
                        <option value="">Loading quiz sets...</option>
                    </select>
                </div>

                <!-- Class Quiz Selection -->
                <div id="classQuizSection" class="form-group hidden">
                    <label class="form-label">Select Class</label>
                    <select id="classSelect" class="form-select" onchange="loadClassLevels()">
                        <option value="">Select a class...</option>
                    </select>
                    
                    <div id="levelSelectContainer" class="class-select-container hidden">
                        <label class="form-label">Select Level</label>
                        <select id="levelSelect" class="form-select">
                            <option value="">Select a level...</option>
                        </select>
                    </div>
                </div>
            </div>

            <!-- Game Settings Section -->
            <div class="form-section">
                <div class="section-title">
                    <i class="fas fa-cog"></i>
                    Game Settings
                </div>

                <div class="form-group">
                    <label class="form-label">Game Mode</label>
                    <div class="game-mode-grid">
                        <div class="mode-card selected" data-mode="fastest_finger" onclick="selectGameMode('fastest_finger')">
                            <div class="mode-icon"><i class="fas fa-bolt"></i></div>
                            <div class="mode-name">Fastest Finger</div>
                        </div>
                        <div class="mode-card" data-mode="all_answer" onclick="selectGameMode('all_answer')">
                            <div class="mode-icon"><i class="fas fa-clock"></i></div>
                            <div class="mode-name">All Answer</div>
                        </div>
                        <div class="mode-card" data-mode="survival" onclick="selectGameMode('survival')">
                            <div class="mode-icon"><i class="fas fa-skull"></i></div>
                            <div class="mode-name">Survival</div>
                        </div>
                    </div>
                    <div class="form-description">
                        <i class="fas fa-bolt"></i> <strong>Fastest Finger:</strong> First correct answer gets most points<br>
                        <i class="fas fa-clock"></i> <strong>All Answer:</strong> Everyone gets time to answer<br>
                        <i class="fas fa-skull"></i> <strong>Survival:</strong> Wrong answer = elimination
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">Time Per Question</label>
                    <select id="timePerQuestion" class="form-select">
                        <option value="15">15 seconds</option>
                        <option value="20">20 seconds</option>
                        <option value="30" selected>30 seconds</option>
                        <option value="45">45 seconds</option>
                        <option value="60">60 seconds</option>
                    </select>
                </div>
            </div>

            <!-- Create Button -->
            <button class="btn-create" onclick="createLobby()" id="createBtn">
                Create Lobby
            </button>
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
            userName: '<%= GetUserName() %>',
            userEmail: '<%= GetUserEmail() %>',
            userRole: '<%= GetUserRole() %>'
        };

        // Selected values
        let selectedQuizSource = 'multiplayer';
        let selectedGameMode = 'fastest_finger';

        // Load data on page load
        document.addEventListener('DOMContentLoaded', function() {
            if (!currentUser.userSlug) {
                alert('Please login to create a lobby');
                window.location.href = '/Pages/Login.aspx';
                return;
            }

            loadMultiplayerQuizSets();
            loadUserClasses();
        });

        // Quiz source selection
        function selectQuizSource(source) {
            selectedQuizSource = source;
            
            // Update UI
            document.querySelectorAll('.quiz-option').forEach(opt => {
                opt.classList.remove('selected');
            });
            document.querySelector(`[data-source="${source}"]`).classList.add('selected');

            // Toggle sections
            if (source === 'multiplayer') {
                document.getElementById('multiplayerQuizSection').classList.remove('hidden');
                document.getElementById('classQuizSection').classList.add('hidden');
            } else {
                document.getElementById('multiplayerQuizSection').classList.add('hidden');
                document.getElementById('classQuizSection').classList.remove('hidden');
            }
        }

        // Game mode selection
        function selectGameMode(mode) {
            selectedGameMode = mode;
            
            document.querySelectorAll('.mode-card').forEach(card => {
                card.classList.remove('selected');
            });
            document.querySelector(`[data-mode="${mode}"]`).classList.add('selected');
        }

        // Load multiplayer quiz sets from Supabase
        async function loadMultiplayerQuizSets() {
            try {
                const { data, error } = await supabase
                    .from('multiplayer_questions')
                    .select('quiz_set_name')
                    .eq('is_active', true);

                if (error) throw error;

                // Get unique quiz set names
                const quizSets = [...new Set(data.map(q => q.quiz_set_name))];
                
                const select = document.getElementById('multiplayerQuizSet');
                select.innerHTML = quizSets.map(name => 
                    `<option value="${name}">${name}</option>`
                ).join('');

                if (quizSets.length === 0) {
                    select.innerHTML = '<option value="">No quiz sets available</option>';
                }
            } catch (error) {
                console.error('[CreateLobby] Error loading quiz sets:', error);
            }
        }

        // Load user's classes from local database
        async function loadUserClasses() {
            try {
                const response = await fetch('/api/GetUserClasses.ashx?userSlug=' + currentUser.userSlug);
                const classes = await response.json();
                
                const select = document.getElementById('classSelect');
                select.innerHTML = '<option value="">Select a class...</option>' +
                    classes.map(c => `<option value="${c.class_slug}">${c.class_name}</option>`).join('');
            } catch (error) {
                console.error('[CreateLobby] Error loading classes:', error);
            }
        }

        // Load levels from selected class
        async function loadClassLevels() {
            const classSlug = document.getElementById('classSelect').value;
            const container = document.getElementById('levelSelectContainer');
            const select = document.getElementById('levelSelect');

            if (!classSlug) {
                container.classList.add('hidden');
                return;
            }

            try {
                console.log('[CreateLobby] Loading levels for class:', classSlug);
                const response = await fetch(`/api/GetClassLevels.ashx?classSlug=${classSlug}`);
                
                if (!response.ok) {
                    console.error('[CreateLobby] HTTP error:', response.status, response.statusText);
                    throw new Error(`HTTP ${response.status}: ${response.statusText}`);
                }
                
                const levels = await response.json();
                console.log('[CreateLobby] Received levels:', levels);
                
                if (!Array.isArray(levels)) {
                    console.error('[CreateLobby] Invalid response format:', levels);
                    throw new Error('Invalid response from server');
                }
                
                if (levels.length === 0) {
                    console.warn('[CreateLobby] No levels with questions found for class:', classSlug);
                    select.innerHTML = '<option value="">No levels with questions available</option>';
                    container.classList.remove('hidden');
                    return;
                }
                
                select.innerHTML = '<option value="">Select a level...</option>' +
                    levels.map(l => `<option value="${l.level_slug}" data-quiz-slug="${l.quiz_slug}">Level ${l.level_number}: ${l.title} (${l.question_count} questions)</option>`).join('');
                
                console.log('[CreateLobby] Populated dropdown with', levels.length, 'levels');
                container.classList.remove('hidden');
            } catch (error) {
                console.error('[CreateLobby] Error loading levels:', error);
                alert('Failed to load levels: ' + error.message);
            }
        }

        // Create lobby
        async function createLobby() {
            const lobbyName = document.getElementById('lobbyName').value.trim();
            const maxPlayers = parseInt(document.getElementById('maxPlayers').value);
            const timePerQuestion = parseInt(document.getElementById('timePerQuestion').value);

            // Validation
            if (!lobbyName) {
                alert('Please enter a lobby name');
                return;
            }

            let quizId = null;
            let classSlug = null;
            let levelSlug = null;

            if (selectedQuizSource === 'multiplayer') {
                quizId = document.getElementById('multiplayerQuizSet').value;
                if (!quizId) {
                    alert('Please select a quiz set');
                    return;
                }
            } else {
                classSlug = document.getElementById('classSelect').value;
                const levelSelect = document.getElementById('levelSelect');
                levelSlug = levelSelect.value;
                
                if (!classSlug || !levelSlug) {
                    alert('Please select a class and level');
                    return;
                }
                
                // Get quiz_slug from selected level option
                const selectedOption = levelSelect.options[levelSelect.selectedIndex];
                quizId = selectedOption.getAttribute('data-quiz-slug');
                
                if (!quizId) {
                    alert('Selected level does not have a quiz. Please select another level.');
                    return;
                }
            }

            // Disable button
            const btn = document.getElementById('createBtn');
            btn.disabled = true;
            btn.textContent = 'Creating Lobby...';

            try {
                // Generate lobby code
                const lobbyCode = generateLobbyCode();

                // Create lobby in Supabase
                const { data, error } = await supabase
                    .from('game_lobbies')
                    .insert({
                        lobby_code: lobbyCode,
                        host_user_slug: currentUser.userSlug,
                        host_name: currentUser.userName,
                        lobby_name: lobbyName,
                        quiz_source: selectedQuizSource,
                        quiz_id: quizId,
                        class_slug: classSlug,
                        max_players: maxPlayers,
                        status: 'waiting',
                        game_mode: selectedGameMode,
                        time_per_question: timePerQuestion
                    })
                    .select()
                    .single();

                if (error) throw error;

                console.log('[CreateLobby] Lobby created:', data);

                // Add host as first participant
                await supabase
                    .from('game_participants')
                    .insert({
                        lobby_id: data.lobby_id,
                        user_slug: currentUser.userSlug,
                        user_name: currentUser.userName,
                        user_email: currentUser.userEmail,
                        avatar_color: '#667eea',
                        is_ready: true,
                        is_online: true
                    });

                // Redirect to lobby room
                window.location.href = `lobby_room.aspx?code=${lobbyCode}`;
            } catch (error) {
                console.error('[CreateLobby] Error creating lobby:', error);
                alert('Failed to create lobby: ' + error.message);
                btn.disabled = false;
                btn.textContent = 'Create Lobby';
            }
        }

        // Generate random 6-character lobby code
        function generateLobbyCode() {
            const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
            let code = '';
            for (let i = 0; i < 6; i++) {
                code += chars.charAt(Math.floor(Math.random() * chars.length));
            }
            return code;
        }
    </script>
</asp:Content>


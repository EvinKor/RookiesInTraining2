<%@ Page Title="Multiplayer Quiz Game" Language="C#" MasterPageFile="~/MasterPages/GameMaster.Master" AutoEventWireup="true" CodeBehind="game_dashboard.aspx.cs" Inherits="RookiesInTraining2.Pages.game.game_dashboard" Async="true" EnableSessionState="True" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .game-dashboard {
            padding: 2rem;
            max-width: 1400px;
            margin: 0 auto;
        }

        .hero-section {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 3rem;
            border-radius: 20px;
            margin-bottom: 2rem;
            text-align: center;
        }

        .hero-section h1 {
            font-size: 3rem;
            font-weight: 700;
            margin-bottom: 1rem;
        }

        .hero-section p {
            font-size: 1.2rem;
            opacity: 0.9;
        }

        .action-buttons {
            display: flex;
            gap: 1rem;
            justify-content: center;
            margin-top: 2rem;
        }

        .btn-create-lobby {
            background: white;
            color: #667eea;
            padding: 1rem 2rem;
            border-radius: 12px;
            font-weight: 600;
            font-size: 1.1rem;
            border: none;
            cursor: pointer;
            transition: all 0.3s;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
        }

        .btn-create-lobby:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(0,0,0,0.2);
        }

        .btn-join-code {
            background: rgba(255,255,255,0.2);
            color: white;
            padding: 1rem 2rem;
            border-radius: 12px;
            font-weight: 600;
            font-size: 1.1rem;
            border: 2px solid white;
            cursor: pointer;
            transition: all 0.3s;
        }

        .btn-join-code:hover {
            background: white;
            color: #667eea;
        }

        .tabs-container {
            display: flex;
            gap: 1rem;
            margin-bottom: 2rem;
            border-bottom: 2px solid #e0e0e0;
        }

        .tab-btn {
            padding: 1rem 2rem;
            background: none;
            border: none;
            border-bottom: 3px solid transparent;
            font-weight: 600;
            font-size: 1rem;
            cursor: pointer;
            color: #666;
            transition: all 0.3s;
        }

        .tab-btn.active {
            color: #667eea;
            border-bottom-color: #667eea;
        }

        .lobby-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            gap: 1.5rem;
        }

        .lobby-card {
            background: white;
            border-radius: 16px;
            padding: 1.5rem;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            transition: all 0.3s;
            border: 2px solid transparent;
        }

        .lobby-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 8px 20px rgba(0,0,0,0.15);
            border-color: #667eea;
        }

        .lobby-header {
            display: flex;
            justify-content: space-between;
            align-items: start;
            margin-bottom: 1rem;
        }

        .lobby-name {
            font-size: 1.3rem;
            font-weight: 700;
            color: #333;
            margin-bottom: 0.5rem;
        }

        .lobby-code {
            background: #667eea;
            color: white;
            padding: 0.4rem 1rem;
            border-radius: 8px;
            font-weight: 700;
            font-size: 1rem;
            letter-spacing: 2px;
        }

        .lobby-status {
            display: inline-block;
            padding: 0.3rem 0.8rem;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 600;
        }

        .status-waiting {
            background: #e3f2fd;
            color: #1976d2;
        }

        .status-in-progress {
            background: #fff3e0;
            color: #f57c00;
        }

        .lobby-info {
            margin: 1rem 0;
        }

        .info-row {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            margin-bottom: 0.5rem;
            color: #666;
            font-size: 0.95rem;
        }

        .lobby-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 1rem;
            padding-top: 1rem;
            border-top: 1px solid #e0e0e0;
        }

        .player-count {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            font-weight: 600;
            color: #667eea;
        }

        .btn-join-lobby {
            background: #667eea;
            color: white;
            padding: 0.6rem 1.5rem;
            border-radius: 8px;
            border: none;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
        }

        .btn-join-lobby:hover {
            background: #5568d3;
            transform: scale(1.05);
        }

        .empty-state {
            text-align: center;
            padding: 4rem 2rem;
            color: #999;
        }

        .empty-state i {
            font-size: 4rem;
            margin-bottom: 1rem;
        }

        /* Join Code Modal */
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            z-index: 9999;
            align-items: center;
            justify-content: center;
        }

        .modal.show {
            display: flex;
        }

        .modal-content {
            background: white;
            padding: 2rem;
            border-radius: 20px;
            max-width: 500px;
            width: 90%;
        }

        .modal-header {
            font-size: 1.5rem;
            font-weight: 700;
            margin-bottom: 1.5rem;
            color: #333;
        }

        .code-input-group {
            display: flex;
            gap: 0.5rem;
            justify-content: center;
            margin: 2rem 0;
        }

        .code-digit {
            width: 60px;
            height: 70px;
            font-size: 2rem;
            font-weight: 700;
            text-align: center;
            border: 2px solid #ddd;
            border-radius: 12px;
            text-transform: uppercase;
        }

        .code-digit:focus {
            border-color: #667eea;
            outline: none;
        }

        .modal-buttons {
            display: flex;
            gap: 1rem;
            justify-content: flex-end;
            margin-top: 2rem;
        }

        .btn-modal-cancel {
            padding: 0.8rem 1.5rem;
            border: 1px solid #ddd;
            background: white;
            border-radius: 8px;
            cursor: pointer;
        }

        .btn-modal-join {
            padding: 0.8rem 1.5rem;
            background: #667eea;
            color: white;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
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
        }

        .btn-back:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.15);
            background: #f8f9fa;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="game-dashboard">
        <!-- Back Button -->
        <div class="mb-4">
            <a href="<%= GetBackUrl() %>" class="btn-back">
                <i class="fas fa-arrow-left"></i>
                Back to Dashboard
            </a>
        </div>
        
        <!-- Hero Section -->
        <div class="hero-section">
            <h1>Multiplayer Quiz Battle</h1>
            <p>Compete with friends in real-time quiz challenges!</p>
            
            <div class="action-buttons">
                <button type="button" class="btn-create-lobby" onclick="window.location.href='<%= ResolveUrl("~/Pages/game/create_lobby.aspx") %>'">
                    <i class="fas fa-plus-circle"></i>
                    Create Lobby
                </button>
                <button type="button" class="btn-join-code" onclick="openJoinCodeModal()">
                    <i class="fas fa-hashtag"></i>
                    Join with Code
                </button>
            </div>
        </div>

        <!-- Tabs -->
        <div class="tabs-container">
            <button type="button" class="tab-btn active" data-tab="available">
                Available Lobbies
            </button>
            <button type="button" class="tab-btn" data-tab="my-games">
                My Games
            </button>
        </div>

        <!-- Lobby Grid -->
        <div id="lobbyGrid" class="lobby-grid">
            <!-- Lobbies will be loaded here via JavaScript -->
        </div>

        <!-- Empty State -->
        <div id="emptyState" class="empty-state" style="display: none;">
            <i class="fas fa-ghost"></i>
            <h3>No active lobbies</h3>
            <p>Be the first to create a game lobby!</p>
        </div>
    </div>

    <!-- Join Code Modal -->
    <div id="joinCodeModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                Enter Lobby Code
            </div>
            
            <div class="code-input-group">
                <input type="text" class="code-digit" maxlength="1" id="code1" />
                <input type="text" class="code-digit" maxlength="1" id="code2" />
                <input type="text" class="code-digit" maxlength="1" id="code3" />
                <input type="text" class="code-digit" maxlength="1" id="code4" />
                <input type="text" class="code-digit" maxlength="1" id="code5" />
                <input type="text" class="code-digit" maxlength="1" id="code6" />
            </div>

            <div class="modal-buttons">
                <button type="button" class="btn-modal-cancel" onclick="closeJoinCodeModal()">Cancel</button>
                <button type="button" class="btn-modal-join" onclick="joinLobbyWithCode()">Join Lobby</button>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
    <script>
        // Initialize Supabase client
        const SUPABASE_URL = '<%= GetSupabaseUrl() %>';
        const SUPABASE_KEY = '<%= GetSupabaseKey() %>';
        const supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_KEY);

        // Current user info
        const currentUser = {
            userSlug: '<%= GetUserSlug() %>',
            userName: '<%= GetUserName() %>',
            userEmail: '<%= GetUserEmail() %>'
        };

        console.log('[GameDashboard] Current user:', currentUser);

        // Load lobbies on page load
        document.addEventListener('DOMContentLoaded', function() {
            loadLobbies();
            setupRealtimeSubscription();
            setupCodeInput();
        });

        // Load available lobbies
        async function loadLobbies() {
            try {
                console.log('[GameDashboard] Loading lobbies...');
                
                const { data, error } = await supabase
                    .from('game_lobbies')
                    .select('*')
                    .in('status', ['waiting', 'in_progress'])
                    .order('created_at', { ascending: false });

                if (error) throw error;

                console.log('[GameDashboard] Raw lobbies loaded:', data ? data.length : 0);
                
                // Filter out lobbies with 0 players
                let activeLobbies = data || [];
                
                // Load player counts and filter
                if (activeLobbies.length > 0) {
                    const lobbyChecks = await Promise.all(
                        activeLobbies.map(async (lobby) => {
                            const { data: players } = await supabase
                                .from('game_participants')
                                .select('participant_id')
                                .eq('lobby_id', lobby.lobby_id);
                            
                            const playerCount = players ? players.length : 0;
                            return { lobby, playerCount };
                        })
                    );
                    
                    // Only show lobbies with at least 1 player
                    activeLobbies = lobbyChecks
                        .filter(({ playerCount }) => playerCount > 0)
                        .map(({ lobby }) => lobby);
                    
                    console.log('[GameDashboard] Active lobbies (with players):', activeLobbies.length);
                }
                
                renderLobbies(activeLobbies);
                
                // Load player counts for display
                if (activeLobbies.length > 0) {
                    activeLobbies.forEach(lobby => loadPlayerCount(lobby.lobby_id));
                }
            } catch (error) {
                console.error('[GameDashboard] Error loading lobbies:', error);
            }
        }

        // Load player count for a lobby
        async function loadPlayerCount(lobbyId) {
            try {
                const { data, error } = await supabase
                    .from('game_participants')
                    .select('participant_id')
                    .eq('lobby_id', lobbyId)
                    .eq('is_online', true);

                if (error) throw error;

                const count = data ? data.length : 0;
                const element = document.getElementById('lobby-players-' + lobbyId);
                if (element) {
                    element.innerHTML = `
                        <i class="fas fa-users"></i>
                        <span>${count} player${count !== 1 ? 's' : ''}</span>
                    `;
                }
            } catch (error) {
                console.error('[GameDashboard] Error loading player count:', error);
            }
        }

        // Render lobbies to grid
        function renderLobbies(lobbies) {
            const grid = document.getElementById('lobbyGrid');
            const emptyState = document.getElementById('emptyState');

            if (!lobbies || lobbies.length === 0) {
                grid.style.display = 'none';
                emptyState.style.display = 'block';
                return;
            }

            grid.style.display = 'grid';
            emptyState.style.display = 'none';

            grid.innerHTML = lobbies.map(lobby => createLobbyCard(lobby)).join('');
        }

        // Create lobby card HTML
        function createLobbyCard(lobby) {
            const statusClass = lobby.status === 'waiting' ? 'status-waiting' : 'status-in-progress';
            const statusText = lobby.status === 'waiting' ? 'Waiting' : 'In Progress';
            const quizSource = lobby.quiz_source === 'multiplayer' ? 'Multiplayer Quiz' : 'Class Quiz';

            return `
                <div class="lobby-card">
                    <div class="lobby-header">
                        <div>
                            <div class="lobby-name">${lobby.lobby_name}</div>
                            <div class="lobby-status ${statusClass}">${statusText}</div>
                        </div>
                        <div class="lobby-code">${lobby.lobby_code}</div>
                    </div>

                    <div class="lobby-info">
                        <div class="info-row">
                            <i class="fas fa-user"></i>
                            <span>Host: ${lobby.host_name}</span>
                        </div>
                        <div class="info-row">
                            <i class="fas fa-question-circle"></i>
                            <span>${quizSource}</span>
                        </div>
                        <div class="info-row">
                            <i class="fas fa-clock"></i>
                            <span>${lobby.time_per_question}s per question</span>
                        </div>
                        <div class="info-row">
                            <i class="fas fa-trophy"></i>
                            <span>Mode: ${lobby.game_mode}</span>
                        </div>
                    </div>

                    <div class="lobby-footer">
                        <div class="player-count" id="lobby-players-${lobby.lobby_id}">
                            <i class="fas fa-users"></i>
                            <span>Loading...</span>
                        </div>
                        ${lobby.status === 'waiting' ? `
                            <button type="button" class="btn-join-lobby" onclick="joinLobby('${lobby.lobby_id}', '${lobby.lobby_code}')">
                                Join Game
                            </button>
                        ` : `
                            <button type="button" class="btn-join-lobby" disabled style="opacity: 0.5; cursor: not-allowed;">
                                Game Started
                            </button>
                        `}
                    </div>
                </div>
            `;
        }

        // Join lobby
        async function joinLobby(lobbyId, lobbyCode) {
            if (!currentUser.userSlug) {
                alert('Please login to join a game!');
                window.location.href = '/Pages/Login.aspx';
                return;
            }

            try {
                console.log('[GameDashboard] Joining lobby:', lobbyId);
                
                // Check if already joined
                const { data: existing } = await supabase
                    .from('game_participants')
                    .select('*')
                    .eq('lobby_id', lobbyId)
                    .eq('user_slug', currentUser.userSlug)
                    .single();

                if (existing) {
                    // Already joined, go to lobby
                    window.location.href = `lobby_room.aspx?code=${lobbyCode}`;
                    return;
                }

                // Add participant
                const { error } = await supabase
                    .from('game_participants')
                    .insert({
                        lobby_id: lobbyId,
                        user_slug: currentUser.userSlug,
                        user_name: currentUser.userName,
                        user_email: currentUser.userEmail,
                        avatar_color: getRandomColor(),
                        is_ready: false,
                        is_online: true
                    });

                if (error) throw error;

                console.log('[GameDashboard] Successfully joined lobby');
                window.location.href = `lobby_room.aspx?code=${lobbyCode}`;
            } catch (error) {
                console.error('[GameDashboard] Error joining lobby:', error);
                alert('Failed to join lobby: ' + error.message);
            }
        }

        // Setup realtime subscription for live updates
        function setupRealtimeSubscription() {
            supabase
                .channel('lobbies')
                .on('postgres_changes', { event: '*', schema: 'public', table: 'game_lobbies' }, payload => {
                    console.log('[GameDashboard] Lobby update:', payload);
                    loadLobbies(); // Reload lobbies
                })
                .subscribe();
        }

        // Join code modal functions
        function openJoinCodeModal() {
            document.getElementById('joinCodeModal').classList.add('show');
            document.getElementById('code1').focus();
        }

        function closeJoinCodeModal() {
            document.getElementById('joinCodeModal').classList.remove('show');
            // Clear inputs
            for (let i = 1; i <= 6; i++) {
                document.getElementById('code' + i).value = '';
            }
        }

        function setupCodeInput() {
            for (let i = 1; i <= 6; i++) {
                const input = document.getElementById('code' + i);
                input.addEventListener('input', function(e) {
                    if (this.value.length === 1 && i < 6) {
                        document.getElementById('code' + (i + 1)).focus();
                    }
                });
                input.addEventListener('keydown', function(e) {
                    if (e.key === 'Backspace' && this.value === '' && i > 1) {
                        document.getElementById('code' + (i - 1)).focus();
                    }
                });
            }
        }

        async function joinLobbyWithCode() {
            let code = '';
            for (let i = 1; i <= 6; i++) {
                code += document.getElementById('code' + i).value;
            }

            if (code.length !== 6) {
                alert('Please enter a 6-character code');
                return;
            }

            try {
                const { data, error } = await supabase
                    .from('game_lobbies')
                    .select('*')
                    .eq('lobby_code', code.toUpperCase())
                    .single();

                if (error || !data) {
                    alert('Invalid lobby code!');
                    return;
                }

                closeJoinCodeModal();
                joinLobby(data.lobby_id, data.lobby_code);
            } catch (error) {
                console.error('[GameDashboard] Error finding lobby:', error);
                alert('Lobby not found!');
            }
        }

        // Utility function
        function getRandomColor() {
            const colors = ['#3B82F6', '#10B981', '#F59E0B', '#EF4444', '#8B5CF6', '#EC4899'];
            return colors[Math.floor(Math.random() * colors.length)];
        }
    </script>
</asp:Content>


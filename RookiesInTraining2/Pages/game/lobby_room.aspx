<%@ Page Title="Lobby Room" Language="C#" MasterPageFile="~/MasterPages/GameMaster.Master" AutoEventWireup="true" CodeBehind="lobby_room.aspx.cs" Inherits="RookiesInTraining2.Pages.game.lobby_room" Async="true" EnableSessionState="True" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .lobby-room-container {
            padding: 2rem;
            max-width: 1400px;
            margin: 0 auto;
        }

        .lobby-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 2rem;
            border-radius: 20px;
            margin-bottom: 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .lobby-info h1 {
            font-size: 2rem;
            font-weight: 700;
            margin-bottom: 0.5rem;
        }

        .lobby-code-display {
            background: rgba(255,255,255,0.2);
            padding: 1rem 2rem;
            border-radius: 12px;
            font-size: 2rem;
            font-weight: 700;
            letter-spacing: 4px;
            border: 2px solid white;
        }

        .share-code-btn {
            background: white;
            color: #667eea;
            padding: 0.6rem 1.5rem;
            border-radius: 8px;
            border: none;
            font-weight: 600;
            cursor: pointer;
            margin-top: 0.5rem;
            transition: all 0.3s;
        }

        .share-code-btn:hover {
            transform: scale(1.05);
        }

        .main-content {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 2rem;
        }

        .players-section {
            background: white;
            padding: 2rem;
            border-radius: 20px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }

        .section-title {
            font-size: 1.5rem;
            font-weight: 700;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .players-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            gap: 1rem;
        }

        .player-card {
            background: #f8f9fa;
            padding: 1rem;
            border-radius: 12px;
            display: flex;
            align-items: center;
            gap: 1rem;
            transition: all 0.3s;
            border: 2px solid transparent;
        }

        .player-card.host {
            border-color: #ffc107;
            background: #fff9e6;
        }

        .player-card.ready {
            border-color: #28a745;
            background: #e8f5e9;
        }

        .player-avatar {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            font-weight: 700;
            color: white;
        }

        .player-info {
            flex: 1;
        }

        .player-name {
            font-weight: 600;
            color: #333;
            margin-bottom: 0.2rem;
        }

        .player-status {
            font-size: 0.85rem;
            color: #666;
        }

        .host-badge {
            background: #ffc107;
            color: white;
            padding: 0.2rem 0.6rem;
            border-radius: 12px;
            font-size: 0.75rem;
            font-weight: 600;
        }

        .ready-badge {
            background: #28a745;
            color: white;
            padding: 0.2rem 0.6rem;
            border-radius: 12px;
            font-size: 0.75rem;
            font-weight: 600;
        }

        .game-info-section {
            background: white;
            padding: 2rem;
            border-radius: 20px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }

        .info-item {
            padding: 1rem;
            background: #f8f9fa;
            border-radius: 10px;
            margin-bottom: 1rem;
        }

        .info-label {
            font-size: 0.85rem;
            color: #666;
            margin-bottom: 0.3rem;
        }

        .info-value {
            font-size: 1.1rem;
            font-weight: 600;
            color: #333;
        }

        .ready-button {
            width: 100%;
            padding: 1rem;
            background: #28a745;
            color: white;
            border: none;
            border-radius: 12px;
            font-size: 1.1rem;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s;
            margin-bottom: 1rem;
        }

        .ready-button:hover {
            background: #218838;
            transform: translateY(-2px);
        }

        .ready-button.ready {
            background: #6c757d;
        }

        .start-button {
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
            margin-bottom: 1rem;
        }

        .start-button:hover:not(:disabled) {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(102, 126, 234, 0.4);
        }

        .start-button:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }

        .leave-button {
            width: 100%;
            padding: 0.8rem;
            background: #dc3545;
            color: white;
            border: none;
            border-radius: 12px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
        }

        .leave-button:hover {
            background: #c82333;
        }

        .chat-section {
            background: white;
            padding: 1.5rem;
            border-radius: 20px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            margin-top: 2rem;
            display: flex;
            flex-direction: column;
            height: 300px;
        }

        .chat-messages {
            flex: 1;
            overflow-y: auto;
            margin-bottom: 1rem;
            padding: 1rem;
            background: #f8f9fa;
            border-radius: 10px;
        }

        .chat-message {
            margin-bottom: 0.8rem;
        }

        .message-author {
            font-weight: 600;
            color: #667eea;
            margin-right: 0.5rem;
        }

        .message-text {
            color: #333;
        }

        .message-time {
            font-size: 0.75rem;
            color: #999;
            margin-left: 0.5rem;
        }

        .chat-input-container {
            display: flex;
            gap: 0.5rem;
        }

        .chat-input {
            flex: 1;
            padding: 0.8rem;
            border: 2px solid #e0e0e0;
            border-radius: 10px;
            font-size: 0.95rem;
        }

        .chat-input:focus {
            border-color: #667eea;
            outline: none;
        }

        .chat-send-btn {
            padding: 0.8rem 1.5rem;
            background: #667eea;
            color: white;
            border: none;
            border-radius: 10px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
        }

        .chat-send-btn:hover {
            background: #5568d3;
        }

        .countdown-overlay {
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
        }

        .countdown-overlay.show {
            display: flex;
        }

        .countdown-number {
            font-size: 10rem;
            font-weight: 700;
            color: white;
            animation: pulse 1s ease-in-out;
        }

        @keyframes pulse {
            0%, 100% { transform: scale(1); opacity: 1; }
            50% { transform: scale(1.2); opacity: 0.8; }
        }

        .waiting-message {
            text-align: center;
            padding: 2rem;
            color: #666;
            font-size: 1.1rem;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="lobby-room-container">
        <!-- Lobby Header -->
        <div class="lobby-header">
            <div class="lobby-info">
                <h1 id="lobbyName">Loading...</h1>
                <p id="lobbyDescription">Waiting for players to join...</p>
            </div>
            <div>
                <div class="lobby-code-display" id="lobbyCode">------</div>
                <button class="share-code-btn" onclick="copyLobbyCode()">
                    <i class="fas fa-copy"></i> Copy Code
                </button>
            </div>
        </div>

        <div class="main-content">
            <!-- Players Section -->
            <div class="players-section">
                <div class="section-title">
                    <i class="fas fa-users"></i>
                    <span>Players (<span id="playerCount">0</span>/<span id="maxPlayers">10</span>)</span>
                </div>
                <div id="playersGrid" class="players-grid">
                    <!-- Players will be loaded here -->
                </div>
                <div id="waitingMessage" class="waiting-message" style="display: none;">
                    Waiting for players to join...
                </div>
            </div>

            <!-- Game Info & Controls -->
            <div>
                <div class="game-info-section">
                    <div class="section-title">
                        <i class="fas fa-info-circle"></i>
                        Game Settings
                    </div>

                    <div class="info-item">
                        <div class="info-label">Quiz Source</div>
                        <div class="info-value" id="quizSource">Loading...</div>
                    </div>

                    <div class="info-item">
                        <div class="info-label">Game Mode</div>
                        <div class="info-value" id="gameMode">Loading...</div>
                    </div>

                    <div class="info-item">
                        <div class="info-label">Time Per Question</div>
                        <div class="info-value" id="timePerQuestion">30 seconds</div>
                    </div>

                    <div class="info-item">
                        <div class="info-label">Host</div>
                        <div class="info-value" id="hostName">Loading...</div>
                    </div>
                </div>

                <!-- Controls -->
                <div style="margin-top: 1.5rem;">
                    <button type="button" id="readyButton" class="ready-button" onclick="toggleReady()">
                        <i class="fas fa-check"></i> Ready
                    </button>

                    <button type="button" id="startButton" class="start-button" onclick="startGame()" style="display: none;">
                        <i class="fas fa-play"></i> Start Game
                    </button>

                    <button type="button" class="leave-button" onclick="leaveLobby()">
                        <i class="fas fa-door-open"></i> Leave Lobby
                    </button>

                    <button type="button" style="width: 100%; padding: 0.8rem; background: #6c757d; color: white; border: none; border-radius: 12px; font-weight: 600; cursor: pointer; transition: all 0.3s; margin-top: 0.5rem;" 
                            onclick="window.location.href='<%= ResolveUrl("~/Pages/game/game_dashboard.aspx") %>'">
                        <i class="fas fa-arrow-left"></i> Back to Dashboard
                    </button>
                </div>
            </div>
        </div>

        <!-- Chat Section -->
        <div class="chat-section">
            <div class="section-title" style="margin-bottom: 1rem;">
                <i class="fas fa-comments"></i>
                Lobby Chat
            </div>
            <div id="chatMessages" class="chat-messages">
                <!-- Chat messages will appear here -->
            </div>
            <div class="chat-input-container">
                <input type="text" id="chatInput" class="chat-input" placeholder="Type a message..." 
                       onkeypress="if(event.key === 'Enter') sendMessage()" />
                <button type="button" class="chat-send-btn" onclick="sendMessage()">
                    <i class="fas fa-paper-plane"></i> Send
                </button>
            </div>
        </div>
    </div>

    <!-- Countdown Overlay -->
    <div id="countdownOverlay" class="countdown-overlay">
        <div class="countdown-number" id="countdownNumber">3</div>
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
            userEmail: '<%= GetUserEmail() %>'
        };

        // Get lobby code from URL
        const urlParams = new URLSearchParams(window.location.search);
        const lobbyCode = urlParams.get('code');

        // State
        let currentLobby = null;
        let participants = [];
        let isHost = false;
        let isReady = false;

        console.log('[LobbyRoom] Loading lobby:', lobbyCode);
        console.log('[LobbyRoom] Current user:', currentUser);

        // Load lobby on page load
        document.addEventListener('DOMContentLoaded', function() {
            if (!currentUser.userSlug) {
                alert('Please login to join a lobby');
                window.location.href = '/Pages/Login.aspx';
                return;
            }

            if (!lobbyCode) {
                alert('Invalid lobby code');
                window.location.href = 'game_dashboard.aspx';
                return;
            }

            loadLobby();
        });

        // Load lobby data
        async function loadLobby() {
            try {
                // Get lobby details
                const { data: lobby, error: lobbyError } = await supabase
                    .from('game_lobbies')
                    .select('*')
                    .eq('lobby_code', lobbyCode)
                    .single();

                if (lobbyError) throw lobbyError;

                currentLobby = lobby;
                isHost = lobby.host_user_slug === currentUser.userSlug;

                console.log('[LobbyRoom] Lobby loaded:', lobby);
                console.log('[LobbyRoom] Is host:', isHost);

                // Update UI
                document.getElementById('lobbyName').textContent = lobby.lobby_name;
                document.getElementById('lobbyCode').textContent = lobby.lobby_code;
                document.getElementById('maxPlayers').textContent = lobby.max_players;
                document.getElementById('quizSource').textContent = lobby.quiz_source === 'multiplayer' ? 'Multiplayer Quiz' : 'Class Quiz';
                document.getElementById('gameMode').textContent = formatGameMode(lobby.game_mode);
                document.getElementById('timePerQuestion').textContent = lobby.time_per_question + ' seconds';
                document.getElementById('hostName').textContent = lobby.host_name;

                // Show start button for host
                if (isHost) {
                    document.getElementById('startButton').style.display = 'block';
                }

                // Load participants
                loadParticipants();
                loadChatMessages();
                
                // Setup realtime after lobby is loaded
                setupRealtimeSubscriptions();
            } catch (error) {
                console.error('[LobbyRoom] Error loading lobby:', error);
                alert('Failed to load lobby: ' + error.message);
                window.location.href = 'game_dashboard.aspx';
            }
        }

        // Load participants
        async function loadParticipants() {
            try {
                const { data, error } = await supabase
                    .from('game_participants')
                    .select('*')
                    .eq('lobby_id', currentLobby.lobby_id)
                    .order('joined_at', { ascending: true });

                if (error) throw error;

                participants = data;
                renderParticipants();

                // Update ready status
                const me = participants.find(p => p.user_slug === currentUser.userSlug);
                if (me) {
                    isReady = me.is_ready;
                    updateReadyButton();
                }

                // Enable start button if all ready
                if (isHost) {
                    checkAllReady();
                }
            } catch (error) {
                console.error('[LobbyRoom] Error loading participants:', error);
            }
        }

        // Render participants
        function renderParticipants() {
            const grid = document.getElementById('playersGrid');
            const waitingMsg = document.getElementById('waitingMessage');
            const playerCount = document.getElementById('playerCount');

            playerCount.textContent = participants.length;

            if (participants.length === 0) {
                grid.style.display = 'none';
                waitingMsg.style.display = 'block';
                return;
            }

            grid.style.display = 'grid';
            waitingMsg.style.display = 'none';

            grid.innerHTML = participants.map(p => {
                const isHostPlayer = p.user_slug === currentLobby.host_user_slug;
                const cardClass = isHostPlayer ? 'host' : (p.is_ready ? 'ready' : '');
                
                return `
                    <div class="player-card ${cardClass}">
                        <div class="player-avatar" style="background: ${p.avatar_color}">
                            ${p.user_name.charAt(0).toUpperCase()}
                        </div>
                        <div class="player-info">
                            <div class="player-name">${p.user_name}</div>
                            <div class="player-status">
                                ${isHostPlayer ? '<span class="host-badge">HOST</span>' : ''}
                                ${p.is_ready ? '<span class="ready-badge">READY</span>' : ''}
                                ${!p.is_online ? '<span style="color: #999;">Offline</span>' : ''}
                            </div>
                        </div>
                    </div>
                `;
            }).join('');
        }

        // Toggle ready status
        async function toggleReady() {
            try {
                isReady = !isReady;

                const { error } = await supabase
                    .from('game_participants')
                    .update({ is_ready: isReady })
                    .eq('lobby_id', currentLobby.lobby_id)
                    .eq('user_slug', currentUser.userSlug);

                if (error) throw error;

                updateReadyButton();
                loadParticipants(); // Reload to update UI
            } catch (error) {
                console.error('[LobbyRoom] Error toggling ready:', error);
                alert('Failed to update ready status');
            }
        }

        // Update ready button
        function updateReadyButton() {
            const btn = document.getElementById('readyButton');
            if (isReady) {
                btn.classList.add('ready');
                btn.innerHTML = '<i class="fas fa-times"></i> Not Ready';
            } else {
                btn.classList.remove('ready');
                btn.innerHTML = '<i class="fas fa-check"></i> Ready';
            }
        }

        // Check if all players ready
        function checkAllReady() {
            const allReady = participants.length >= 2 && 
                           participants.every(p => p.is_ready || p.user_slug === currentLobby.host_user_slug);
            
            document.getElementById('startButton').disabled = !allReady;
        }

        // Start game (host only)
        async function startGame() {
            if (!isHost) return;

            try {
                // Update lobby status
                const { error } = await supabase
                    .from('game_lobbies')
                    .update({ 
                        status: 'in_progress',
                        started_at: new Date().toISOString()
                    })
                    .eq('lobby_id', currentLobby.lobby_id);

                if (error) throw error;

                // Show countdown
                showCountdown();
            } catch (error) {
                console.error('[LobbyRoom] Error starting game:', error);
                alert('Failed to start game: ' + error.message);
            }
        }

        // Show countdown before game starts
        function showCountdown() {
            const overlay = document.getElementById('countdownOverlay');
            const number = document.getElementById('countdownNumber');
            
            overlay.classList.add('show');
            let count = 3;

            const interval = setInterval(() => {
                number.textContent = count;
                count--;

                if (count < 0) {
                    clearInterval(interval);
                    // Redirect to game play
                    window.location.href = `game_play.aspx?lobby=${currentLobby.lobby_id}`;
                }
            }, 1000);
        }

        // Leave lobby
        async function leaveLobby() {
            if (!confirm('Are you sure you want to leave?')) return;

            try {
                console.log('[LobbyRoom] Leaving lobby...');
                console.log('[LobbyRoom] Current user:', currentUser.userSlug);
                console.log('[LobbyRoom] Current lobby:', currentLobby.lobby_id);
                
                // First, check how many players before leaving
                const { data: beforePlayers } = await supabase
                    .from('game_participants')
                    .select('user_slug')
                    .eq('lobby_id', currentLobby.lobby_id);
                
                console.log('[LobbyRoom] Players BEFORE leaving:', beforePlayers ? beforePlayers.length : 0);
                console.log('[LobbyRoom] Players list:', beforePlayers);
                
                // Remove participant
                const { data: deleted, error: deleteError } = await supabase
                    .from('game_participants')
                    .delete()
                    .eq('lobby_id', currentLobby.lobby_id)
                    .eq('user_slug', currentUser.userSlug)
                    .select();

                if (deleteError) {
                    console.error('[LobbyRoom] ❌ DELETE FAILED!');
                    console.error('[LobbyRoom] Error details:', deleteError);
                    console.error('[LobbyRoom] Error message:', deleteError.message);
                    console.error('[LobbyRoom] Error code:', deleteError.code);
                    
                    alert('❌ Cannot leave lobby!\n\nError: ' + deleteError.message + 
                          '\n\nDid you add the DELETE policy to Supabase?\nCheck SUPABASE_FIX_DELETE_POLICY.sql');
                    throw deleteError;
                }

                console.log('[LobbyRoom] Deleted participants:', deleted);
                console.log('[LobbyRoom] Successfully removed from lobby');

                // Wait a moment for deletion to complete
                await new Promise(resolve => setTimeout(resolve, 500));

                // Check if lobby is now empty
                const { data: remainingPlayers, error: countError } = await supabase
                    .from('game_participants')
                    .select('user_slug')
                    .eq('lobby_id', currentLobby.lobby_id);

                if (countError) throw countError;

                console.log('[LobbyRoom] Players AFTER leaving:', remainingPlayers ? remainingPlayers.length : 0);
                console.log('[LobbyRoom] Remaining players:', remainingPlayers);

                // If no players left, cancel the lobby
                if (!remainingPlayers || remainingPlayers.length === 0) {
                    console.log('[LobbyRoom] ⚠️ Lobby is now empty, marking as cancelled...');
                    
                    const { error: cancelError } = await supabase
                        .from('game_lobbies')
                        .update({ status: 'cancelled' })
                        .eq('lobby_id', currentLobby.lobby_id);
                    
                    if (cancelError) {
                        console.error('[LobbyRoom] Error cancelling lobby:', cancelError);
                    } else {
                        console.log('[LobbyRoom] ✅ Empty lobby cancelled successfully');
                    }
                }

                console.log('[LobbyRoom] Redirecting to dashboard...');
                // Add timestamp to force page refresh
                window.location.href = '<%= ResolveUrl("~/Pages/game/game_dashboard.aspx") %>?refresh=' + Date.now();
            } catch (error) {
                console.error('[LobbyRoom] Error leaving lobby:', error);
                alert('Failed to leave lobby: ' + error.message);
            }
        }

        // Copy lobby code
        function copyLobbyCode() {
            navigator.clipboard.writeText(lobbyCode);
            alert('Lobby code copied to clipboard!');
        }

        // Load chat messages
        async function loadChatMessages() {
            try {
                const { data, error } = await supabase
                    .from('game_chat_messages')
                    .select('*')
                    .eq('lobby_id', currentLobby.lobby_id)
                    .order('created_at', { ascending: true })
                    .limit(50);

                if (error) throw error;

                renderChatMessages(data || []);
            } catch (error) {
                console.error('[LobbyRoom] Error loading chat:', error);
            }
        }

        // Render chat messages
        function renderChatMessages(messages) {
            const container = document.getElementById('chatMessages');
            
            container.innerHTML = messages.map(msg => {
                const time = new Date(msg.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
                return `
                    <div class="chat-message">
                        <span class="message-author">${msg.user_name}:</span>
                        <span class="message-text">${escapeHtml(msg.message_text)}</span>
                        <span class="message-time">${time}</span>
                    </div>
                `;
            }).join('');

            container.scrollTop = container.scrollHeight;
        }

        // Send chat message
        async function sendMessage() {
            const input = document.getElementById('chatInput');
            const message = input.value.trim();

            if (!message) return;

            try {
                const { error } = await supabase
                    .from('game_chat_messages')
                    .insert({
                        lobby_id: currentLobby.lobby_id,
                        user_slug: currentUser.userSlug,
                        user_name: currentUser.userName,
                        message_text: message,
                        message_type: 'chat'
                    });

                if (error) throw error;

                input.value = '';
                console.log('[LobbyRoom] Message sent');
            } catch (error) {
                console.error('[LobbyRoom] Error sending message:', error);
                alert('Failed to send message: ' + error.message);
            }
        }

        // Setup realtime subscriptions
        function setupRealtimeSubscriptions() {
            if (!currentLobby || !currentLobby.lobby_id) {
                console.error('[LobbyRoom] Cannot setup subscriptions: currentLobby is null');
                return;
            }

            console.log('[LobbyRoom] Setting up realtime subscriptions for lobby:', currentLobby.lobby_id);

            // Participants updates
            supabase
                .channel('participants')
                .on('postgres_changes', { 
                    event: '*', 
                    schema: 'public', 
                    table: 'game_participants',
                    filter: `lobby_id=eq.${currentLobby.lobby_id}`
                }, payload => {
                    console.log('[LobbyRoom] Participant update:', payload);
                    loadParticipants();
                })
                .subscribe();

            // Lobby updates
            supabase
                .channel('lobby')
                .on('postgres_changes', { 
                    event: 'UPDATE', 
                    schema: 'public', 
                    table: 'game_lobbies',
                    filter: `lobby_id=eq.${currentLobby.lobby_id}`
                }, payload => {
                    console.log('[LobbyRoom] Lobby update:', payload);
                    
                    if (payload.new.status === 'in_progress' && !isHost) {
                        // Game started by host, redirect
                        showCountdown();
                    }
                })
                .subscribe();

            // Chat updates
            supabase
                .channel('chat')
                .on('postgres_changes', { 
                    event: 'INSERT', 
                    schema: 'public', 
                    table: 'game_chat_messages',
                    filter: `lobby_id=eq.${currentLobby.lobby_id}`
                }, payload => {
                    console.log('[LobbyRoom] New chat message:', payload);
                    loadChatMessages();
                })
                .subscribe();
        }

        // Utility functions
        function formatGameMode(mode) {
            const modes = {
                'fastest_finger': '⚡ Fastest Finger',
                'all_answer': '⏱️ All Answer',
                'survival': '💀 Survival'
            };
            return modes[mode] || mode;
        }

        function escapeHtml(text) {
            const div = document.createElement('div');
            div.textContent = text;
            return div.innerHTML;
        }
    </script>
</asp:Content>


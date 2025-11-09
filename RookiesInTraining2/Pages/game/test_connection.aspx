<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="test_connection.aspx.cs" Inherits="RookiesInTraining2.Pages.game.test_connection" %>

<!DOCTYPE html>
<html>
<head>
    <title>Game System Test</title>
    <style>
        body { font-family: Arial; padding: 2rem; background: #f5f5f5; }
        .test-box { background: white; padding: 2rem; margin: 1rem 0; border-radius: 10px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .success { color: green; font-weight: bold; }
        .error { color: red; font-weight: bold; }
        .info { color: blue; }
        h1 { color: #333; }
        h2 { color: #666; margin-top: 2rem; }
        pre { background: #f0f0f0; padding: 1rem; border-radius: 5px; overflow-x: auto; }
        button { padding: 0.8rem 1.5rem; background: #667eea; color: white; border: none; border-radius: 8px; cursor: pointer; margin: 0.5rem; }
        button:hover { background: #5568d3; }
    </style>
</head>
<body>
    <h1>🔧 Multiplayer Game System Test</h1>

    <div class="test-box">
        <h2>1. Server-Side Tests</h2>
        
        <p><strong>Session Status:</strong> 
            <span class="<%= GetSessionStatus() %>"><%= GetSessionInfo() %></span>
        </p>
        
        <p><strong>User Info:</strong></p>
        <pre><%= GetUserInfo() %></pre>
        
        <p><strong>Supabase Configuration:</strong> 
            <span class="<%= GetSupabaseStatus() %>"><%= GetSupabaseInfo() %></span>
        </p>
        
        <p><strong>Supabase URL:</strong> <code><%= GetSupabaseUrlDisplay() %></code></p>
        <p><strong>Supabase Key:</strong> <code><%= GetSupabaseKeyDisplay() %></code></p>
    </div>

    <div class="test-box">
        <h2>2. Client-Side Tests</h2>
        
        <p><strong>Supabase.js Loading:</strong> <span id="supabaseStatus" class="info">Testing...</span></p>
        <p><strong>Supabase Client:</strong> <span id="clientStatus" class="info">Testing...</span></p>
        <p><strong>Connection Test:</strong> <span id="connectionStatus" class="info">Testing...</span></p>
        
        <div id="testResults"></div>
    </div>

    <div class="test-box">
        <h2>3. Manual Tests</h2>
        <button onclick="testSupabaseConnection()">Test Supabase Connection</button>
        <button onclick="testCreateLobby()">Test Create Lobby</button>
        <button onclick="testLoadLobbies()">Test Load Lobbies</button>
        
        <pre id="manualTestResults" style="margin-top: 1rem; min-height: 100px;"></pre>
    </div>

    <div class="test-box">
        <h2>4. Navigation Tests</h2>
        <button onclick="window.location.href='game_dashboard.aspx'">Go to Game Dashboard</button>
        <button onclick="window.location.href='create_lobby.aspx'">Go to Create Lobby</button>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
    <script>
        const SUPABASE_URL = '<%= GetSupabaseUrl() %>';
        const SUPABASE_KEY = '<%= GetSupabaseKey() %>';
        
        console.log('[Test] Supabase URL:', SUPABASE_URL);
        console.log('[Test] Supabase Key:', SUPABASE_KEY ? 'Present (length: ' + SUPABASE_KEY.length + ')' : 'MISSING!');

        // Test 1: Check if supabase library loaded
        if (typeof window.supabase !== 'undefined') {
            document.getElementById('supabaseStatus').textContent = '✅ Loaded successfully';
            document.getElementById('supabaseStatus').className = 'success';
        } else {
            document.getElementById('supabaseStatus').textContent = '❌ Failed to load (check Network tab)';
            document.getElementById('supabaseStatus').className = 'error';
        }

        // Test 2: Create supabase client
        let supabase = null;
        try {
            if (window.supabase && SUPABASE_URL && SUPABASE_KEY) {
                supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_KEY);
                document.getElementById('clientStatus').textContent = '✅ Client created successfully';
                document.getElementById('clientStatus').className = 'success';
            } else {
                throw new Error('Missing supabase library or credentials');
            }
        } catch (error) {
            document.getElementById('clientStatus').textContent = '❌ Error: ' + error.message;
            document.getElementById('clientStatus').className = 'error';
            console.error('[Test] Client creation error:', error);
        }

        // Test 3: Test connection
        async function testConnection() {
            try {
                const { data, error } = await supabase.from('game_lobbies').select('count').limit(1);
                
                if (error) throw error;
                
                document.getElementById('connectionStatus').textContent = '✅ Connected to Supabase successfully!';
                document.getElementById('connectionStatus').className = 'success';
                console.log('[Test] Connection successful:', data);
            } catch (error) {
                document.getElementById('connectionStatus').textContent = '❌ Connection failed: ' + error.message;
                document.getElementById('connectionStatus').className = 'error';
                console.error('[Test] Connection error:', error);
            }
        }

        if (supabase) {
            testConnection();
        }

        // Manual test functions
        async function testSupabaseConnection() {
            const results = document.getElementById('manualTestResults');
            results.textContent = 'Testing Supabase connection...\n';
            
            try {
                const { data, error } = await supabase.from('game_lobbies').select('*').limit(5);
                
                if (error) throw error;
                
                results.textContent += '✅ SUCCESS!\n';
                results.textContent += 'Lobbies found: ' + (data ? data.length : 0) + '\n';
                results.textContent += 'Data: ' + JSON.stringify(data, null, 2);
            } catch (error) {
                results.textContent += '❌ ERROR: ' + error.message + '\n';
                results.textContent += 'Stack: ' + error.stack;
                console.error('[Test] Manual test error:', error);
            }
        }

        async function testCreateLobby() {
            const results = document.getElementById('manualTestResults');
            results.textContent = 'Testing Create Lobby...\n';
            
            try {
                const lobbyCode = 'TEST' + Math.floor(Math.random() * 100);
                
                const { data, error } = await supabase
                    .from('game_lobbies')
                    .insert({
                        lobby_code: lobbyCode,
                        host_user_slug: '<%= GetUserSlug() %>',
                        host_name: '<%= GetUserName() %>',
                        lobby_name: 'Test Lobby',
                        quiz_source: 'multiplayer',
                        quiz_id: 'General Knowledge Set 1',
                        max_players: 10,
                        status: 'waiting',
                        game_mode: 'fastest_finger',
                        time_per_question: 30
                    })
                    .select();
                
                if (error) throw error;
                
                results.textContent += '✅ SUCCESS! Lobby created!\n';
                results.textContent += 'Lobby Code: ' + lobbyCode + '\n';
                results.textContent += 'Data: ' + JSON.stringify(data, null, 2);
            } catch (error) {
                results.textContent += '❌ ERROR: ' + error.message + '\n';
                results.textContent += 'Details: ' + JSON.stringify(error, null, 2);
                console.error('[Test] Create lobby error:', error);
            }
        }

        async function testLoadLobbies() {
            const results = document.getElementById('manualTestResults');
            results.textContent = 'Testing Load Lobbies...\n';
            
            try {
                const { data, error } = await supabase
                    .from('game_lobbies')
                    .select('*')
                    .in('status', ['waiting', 'in_progress'])
                    .order('created_at', { ascending: false });
                
                if (error) throw error;
                
                results.textContent += '✅ SUCCESS! Lobbies loaded!\n';
                results.textContent += 'Count: ' + (data ? data.length : 0) + '\n';
                results.textContent += 'Data: ' + JSON.stringify(data, null, 2);
            } catch (error) {
                results.textContent += '❌ ERROR: ' + error.message + '\n';
                results.textContent += 'Details: ' + JSON.stringify(error, null, 2);
                console.error('[Test] Load lobbies error:', error);
            }
        }
    </script>
</body>
</html>


# 🎮 Multiplayer Quiz Game - Complete Setup Guide

## 📋 Overview

This multiplayer quiz game system allows students and teachers to compete in real-time quiz battles. Features include:

- **Create Lobbies**: Host your own quiz game rooms
- **Join Games**: Join using 6-digit lobby codes
- **Real-time Updates**: Live player tracking and score updates
- **Multiple Quiz Sources**: Use pre-made multiplayer quizzes OR class quizzes
- **Game Modes**: 
  - ⚡ **Fastest Finger**: First correct answer gets most points
  - ⏱️ **All Answer**: Everyone gets full time to answer
  - 💀 **Survival**: Wrong answer = elimination
- **Live Leaderboard**: Real-time rankings during gameplay

---

## 🚀 Step-by-Step Setup

### Step 1: Create Supabase Project

1. Go to [https://app.supabase.com](https://app.supabase.com)
2. Click **"New Project"**
3. Fill in:
   - **Name**: RookiesMultiplayerGame (or any name)
   - **Database Password**: (create a strong password)
   - **Region**: Choose closest to you
4. Click **"Create new project"** (takes ~2 minutes)

---

### Step 2: Get Supabase Credentials

Once your project is created:

1. Go to **Settings** (⚙️ icon in sidebar)
2. Click **API** in the left menu
3. Copy these values:
   - **Project URL** (e.g., `https://xxxxx.supabase.co`)
   - **anon/public key** (long JWT token starting with `eyJ...`)
   - **service_role key** (another long JWT token)

---

### Step 3: Create Database Tables in Supabase

1. In Supabase Dashboard, go to **SQL Editor** (left sidebar)
2. Click **"+ New query"**
3. Open the file: `SUPABASE_MULTIPLAYER_SCHEMA.sql`
4. **Copy ALL the SQL code** from that file
5. **Paste it** into the Supabase SQL Editor
6. Click **"Run"** (or press Ctrl+Enter)
7. ✅ You should see: "Success. No rows returned"

**This creates:**
- 7 tables (lobbies, participants, questions, sessions, answers, results, chat)
- Indexes for performance
- Row Level Security policies
- Realtime subscriptions
- Sample quiz questions

---

### Step 4: Enable Realtime in Supabase

1. In Supabase Dashboard, go to **Database** → **Replication**
2. Enable realtime for these tables (click toggle to ON):
   - ✅ `game_lobbies`
   - ✅ `game_participants`
   - ✅ `game_sessions`
   - ✅ `game_answers`
   - ✅ `game_results`
   - ✅ `game_chat_messages`

---

### Step 5: Add Credentials to Web.config

1. Open your `Web.config` file
2. Find the `<appSettings>` section
3. Add these lines (replace with YOUR actual values):

```xml
<appSettings>
  <!-- Your existing settings... -->
  
  <!-- Supabase Configuration -->
  <add key="SupabaseUrl" value="PASTE_YOUR_PROJECT_URL_HERE" />
  <add key="SupabaseKey" value="PASTE_YOUR_ANON_KEY_HERE" />
  <add key="SupabaseServiceKey" value="PASTE_YOUR_SERVICE_KEY_HERE" />
</appSettings>
```

**Example:**
```xml
<add key="SupabaseUrl" value="https://abcdefghijklmn.supabase.co" />
<add key="SupabaseKey" value="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ..." />
<add key="SupabaseServiceKey" value="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ..." />
```

⚠️ **IMPORTANT**: Never commit the service key to Git! Keep it secret!

---

### Step 6: Update Visual Studio Project

The new files need to be added to your project:

**Option A: Using Visual Studio**
1. In **Solution Explorer**, right-click on your project
2. Click **Add** → **Existing Item**
3. Navigate to and select:
   - All files in `RookiesInTraining2/Pages/game/` folder
   - All files in `RookiesInTraining2/api/` folder
   - `RookiesInTraining2/App_Code/SupabaseConfig.cs`
4. Click **Add**

**Option B: Edit .csproj file** (faster)
1. Right-click project → **Edit Project File**
2. I'll provide the XML to add in the next step

---

### Step 7: Build and Test

1. **Rebuild Solution** (Ctrl+Shift+B)
2. **Run the application** (F5)
3. **Login** as student or teacher
4. **Navigate to**: `/Pages/game/game_dashboard.aspx`

---

## 📁 File Structure

```
RookiesInTraining2/
├── Pages/
│   └── game/
│       ├── game_dashboard.aspx          # Browse and join lobbies
│       ├── game_dashboard.aspx.cs
│       ├── game_dashboard.aspx.designer.cs
│       ├── create_lobby.aspx            # Create new game lobby
│       ├── create_lobby.aspx.cs
│       └── create_lobby.aspx.designer.cs
│
├── api/
│   ├── GetUserClasses.ashx              # API: Get user's classes
│   └── GetClassQuizzes.ashx             # API: Get class quizzes
│
├── App_Code/
│   └── SupabaseConfig.cs                # Supabase integration
│
└── SQL Files (for reference):
    ├── SUPABASE_MULTIPLAYER_SCHEMA.sql  # Database schema
    └── SUPABASE_WEB_CONFIG_TEMPLATE.txt # Config template
```

---

## 🎮 How to Use

### For Teachers and Students:

1. **Create a Lobby**:
   - Go to Game Dashboard
   - Click "Create Lobby"
   - Choose quiz source (Multiplayer Quiz or Class Quiz)
   - Set game mode and time limits
   - Click "Create Lobby"
   - Share the 6-digit code with players

2. **Join a Lobby**:
   - Go to Game Dashboard
   - Click "Join with Code"
   - Enter the 6-digit code
   - OR browse available lobbies and click "Join Game"

3. **Play the Game**:
   - Wait in lobby for other players
   - Host starts the game when ready
   - Answer questions as fast as possible
   - See live leaderboard
   - View final results

---

## 🔧 Troubleshooting

### "Supabase is not configured!"
- ✅ Check Web.config has all 3 Supabase settings
- ✅ Make sure values are inside quotes
- ✅ Restart IIS/web server

### "No quiz sets available"
- ✅ Make sure you ran the full SQL schema (includes sample questions)
- ✅ Check Supabase Dashboard → Table Editor → `multiplayer_questions`

### "Cannot connect to Supabase"
- ✅ Check your internet connection
- ✅ Verify Supabase URL and keys are correct
- ✅ Check Supabase project status (should be "Active" in dashboard)

### API Handlers not working
- ✅ Make sure .ashx files are in the `api/` folder
- ✅ Check IIS is configured to handle .ashx files
- ✅ Verify connection string in Web.config

---

## 🎯 Next Steps (TODO for Complete Game)

The following pages still need to be created for full functionality:

1. **lobby_room.aspx** - Waiting room before game starts
2. **game_play.aspx** - Main game interface during quiz
3. **game_results.aspx** - Final results and rankings
4. **manage_multiplayer_questions.aspx** - Admin page to create custom quiz sets

These will be created in the next phase once you confirm the basic setup is working.

---

## 📊 Database Tables (Supabase)

| Table | Purpose |
|-------|---------|
| `game_lobbies` | Store lobby information |
| `game_participants` | Track players in each lobby |
| `multiplayer_questions` | Pre-made quiz questions |
| `game_sessions` | Track active game state |
| `game_answers` | Record player answers |
| `game_results` | Final scores and rankings |
| `game_chat_messages` | Optional lobby chat |

---

## 🔐 Security Notes

- ✅ Row Level Security (RLS) is enabled on all tables
- ✅ Public can read lobbies and join games
- ✅ Only authenticated users can create lobbies
- ✅ Realtime updates are enabled for live gameplay
- ⚠️ Keep `SupabaseServiceKey` secret (never in client-side code)

---

## 💡 Tips

- Use **"General Knowledge Set 1"** for testing (comes with 5 sample questions)
- Test with 2 browser windows (different accounts) to simulate multiplayer
- Check browser console (F12) for debug logs
- Check Visual Studio Output window for server-side logs

---

## 📞 Need Help?

If you encounter any issues:

1. Check browser console (F12 → Console tab)
2. Check Visual Studio Output window
3. Check Supabase Dashboard → Logs
4. Verify all steps above were completed

---

## ✅ Ready to Test!

Once you've completed all 7 steps above, paste your Supabase credentials and I'll help you test the system!

**Please provide:**
```
Supabase URL: 
Supabase Anon Key:
```

Then we can continue building the remaining pages (lobby room, game play, results).


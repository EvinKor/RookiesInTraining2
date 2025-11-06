# Rookies in Training - Web Application

A gamified learning platform for Malaysian high school students built with ASP.NET Web Forms.

## 🚀 Quick Start

### Prerequisites
- Visual Studio 2019 or later
- SQL Server (LocalDB or full instance)
- .NET Framework 4.7.2

### Setup

1. **Clone/Download the repository**

2. **Database Setup**:
   ```sql
   -- Run in SQL Server Management Studio
   -- 1. Create database (or use existing)
   -- 2. Run ALL_TABLES_FORMATTED.sql
   -- 3. Run FORUM_TABLES.sql (for forum feature)
   -- 4. Run SEED_Test_Accounts.sql (for test accounts)
   ```

3. **Configure Connection String**:
   - Open `RookiesInTraining2/Web.config`
   - Update `ConnectionStrings:ConnectionString` if needed
   - Default uses LocalDB: `(LocalDB)\MSSQLLocalDB`

4. **Build & Run**:
   - Open `RookiesInTraining2.sln` in Visual Studio
   - Press F5 to run
   - Navigate to `/Pages/Login.aspx`

### Test Accounts

After running seed script:
- **Student**: `student@example.com` / `password123`
- **Teacher**: `teacher@example.com` / `password123`
- **Admin**: `admin@example.com` / `password123`

## 📁 Project Structure

```
RookiesInTraining2/
├── Pages/
│   ├── student/
│   │   ├── dashboard_student.aspx    # Student dashboard
│   │   ├── story.aspx                 # Story mode stage map
│   │   └── story_stage.aspx           # Individual stage quiz
│   ├── teacher/                       # Teacher pages
│   ├── admin/                         # Admin pages
│   └── forum/                         # Forum (CRUD demo)
│       ├── list.aspx                  # Thread list
│       └── create.aspx                # Create thread
├── Services/
│   └── ProgressService.cs             # XP/Levels/Badges service
├── MasterPages/
│   └── dashboard.Master               # Dashboard template
└── Web.config                         # Configuration
```

## ✨ Features Implemented

### ✅ Completed (50-60%)

1. **Story Mode**
   - Sequential stage progression
   - Lock/unlock logic
   - Quiz integration
   - XP rewards

2. **XP/Levels/Badges**
   - ProgressService for XP calculation
   - Level calculation from XP
   - Badge awarding system
   - Real-time progress tracking

3. **Forum (CRUD Demo)**
   - Thread listing
   - Create threads
   - Form validation
   - Database integration

4. **CSS Examples**
   - ✅ External CSS: `Site.css`, Bootstrap
   - ✅ Internal CSS: `story.aspx` (in `<style>` tag)
   - ✅ Inline CSS: `forum/list.aspx` (in `style` attribute)

5. **Database Integration**
   - All features use real database
   - ADO.NET data access
   - Service layer pattern

### ⚠️ In Progress / Partial

- **Quiz Battles**: Structure ready, needs SignalR 2.x
- **Hint System**: Database ready, UI pending
- **Leaderboards**: Service ready, pages pending
- **AI Question Generation**: Interface ready, implementation pending

## 📚 Documentation

- **ARCHITECTURE.md** - Current architecture and target design
- **docs/GAP-ANALYSIS.md** - Detailed gap analysis
- **docs/IMPLEMENTATION-SUMMARY.md** - What's implemented
- **docs/AZURE-SETUP.md** - Azure deployment guide
- **docs/DEMO-SCRIPT.md** - Presentation demo script

## 🎯 Demo Flow

1. **Login** as student
2. **Dashboard** - Shows XP, Level, Progress
3. **Story Mode** - Navigate stages, complete quizzes
4. **Forum** - Create/view threads (CRUD demo)
5. **Database** - Show real data connectivity

## 🔧 Technology Stack

- **Framework**: ASP.NET Web Forms (.NET Framework 4.7.2)
- **Database**: SQL Server (LocalDB for dev, Azure SQL for production)
- **Frontend**: Bootstrap 5.3, jQuery 3.7
- **Data Access**: ADO.NET (direct SQL)
- **Authentication**: Custom session-based

## 📝 Assignment Requirements Coverage

- ✅ Interlinked pages with navigation
- ✅ HTML5 semantics
- ✅ CSS usage (External, Internal, Inline)
- ✅ CRUD operations (Forum, Quizzes, User Progress)
- ✅ Registration + Login
- ✅ Role-based access (Student, Teacher, Admin)
- ✅ Form validation (client + server)
- ✅ Database connectivity (ADO.NET)
- ✅ File organization & naming
- ⚠️ Real-time features (SignalR structure ready)
- ⚠️ Azure deployment (docs provided)

## 🚀 Deployment to Azure

See **docs/AZURE-SETUP.md** for detailed instructions.

Quick steps:
1. Create Azure SQL Database
2. Create Azure App Service (Windows, .NET Framework 4.7)
3. Deploy database schema
4. Configure connection strings in Azure Portal
5. Publish from Visual Studio

## 🐛 Known Issues / TODOs

- SignalR 2.x not yet installed (battles need this)
- Forum thread detail page not created
- Leaderboard pages not created
- Hint system UI not added
- AI question generation not implemented

## 📞 Support

For issues or questions:
1. Check documentation in `docs/` folder
2. Review `ARCHITECTURE.md` for system design
3. Check `docs/GAP-ANALYSIS.md` for feature status

## 📄 License

This is an academic project for assignment purposes.

---

**Status**: ~55-60% Complete - Ready for demo presentation!

**Last Updated**: November 2025


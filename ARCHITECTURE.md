# Architecture Documentation - Rookies in Training

## Current State Analysis

### Solution Structure

**Solution File**: `RookiesInTraining2.sln`  
**Project**: `RookiesInTraining2` (Single Web Application Project)  
**Framework**: .NET Framework 4.7.2  
**Technology Stack**: ASP.NET Web Forms (NOT ASP.NET Core)

### Project Type & Framework

- **Framework**: ASP.NET Web Forms (.NET Framework 4.7.2)
- **NOT ASP.NET Core**: This is a traditional Web Forms application
- **Startup**: `Global.asax.cs` (not Program.cs/Startup.cs)
- **Configuration**: `Web.config` (not appsettings.json)
- **Routing**: Friendly URLs via `RouteConfig.cs` in `App_Start`

### Data Access Layer

**Current Implementation**:
- **Direct ADO.NET**: Uses `SqlConnection` and `SqlCommand` directly in code-behind files
- **No ORM**: Entity Framework Core is NOT present
- **Connection String**: Stored in `Web.config` under `ConnectionStrings:ConnectionString`
- **Database**: SQL Server LocalDB (`RookiesDatabase.mdf` in `App_Data`)

**Database Schema** (14 tables):
1. `Users` - User accounts with roles (student/teacher/admin)
2. `Classes` - Learning classes created by teachers
3. `Enrollments` - Student enrollments in classes
4. `Levels` - Learning stages/levels within classes
5. `Quizzes` - Quiz definitions
6. `Questions` - Quiz questions with JSON options
7. `Modules` - Learning modules (for student dashboard)
8. `ModuleQuizzes` - Quizzes within modules
9. `Badges` - Achievement badges
10. `UserBadges` - User badge assignments
11. `UserProgress` - Quiz progress tracking
12. `LevelSlides` - Learning material slides
13. `StudentLevelProgress` - Student progress in levels
14. `QuizAssignments` - Class-Quiz mappings

### Authentication & Authorization

**Current Implementation**:
- **Custom Session-Based Authentication**: NOT using ASP.NET Identity
- **Password Hashing**: SHA256 (implemented in `Login.aspx.cs` and `Register.aspx.cs`)
- **Session Variables**: 
  - `Session["UserSlug"]` - User identifier
  - `Session["FullName"]` - Display name
  - `Session["Email"]` - User email
  - `Session["Role"]` - Role (student/teacher/admin)
- **Role-Based Access**: Manual checks in `Page_Load` methods
- **Roles**: `student`, `teacher`, `admin` (stored in `Users.role_global`)

**Authentication Flow**:
1. User registers/logs in via `Register.aspx` / `Login.aspx`
2. Password is hashed with SHA256
3. Session variables are set
4. Redirect based on role to appropriate dashboard

### Pages & Structure

**Page Organization**:
```
Pages/
├── Login.aspx
├── Register.aspx
├── admin/
│   └── dashboard_admin.aspx
├── student/
│   └── dashboard_student.aspx
└── teacher/
    ├── dashboard_teacher.aspx
    ├── teacher_classes.aspx
    ├── teacher_browse_classes.aspx
    ├── teacher_create_class.aspx
    ├── teacher_create_module.aspx
    ├── class_detail.aspx
    └── add_questions.aspx
```

**Master Pages**:
- `Site.Master` - Main site template
- `Site.Mobile.Master` - Mobile template
- `MasterPages/dashboard.Master` - Dashboard template with logout

### Services & Business Logic

**Current State**:
- **No Service Layer**: Business logic is in code-behind files
- **No Repository Pattern**: Direct database access in pages
- **No Dependency Injection**: Static connection string access
- **No Interfaces/Abstractions**: Tightly coupled implementation

### Frontend Assets

**CSS**:
- Bootstrap 5.3.8 (external)
- Custom CSS files in `Content/`:
  - `Site.css` (external)
  - `student-dashboard.css`
  - `teacher-classes.css`
  - `class-detail.css`
  - `add-questions.css`

**JavaScript**:
- jQuery 3.7.0
- Bootstrap JS
- Custom page-specific JS files in `Scripts/`

**CSS Usage Examples**:
- ✅ External CSS: `Site.css`, Bootstrap files
- ⚠️ Internal CSS: Not yet demonstrated (needs to be added)
- ⚠️ Inline CSS: Not yet demonstrated (needs to be added)

### Validation

**Current Implementation**:
- **Server-Side**: Manual validation in code-behind
- **Client-Side**: Unobtrusive validation disabled (`UnobtrusiveValidationMode.None`)
- **DataAnnotations**: Not used (no model classes)
- **Form Validation**: Basic checks in `Page_Load` and event handlers

### Real-time Features

**Current State**:
- ❌ **SignalR**: NOT implemented
- ❌ **WebSockets**: NOT configured
- ❌ **Real-time Quiz Battles**: NOT implemented

### AI & File Processing

**Current State**:
- ❌ **AI Question Generation**: NOT implemented
- ❌ **File Upload Service**: Basic file upload exists (to `Uploads/` folder)
- ❌ **Azure Blob Storage**: NOT configured
- ❌ **PDF/PPT Processing**: NOT implemented

### Azure Configuration

**Current State**:
- ❌ **Azure SQL**: Using LocalDB (not Azure SQL)
- ❌ **Azure Blob Storage**: NOT configured
- ❌ **Azure App Service**: No publish profile
- ❌ **Environment Configuration**: No appsettings.{Environment}.json
- ❌ **Connection Strings**: Hardcoded in Web.config for LocalDB

### Testing

**Current State**:
- ❌ **Unit Tests**: No test project
- ❌ **Integration Tests**: No test infrastructure

---

## Target Architecture (Proposed)

### Framework Migration Consideration

**IMPORTANT**: The requirements specify ASP.NET Core, but the current codebase is ASP.NET Web Forms (.NET Framework). Two paths forward:

#### Option A: Migrate to ASP.NET Core (Recommended for Long-term)
- **Pros**: Modern framework, better Azure support, SignalR built-in, EF Core, Identity
- **Cons**: Significant refactoring required, breaking changes
- **Effort**: High (weeks of work)

#### Option B: Enhance Web Forms (Pragmatic for Assignment)
- **Pros**: Minimal disruption, works with existing code
- **Cons**: Limited SignalR support (requires SignalR 2.x for .NET Framework), no native EF Core
- **Effort**: Medium (days of work)

**Recommendation**: For assignment purposes, proceed with **Option B** but document the migration path. We can add SignalR 2.x for .NET Framework and use ADO.NET with better abstraction.

### Proposed Layered Architecture

```
RookiesInTraining2/
├── Models/              # Entity classes (DTOs)
│   ├── User.cs
│   ├── Quiz.cs
│   ├── Question.cs
│   └── ...
├── Services/            # Business logic
│   ├── IProgressService.cs
│   ├── IHintService.cs
│   ├── IBattleService.cs
│   ├── IAssessmentGenerator.cs
│   └── IFileStorage.cs
├── Repositories/        # Data access abstraction
│   ├── IUserRepository.cs
│   ├── IQuizRepository.cs
│   └── ...
├── Hubs/                # SignalR hubs (if using SignalR 2.x)
│   └── BattleHub.cs
├── Infrastructure/      # External integrations
│   ├── AzureBlobFileStorage.cs
│   ├── AzureOpenAIService.cs
│   └── ...
└── Pages/               # Existing Web Forms pages
```

### Key Entities to Add/Extend

**New Entities Needed**:
- `StoryStage` - Story mode progression stages
- `StageRequirement` - Unlock requirements for stages
- `BattleRoom` - Quiz battle room definitions
- `BattleSession` - Active battle sessions
- `BattleParticipant` - Participants in a battle
- `BattleAnswer` - Answers submitted during battles
- `HintUsage` - Track hint usage per quiz attempt
- `XPEvent` - XP gain events (for leaderboards)
- `LeaderboardSnapshot` - Cached leaderboard data
- `ForumThread` - Forum discussion threads
- `ForumPost` - Forum post replies
- `MaterialUpload` - Uploaded PDF/PPT files
- `GeneratedQuestion` - AI-generated questions (before teacher approval)

### Services to Implement

1. **IProgressService**
   - Calculate XP from quiz completion
   - Determine level from total XP
   - Award badges based on achievements
   - Track story mode progression

2. **IHintService**
   - Provide hints for questions
   - Track hint usage per attempt
   - Apply score penalty (e.g., -10% per hint)

3. **IBattleService**
   - Create/join battle rooms
   - Manage battle sessions
   - Calculate ELO ratings
   - Track battle results

4. **IAssessmentGenerator**
   - Extract text from PDF/PPT
   - Generate questions using AI
   - Tag difficulty levels
   - Return structured question data

5. **IFileStorage**
   - Upload files to Azure Blob Storage
   - Generate signed URLs for downloads
   - Manage file lifecycle

6. **ILeaderboardService**
   - Calculate Story Mode leaderboard (top 10 by XP)
   - Calculate Battle leaderboard (top 10 by ELO/win rate)
   - Cache snapshots for performance

7. **IForumService**
   - CRUD operations for threads/posts
   - Moderation tools
   - Pagination support

### SignalR Implementation

**For .NET Framework Web Forms**:
- Use **SignalR 2.x** (last version for .NET Framework)
- Create `BattleHub` for real-time quiz battles
- Configure in `Global.asax.cs` or via OWIN startup
- Client-side: Use SignalR JavaScript client

**Hub Methods**:
- `JoinRoom(string roomCode)`
- `LeaveRoom(string roomCode)`
- `ReadyCheck(string roomCode)`
- `SubmitAnswer(string roomCode, string questionId, int answerIndex)`
- `GetScore(string roomCode)`

### Azure Integration

**Required Azure Resources**:
1. **Azure SQL Database** (replace LocalDB)
2. **Azure Blob Storage** (for PDF/PPT uploads)
3. **Azure App Service** (for hosting)
4. **Azure SignalR Service** (optional, for scale-out)
5. **Azure OpenAI** (for question generation)

**Configuration**:
- Create `appsettings.Production.json` (even for Web Forms, can use custom config reader)
- Store connection strings in Azure App Service Configuration
- Use Azure Key Vault for secrets (optional)

### Data Access Strategy

**Option 1: Keep ADO.NET, Add Repository Pattern**
- Create repository interfaces
- Implement with ADO.NET
- Inject via simple DI container or static factory

**Option 2: Add Entity Framework 6** (not EF Core, as this is .NET Framework)
- Install EF6 NuGet package
- Create DbContext
- Migrate to Code First or Database First
- Use migrations for schema changes

**Recommendation**: Start with Option 1 (Repository pattern with ADO.NET) for minimal disruption, then consider EF6 if needed.

---

## Current vs. Target Comparison

| Component | Current | Target |
|-----------|---------|--------|
| Framework | Web Forms (.NET Framework 4.7.2) | Web Forms (enhanced) OR ASP.NET Core |
| Data Access | Direct ADO.NET | Repository pattern + ADO.NET (or EF6) |
| Authentication | Custom session-based | Keep custom OR migrate to Identity |
| Real-time | None | SignalR 2.x (or Core SignalR if migrated) |
| File Storage | Local file system | Azure Blob Storage |
| AI Integration | None | Azure OpenAI service |
| Testing | None | Unit + Integration tests |
| Azure Deployment | Not configured | Azure App Service ready |

---

## Migration Path (If Moving to ASP.NET Core)

If the decision is made to migrate to ASP.NET Core:

1. **Create new ASP.NET Core project**
2. **Migrate database schema** (keep as-is, use EF Core)
3. **Migrate authentication** (ASP.NET Core Identity)
4. **Migrate pages** (Web Forms → Razor Pages/MVC)
5. **Add SignalR** (native support in Core)
6. **Add Azure services** (better integration)
7. **Migrate business logic** (services layer)

**Estimated Effort**: 3-4 weeks for full migration

---

## Next Steps

1. Review this architecture document
2. Decide on migration path (enhance Web Forms vs. migrate to Core)
3. Proceed with gap analysis
4. Implement missing features incrementally


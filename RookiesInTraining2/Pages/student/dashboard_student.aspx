<%@ Page Title="Student Dashboard"
    Language="C#"
    MasterPageFile="~/MasterPages/MyMain.Master"
    AutoEventWireup="true"
    CodeBehind="dashboard_student.aspx.cs"
    Inherits="RookiesInTraining2.Pages.dashboard_student" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <!-- CSS -->
    <link rel="stylesheet" href="<%= ResolveUrl("~/Content/student-dashboard.css") %>" />

    <div class="student-dashboard">
        
        <!-- Header Section -->
        <div class="dashboard-header">
            <div class="container-fluid py-4">
                <div class="row align-items-center">
                    <div class="col-lg-8">
                        <h1 class="mb-2" style="color: white;">
                            Welcome back, <span id="studentName" style="color: #ffd700;"></span>!                        </h1>
                        <div class="d-flex flex-wrap gap-4 mt-3">
                            <div class="stat-badge">
                                <i class="bi bi-star-fill text-warning"></i>
                                <span class="stat-value" id="totalXP">0</span> XP
                            </div>
                            <div class="stat-badge">
                                <i class="bi bi-fire text-danger"></i>
                                <span class="stat-value" id="streak">0</span> day streak
                            </div>
                            <div class="stat-badge">
                                <i class="bi bi-trophy-fill text-success"></i>
                                <span class="stat-value">
                                    <span id="completedCount">0</span>/<span id="totalCount">0</span>
                                </span> quizzes
                            </div>
                        </div>
                        
                        <!-- Overall Progress Bar -->
                        <div class="mt-3">
                            <div class="d-flex justify-content-between align-items-center mb-1">
                                <small style="color: white;">Overall Progress</small>
                                <small style="color: white;"><span id="progressPct">0</span>%</small>
                            </div>
                            <div class="progress" style="height: 8px;">
                                <div id="overallProgress" class="progress-bar bg-primary" 
                                     role="progressbar" style="width: 0%"></div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-lg-4 text-lg-end mt-3 mt-lg-0">
                        <div class="d-flex flex-column gap-2 align-items-lg-end">
                            <button id="btnContinue" class="btn btn-primary btn-lg px-4 py-2" type="button">
                                <i class="bi bi-play-circle-fill me-2"></i>Continue Learning
                            </button>
                            <asp:HyperLink ID="lnkMultiplayerGame" runat="server" 
                                          NavigateUrl="~/Pages/game/game_dashboard.aspx"
                                          CssClass="btn btn-success btn-lg px-4 py-2">
                                <i class="bi bi-controller me-2"></i>Multiplayer Quiz Game
                            </asp:HyperLink>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- My Classes Section -->
        <div class="container-fluid py-4">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <div>
                    <h3 class="mb-1">My Classes</h3>
                    <p class="text-muted mb-0">Your enrolled classes</p>
                </div>
                <asp:HyperLink ID="lnkJoinClass" runat="server" 
                              NavigateUrl="~/Pages/student/join_class.aspx"
                              CssClass="btn btn-success btn-lg">
                    <i class="bi bi-plus-circle me-2"></i>Join New Class
                </asp:HyperLink>
            </div>
            
            <div id="classesGrid" class="row g-4">
                <!-- Class cards will be inserted here by JavaScript -->
            </div>
            
            <div id="noClasses" class="text-center py-5" style="display: none;">
                <i class="bi bi-door-open display-1 text-muted opacity-25"></i>
                <h4 class="mt-3 mb-2">No Classes Yet</h4>
                <p class="text-muted">Join your first class to start learning!</p>
                <asp:HyperLink ID="lnkJoinFirst" runat="server" 
                              NavigateUrl="~/Pages/student/join_class.aspx"
                              CssClass="btn btn-success btn-lg mt-3">
                    <i class="bi bi-plus-circle me-2"></i>Join a Class
                </asp:HyperLink>
            </div>
        </div>

        <!-- Quiz Rail Section (Hidden by default, shown when module selected) -->
        <div id="quizRailSection" class="container-fluid py-4" style="display: none;">
            <div class="quiz-rail-header mb-3">
                <button id="btnBackToModules" class="btn btn-sm btn-outline-secondary mb-2">
                    <i class="bi bi-arrow-left me-1"></i> Back to Modules
                </button>
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h3 class="mb-1" id="currentModuleTitle"></h3>
                        <p class="text-muted mb-0" id="currentModuleSummary"></p>
                    </div>
                    <button id="btnModuleContinue" class="btn btn-primary" type="button">
                        <i class="bi bi-play-circle-fill me-2"></i>Continue
                    </button>
                </div>
            </div>
            
            <div class="rail-container">
                <div class="rail-mask">
                    <div class="story-rail" tabindex="0" aria-label="Quiz levels" id="quizRail">
                        <!-- Quiz cards will be inserted here -->
                    </div>
                </div>
            </div>
        </div>

        <!-- Badges Section -->
        <div class="container-fluid py-4">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h4 class="mb-0">Your Badges</h4>
                <a href="#" class="btn btn-sm btn-outline-primary">View All</a>
            </div>
            
            <div id="badgesGrid" class="badges-grid">
                <!-- Badges will be inserted here -->
            </div>
            
            <div id="noBadges" class="text-center text-muted py-5" style="display: none;">
                <i class="bi bi-award display-4 mb-3 d-block"></i>
                <p>No badges earned yet. Complete quizzes to earn badges!</p>
            </div>
        </div>

        <!-- Empty State (hidden by default) -->
        <div id="emptyState" class="container py-5 text-center" style="display: none;">
            <div class="py-5">
                <i class="bi bi-compass display-1 text-muted mb-4"></i>
                <h3 class="mb-3">No modules yet</h3>
                <p class="text-muted">Check back soon for exciting new learning content!</p>
            </div>
        </div>

        <!-- Hidden Fields for Data -->
        <asp:HiddenField ID="hfModulesJson" runat="server" />
        <asp:HiddenField ID="hfQuizzesJson" runat="server" />
        <asp:HiddenField ID="hfSummaryJson" runat="server" />
        <asp:HiddenField ID="hfBadgesJson" runat="server" />
    </div>

    <!-- Expose data as global variables for JavaScript -->
    <script type="text/javascript">
        window.DASHBOARD_DATA = {
            modulesFieldId: '<%= hfModulesJson.ClientID %>',
            quizzesFieldId: '<%= hfQuizzesJson.ClientID %>',
            summaryFieldId: '<%= hfSummaryJson.ClientID %>',
            badgesFieldId: '<%= hfBadgesJson.ClientID %>'
        };
        
        // Load and render classes
        document.addEventListener('DOMContentLoaded', function() {
            console.log('[Dashboard] ===== DOM CONTENT LOADED =====');
            console.log('[Dashboard] DASHBOARD_DATA:', window.DASHBOARD_DATA);
            loadClasses();
        });
        
        function loadClasses() {
            console.log('[Dashboard] ===== loadClasses() CALLED =====');
            
            const modulesFieldId = window.DASHBOARD_DATA.modulesFieldId;
            console.log('[Dashboard] Looking for hidden field with ID:', modulesFieldId);
            
            const modulesField = document.getElementById(modulesFieldId);
            console.log('[Dashboard] Hidden field element:', modulesField);
            console.log('[Dashboard] Hidden field value:', modulesField?.value);
            console.log('[Dashboard] Hidden field value length:', modulesField?.value?.length);
            
            const container = document.getElementById('classesGrid');
            const noClasses = document.getElementById('noClasses');
            
            console.log('[Dashboard] Container element:', container);
            console.log('[Dashboard] No classes element:', noClasses);
            
            if (!modulesField) {
                console.error('[Dashboard] ❌ Hidden field NOT FOUND! ID:', modulesFieldId);
                container.style.display = 'none';
                noClasses.style.display = 'block';
                return;
            }
            
            if (!modulesField.value) {
                console.warn('[Dashboard] ⚠️ Hidden field is EMPTY');
                container.style.display = 'none';
                noClasses.style.display = 'block';
                return;
            }
            
            try {
                console.log('[Dashboard] Parsing JSON...');
                const classes = JSON.parse(modulesField.value);
                console.log('[Dashboard] ✅ Parsed classes:', classes);
                console.log('[Dashboard] Classes count:', classes.length);
                
                if (classes.length === 0) {
                    console.warn('[Dashboard] No classes in array');
                    container.style.display = 'none';
                    noClasses.style.display = 'block';
                    return;
                }
                
                console.log('[Dashboard] Rendering', classes.length, 'class cards...');
                container.style.display = 'flex';
                noClasses.style.display = 'none';
                
                container.innerHTML = classes.map(cls => `
                    <div class="col-md-6 col-lg-4">
                        <div class="card h-100 border-0 shadow-sm" style="cursor: pointer; --class-color: ${cls.Color}"
                             onclick="window.location.href='student_class.aspx?class=${cls.ClassSlug}'">
                            <div class="card-header" style="background: linear-gradient(135deg, ${cls.Color}, ${cls.Color}90); border: none; color: white; padding: 1.5rem;">
                                <div class="d-flex align-items-center">
                                    <i class="${cls.Icon} fs-2 me-3"></i>
                                    <div class="flex-grow-1">
                                        <h5 class="mb-0">${escapeHtml(cls.ClassName)}</h5>
                                        <small class="opacity-75">${cls.ClassCode}</small>
                                    </div>
                                </div>
                            </div>
                            <div class="card-body">
                                <p class="text-muted small mb-3">${escapeHtml(cls.Description || 'No description')}</p>
                                <div class="d-flex justify-content-between align-items-center">
                                    <span class="badge bg-light text-dark">
                                        <i class="bi bi-layers me-1"></i>${cls.Total} levels
                                    </span>
                                    <span class="badge ${cls.Completed > 0 ? 'bg-success' : 'bg-secondary'}">
                                        <i class="bi bi-check-circle me-1"></i>${cls.Completed}/${cls.Total}
                                    </span>
                                </div>
                            </div>
                            <div class="card-footer bg-light border-0 text-center">
                                <small class="text-primary fw-semibold">
                                    <i class="bi bi-arrow-right-circle me-1"></i>Click to open class
                                </small>
                            </div>
                        </div>
                    </div>
                `).join('');
                
                console.log('[Dashboard] ✅ Successfully rendered', classes.length, 'class cards');
            } catch (error) {
                console.error('[Dashboard] ❌ Error loading/rendering classes:', error);
                console.error('[Dashboard] Error stack:', error.stack);
                container.style.display = 'none';
                noClasses.style.display = 'block';
            }
        }
        
        function escapeHtml(text) {
            const div = document.createElement('div');
            div.textContent = text || '';
            return div.innerHTML;
        }
    </script>

    <!-- JavaScript -->
    <script src="<%= ResolveUrl("~/Scripts/student-dashboard.js") %>"></script>
</asp:Content>

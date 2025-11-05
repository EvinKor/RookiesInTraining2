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
                        <h1 class="mb-2">
                            Welcome back, <span class="text-primary" id="studentName"></span>! 🚀
                        </h1>
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
                                <small class="text-muted">Overall Progress</small>
                                <small class="text-muted"><span id="progressPct">0</span>%</small>
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
                            <asp:Button ID="btnLogout" runat="server" 
                                        CssClass="btn btn-outline-secondary" 
                                        Text="Logout"
                                        OnClick="btnLogout_Click" />
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Module Grid Section -->
        <div class="container-fluid py-4">
            <div class="mb-3">
                <h3 class="mb-1">Learning Modules</h3>
                <p class="text-muted">Choose a module to start learning</p>
            </div>
            
            <div id="moduleGrid" class="module-grid">
                <!-- Module cards will be inserted here by JavaScript -->
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
    </script>

    <!-- JavaScript -->
    <script src="<%= ResolveUrl("~/Scripts/student-dashboard.js") %>"></script>
</asp:Content>

<%@ Page Title="Teacher Dashboard"
    Language="C#"
    MasterPageFile="~/MasterPages/dashboard.Master"
    AutoEventWireup="true"
    CodeBehind="dashboard_teacher.aspx.cs"
    Inherits="RookiesInTraining2.Pages.dashboard_teacher" %>

<asp:Content ID="Content1" ContentPlaceHolderID="DashboardContent" runat="server">
    
    <!-- Welcome Section -->
    <div class="row mb-4">
        <div class="col-12">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h2 class="mb-1">Welcome, <asp:Label ID="lblTeacherName" runat="server" CssClass="text-primary" /></h2>
                    <p class="text-muted mb-0">You have <asp:Label ID="lblTodayClasses" runat="server" Text="0" /> classes today</p>
                </div>
                <div class="text-end">
                    <small class="text-muted d-block">Today</small>
                    <strong><asp:Label ID="lblCurrentDate" runat="server" /></strong>
                </div>
            </div>
        </div>
    </div>

    <!-- Stats Cards -->
    <div class="row g-3 mb-4">
        <div class="col-md-3">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-body">
                    <div class="d-flex align-items-center">
                        <div class="flex-shrink-0">
                            <div class="bg-primary bg-opacity-10 rounded-3 p-3">
                                <i class="bi bi-book text-primary fs-3"></i>
                            </div>
                        </div>
                        <div class="flex-grow-1 ms-3">
                            <h6 class="text-muted mb-1 small">My Courses</h6>
                            <h3 class="mb-0">
                                <asp:Label ID="lblMyCourses" runat="server" Text="0" />
                            </h3>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="col-md-3">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-body">
                    <div class="d-flex align-items-center">
                        <div class="flex-shrink-0">
                            <div class="bg-success bg-opacity-10 rounded-3 p-3">
                                <i class="bi bi-people text-success fs-3"></i>
                            </div>
                        </div>
                        <div class="flex-grow-1 ms-3">
                            <h6 class="text-muted mb-1 small">Total Students</h6>
                            <h3 class="mb-0">
                                <asp:Label ID="lblTotalStudents" runat="server" Text="0" />
                            </h3>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="col-md-3">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-body">
                    <div class="d-flex align-items-center">
                        <div class="flex-shrink-0">
                            <div class="bg-warning bg-opacity-10 rounded-3 p-3">
                                <i class="bi bi-clipboard-check text-warning fs-3"></i>
                            </div>
                        </div>
                        <div class="flex-grow-1 ms-3">
                            <h6 class="text-muted mb-1 small">Pending Assignments</h6>
                            <h3 class="mb-0">
                                <asp:Label ID="lblPendingAssignments" runat="server" Text="0" />
                            </h3>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="col-md-3">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-body">
                    <div class="d-flex align-items-center">
                        <div class="flex-shrink-0">
                            <div class="bg-info bg-opacity-10 rounded-3 p-3">
                                <i class="bi bi-file-earmark-text text-info fs-3"></i>
                            </div>
                        </div>
                        <div class="flex-grow-1 ms-3">
                            <h6 class="text-muted mb-1 small">Teaching Materials</h6>
                            <h3 class="mb-0">
                                <asp:Label ID="lblMaterials" runat="server" Text="0" />
                            </h3>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Two Column Layout -->
    <div class="row g-4">
        <!-- Full Width - My Classes -->
        <div class="col-12">
            <!-- My Classes -->
            <div class="card border-0 shadow-sm mb-4">
                <div class="card-header bg-transparent border-0 d-flex justify-content-between align-items-center py-3">
                    <h5 class="mb-0"><i class="bi bi-collection me-2"></i>My Classes</h5>
                    <div class="d-flex gap-2">
                        <asp:HyperLink runat="server" NavigateUrl="~/Pages/game/game_dashboard.aspx" CssClass="btn btn-sm btn-primary">
                            <i class="bi bi-controller me-1"></i>Multiplayer Game
                        </asp:HyperLink>
                        <a href="<%= ResolveUrl("~/Pages/teacher/teacher_create_module.aspx") %>" class="btn btn-sm btn-success">
                            <i class="bi bi-plus-circle me-1"></i>Create New Class
                        </a>
                    </div>
                </div>
                <div class="card-body">
                    <!-- Classes Grid -->
                    <div class="row g-4" id="classesGrid">
                        <!-- Class cards will be rendered here by JavaScript -->
                    </div>
                    
                    <!-- View More Button -->
                    <div id="viewMoreClasses" class="text-center mt-4" style="display: none;">
                        <a href="<%= ResolveUrl("~/Pages/teacher/manage_classes.aspx") %>" 
                           class="btn btn-outline-primary btn-lg">
                            <i class="bi bi-collection me-2"></i>View All Classes
                            <i class="bi bi-arrow-right ms-2"></i>
                        </a>
                    </div>
                    
                    <!-- Empty State -->
                    <div id="emptyState" class="text-center py-5" style="display: none;">
                        <i class="bi bi-collection display-1 text-muted opacity-25 mb-3"></i>
                        <h4 class="mb-2">No Classes Yet</h4>
                        <p class="text-muted">Create your first class to start teaching!</p>
                        <a href="<%= ResolveUrl("~/Pages/teacher/teacher_create_module.aspx") %>" 
                           class="btn btn-success btn-lg mt-3">
                            <i class="bi bi-plus-circle me-2"></i>Create Your First Class
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <!-- Left Column -->
        <div class="col-lg-8">

            <!-- Recent Activity -->
            <div class="card border-0 shadow-sm">
                <div class="card-header bg-transparent border-0 py-3">
                    <h5 class="mb-0"><i class="bi bi-clock-history me-2"></i>Recent Activity</h5>
                </div>
                <div class="card-body">
                    <asp:Repeater ID="rptActivity" runat="server">
                        <ItemTemplate>
                            <div class="d-flex align-items-start mb-3">
                                <div class="flex-shrink-0">
                                    <div class="rounded-circle bg-<%# Eval("IconColor") %> bg-opacity-10 p-2">
                                        <i class="bi bi-<%# Eval("Icon") %> text-<%# Eval("IconColor") %>"></i>
                                    </div>
                                </div>
                                <div class="flex-grow-1 ms-3">
                                    <p class="mb-1"><%# Eval("ActivityText") %></p>
                                    <small class="text-muted"><%# Eval("TimeAgo") %></small>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                    <asp:Label ID="lblNoActivityMessage" runat="server" CssClass="text-muted text-center d-block py-4"
                               Text="No recent activity" Visible="false" />
                </div>
            </div>
        </div>

        <!-- Right Column -->
        <div class="col-lg-4">
            <!-- Quick Actions -->
            <div class="card border-0 shadow-sm mb-4">
                <div class="card-header bg-transparent border-0 py-3">
                    <h5 class="mb-0"><i class="bi bi-lightning me-2"></i>Quick Actions</h5>
                </div>
                <div class="card-body">
                    <div class="d-grid gap-2">
                        <a href="<%= ResolveUrl("~/Pages/teacher/manage_classes.aspx") %>" class="btn btn-primary text-start">
                            <i class="bi bi-gear me-2"></i>Manage Classes
                        </a>
                        <a href="#" class="btn btn-outline-success text-start">
                            <i class="bi bi-file-earmark-plus me-2"></i>Upload Materials
                        </a>
                        <a href="#" class="btn btn-outline-info text-start">
                            <i class="bi bi-magic me-2"></i>AI Quiz Generator
                        </a>
                        <a href="#" class="btn btn-outline-warning text-start">
                            <i class="bi bi-clipboard-check me-2"></i>Grade Assignments
                        </a>
                        <a href="#" class="btn btn-outline-secondary text-start">
                            <i class="bi bi-graph-up-arrow me-2"></i>View Performance
                        </a>
                    </div>
                </div>
            </div>

            <!-- Pending Assignments -->
            <div class="card border-0 shadow-sm">
                <div class="card-header bg-transparent border-0 d-flex justify-content-between align-items-center py-3">
                    <h5 class="mb-0"><i class="bi bi-clipboard-check me-2"></i>Pending</h5>
                    <span class="badge bg-warning text-dark">
                        <asp:Label ID="lblPendingCount" runat="server" Text="0" />
                    </span>
                </div>
                <div class="card-body">
                    <asp:Repeater ID="rptPendingItems" runat="server">
                        <ItemTemplate>
                            <div class="d-flex align-items-center mb-3 pb-3 border-bottom">
                                <div class="flex-shrink-0">
                                    <div class="rounded-circle bg-warning bg-opacity-10 p-2">
                                        <i class="bi bi-file-text text-warning"></i>
                                    </div>
                                </div>
                                <div class="flex-grow-1 ms-3">
                                    <div class="fw-semibold small"><%# Eval("ItemTitle") %></div>
                                    <small class="text-muted"><%# Eval("CourseName") %></small>
                                </div>
                                <div class="flex-shrink-0">
                                    <span class="badge bg-warning text-dark"><%# Eval("Count") %></span>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                    <asp:Label ID="lblNoPendingMessage" runat="server" CssClass="text-muted text-center d-block py-4"
                               Text="Great! No pending tasks" Visible="false" />
                </div>
            </div>
        </div>
    </div>

    <!-- Hidden Fields -->
    <asp:HiddenField ID="hfClassesJson" runat="server" />

    <!-- JavaScript for rendering class cards -->
    <script src="<%= ResolveUrl("~/Scripts/teacher-browse-classes.js") %>"></script>
    <script>
        window.TEACHER_DATA = {
            teacherSlug: '<%= Session["UserSlug"] %>',
            teacherName: '<%= Session["FullName"] %>',
            classesFieldId: '<%= hfClassesJson.ClientID %>'
        };
        
        // Debug: Check if classes data is loaded
        console.log('TEACHER_DATA:', window.TEACHER_DATA);
        console.log('Hidden field value:', document.getElementById('<%= hfClassesJson.ClientID %>')?.value);
    </script>

    <style>
        /* Light Theme Dashboard */
        body {
            background: #f5f7fa !important;
        }

        .card {
            background: white;
            border: 1px solid #e8ecf1;
        }

        .card-header {
            background: #ffffff !important;
            border-bottom: 1px solid #e8ecf1;
        }

        /* Class Cards */
        .class-card {
            border: 1px solid #e8ecf1;
            border-radius: 1rem;
            overflow: hidden;
            transition: all 0.3s ease;
            cursor: pointer;
            height: 100%;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            background: white;
        }
        .class-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 8px 24px rgba(0,0,0,0.12);
            border-color: var(--card-color, #667eea);
        }
        .class-card-header {
            padding: 1.5rem;
            border-bottom: 3px solid var(--card-color, #667eea);
            background: linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(118, 75, 162, 0.1) 100%);
            color: #2d3748;
        }
        .class-card-body {
            padding: 1.5rem;
            background: white;
        }
        .class-card-footer {
            padding: 1rem 1.5rem;
            background: #f8f9fa;
            border-top: 1px solid #e8ecf1;
            color: #6c757d;
            font-size: 0.875rem;
        }
        .class-icon {
            font-size: 2rem;
            margin-bottom: 0.5rem;
            opacity: 0.9;
        }
        .class-name {
            font-size: 1.25rem;
            font-weight: 600;
            color: #2d3748;
            margin-bottom: 0.5rem;
        }
        .class-code {
            display: inline-block;
            padding: 0.25rem 0.75rem;
            background: white;
            border: 1px solid #e8ecf1;
            border-radius: 0.5rem;
            font-size: 0.875rem;
            color: #6c757d;
            font-weight: 500;
        }
        .class-stats {
            display: flex;
            gap: 1.5rem;
        }
        .class-stat {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        .class-stat i {
            font-size: 1.5rem;
            color: var(--card-color, #667eea);
            opacity: 0.7;
        }
        .class-stat-value {
            font-size: 1.25rem;
            font-weight: 700;
            color: #2d3748;
        }
        .class-stat-label {
            font-size: 0.75rem;
            color: #6c757d;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        /* Stat Cards */
        .bg-primary.bg-opacity-10,
        .bg-success.bg-opacity-10,
        .bg-warning.bg-opacity-10,
        .bg-info.bg-opacity-10 {
            background: #f0f4ff !important;
        }

        /* Text Colors for Light Theme */
        h2, h3, h4, h5, h6 {
            color: #2d3748 !important;
        }
        
        .text-primary {
            color: #667eea !important;
        }
    </style>

</asp:Content>


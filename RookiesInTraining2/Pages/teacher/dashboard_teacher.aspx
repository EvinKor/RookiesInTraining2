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
        <!-- Left Column -->
        <div class="col-lg-8">
            <!-- My Courses -->
            <div class="card border-0 shadow-sm mb-4">
                <div class="card-header bg-transparent border-0 d-flex justify-content-between align-items-center py-3">
                    <h5 class="mb-0"><i class="bi bi-collection me-2"></i>My Classes</h5>
                    <a href="<%= ResolveUrl("~/Pages/teacher/teacher_browse_classes.aspx") %>" class="btn btn-sm btn-primary">
                        <i class="bi bi-eye me-1"></i>View All Classes
                    </a>
                </div>
                <div class="card-body">
                    <asp:Repeater ID="rptCourses" runat="server">
                        <ItemTemplate>
                            <div class="d-flex align-items-center mb-3 pb-3 border-bottom">
                                <div class="flex-shrink-0">
                                    <div class="bg-primary bg-opacity-10 rounded p-3">
                                        <i class="bi bi-book fs-4 text-primary"></i>
                                    </div>
                                </div>
                                <div class="flex-grow-1 ms-3">
                                    <h6 class="mb-1"><%# Eval("CourseName") %></h6>
                                    <small class="text-muted">
                                        <i class="bi bi-people me-1"></i><%# Eval("StudentCount") %> students
                                    </small>
                                </div>
                                <div class="flex-shrink-0 ms-3">
                                    <a href="#" class="btn btn-sm btn-outline-primary me-1">View</a>
                                    <a href="#" class="btn btn-sm btn-outline-secondary">Edit</a>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                    <asp:Label ID="lblNoCoursesMessage" runat="server" CssClass="text-muted text-center d-block py-4"
                               Text="No courses created yet" Visible="false" />
                </div>
            </div>

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
                        <a href="<%= ResolveUrl("~/Pages/teacher/teacher_browse_classes.aspx") %>" class="btn btn-primary text-start">
                            <i class="bi bi-collection me-2"></i>Manage Classes
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

</asp:Content>


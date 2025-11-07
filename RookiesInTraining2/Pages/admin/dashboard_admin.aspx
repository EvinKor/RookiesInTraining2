<%@ Page Title="Admin Dashboard"
    Language="C#"
    MasterPageFile="~/MasterPages/dashboard.Master"
    AutoEventWireup="true"
    CodeBehind="dashboard_admin.aspx.cs"
    Inherits="RookiesInTraining2.Pages.dashboard_admin" %>

<asp:Content ID="Content1" ContentPlaceHolderID="DashboardContent" runat="server">
    
    <!-- Welcome Section -->
    <div class="row mb-4">
        <div class="col-12">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h2 class="mb-1">Admin Console</h2>
                    <p class="text-muted mb-0">System Overview & Management</p>
                </div>
                <div class="text-end">
                    <small class="text-muted d-block">System Time</small>
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
                                <i class="bi bi-people text-primary fs-3"></i>
                            </div>
                        </div>
                        <div class="flex-grow-1 ms-3">
                            <h6 class="text-muted mb-1 small">Total Users</h6>
                            <h3 class="mb-0">
                                <asp:Label ID="lblTotalUsers" runat="server" Text="0" />
                            </h3>
                            <small class="text-success"><i class="bi bi-arrow-up"></i> <asp:Label ID="lblNewUsers" runat="server" Text="0" /> new this month</small>
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
                                <i class="bi bi-book text-success fs-3"></i>
                            </div>
                        </div>
                        <div class="flex-grow-1 ms-3">
                            <h6 class="text-muted mb-1 small">Total Courses</h6>
                            <h3 class="mb-0">
                                <asp:Label ID="lblTotalCourses" runat="server" Text="0" />
                            </h3>
                            <small class="text-info"><asp:Label ID="lblActiveCourses" runat="server" Text="0" /> active</small>
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
                                <i class="bi bi-mortarboard text-warning fs-3"></i>
                            </div>
                        </div>
                        <div class="flex-grow-1 ms-3">
                            <h6 class="text-muted mb-1 small">Total Students</h6>
                            <h3 class="mb-0">
                                <asp:Label ID="lblTotalStudents" runat="server" Text="0" />
                            </h3>
                            <small class="text-muted"><asp:Label ID="lblActiveStudents" runat="server" Text="0" /> active</small>
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
                                <i class="bi bi-person-badge text-info fs-3"></i>
                            </div>
                        </div>
                        <div class="flex-grow-1 ms-3">
                            <h6 class="text-muted mb-1 small">Total Teachers</h6>
                            <h3 class="mb-0">
                                <asp:Label ID="lblTotalTeachers" runat="server" Text="0" />
                            </h3>
                            <small class="text-muted"><asp:Label ID="lblDepartments" runat="server" Text="0" /> departments</small>
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
            <!-- Recent Users -->
            <div class="card border-0 shadow-sm mb-4">
                <div class="card-header bg-transparent border-0 d-flex justify-content-between align-items-center py-3">
                    <h5 class="mb-0"><i class="bi bi-person-plus me-2"></i>Recent Users</h5>
                    <a href="Users.aspx" class="btn btn-sm btn-outline-primary">Manage All Users</a>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover mb-0">
                            <thead>
                                <tr class="text-muted small">
                                    <th class="border-0 ps-4">User</th>
                                    <th class="border-0">Email</th>
                                    <th class="border-0">Role</th>
                                    <th class="border-0">Registered</th>
                                    <th class="border-0 text-end pe-4">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <asp:Repeater ID="rptRecentUsers" runat="server">
                                    <ItemTemplate>
                                        <tr>
                                            <td class="ps-4">
                                                <div class="d-flex align-items-center">
                                                    <img src="<%# Eval("AvatarUrl") %>" class="rounded-circle me-2" 
                                                         style="width: 32px; height: 32px; object-fit: cover;" 
                                                         onerror="this.onerror=null; this.src='data:image/svg+xml,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22%3E%3Ccircle cx=%2250%22 cy=%2250%22 r=%2240%22 fill=%22%23667eea%22/%3E%3Ctext x=%2250%22 y=%2265%22 font-size=%2240%22 text-anchor=%22middle%22 fill=%22white%22%3EA%3C/text%3E%3C/svg%3E';" />
                                                    <span class="fw-semibold"><%# Eval("DisplayName") %></span>
                                                </div>
                                            </td>
                                            <td><%# Eval("Email") %></td>
                                            <td>
                                                <span class="badge bg-<%# GetRoleBadgeColor(Eval("Role").ToString()) %>">
                                                    <%# GetRoleText(Eval("Role").ToString()) %>
                                                </span>
                                            </td>
                                            <td><%# Eval("CreatedAt") %></td>
                                            <td class="text-end pe-4">
                                                <a href="Users.aspx?user=<%# Server.UrlEncode(Eval("UserSlug").ToString()) %>" class="btn btn-sm btn-outline-secondary" title="View User Details">
                                                    <i class="bi bi-pencil"></i>
                                                </a>
                                            </td>
                                        </tr>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </tbody>
                        </table>
                    </div>
                    <asp:Label ID="lblNoUsersMessage" runat="server" CssClass="text-muted text-center d-block py-4"
                               Text="No users found" Visible="false" />
                </div>
            </div>

            <!-- System Activity Log -->
            <div class="card border-0 shadow-sm">
                <div class="card-header bg-transparent border-0 d-flex justify-content-between align-items-center py-3">
                    <h5 class="mb-0"><i class="bi bi-activity me-2"></i>System Activity Log</h5>
                    <a href="#" class="btn btn-sm btn-outline-secondary">View All</a>
                </div>
                <div class="card-body">
                    <asp:Repeater ID="rptSystemLogs" runat="server">
                        <ItemTemplate>
                            <div class="d-flex align-items-start mb-3 pb-3 border-bottom">
                                <div class="flex-shrink-0">
                                    <div class="rounded-circle bg-<%# Eval("StatusColor") %> bg-opacity-10 p-2">
                                        <i class="bi bi-<%# Eval("Icon") %> text-<%# Eval("StatusColor") %>"></i>
                                    </div>
                                </div>
                                <div class="flex-grow-1 ms-3">
                                    <p class="mb-1"><%# Eval("LogMessage") %></p>
                                    <small class="text-muted"><%# Eval("Timestamp") %></small>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                    <asp:Label ID="lblNoLogsMessage" runat="server" CssClass="text-muted text-center d-block py-4"
                               Text="No system logs available" Visible="false" />
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
                        <a href="Users.aspx" class="btn btn-outline-primary text-start">
                            <i class="bi bi-person-plus me-2"></i>Add New User
                        </a>
                        <a href="#" class="btn btn-outline-success text-start">
                            <i class="bi bi-book me-2"></i>Create Course
                        </a>
                        <a href="Reports.aspx" class="btn btn-outline-info text-start">
                            <i class="bi bi-file-earmark-bar-graph me-2"></i>Generate Report
                        </a>
                        <a href="Settings.aspx" class="btn btn-outline-warning text-start">
                            <i class="bi bi-gear me-2"></i>System Settings
                        </a>
                    </div>
                </div>
            </div>

            <!-- System Status -->
            <div class="card border-0 shadow-sm mb-4">
                <div class="card-header bg-transparent border-0 py-3">
                    <h5 class="mb-0"><i class="bi bi-server me-2"></i>System Status</h5>
                </div>
                <div class="card-body">
                    <div class="mb-3">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span class="small text-muted">Database</span>
                            <span class="badge bg-success">Normal</span>
                        </div>
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span class="small text-muted">API Service</span>
                            <span class="badge bg-success">Normal</span>
                        </div>
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span class="small text-muted">Storage</span>
                            <span class="badge bg-warning text-dark">75% Used</span>
                        </div>
                        <div class="d-flex justify-content-between align-items-center">
                            <span class="small text-muted">Backup Status</span>
                            <span class="badge bg-success">Latest: Today</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Alerts/Notifications -->
            <div class="card border-0 shadow-sm">
                <div class="card-header bg-transparent border-0 py-3">
                    <h5 class="mb-0"><i class="bi bi-bell me-2"></i>System Notifications</h5>
                </div>
                <div class="card-body">
                    <asp:Repeater ID="rptAlerts" runat="server">
                        <ItemTemplate>
                            <div class="alert alert-<%# Eval("AlertType") %> py-2 mb-2">
                                <small><i class="bi bi-<%# Eval("Icon") %> me-1"></i><%# Eval("Message") %></small>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                    <asp:Label ID="lblNoAlertsMessage" runat="server" CssClass="text-muted text-center d-block py-3"
                               Text="No system notifications" Visible="false" />
                </div>
            </div>
        </div>
    </div>

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

        /* Ensure Bootstrap Icons display correctly */
        .bi {
            display: inline-block;
            font-family: "bootstrap-icons" !important;
            font-style: normal;
            font-weight: normal !important;
            font-variant: normal;
            text-transform: none;
            line-height: 1;
            vertical-align: -.125em;
            -webkit-font-smoothing: antialiased;
            -moz-osx-font-smoothing: grayscale;
        }
    </style>

</asp:Content>

<%@ Page Title="Reports"
    Language="C#"
    MasterPageFile="~/MasterPages/dashboard.Master"
    AutoEventWireup="true"
    CodeBehind="Reports.aspx.cs"
    Inherits="RookiesInTraining2.Pages.AdminReports" %>

<asp:Content ID="Content1" ContentPlaceHolderID="DashboardContent" runat="server">
    <!-- Page Header -->
    <div class="row mb-4">
        <div class="col-12">
            <div class="d-flex align-items-center mb-3">
                <a href="dashboard_admin.aspx" class="btn btn-outline-secondary me-3">
                    <i class="bi bi-arrow-left me-2"></i>Back to Dashboard
                </a>
                <div class="flex-grow-1">
                    <h2 class="mb-1">System Reports</h2>
                    <p class="text-muted mb-0">Review platform performance and export insights</p>
                </div>
                <div class="d-flex gap-2">
                    <asp:Button ID="btnPrint" runat="server" Text="Print" CssClass="btn btn-outline-primary" OnClick="btnPrint_Click" />
                    <asp:Button ID="btnExportCsv" runat="server" Text="Export CSV" CssClass="btn btn-primary" OnClick="btnExportCsv_Click" />
                </div>
            </div>
        </div>
    </div>

    <!-- Filters -->
    <div class="card border-0 shadow-sm mb-4">
        <div class="card-body">
            <div class="row g-3 align-items-end">
                <div class="col-md-3">
                    <label class="form-label fw-semibold">Start Date</label>
                    <asp:TextBox ID="txtStartDate" runat="server" CssClass="form-control" TextMode="Date" />
                </div>
                <div class="col-md-3">
                    <label class="form-label fw-semibold">End Date</label>
                    <asp:TextBox ID="txtEndDate" runat="server" CssClass="form-control" TextMode="Date" />
                </div>
                <div class="col-md-3">
                    <label class="form-label fw-semibold">Role</label>
                    <asp:DropDownList ID="ddlRoleFilter" runat="server" CssClass="form-select">
                        <asp:ListItem Text="All Roles" Value="" Selected="True" />
                        <asp:ListItem Text="Students" Value="student" />
                        <asp:ListItem Text="Teachers" Value="teacher" />
                        <asp:ListItem Text="Admins" Value="admin" />
                    </asp:DropDownList>
                </div>
                <div class="col-md-3">
                    <asp:Button ID="btnApplyFilters" runat="server" Text="Apply Filters" CssClass="btn btn-success w-100" OnClick="btnApplyFilters_Click" />
                </div>
            </div>
        </div>
    </div>

    <!-- Summary Cards -->
    <div class="row g-3 mb-4">
        <div class="col-md-3">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-body">
                    <div class="d-flex align-items-center justify-content-between">
                        <div>
                            <p class="text-muted mb-1">Total Users</p>
                            <h3 class="mb-0"><asp:Label ID="lblTotalUsers" runat="server" Text="-" /></h3>
                        </div>
                        <div class="icon-circle text-primary bg-primary bg-opacity-10">
                            <i class="bi bi-people"></i>
                        </div>
                    </div>
                    <small class="text-muted">All active users in the system</small>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-body">
                    <div class="d-flex align-items-center justify-content-between">
                        <div>
                            <p class="text-muted mb-1">New Users</p>
                            <h3 class="mb-0"><asp:Label ID="lblNewUsers" runat="server" Text="-" /></h3>
                        </div>
                        <div class="icon-circle text-success bg-success bg-opacity-10">
                            <i class="bi bi-person-plus"></i>
                        </div>
                    </div>
                    <small class="text-muted">Registered in selected period</small>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-body">
                    <div class="d-flex align-items-center justify-content-between">
                        <div>
                            <p class="text-muted mb-1">Active Teachers</p>
                            <h3 class="mb-0"><asp:Label ID="lblTeacherCount" runat="server" Text="-" /></h3>
                        </div>
                        <div class="icon-circle text-info bg-info bg-opacity-10">
                            <i class="bi bi-mortarboard"></i>
                        </div>
                    </div>
                    <small class="text-muted">Teachers currently active</small>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-body">
                    <div class="d-flex align-items-center justify-content-between">
                        <div>
                            <p class="text-muted mb-1">Average Daily Signups</p>
                            <h3 class="mb-0"><asp:Label ID="lblAverageDaily" runat="server" Text="-" /></h3>
                        </div>
                        <div class="icon-circle text-warning bg-warning bg-opacity-10">
                            <i class="bi bi-graph-up"></i>
                        </div>
                    </div>
                    <small class="text-muted">Average users per day in period</small>
                </div>
            </div>
        </div>
    </div>

    <!-- Role Breakdown -->
    <div class="card border-0 shadow-sm mb-4">
        <div class="card-header bg-transparent border-0 py-3 d-flex justify-content-between align-items-center">
            <h5 class="mb-0"><i class="bi bi-pie-chart me-2"></i>User Role Breakdown</h5>
            <span class="text-muted small">Distribution by role</span>
        </div>
        <div class="card-body">
            <div class="row g-4">
                <asp:Repeater ID="rptRoleBreakdown" runat="server">
                    <ItemTemplate>
                        <div class="col-md-4">
                            <div class="border rounded p-3 h-100">
                                <div class="d-flex justify-content-between align-items-center mb-2">
                                    <h6 class="mb-0"><%# Eval("RoleName") %></h6>
                                    <span class="badge bg-<%# Eval("BadgeColor") %>"><%# Eval("UserCount") %></span>
                                </div>
                                <div class="progress" style="height: 8px;">
                                    <div class="progress-bar bg-<%# Eval("BadgeColor") %>" role="progressbar" style="width: <%# Eval("Percentage") %>%"></div>
                                </div>
                                <small class="text-muted d-block mt-2"><%# Eval("Percentage", "{0:N1}% of users") %></small>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </div>

    <!-- Detailed Table -->
    <div class="card border-0 shadow-sm mb-4">
        <div class="card-header bg-transparent border-0 py-3 d-flex justify-content-between align-items-center">
            <h5 class="mb-0"><i class="bi bi-table me-2"></i>User Activity Report</h5>
            <asp:Label ID="lblResultCount" runat="server" CssClass="text-muted small" />
        </div>
        <div class="card-body p-0">
            <asp:GridView ID="gvReport" runat="server" CssClass="table table-hover mb-0" AutoGenerateColumns="false" GridLines="None">
                <HeaderStyle CssClass="table-light" />
                <Columns>
                    <asp:BoundField DataField="display_name" HeaderText="Name" />
                    <asp:BoundField DataField="email" HeaderText="Email" />
                    <asp:BoundField DataField="role_global" HeaderText="Role" />
                    <asp:BoundField DataField="created_at" HeaderText="Registered" HtmlEncode="false" DataFormatString="{0:yyyy-MM-dd HH:mm}" />
                    <asp:BoundField DataField="last_login_at" HeaderText="Last Login" HtmlEncode="false" DataFormatString="{0:yyyy-MM-dd HH:mm}" />
                    <asp:BoundField DataField="class_count" HeaderText="Classes" />
                </Columns>
            </asp:GridView>
            <asp:Label ID="lblNoResults" runat="server" CssClass="text-center text-muted d-block py-4" Text="No data available for selected filters" Visible="false" />
        </div>
    </div>

    <!-- Recent Activity -->
    <div class="card border-0 shadow-sm mb-4">
        <div class="card-header bg-transparent border-0 py-3">
            <h5 class="mb-0"><i class="bi bi-clock-history me-2"></i>Recent Registrations</h5>
        </div>
        <div class="card-body p-0">
            <asp:Repeater ID="rptRecentRegistrations" runat="server">
                <HeaderTemplate>
                    <ul class="list-group list-group-flush">
                </HeaderTemplate>
                <ItemTemplate>
                    <li class="list-group-item d-flex justify-content-between align-items-center">
                        <div>
                            <div class="fw-semibold"><%# Eval("DisplayName") %> <span class="badge bg-<%# Eval("BadgeColor") %> ms-2"><%# Eval("Role") %></span></div>
                            <small class="text-muted">Joined <%# Eval("JoinedAgo") %></small>
                        </div>
                        <div class="text-end">
                            <small class="d-block text-muted"><%# Eval("Email") %></small>
                            <small class="text-muted"><%# Eval("CreatedAt") %></small>
                        </div>
                    </li>
                </ItemTemplate>
                <FooterTemplate>
                    </ul>
                </FooterTemplate>
            </asp:Repeater>
            <asp:Label ID="lblNoRecent" runat="server" CssClass="text-center text-muted d-block py-4" Text="No recent registrations" Visible="false" />
        </div>
    </div>

    <asp:Label ID="lblPageError" runat="server" CssClass="alert alert-danger d-none" />
    <asp:Label ID="lblPageMessage" runat="server" CssClass="alert alert-success d-none" />

    <style>
        body {
            background: #f5f7fa !important;
        }

        .card {
            background: #ffffff;
            border: 1px solid #e8ecf1;
        }

        .card-header {
            background: #ffffff !important;
            border-bottom: 1px solid #e8ecf1;
        }

        h2, h3, h4, h5, h6 {
            color: #2d3748 !important;
        }

        .icon-circle {
            width: 44px;
            height: 44px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.25rem;
        }

        .table th, .table td {
            vertical-align: middle;
        }

        .list-group-item {
            padding: 1rem 1.25rem;
        }

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

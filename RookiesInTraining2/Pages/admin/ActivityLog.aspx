<%@ Page Title="Activity Log"
    Language="C#"
    MasterPageFile="~/MasterPages/dashboard.Master"
    AutoEventWireup="true"
    CodeBehind="ActivityLog.aspx.cs"
    Inherits="RookiesInTraining2.Pages.admin.ActivityLog" %>

<asp:Content ID="Content1" ContentPlaceHolderID="DashboardContent" runat="server">
    
    <!-- Page Header -->
    <div class="row mb-4">
        <div class="col-12">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h2 class="mb-1"><i class="bi bi-activity me-2"></i>System Activity Log</h2>
                    <p class="text-muted mb-0">Complete audit trail of all admin actions</p>
                </div>
            </div>
        </div>
    </div>

    <!-- Filters -->
    <div class="card border-0 shadow-sm mb-4">
        <div class="card-body">
            <div class="row g-3 align-items-end">
                <div class="col-md-3">
                    <label class="form-label fw-semibold">Action Type</label>
                    <asp:DropDownList ID="ddlActionType" runat="server" CssClass="form-select">
                        <asp:ListItem Text="All Actions" Value="" Selected="True" />
                        <asp:ListItem Text="Create User" Value="create_user" />
                        <asp:ListItem Text="Delete User" Value="delete_user" />
                        <asp:ListItem Text="Block User" Value="block_user" />
                        <asp:ListItem Text="Unblock User" Value="unblock_user" />
                        <asp:ListItem Text="Edit User" Value="edit_user" />
                        <asp:ListItem Text="Change Role" Value="change_role" />
                        <asp:ListItem Text="Delete Class" Value="delete_class" />
                        <asp:ListItem Text="Delete Post" Value="delete_post" />
                        <asp:ListItem Text="Edit Post" Value="edit_post" />
                        <asp:ListItem Text="Delete Reply" Value="delete_reply" />
                        <asp:ListItem Text="Edit Reply" Value="edit_reply" />
                    </asp:DropDownList>
                </div>
                <div class="col-md-3">
                    <label class="form-label fw-semibold">Admin</label>
                    <asp:TextBox ID="txtAdminSearch" runat="server" CssClass="form-control" placeholder="Search by admin name" />
                </div>
                <div class="col-md-2">
                    <label class="form-label fw-semibold">Start Date</label>
                    <asp:TextBox ID="txtStartDate" runat="server" CssClass="form-control" TextMode="Date" />
                </div>
                <div class="col-md-2">
                    <label class="form-label fw-semibold">End Date</label>
                    <asp:TextBox ID="txtEndDate" runat="server" CssClass="form-control" TextMode="Date" />
                </div>
                <div class="col-md-2">
                    <asp:Button ID="btnApplyFilters" runat="server" Text="Apply Filters" CssClass="btn btn-success w-100" OnClick="btnApplyFilters_Click" />
                </div>
            </div>
        </div>
    </div>

    <!-- Activity Log Table -->
    <div class="card border-0 shadow-sm">
        <div class="card-header bg-transparent border-0 py-3 d-flex justify-content-between align-items-center">
            <h5 class="mb-0"><i class="bi bi-list-ul me-2"></i>Activity Logs</h5>
            <asp:Label ID="lblLogCount" runat="server" CssClass="text-muted small" />
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <asp:GridView ID="gvActivityLogs" runat="server" CssClass="table table-hover mb-0" 
                    AutoGenerateColumns="false" GridLines="None" AllowPaging="true" PageSize="50"
                    AllowSorting="true" OnPageIndexChanging="gvActivityLogs_PageIndexChanging"
                    OnSorting="gvActivityLogs_Sorting" PagerSettings-Mode="NumericFirstLast">
                    <HeaderStyle CssClass="table-light" />
                    <PagerStyle CssClass="pagination justify-content-center" />
                    <Columns>
                        <asp:TemplateField HeaderText="Action" SortExpression="action_type">
                            <ItemTemplate>
                                <div class="d-flex align-items-center">
                                    <div class="rounded-circle bg-<%# GetActionColor(Eval("ActionType").ToString()) %> bg-opacity-10 p-2 me-2">
                                        <i class="bi bi-<%# GetActionIcon(Eval("ActionType").ToString()) %> text-<%# GetActionColor(Eval("ActionType").ToString()) %>"></i>
                                    </div>
                                    <span class="fw-semibold"><%# FormatActionType(Eval("ActionType").ToString()) %></span>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="AdminName" HeaderText="Admin" SortExpression="admin_name" />
                        <asp:BoundField DataField="TargetType" HeaderText="Target Type" SortExpression="target_type" />
                        <asp:BoundField DataField="Details" HeaderText="Details" />
                        <asp:BoundField DataField="CreatedAt" HeaderText="Date & Time" SortExpression="created_at" HtmlEncode="false" DataFormatString="{0:yyyy-MM-dd HH:mm:ss}" />
                    </Columns>
                </asp:GridView>
            </div>
            <asp:Label ID="lblNoLogs" runat="server" CssClass="text-center text-muted d-block py-4" Text="No activity logs found" Visible="false" />
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
        .table th, .table td {
            vertical-align: middle;
        }
    </style>

</asp:Content>


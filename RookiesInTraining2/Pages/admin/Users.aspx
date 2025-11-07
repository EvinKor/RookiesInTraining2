<%@ Page Title="Manage Users"
    Language="C#"
    MasterPageFile="~/MasterPages/dashboard.Master"
    AutoEventWireup="true"
    CodeBehind="Users.aspx.cs"
    Inherits="RookiesInTraining2.Pages.ManageUsers" %>

<asp:Content ID="Content1" ContentPlaceHolderID="DashboardContent" runat="server">
    
    <!-- Page Header -->
    <div class="row mb-4">
        <div class="col-12">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h2 class="mb-1">User Management</h2>
                    <p class="text-muted mb-0">Manage all users in the system</p>
                </div>
                <div>
                    <button type="button" class="btn btn-success" data-bs-toggle="modal" data-bs-target="#createUserModal">
                        <i class="bi bi-person-plus me-2"></i>Create New User
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Filters and Search -->
    <div class="row mb-3">
        <div class="col-md-6">
            <div class="input-group">
                <span class="input-group-text"><i class="bi bi-search"></i></span>
                <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" placeholder="Search by name or email..." AutoPostBack="true" OnTextChanged="txtSearch_TextChanged" />
            </div>
        </div>
        <div class="col-md-3">
            <asp:DropDownList ID="ddlRoleFilter" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlRoleFilter_SelectedIndexChanged">
                <asp:ListItem Value="" Text="All Roles" />
                <asp:ListItem Value="student" Text="Students" />
                <asp:ListItem Value="teacher" Text="Teachers" />
                <asp:ListItem Value="admin" Text="Admins" />
            </asp:DropDownList>
        </div>
        <div class="col-md-3">
            <asp:Label ID="lblUserCount" runat="server" CssClass="form-control text-muted" />
        </div>
    </div>

    <!-- Users Table -->
    <div class="card border-0 shadow-sm">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover mb-0">
                    <thead class="table-light">
                        <tr>
                            <th class="ps-4">User</th>
                            <th>Email</th>
                            <th>Role</th>
                            <th>Registered</th>
                            <th class="text-end pe-4">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="rptUsers" runat="server" OnItemCommand="rptUsers_ItemCommand">
                            <ItemTemplate>
                                <tr>
                                    <td class="ps-4">
                                        <div class="d-flex align-items-center">
                                            <div class="rounded-circle bg-primary text-white d-flex align-items-center justify-content-center me-2" 
                                                 style="width: 40px; height: 40px; font-weight: 600;">
                                                <%# Eval("DisplayName").ToString().Substring(0, 1).ToUpper() %>
                                            </div>
                                            <div>
                                                <div class="fw-semibold"><%# Eval("DisplayName") %></div>
                                                <small class="text-muted"><%# Eval("UserSlug") %></small>
                                            </div>
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
                                        <button type="button" class="btn btn-sm btn-outline-info me-1 view-user-btn" 
                                                data-user-slug="<%# Server.HtmlEncode(Eval("UserSlug").ToString()) %>"
                                                data-display-name="<%# Server.HtmlEncode(Eval("DisplayName").ToString()) %>"
                                                data-email="<%# Server.HtmlEncode(Eval("Email").ToString()) %>"
                                                data-role="<%# Server.HtmlEncode(Eval("Role").ToString()) %>"
                                                data-created-at="<%# Server.HtmlEncode(Eval("CreatedAt").ToString()) %>">
                                            <i class="bi bi-eye"></i>
                                        </button>
                                        <asp:LinkButton ID="btnDelete" runat="server" 
                                                        CommandName="DeleteUser" 
                                                        CommandArgument='<%# Eval("UserSlug") %>'
                                                        CssClass="btn btn-sm btn-outline-danger"
                                                        OnClientClick="return confirm('Are you sure you want to delete this user? This action cannot be undone.');">
                                            <i class="bi bi-trash"></i>
                                        </asp:LinkButton>
                                    </td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
            </div>
            <asp:Label ID="lblNoUsers" runat="server" CssClass="text-muted text-center d-block py-5"
                       Text="No users found" Visible="false" />
        </div>
    </div>

    <!-- Create User Modal -->
    <div class="modal fade" id="createUserModal" tabindex="-1" aria-labelledby="createUserModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="createUserModalLabel">Create New User</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <asp:Panel ID="pnlCreateUser" runat="server" DefaultButton="btnCreateUser">
                    <div class="modal-body">
                        <asp:ValidationSummary ID="vsCreateUser" runat="server" ValidationGroup="CreateUserGroup"
                            CssClass="alert alert-danger py-2" DisplayMode="BulletList" />
                        
                        <div class="mb-3">
                            <label class="form-label">Full Name <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtCreateFullName" runat="server" CssClass="form-control" />
                            <asp:RequiredFieldValidator ID="rfvFullName" runat="server" 
                                ControlToValidate="txtCreateFullName" ValidationGroup="CreateUserGroup"
                                CssClass="text-danger small" ErrorMessage="Full name is required." Display="Dynamic" />
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Email <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtCreateEmail" runat="server" CssClass="form-control" TextMode="Email" />
                            <asp:RequiredFieldValidator ID="rfvEmail" runat="server" 
                                ControlToValidate="txtCreateEmail" ValidationGroup="CreateUserGroup"
                                CssClass="text-danger small" ErrorMessage="Email is required." Display="Dynamic" />
                            <asp:RegularExpressionValidator ID="revEmail" runat="server"
                                ControlToValidate="txtCreateEmail" ValidationGroup="CreateUserGroup"
                                ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"
                                CssClass="text-danger small" ErrorMessage="Invalid email format." Display="Dynamic" />
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Password <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtCreatePassword" runat="server" CssClass="form-control" TextMode="Password" />
                            <asp:RequiredFieldValidator ID="rfvPassword" runat="server" 
                                ControlToValidate="txtCreatePassword" ValidationGroup="CreateUserGroup"
                                CssClass="text-danger small" ErrorMessage="Password is required." Display="Dynamic" />
                            <small class="text-muted">Minimum 6 characters</small>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Confirm Password <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtCreateConfirmPassword" runat="server" CssClass="form-control" TextMode="Password" />
                            <asp:RequiredFieldValidator ID="rfvConfirmPassword" runat="server" 
                                ControlToValidate="txtCreateConfirmPassword" ValidationGroup="CreateUserGroup"
                                CssClass="text-danger small" ErrorMessage="Please confirm password." Display="Dynamic" />
                            <asp:CompareValidator ID="cvPassword" runat="server"
                                ControlToValidate="txtCreateConfirmPassword" ControlToCompare="txtCreatePassword"
                                ValidationGroup="CreateUserGroup"
                                CssClass="text-danger small" ErrorMessage="Passwords do not match." Display="Dynamic" />
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Role <span class="text-danger">*</span></label>
                            <asp:DropDownList ID="ddlCreateRole" runat="server" CssClass="form-select">
                                <asp:ListItem Value="student" Text="Student" />
                                <asp:ListItem Value="teacher" Text="Teacher" Selected="True" />
                            </asp:DropDownList>
                            <small class="text-muted">Note: Only admins can create teacher accounts</small>
                        </div>

                        <asp:Label ID="lblCreateError" runat="server" CssClass="text-danger small" />
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <asp:Button ID="btnCreateUser" runat="server" Text="Create User" 
                            CssClass="btn btn-success" ValidationGroup="CreateUserGroup" 
                            OnClick="btnCreateUser_Click" />
                    </div>
                </asp:Panel>
            </div>
        </div>
    </div>

    <!-- User Details Modal -->
    <div class="modal fade" id="userDetailsModal" tabindex="-1" aria-labelledby="userDetailsModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="userDetailsModalLabel">User Details</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label fw-bold">Full Name</label>
                        <p id="detailFullName" class="mb-0"></p>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-bold">Email</label>
                        <p id="detailEmail" class="mb-0"></p>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-bold">Role</label>
                        <p id="detailRole" class="mb-0"></p>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-bold">User Slug</label>
                        <p id="detailUserSlug" class="mb-0 text-muted small"></p>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-bold">Registered</label>
                        <p id="detailCreatedAt" class="mb-0"></p>
                    </div>
                    <div class="alert alert-info mb-0">
                        <small><i class="bi bi-info-circle me-1"></i>Password information is not displayed for security reasons.</small>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
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

        .form-label {
            color: #111 !important;
        }

        h2, h3, h4, h5, h6 {
            color: #2d3748 !important;
        }

        /* User Details Modal Text Colors */
        #detailFullName,
        #detailEmail,
        #detailRole,
        #detailCreatedAt {
            color: #2d3748; /* Change this to your desired color */
        }

        /* Or use Bootstrap utility classes directly in the HTML */
    </style>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            var viewButtons = document.querySelectorAll('.view-user-btn');
            viewButtons.forEach(function(btn) {
                btn.addEventListener('click', function() {
                    var userSlug = this.getAttribute('data-user-slug');
                    var displayName = this.getAttribute('data-display-name');
                    var email = this.getAttribute('data-email');
                    var role = this.getAttribute('data-role');
                    var createdAt = this.getAttribute('data-created-at');
                    
                    document.getElementById('detailUserSlug').textContent = userSlug;
                    document.getElementById('detailFullName').textContent = displayName;
                    document.getElementById('detailEmail').textContent = email;
                    document.getElementById('detailRole').textContent = role.charAt(0).toUpperCase() + role.slice(1);
                    document.getElementById('detailCreatedAt').textContent = createdAt;
                    
                    var modal = new bootstrap.Modal(document.getElementById('userDetailsModal'));
                    modal.show();
                });
            });
        });
    </script>

</asp:Content>


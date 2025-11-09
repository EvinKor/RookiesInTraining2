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
            <div class="d-flex align-items-center mb-3">
                <a href="dashboard_admin.aspx" class="btn btn-outline-secondary me-3">
                    <i class="bi bi-arrow-left me-2"></i>Back to Dashboard
                </a>
                <div class="flex-grow-1">
                    <h2 class="mb-1">User Management</h2>
                    <p class="text-muted mb-0">Manage all users in the system</p>
                </div>
                <div>
                    <asp:Button ID="btnExportCSV" runat="server" Text="Export CSV" CssClass="btn btn-outline-primary me-2" OnClick="btnExportCSV_Click" />
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
        <div class="col-md-2">
            <asp:DropDownList ID="ddlRoleFilter" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlRoleFilter_SelectedIndexChanged">
                <asp:ListItem Value="" Text="All Roles" />
                <asp:ListItem Value="student" Text="Students" />
                <asp:ListItem Value="teacher" Text="Teachers" />
                <asp:ListItem Value="admin" Text="Admins" />
            </asp:DropDownList>
        </div>
        <div class="col-md-2">
            <asp:DropDownList ID="ddlStatusFilter" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlStatusFilter_SelectedIndexChanged">
                <asp:ListItem Value="" Text="All Status" />
                <asp:ListItem Value="active" Text="Active" />
                <asp:ListItem Value="blocked" Text="Blocked" />
            </asp:DropDownList>
        </div>
        <div class="col-md-2">
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
                            <th>Status</th>
                            <th>Registered</th>
                            <th class="text-end pe-4">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="rptUsers" runat="server" OnItemCommand="rptUsers_ItemCommand">
                            <ItemTemplate>
                                <tr class="user-row-clickable" 
                                    style="cursor: pointer;"
                                    data-user-slug="<%# Server.HtmlEncode(Eval("UserSlug").ToString()) %>"
                                    data-display-name="<%# Server.HtmlEncode(Eval("DisplayName").ToString()) %>"
                                    data-email="<%# Server.HtmlEncode(Eval("Email").ToString()) %>"
                                    data-role="<%# Server.HtmlEncode(Eval("Role").ToString()) %>"
                                    data-created-at="<%# Server.HtmlEncode(Eval("CreatedAt").ToString()) %>">
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
                                    <td><%# GetStatusBadge(Convert.ToBoolean(Eval("IsBlocked"))) %></td>
                                    <td><%# Eval("CreatedAt") %></td>
                                    <td class="text-end pe-4" onclick="event.stopPropagation();">
                                        <div class="btn-group" role="group">
                                            <button type="button" class="btn btn-sm btn-outline-primary edit-user-btn <%# Convert.ToBoolean(Eval("IsCurrentAdmin")) ? "disabled" : "" %>" 
                                                    <%# Convert.ToBoolean(Eval("IsCurrentAdmin")) ? "disabled=\"disabled\"" : "" %>
                                                    data-user-slug="<%# Server.HtmlEncode(Eval("UserSlug").ToString()) %>"
                                                    data-display-name="<%# Server.HtmlEncode(Eval("DisplayName").ToString()) %>"
                                                    data-email="<%# Server.HtmlEncode(Eval("Email").ToString()) %>"
                                                    data-role="<%# Server.HtmlEncode(Eval("Role").ToString()) %>"
                                                    data-is-blocked="<%# Convert.ToBoolean(Eval("IsBlocked")).ToString().ToLower() %>"
                                                    title="<%# Convert.ToBoolean(Eval("IsCurrentAdmin")) ? "Cannot edit your own account" : "Edit User" %>">
                                                <i class="bi bi-pencil"></i>
                                            </button>
                                            <button type="button" class="btn btn-sm btn-outline-info change-role-btn <%# Convert.ToBoolean(Eval("IsCurrentAdmin")) ? "disabled" : "" %>" 
                                                    <%# Convert.ToBoolean(Eval("IsCurrentAdmin")) ? "disabled=\"disabled\"" : "" %>
                                                    data-user-slug="<%# Server.HtmlEncode(Eval("UserSlug").ToString()) %>"
                                                    data-role="<%# Server.HtmlEncode(Eval("Role").ToString()) %>"
                                                    data-display-name="<%# Server.HtmlEncode(Eval("DisplayName").ToString()) %>"
                                                    title="<%# Convert.ToBoolean(Eval("IsCurrentAdmin")) ? "Cannot change your own role" : "Change Role" %>">
                                                <i class="bi bi-person-badge"></i>
                                            </button>
                                            <asp:LinkButton ID="btnBlockUnblock" runat="server" 
                                                            CommandName='<%# Convert.ToBoolean(Eval("IsBlocked")) ? "UnblockUser" : "BlockUser" %>'
                                                            CommandArgument='<%# Eval("UserSlug") %>'
                                                            CssClass='<%# GetBlockUnblockCssClass(Convert.ToBoolean(Eval("IsCurrentAdmin")), Convert.ToBoolean(Eval("IsBlocked"))) %>'
                                                            Enabled='<%# !Convert.ToBoolean(Eval("IsCurrentAdmin")) %>'
                                                            OnClientClick='<%# GetBlockUnblockOnClientClick(Convert.ToBoolean(Eval("IsCurrentAdmin")), Convert.ToBoolean(Eval("IsBlocked"))) %>'
                                                            title='<%# GetBlockUnblockTitle(Convert.ToBoolean(Eval("IsCurrentAdmin")), Convert.ToBoolean(Eval("IsBlocked"))) %>'>
                                                <i class='<%# Convert.ToBoolean(Eval("IsBlocked")) ? "bi bi-unlock" : "bi bi-lock" %>'></i>
                                            </asp:LinkButton>
                                            <asp:LinkButton ID="btnDelete" runat="server" 
                                                            CommandName="DeleteUser" 
                                                            CommandArgument='<%# Eval("UserSlug") %>'
                                                            CssClass='<%# GetDeleteCssClass(Convert.ToBoolean(Eval("IsCurrentAdmin"))) %>'
                                                            Enabled='<%# !Convert.ToBoolean(Eval("IsCurrentAdmin")) %>'
                                                            OnClientClick='<%# GetDeleteOnClientClick(Convert.ToBoolean(Eval("IsCurrentAdmin"))) %>'
                                                            title='<%# GetDeleteTitle(Convert.ToBoolean(Eval("IsCurrentAdmin"))) %>'>
                                                <i class="bi bi-trash"></i>
                                            </asp:LinkButton>
                                        </div>
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

    <!-- Edit User Modal -->
    <div class="modal fade" id="editUserModal" tabindex="-1" aria-labelledby="editUserModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="editUserModalLabel">Edit User</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <asp:Panel ID="pnlEditUser" runat="server" DefaultButton="btnUpdateUser">
                    <div class="modal-body">
                        <asp:Label ID="lblEditError" runat="server" CssClass="text-danger small" />
                        
                        <div class="mb-3">
                            <label class="form-label">Display Name <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtEditDisplayName" runat="server" CssClass="form-control" />
                            <asp:RequiredFieldValidator ID="rfvEditDisplayName" runat="server" 
                                ControlToValidate="txtEditDisplayName" ValidationGroup="EditUserGroup"
                                CssClass="text-danger small" ErrorMessage="Display name is required." Display="Dynamic" />
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Email <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtEditEmail" runat="server" CssClass="form-control" TextMode="Email" />
                            <asp:RequiredFieldValidator ID="rfvEditEmail" runat="server" 
                                ControlToValidate="txtEditEmail" ValidationGroup="EditUserGroup"
                                CssClass="text-danger small" ErrorMessage="Email is required." Display="Dynamic" />
                            <asp:RegularExpressionValidator ID="revEditEmail" runat="server"
                                ControlToValidate="txtEditEmail" ValidationGroup="EditUserGroup"
                                ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"
                                CssClass="text-danger small" ErrorMessage="Invalid email format." Display="Dynamic" />
                        </div>

                        <div class="mb-3">
                            <div class="form-check form-switch">
                                <asp:CheckBox ID="chkEditIsBlocked" runat="server" CssClass="form-check-input" />
                                <label class="form-check-label" for="<%= chkEditIsBlocked.ClientID %>">
                                    Block User
                                </label>
                            </div>
                            <small class="text-muted">Blocked users cannot log in to the system</small>
                        </div>

                        <asp:HiddenField ID="hfEditUserSlug" runat="server" />
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <asp:Button ID="btnUpdateUser" runat="server" Text="Update User" 
                            CssClass="btn btn-primary" ValidationGroup="EditUserGroup" 
                            OnClick="btnUpdateUser_Click" />
                    </div>
                </asp:Panel>
            </div>
        </div>
    </div>

    <!-- Change Role Modal -->
    <div class="modal fade" id="changeRoleModal" tabindex="-1" aria-labelledby="changeRoleModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="changeRoleModalLabel">Change User Role</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <asp:Panel ID="pnlChangeRole" runat="server" DefaultButton="btnChangeRole">
                    <div class="modal-body">
                        <p class="mb-3">Change role for: <strong id="changeRoleUserName"></strong></p>
                        <p class="mb-3">Current role: <strong id="changeRoleCurrentRole"></strong></p>
                        <asp:Label ID="lblChangeRoleError" runat="server" CssClass="text-danger small" />
                        
                        <div class="mb-3">
                            <label class="form-label">New Role <span class="text-danger">*</span></label>
                            <asp:DropDownList ID="ddlChangeRole" runat="server" CssClass="form-select">
                                <asp:ListItem Value="student" Text="Student" />
                                <asp:ListItem Value="teacher" Text="Teacher" />
                            </asp:DropDownList>
                            <small class="text-muted">Note: Cannot change role to Admin via this interface</small>
                        </div>

                        <asp:HiddenField ID="hfChangeRoleUserSlug" runat="server" />
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <asp:Button ID="btnChangeRole" runat="server" Text="Change Role" 
                            CssClass="btn btn-primary" 
                            OnClick="btnChangeRole_Click" />
                    </div>
                </asp:Panel>
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

    <!-- Hidden fields for modal data from query string -->
    <asp:HiddenField ID="hfModalUserSlug" runat="server" />
    <asp:HiddenField ID="hfModalDisplayName" runat="server" />
    <asp:HiddenField ID="hfModalEmail" runat="server" />
    <asp:HiddenField ID="hfModalRole" runat="server" />
    <asp:HiddenField ID="hfModalIsBlocked" runat="server" />
    <asp:HiddenField ID="hfModalCreatedAt" runat="server" />
    <asp:HiddenField ID="hfShowModal" runat="server" Value="false" />

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
                    
                    showUserDetailsModal(userSlug, displayName, email, role, createdAt);
                });
            });

            // Check if we need to show modal from query string
            var showModal = document.getElementById('<%= hfShowModal.ClientID %>').value === 'true';
            if (showModal) {
                var userSlug = document.getElementById('<%= hfModalUserSlug.ClientID %>').value;
                var displayName = document.getElementById('<%= hfModalDisplayName.ClientID %>').value;
                var email = document.getElementById('<%= hfModalEmail.ClientID %>').value;
                
                // Remove query string from URL after showing modal
                if (window.history && window.history.replaceState) {
                    window.history.replaceState({}, document.title, window.location.pathname);
                }
                var role = document.getElementById('<%= hfModalRole.ClientID %>').value;
                var createdAt = document.getElementById('<%= hfModalCreatedAt.ClientID %>').value;
                
                showUserDetailsModal(userSlug, displayName, email, role, createdAt);
            }
        });

        function showUserDetailsModal(userSlug, displayName, email, role, createdAt) {
            document.getElementById('detailUserSlug').textContent = userSlug;
            document.getElementById('detailFullName').textContent = displayName;
            document.getElementById('detailEmail').textContent = email;
            document.getElementById('detailRole').textContent = role.charAt(0).toUpperCase() + role.slice(1);
            document.getElementById('detailCreatedAt').textContent = createdAt;
            
            var modal = new bootstrap.Modal(document.getElementById('userDetailsModal'));
            modal.show();
        }

        // Edit User Modal
        document.querySelectorAll('.edit-user-btn').forEach(function(btn) {
            btn.addEventListener('click', function() {
                // Don't open modal if button is disabled
                if (this.disabled || this.classList.contains('disabled')) {
                    return;
                }
                
                document.getElementById('<%= hfEditUserSlug.ClientID %>').value = this.getAttribute('data-user-slug');
                document.getElementById('<%= txtEditDisplayName.ClientID %>').value = this.getAttribute('data-display-name');
                document.getElementById('<%= txtEditEmail.ClientID %>').value = this.getAttribute('data-email');
                document.getElementById('<%= chkEditIsBlocked.ClientID %>').checked = this.getAttribute('data-is-blocked') === 'true';
                
                var modal = new bootstrap.Modal(document.getElementById('editUserModal'));
                modal.show();
            });
        });

        // Change Role Modal
        document.querySelectorAll('.change-role-btn').forEach(function(btn) {
            btn.addEventListener('click', function(e) {
                e.stopPropagation();
                
                // Don't open modal if button is disabled
                if (this.disabled || this.classList.contains('disabled')) {
                    return;
                }
                
                var userSlug = this.getAttribute('data-user-slug');
                var currentRole = this.getAttribute('data-role');
                var displayName = this.getAttribute('data-display-name');
                
                document.getElementById('<%= hfChangeRoleUserSlug.ClientID %>').value = userSlug;
                document.getElementById('changeRoleUserName').textContent = displayName;
                document.getElementById('changeRoleCurrentRole').textContent = currentRole.charAt(0).toUpperCase() + currentRole.slice(1);
                document.getElementById('<%= ddlChangeRole.ClientID %>').value = currentRole === 'admin' ? 'student' : currentRole;
                document.getElementById('<%= lblChangeRoleError.ClientID %>').textContent = '';
                
                var modal = new bootstrap.Modal(document.getElementById('changeRoleModal'));
                modal.show();
            });
        });

        // Make user rows clickable to show details
        document.querySelectorAll('.user-row-clickable').forEach(function(row) {
            row.addEventListener('click', function(e) {
                // Don't trigger if clicking on action buttons
                if (e.target.closest('.btn-group, .btn, button, a')) {
                    return;
                }
                
                var userSlug = this.getAttribute('data-user-slug');
                
                // Navigate to the same page with user query parameter
                var currentUrl = window.location.pathname;
                window.location.href = currentUrl + '?user=' + encodeURIComponent(userSlug);
            });
        });

        // Prevent row click when clicking action buttons
        document.querySelectorAll('.edit-user-btn').forEach(function(btn) {
            btn.addEventListener('click', function(e) {
                e.stopPropagation();
            });
        });
    </script>

    <style>
        /* Clickable user row hover effect */
        .user-row-clickable:hover {
            background-color: #f8f9fa !important;
        }
        
        /* Disabled button styling */
        .btn.disabled,
        .btn:disabled {
            opacity: 0.5;
            cursor: not-allowed;
            pointer-events: none;
        }
    </style>

</asp:Content>


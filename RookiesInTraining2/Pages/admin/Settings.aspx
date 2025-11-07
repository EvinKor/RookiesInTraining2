<%@ Page Title="System Settings"
    Language="C#"
    MasterPageFile="~/MasterPages/dashboard.Master"
    AutoEventWireup="true"
    CodeBehind="Settings.aspx.cs"
    Inherits="RookiesInTraining2.Pages.Settings" %>

<asp:Content ID="Content1" ContentPlaceHolderID="DashboardContent" runat="server">
    
    <!-- Page Header -->
    <div class="row mb-4">
        <div class="col-12">
            <div class="d-flex align-items-center mb-3">
                <a href="dashboard_admin.aspx" class="btn btn-outline-secondary me-3">
                    <i class="bi bi-arrow-left me-2"></i>Back to Dashboard
                </a>
                <div class="flex-grow-1">
                    <h2 class="mb-1">System Settings</h2>
                    <p class="text-muted mb-0">Configure system-wide settings and preferences</p>
                </div>
            </div>
        </div>
    </div>

    <!-- Settings Tabs -->
    <ul class="nav nav-tabs mb-4" id="settingsTabs" role="tablist">
        <li class="nav-item" role="presentation">
            <button class="nav-link active" id="general-tab" data-bs-toggle="tab" data-bs-target="#general" type="button" role="tab">
                <i class="bi bi-gear me-2"></i>General
            </button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link" id="security-tab" data-bs-toggle="tab" data-bs-target="#security" type="button" role="tab">
                <i class="bi bi-shield-check me-2"></i>Security
            </button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link" id="notifications-tab" data-bs-toggle="tab" data-bs-target="#notifications" type="button" role="tab">
                <i class="bi bi-bell me-2"></i>Notifications
            </button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link" id="maintenance-tab" data-bs-toggle="tab" data-bs-target="#maintenance" type="button" role="tab">
                <i class="bi bi-tools me-2"></i>Maintenance
            </button>
        </li>
    </ul>

    <!-- Settings Content -->
    <div class="tab-content" id="settingsTabContent">
        <!-- General Settings -->
        <div class="tab-pane fade show active" id="general" role="tabpanel">
            <div class="card border-0 shadow-sm mb-4">
                <div class="card-header bg-transparent border-0 py-3">
                    <h5 class="mb-0"><i class="bi bi-info-circle me-2"></i>General Settings</h5>
                </div>
                <div class="card-body">
                    <asp:Panel ID="pnlGeneralSettings" runat="server" DefaultButton="btnSaveGeneral">
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label class="form-label fw-bold">System Name</label>
                                <asp:TextBox ID="txtSystemName" runat="server" CssClass="form-control" placeholder="Rookies in Training" />
                                <small class="text-muted">Display name for the application</small>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-bold">System Email</label>
                                <asp:TextBox ID="txtSystemEmail" runat="server" CssClass="form-control" TextMode="Email" placeholder="admin@rookies.com" />
                                <small class="text-muted">Default email for system notifications</small>
                            </div>
                        </div>

                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label class="form-label fw-bold">Default Timezone</label>
                                <asp:DropDownList ID="ddlTimezone" runat="server" CssClass="form-select">
                                    <asp:ListItem Value="UTC" Text="UTC (Coordinated Universal Time)" />
                                    <asp:ListItem Value="EST" Text="EST (Eastern Standard Time)" />
                                    <asp:ListItem Value="PST" Text="PST (Pacific Standard Time)" />
                                    <asp:ListItem Value="GMT" Text="GMT (Greenwich Mean Time)" />
                                </asp:DropDownList>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-bold">Date Format</label>
                                <asp:DropDownList ID="ddlDateFormat" runat="server" CssClass="form-select">
                                    <asp:ListItem Value="MM/dd/yyyy" Text="MM/DD/YYYY" Selected="True" />
                                    <asp:ListItem Value="dd/MM/yyyy" Text="DD/MM/YYYY" />
                                    <asp:ListItem Value="yyyy-MM-dd" Text="YYYY-MM-DD" />
                                </asp:DropDownList>
                            </div>
                        </div>

                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label class="form-label fw-bold">Items Per Page</label>
                                <asp:DropDownList ID="ddlItemsPerPage" runat="server" CssClass="form-select">
                                    <asp:ListItem Value="10" Text="10" />
                                    <asp:ListItem Value="25" Text="25" Selected="True" />
                                    <asp:ListItem Value="50" Text="50" />
                                    <asp:ListItem Value="100" Text="100" />
                                </asp:DropDownList>
                                <small class="text-muted">Default number of items displayed per page</small>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-bold">Session Timeout (minutes)</label>
                                <asp:TextBox ID="txtSessionTimeout" runat="server" CssClass="form-control" TextMode="Number" Text="30" />
                                <small class="text-muted">User session timeout duration</small>
                            </div>
                        </div>

                        <div class="mb-3">
                            <div class="form-check form-switch">
                                <asp:CheckBox ID="chkAllowRegistration" runat="server" CssClass="form-check-input" Checked="true" />
                                <label class="form-check-label" for="<%= chkAllowRegistration.ClientID %>">
                                    Allow new user registration
                                </label>
                            </div>
                            <small class="text-muted">When disabled, only admins can create new accounts</small>
                        </div>

                        <div class="mb-3">
                            <div class="form-check form-switch">
                                <asp:CheckBox ID="chkEmailVerification" runat="server" CssClass="form-check-input" />
                                <label class="form-check-label" for="<%= chkEmailVerification.ClientID %>">
                                    Require email verification
                                </label>
                            </div>
                            <small class="text-muted">Users must verify their email before accessing the system</small>
                        </div>

                        <div class="d-flex justify-content-end">
                            <asp:Button ID="btnSaveGeneral" runat="server" Text="Save General Settings" 
                                CssClass="btn btn-primary" OnClick="btnSaveGeneral_Click" />
                        </div>
                    </asp:Panel>
                </div>
            </div>
        </div>

        <!-- Security Settings -->
        <div class="tab-pane fade" id="security" role="tabpanel">
            <div class="card border-0 shadow-sm mb-4">
                <div class="card-header bg-transparent border-0 py-3">
                    <h5 class="mb-0"><i class="bi bi-shield-lock me-2"></i>Security Settings</h5>
                </div>
                <div class="card-body">
                    <asp:Panel ID="pnlSecuritySettings" runat="server" DefaultButton="btnSaveSecurity">
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label class="form-label fw-bold">Minimum Password Length</label>
                                <asp:TextBox ID="txtMinPasswordLength" runat="server" CssClass="form-control" TextMode="Number" Text="6" />
                                <small class="text-muted">Minimum characters required for passwords</small>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-bold">Password Expiry (days)</label>
                                <asp:TextBox ID="txtPasswordExpiry" runat="server" CssClass="form-control" TextMode="Number" Text="90" />
                                <small class="text-muted">Days before password expires (0 = never)</small>
                            </div>
                        </div>

                        <div class="mb-3">
                            <div class="form-check form-switch">
                                <asp:CheckBox ID="chkRequireStrongPassword" runat="server" CssClass="form-check-input" />
                                <label class="form-check-label" for="<%= chkRequireStrongPassword.ClientID %>">
                                    Require strong passwords
                                </label>
                            </div>
                            <small class="text-muted">Passwords must contain uppercase, lowercase, numbers, and special characters</small>
                        </div>

                        <div class="mb-3">
                            <div class="form-check form-switch">
                                <asp:CheckBox ID="chkEnableTwoFactor" runat="server" CssClass="form-check-input" />
                                <label class="form-check-label" for="<%= chkEnableTwoFactor.ClientID %>">
                                    Enable Two-Factor Authentication
                                </label>
                            </div>
                            <small class="text-muted">Require additional verification for admin accounts</small>
                        </div>

                        <div class="mb-3">
                            <div class="form-check form-switch">
                                <asp:CheckBox ID="chkLockoutEnabled" runat="server" CssClass="form-check-input" Checked="true" />
                                <label class="form-check-label" for="<%= chkLockoutEnabled.ClientID %>">
                                    Enable account lockout
                                </label>
                            </div>
                            <small class="text-muted">Lock accounts after failed login attempts</small>
                        </div>

                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label class="form-label fw-bold">Max Failed Attempts</label>
                                <asp:TextBox ID="txtMaxFailedAttempts" runat="server" CssClass="form-control" TextMode="Number" Text="5" />
                                <small class="text-muted">Number of failed attempts before lockout</small>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-bold">Lockout Duration (minutes)</label>
                                <asp:TextBox ID="txtLockoutDuration" runat="server" CssClass="form-control" TextMode="Number" Text="30" />
                                <small class="text-muted">How long accounts remain locked</small>
                            </div>
                        </div>

                        <div class="d-flex justify-content-end">
                            <asp:Button ID="btnSaveSecurity" runat="server" Text="Save Security Settings" 
                                CssClass="btn btn-primary" OnClick="btnSaveSecurity_Click" />
                        </div>
                    </asp:Panel>
                </div>
            </div>
        </div>

        <!-- Notifications Settings -->
        <div class="tab-pane fade" id="notifications" role="tabpanel">
            <div class="card border-0 shadow-sm mb-4">
                <div class="card-header bg-transparent border-0 py-3">
                    <h5 class="mb-0"><i class="bi bi-bell me-2"></i>Notification Settings</h5>
                </div>
                <div class="card-body">
                    <asp:Panel ID="pnlNotificationSettings" runat="server" DefaultButton="btnSaveNotifications">
                        <div class="mb-3">
                            <div class="form-check form-switch">
                                <asp:CheckBox ID="chkEmailNotifications" runat="server" CssClass="form-check-input" Checked="true" />
                                <label class="form-check-label" for="<%= chkEmailNotifications.ClientID %>">
                                    Enable email notifications
                                </label>
                            </div>
                            <small class="text-muted">Send email notifications for system events</small>
                        </div>

                        <div class="mb-3">
                            <div class="form-check form-switch">
                                <asp:CheckBox ID="chkNotifyNewUsers" runat="server" CssClass="form-check-input" Checked="true" />
                                <label class="form-check-label" for="<%= chkNotifyNewUsers.ClientID %>">
                                    Notify on new user registration
                                </label>
                            </div>
                        </div>

                        <div class="mb-3">
                            <div class="form-check form-switch">
                                <asp:CheckBox ID="chkNotifyFailedLogins" runat="server" CssClass="form-check-input" Checked="true" />
                                <label class="form-check-label" for="<%= chkNotifyFailedLogins.ClientID %>">
                                    Notify on failed login attempts
                                </label>
                            </div>
                        </div>

                        <div class="mb-3">
                            <div class="form-check form-switch">
                                <asp:CheckBox ID="chkNotifySystemErrors" runat="server" CssClass="form-check-input" Checked="true" />
                                <label class="form-check-label" for="<%= chkNotifySystemErrors.ClientID %>">
                                    Notify on system errors
                                </label>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-bold">Notification Email Recipients</label>
                            <asp:TextBox ID="txtNotificationEmails" runat="server" CssClass="form-control" 
                                placeholder="admin@example.com, support@example.com" TextMode="MultiLine" Rows="3" />
                            <small class="text-muted">Comma-separated list of email addresses to receive notifications</small>
                        </div>

                        <div class="d-flex justify-content-end">
                            <asp:Button ID="btnSaveNotifications" runat="server" Text="Save Notification Settings" 
                                CssClass="btn btn-primary" OnClick="btnSaveNotifications_Click" />
                        </div>
                    </asp:Panel>
                </div>
            </div>
        </div>

        <!-- Maintenance Settings -->
        <div class="tab-pane fade" id="maintenance" role="tabpanel">
            <div class="card border-0 shadow-sm mb-4">
                <div class="card-header bg-transparent border-0 py-3">
                    <h5 class="mb-0"><i class="bi bi-database me-2"></i>Database Maintenance</h5>
                </div>
                <div class="card-body">
                    <div class="row mb-4">
                        <div class="col-md-6">
                            <div class="card border">
                                <div class="card-body">
                                    <h6 class="card-title"><i class="bi bi-trash me-2"></i>Clean Up Deleted Records</h6>
                                    <p class="card-text small text-muted">Permanently remove soft-deleted records older than specified days</p>
                                    <div class="mb-3">
                                        <label class="form-label small">Delete records older than (days)</label>
                                        <asp:TextBox ID="txtCleanupDays" runat="server" CssClass="form-control form-control-sm" TextMode="Number" Text="90" />
                                    </div>
                                    <asp:Button ID="btnCleanupDeleted" runat="server" Text="Clean Up" 
                                        CssClass="btn btn-sm btn-outline-danger" OnClick="btnCleanupDeleted_Click" />
                                </div>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="card border">
                                <div class="card-body">
                                    <h6 class="card-title"><i class="bi bi-archive me-2"></i>Database Backup</h6>
                                    <p class="card-text small text-muted">Create a backup of the database</p>
                                    <div class="mb-3">
                                        <small class="text-muted">Last backup: <asp:Label ID="lblLastBackup" runat="server" Text="Never" /></small>
                                    </div>
                                    <asp:Button ID="btnBackupDatabase" runat="server" Text="Create Backup" 
                                        CssClass="btn btn-sm btn-outline-primary" OnClick="btnBackupDatabase_Click" />
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="alert alert-warning">
                        <i class="bi bi-exclamation-triangle me-2"></i>
                        <strong>Warning:</strong> Maintenance operations are irreversible. Please ensure you have backups before proceeding.
                    </div>
                </div>
            </div>

            <div class="card border-0 shadow-sm">
                <div class="card-header bg-transparent border-0 py-3">
                    <h5 class="mb-0"><i class="bi bi-info-circle me-2"></i>System Information</h5>
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-bold small text-muted">Application Version</label>
                            <p class="mb-0"><asp:Label ID="lblAppVersion" runat="server" Text="1.0.0" /></p>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-bold small text-muted">Database Version</label>
                            <p class="mb-0"><asp:Label ID="lblDbVersion" runat="server" Text="Checking..." /></p>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-bold small text-muted">Server Time</label>
                            <p class="mb-0"><asp:Label ID="lblServerTime" runat="server" /></p>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-bold small text-muted">Database Size</label>
                            <p class="mb-0"><asp:Label ID="lblDbSize" runat="server" Text="Calculating..." /></p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Success/Error Messages -->
    <asp:Label ID="lblMessage" runat="server" CssClass="alert alert-success d-none" />
    <asp:Label ID="lblError" runat="server" CssClass="alert alert-danger d-none" />

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

        h2, h3, h4, h5, h6 {
            color: #2d3748 !important;
        }

        .nav-tabs .nav-link {
            color: #6c757d;
            border: none;
            border-bottom: 2px solid transparent;
        }

        .nav-tabs .nav-link:hover {
            border-bottom-color: #dee2e6;
            color: #495057;
        }

        .nav-tabs .nav-link.active {
            color: #667eea;
            border-bottom-color: #667eea;
            background: transparent;
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


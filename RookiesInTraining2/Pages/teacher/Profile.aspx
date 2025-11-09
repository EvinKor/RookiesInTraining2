<%@ Page Title="My Profile"
    Language="C#"
    MasterPageFile="~/MasterPages/dashboard.Master"
    AutoEventWireup="true"
    CodeBehind="Profile.aspx.cs"
    Inherits="RookiesInTraining2.Pages.TeacherProfile" %>

<asp:Content ID="Content1" ContentPlaceHolderID="DashboardContent" runat="server">
    
    <!-- Page Header -->
    <div class="row mb-4">
        <div class="col-12">
            <div class="d-flex align-items-center mb-3">
                <a href="dashboard_teacher.aspx" class="btn btn-outline-secondary me-3">
                    <i class="bi bi-arrow-left me-2"></i>Back to Dashboard
                </a>
                <div class="flex-grow-1">
                    <h2 class="mb-1">My Profile</h2>
                    <p class="text-muted mb-0">Update your profile information</p>
                </div>
            </div>
        </div>
    </div>

    <!-- Profile Settings -->
    <div class="row">
        <div class="col-lg-8">
            <!-- Profile Information -->
            <div class="card border-0 shadow-sm mb-4">
                <div class="card-header bg-transparent border-0 py-3">
                    <h5 class="mb-0"><i class="bi bi-person-circle me-2"></i>Profile Information</h5>
                </div>
                <div class="card-body">
                    <asp:Panel ID="pnlProfileInfo" runat="server" DefaultButton="btnUpdateProfile">
                        <asp:ValidationSummary ID="vsProfileInfo" runat="server" ValidationGroup="ProfileInfoGroup"
                            CssClass="alert alert-danger py-2" DisplayMode="BulletList" />
                        
                        <div class="mb-3">
                            <label class="form-label fw-bold">Display Name <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtDisplayName" runat="server" CssClass="form-control" />
                            <asp:RequiredFieldValidator ID="rfvDisplayName" runat="server" 
                                ControlToValidate="txtDisplayName" ValidationGroup="ProfileInfoGroup"
                                CssClass="text-danger small" ErrorMessage="Display name is required." Display="Dynamic" />
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-bold">Email <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" />
                            <asp:RequiredFieldValidator ID="rfvEmail" runat="server" 
                                ControlToValidate="txtEmail" ValidationGroup="ProfileInfoGroup"
                                CssClass="text-danger small" ErrorMessage="Email is required." Display="Dynamic" />
                            <asp:RegularExpressionValidator ID="revEmail" runat="server"
                                ControlToValidate="txtEmail" ValidationGroup="ProfileInfoGroup"
                                ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"
                                CssClass="text-danger small" ErrorMessage="Invalid email format." Display="Dynamic" />
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-bold">User Slug</label>
                            <asp:TextBox ID="txtUserSlug" runat="server" CssClass="form-control" ReadOnly="true" />
                            <small class="text-muted">User slug cannot be changed</small>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-bold">Role</label>
                            <asp:TextBox ID="txtRole" runat="server" CssClass="form-control" ReadOnly="true" />
                            <small class="text-muted">Role cannot be changed</small>
                        </div>

                        <asp:Label ID="lblProfileError" runat="server" CssClass="text-danger small" />
                        <asp:Label ID="lblProfileSuccess" runat="server" CssClass="text-success small" />

                        <div class="d-flex justify-content-end mt-4">
                            <asp:Button ID="btnUpdateProfile" runat="server" Text="Update Profile" 
                                CssClass="btn btn-primary" ValidationGroup="ProfileInfoGroup" 
                                OnClick="btnUpdateProfile_Click" />
                        </div>
                    </asp:Panel>
                </div>
            </div>

            <!-- Change Password -->
            <div class="card border-0 shadow-sm">
                <div class="card-header bg-transparent border-0 py-3">
                    <h5 class="mb-0"><i class="bi bi-key me-2"></i>Change Password</h5>
                </div>
                <div class="card-body">
                    <asp:Panel ID="pnlChangePassword" runat="server" DefaultButton="btnChangePassword">
                        <asp:ValidationSummary ID="vsChangePassword" runat="server" ValidationGroup="ChangePasswordGroup"
                            CssClass="alert alert-danger py-2" DisplayMode="BulletList" />
                        
                        <div class="mb-3">
                            <label class="form-label fw-bold">Current Password <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtCurrentPassword" runat="server" CssClass="form-control" TextMode="Password" />
                            <asp:RequiredFieldValidator ID="rfvCurrentPassword" runat="server" 
                                ControlToValidate="txtCurrentPassword" ValidationGroup="ChangePasswordGroup"
                                CssClass="text-danger small" ErrorMessage="Current password is required." Display="Dynamic" />
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-bold">New Password <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtNewPassword" runat="server" CssClass="form-control" TextMode="Password" />
                            <asp:RequiredFieldValidator ID="rfvNewPassword" runat="server" 
                                ControlToValidate="txtNewPassword" ValidationGroup="ChangePasswordGroup"
                                CssClass="text-danger small" ErrorMessage="New password is required." Display="Dynamic" />
                            <small class="text-muted">Minimum 6 characters</small>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-bold">Confirm New Password <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtConfirmNewPassword" runat="server" CssClass="form-control" TextMode="Password" />
                            <asp:RequiredFieldValidator ID="rfvConfirmNewPassword" runat="server" 
                                ControlToValidate="txtConfirmNewPassword" ValidationGroup="ChangePasswordGroup"
                                CssClass="text-danger small" ErrorMessage="Please confirm new password." Display="Dynamic" />
                            <asp:CompareValidator ID="cvNewPassword" runat="server"
                                ControlToValidate="txtConfirmNewPassword" ControlToCompare="txtNewPassword"
                                ValidationGroup="ChangePasswordGroup"
                                CssClass="text-danger small" ErrorMessage="Passwords do not match." Display="Dynamic" />
                        </div>

                        <asp:Label ID="lblPasswordError" runat="server" CssClass="text-danger small" />
                        <asp:Label ID="lblPasswordSuccess" runat="server" CssClass="text-success small" />

                        <div class="d-flex justify-content-end mt-4">
                            <asp:Button ID="btnChangePassword" runat="server" Text="Change Password" 
                                CssClass="btn btn-warning" ValidationGroup="ChangePasswordGroup" 
                                OnClick="btnChangePassword_Click" />
                        </div>
                    </asp:Panel>
                </div>
            </div>
        </div>

        <!-- Right Column - Account Info -->
        <div class="col-lg-4">
            <div class="card border-0 shadow-sm">
                <div class="card-header bg-transparent border-0 py-3">
                    <h5 class="mb-0"><i class="bi bi-info-circle me-2"></i>Account Information</h5>
                </div>
                <div class="card-body">
                    <div class="mb-3">
                        <label class="form-label fw-bold small text-muted">Account Created</label>
                        <p class="mb-0"><asp:Label ID="lblCreatedAt" runat="server" /></p>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-bold small text-muted">Last Updated</label>
                        <p class="mb-0"><asp:Label ID="lblUpdatedAt" runat="server" /></p>
                    </div>
                    <div class="alert alert-info mb-0">
                        <small><i class="bi bi-shield-check me-1"></i>Your account is secure. Only you can update your profile information.</small>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <style>
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
    </style>

</asp:Content>


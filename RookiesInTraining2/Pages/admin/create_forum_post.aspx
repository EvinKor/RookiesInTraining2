<%@ Page Title="Create Forum Post - Admin"
    Language="C#"
    MasterPageFile="~/MasterPages/dashboard.Master"
    AutoEventWireup="true"
    CodeBehind="create_forum_post.aspx.cs"
    Inherits="RookiesInTraining2.Pages.admin.create_forum_post" %>

<asp:Content ID="Content1" ContentPlaceHolderID="DashboardContent" runat="server">
    
    <style>
        body {
            background: #f5f7fa !important;
        }
        .card {
            background: white;
            border: 1px solid #e8ecf1;
        }
        h2, h3, h4, h5, h6 {
            color: #2d3748 !important;
        }
        .text-muted {
            color: #6c757d !important;
        }
        .card-header.bg-light {
            background-color: #f8f9fa !important;
            color: #2d3748 !important;
        }
        .form-control {
            background-color: white;
            border-color: #ced4da;
            color: #212529;
        }
        .form-control:focus {
            background-color: white;
            border-color: #80bdff;
            color: #212529;
        }
        .btn-outline-secondary {
            color: #6c757d;
            border-color: #6c757d;
        }
        .btn-outline-secondary:hover {
            background-color: #6c757d;
            border-color: #6c757d;
            color: white;
        }
        .text-primary {
            color: #0d6efd !important;
        }
        .bg-primary {
            background-color: #0d6efd !important;
        }
    </style>
    
    <div class="container mt-4">
        <!-- Header -->
        <div class="card border-0 shadow-sm mb-4">
            <div class="card-body p-4">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h2 class="mb-2"><i class="bi bi-chat-dots-fill me-2 text-primary"></i>Create Forum Post</h2>
                        <p class="mb-0 text-muted">Post a discussion for <strong id="className"></strong></p>
                    </div>
                    <asp:HyperLink ID="lnkBack" runat="server" CssClass="btn btn-outline-secondary btn-lg">
                        <i class="bi bi-arrow-left me-2"></i>Back to Forum
                    </asp:HyperLink>
                </div>
            </div>
        </div>

        <!-- Error Message -->
        <asp:Label ID="lblError" runat="server" CssClass="alert alert-danger" Visible="false" />

        <!-- Form -->
        <div class="card border-0 shadow-sm">
            <div class="card-body p-4">
                
                <div class="mb-4">
                    <label class="form-label fw-bold">Post Title <span class="text-danger">*</span></label>
                    <asp:TextBox ID="txtTitle" runat="server" 
                                 CssClass="form-control form-control-lg"
                                 placeholder="Enter an engaging title for your post..." 
                                 MaxLength="200" />
                    <asp:RequiredFieldValidator ID="rfvTitle" runat="server" 
                                               ControlToValidate="txtTitle"
                                               ErrorMessage="Post title is required"
                                               CssClass="text-danger small"
                                               Display="Dynamic" />
                </div>
                
                <div class="mb-4">
                    <label class="form-label fw-bold">Content <span class="text-danger">*</span></label>
                    <asp:TextBox ID="txtContent" runat="server" 
                                 TextMode="MultiLine" Rows="10"
                                 CssClass="form-control" 
                                 placeholder="Write your message here...&#13;&#10;&#13;&#10;You can ask questions, share announcements, or start discussions with your students." />
                    <asp:RequiredFieldValidator ID="rfvContent" runat="server" 
                                               ControlToValidate="txtContent"
                                               ErrorMessage="Post content is required"
                                               CssClass="text-danger small"
                                               Display="Dynamic" />
                    <small class="text-muted">Tip: Be clear and specific to encourage meaningful discussions</small>
                </div>

                <!-- Hidden Fields -->
                <asp:HiddenField ID="hfClassSlug" runat="server" />

            </div>
            
            <!-- Footer -->
            <div class="card-footer bg-light p-4">
                <div class="d-flex justify-content-between align-items-center">
                    <asp:HyperLink ID="lnkCancel" runat="server" CssClass="btn btn-outline-secondary btn-lg">
                        <i class="bi bi-x-circle me-2"></i>Cancel
                    </asp:HyperLink>
                    <asp:Button ID="btnCreatePost" runat="server" 
                                Text="Post to Forum" 
                                CssClass="btn btn-primary btn-lg px-5"
                                OnClick="btnCreatePost_Click" />
                </div>
            </div>
        </div>
    </div>

    <script>
        // Display class name from query string
        const urlParams = new URLSearchParams(window.location.search);
        const className = urlParams.get('className');
        if (className) {
            document.getElementById('className').textContent = decodeURIComponent(className);
        }
    </script>

</asp:Content>



<%@ Page Title="Create New Level - Admin"
    Language="C#"
    MasterPageFile="~/MasterPages/dashboard.Master"
    AutoEventWireup="true"
    CodeBehind="create_level.aspx.cs"
    Inherits="RookiesInTraining2.Pages.admin.create_level" %>

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
                        <h2 class="mb-2"><i class="bi bi-plus-circle me-2 text-primary"></i>Create New Learning Level</h2>
                        <p class="mb-0 text-muted">Add a new level with quiz to <strong id="className"></strong></p>
                    </div>
                    <asp:HyperLink ID="lnkBack" runat="server" CssClass="btn btn-outline-secondary btn-lg">
                        <i class="bi bi-arrow-left me-2"></i>Back to Storymode
                    </asp:HyperLink>
                </div>
            </div>
        </div>

        <!-- Error Message -->
        <asp:Label ID="lblError" runat="server" CssClass="alert alert-danger" Visible="false" />

        <!-- Form -->
        <div class="card border-0 shadow-sm">
            <div class="card-body p-4">
                
                <!-- Level Information -->
                <h4 class="mb-4"><i class="bi bi-layers me-2 text-primary"></i>Level Information</h4>
                
                <div class="row g-3 mb-4">
                    <div class="col-md-3">
                        <label class="form-label fw-bold">Level Number</label>
                        <asp:TextBox ID="txtLevelNumber" runat="server" 
                                     CssClass="form-control form-control-lg text-center"
                                     TextMode="Number" ReadOnly="true" />
                    </div>
                    <div class="col-md-9">
                        <label class="form-label fw-bold">Level Title <span class="text-danger">*</span></label>
                        <asp:TextBox ID="txtLevelTitle" runat="server" 
                                     CssClass="form-control form-control-lg"
                                     placeholder="e.g., Introduction to Variables" 
                                     MaxLength="200" />
                        <asp:RequiredFieldValidator ID="rfvTitle" runat="server" 
                                                   ControlToValidate="txtLevelTitle"
                                                   ErrorMessage="Level title is required"
                                                   CssClass="text-danger small"
                                                   Display="Dynamic" />
                    </div>
                </div>
                
                <div class="mb-4">
                    <label class="form-label fw-bold">Description</label>
                    <asp:TextBox ID="txtDescription" runat="server" 
                                 TextMode="MultiLine" Rows="3"
                                 CssClass="form-control" 
                                 placeholder="What will students learn in this level..."
                                 MaxLength="500" />
                </div>
                
                <div class="row g-3 mb-4">
                    <div class="col-md-6">
                        <label class="form-label fw-bold">Estimated Minutes</label>
                        <asp:TextBox ID="txtMinutes" runat="server" 
                                     CssClass="form-control" TextMode="Number" Text="15" />
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-bold">XP Reward</label>
                        <asp:TextBox ID="txtXP" runat="server" 
                                     CssClass="form-control" TextMode="Number" Text="50" />
                    </div>
                </div>
                
                <div class="mb-4">
                    <label class="form-label fw-bold">Upload Learning Material (Optional)</label>
                    <asp:FileUpload ID="fileUpload" runat="server" 
                                    CssClass="form-control form-control-lg" 
                                    accept=".pdf,.pptx,.ppt" />
                    <small class="text-muted">Supported: PDF, PowerPoint (You can also add custom slides later)</small>
                </div>
                
                <hr class="my-4" />
                
                <!-- Quiz Information -->
                <h4 class="mb-4"><i class="bi bi-question-circle-fill me-2 text-warning"></i>Quiz for This Level</h4>
                
                <div class="mb-3">
                    <label class="form-label fw-bold">Quiz Title <span class="text-danger">*</span></label>
                    <asp:TextBox ID="txtQuizTitle" runat="server" 
                                 CssClass="form-control form-control-lg"
                                 placeholder="e.g., Level 1 Quiz"
                                 MaxLength="200" />
                    <asp:RequiredFieldValidator ID="rfvQuizTitle" runat="server" 
                                               ControlToValidate="txtQuizTitle"
                                               ErrorMessage="Quiz title is required"
                                               CssClass="text-danger small"
                                               Display="Dynamic" />
                </div>
                
                <div class="row g-3 mb-4">
                    <div class="col-md-4">
                        <label class="form-label fw-bold">Quiz Mode</label>
                        <asp:DropDownList ID="ddlQuizMode" runat="server" CssClass="form-select">
                            <asp:ListItem Value="story" Selected="True">Story Mode</asp:ListItem>
                            <asp:ListItem Value="battle">Battle Mode</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-bold">Time Limit (minutes)</label>
                        <asp:TextBox ID="txtTimeLimit" runat="server" 
                                     CssClass="form-control" TextMode="Number" Text="30" />
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-bold">Passing Score (%)</label>
                        <asp:TextBox ID="txtPassingScore" runat="server" 
                                     CssClass="form-control" TextMode="Number" Text="70" />
                    </div>
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
                    <asp:Button ID="btnCreateLevel" runat="server" 
                                Text="Create Level with Quiz" 
                                CssClass="btn btn-primary btn-lg px-5"
                                OnClick="btnCreateLevel_Click" />
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


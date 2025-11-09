<%@ Page Title="Create Quiz - Admin"
    Language="C#"
    MasterPageFile="~/MasterPages/dashboard.Master"
    AutoEventWireup="true"
    CodeBehind="create_quiz.aspx.cs"
    Inherits="RookiesInTraining2.Pages.admin.create_quiz" %>

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
        .bg-warning {
            background-color: #ffc107 !important;
        }
    </style>
    
    <div class="container mt-4">
        <!-- Header -->
        <div class="card border-0 shadow-sm mb-4">
            <div class="card-body p-4">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h2 class="mb-2"><i class="bi bi-question-circle-fill me-2 text-primary"></i>Create Quiz</h2>
                        <p class="mb-0 text-muted">Create a new quiz for <strong id="className"></strong></p>
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
                
                <div class="mb-4">
                    <label class="form-label fw-bold">
                        <i class="bi bi-layers me-1"></i>Select Level <span class="text-danger">*</span>
                    </label>
                    <asp:DropDownList ID="ddlLevelForQuiz" runat="server" 
                                      CssClass="form-select form-select-lg" />
                    <asp:RequiredFieldValidator ID="rfvLevel" runat="server" 
                                               ControlToValidate="ddlLevelForQuiz"
                                               ErrorMessage="Please select a level"
                                               CssClass="text-danger small"
                                               Display="Dynamic" />
                    <small class="text-muted">Select the level this quiz belongs to</small>
                </div>

                <div class="mb-4">
                    <label class="form-label fw-bold">
                        Quiz Title <span class="text-danger">*</span>
                    </label>
                    <asp:TextBox ID="txtQuizTitle" runat="server" 
                                 CssClass="form-control form-control-lg"
                                 placeholder="e.g., Variables Quiz" MaxLength="200" />
                    <asp:RequiredFieldValidator ID="rfvQuizTitle" runat="server" 
                                               ControlToValidate="txtQuizTitle"
                                               ErrorMessage="Quiz title is required"
                                               CssClass="text-danger small"
                                               Display="Dynamic" />
                </div>

                <div class="row g-3 mb-4">
                    <div class="col-md-4">
                        <label class="form-label fw-bold">
                            <i class="bi bi-clock text-info me-1"></i>Time Limit (min)
                        </label>
                        <asp:TextBox ID="txtTimeLimit" runat="server" 
                                     CssClass="form-control"
                                     TextMode="Number" Text="30" />
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-bold">
                            <i class="bi bi-graph-up text-success me-1"></i>Passing Score (%)
                        </label>
                        <asp:TextBox ID="txtPassingScore" runat="server" 
                                     CssClass="form-control"
                                     TextMode="Number" Text="70" />
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-bold">
                            <i class="bi bi-controller me-1"></i>Mode
                        </label>
                        <asp:DropDownList ID="ddlQuizMode" runat="server" CssClass="form-select">
                            <asp:ListItem Value="story" Selected="True">Story Mode</asp:ListItem>
                            <asp:ListItem Value="battle">Battle Mode</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>

                <div class="mb-4">
                    <div class="form-check form-switch">
                        <asp:CheckBox ID="chkPublishQuiz" runat="server" 
                                      CssClass="form-check-input"
                                      Checked="false" />
                        <label class="form-check-label fw-bold">
                            <i class="bi bi-eye me-1"></i>Publish immediately
                        </label>
                    </div>
                </div>

                <div class="alert alert-info border-0 shadow-sm">
                    <div class="d-flex align-items-start">
                        <i class="bi bi-lightbulb-fill text-info me-3 fs-4"></i>
                        <div>
                            <strong>Tip:</strong> After creating the quiz, you'll be able to add questions to it.
                        </div>
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
                    <asp:Button ID="btnCreateQuiz" runat="server" 
                                Text="Create Quiz & Add Questions" 
                                CssClass="btn btn-warning text-dark btn-lg px-5 fw-bold"
                                OnClick="btnCreateQuiz_Click" />
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


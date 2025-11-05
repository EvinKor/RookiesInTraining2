<%@ Page Title="Class Detail"
    Language="C#"
    MasterPageFile="~/MasterPages/MyMain.Master"
    AutoEventWireup="true"
    CodeBehind="class_detail.aspx.cs"
    Inherits="RookiesInTraining2.Pages.class_detail" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <link rel="stylesheet" href="<%= ResolveUrl("~/Content/class-detail.css") %>" />

    <div class="class-detail-container">
        
        <!-- Class Header -->
        <div class="class-header" id="classHeader">
            <div class="container-fluid py-4">
                <div class="d-flex justify-content-between align-items-start mb-3">
                    <a href="<%= ResolveUrl("~/Pages/teacher_classes.aspx") %>" class="btn btn-sm btn-outline-light">
                        <i class="bi bi-arrow-left me-1"></i> Back to Classes
                    </a>
                    <div class="dropdown">
                        <button class="btn btn-sm btn-outline-light dropdown-toggle" type="button" data-bs-toggle="dropdown">
                            <i class="bi bi-three-dots"></i>
                        </button>
                        <ul class="dropdown-menu">
                            <li><a class="dropdown-item" href="#"><i class="bi bi-gear me-2"></i>Class Settings</a></li>
                            <li><a class="dropdown-item" href="#"><i class="bi bi-people me-2"></i>Manage Students</a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item text-danger" href="#"><i class="bi bi-archive me-2"></i>Archive Class</a></li>
                        </ul>
                    </div>
                </div>
                
                <div class="row align-items-center">
                    <div class="col-lg-8">
                        <div class="d-flex align-items-center mb-3">
                            <div class="class-icon-large me-3" id="classIconLarge">
                                <i class="bi bi-book"></i>
                            </div>
                            <div>
                                <h1 class="mb-1" id="className">Loading...</h1>
                                <div class="class-code-display">
                                    <i class="bi bi-key me-1"></i>
                                    <span id="classCode">...</span>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-4 text-lg-end">
                        <div class="class-stats-compact">
                            <div class="stat-item">
                                <i class="bi bi-people-fill"></i>
                                <span id="studentCount">0</span> Students
                            </div>
                            <div class="stat-item">
                                <i class="bi bi-layers"></i>
                                <span id="levelCount">0</span> Levels
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Tab Navigation -->
        <div class="container-fluid">
            <ul class="nav nav-tabs custom-tabs" role="tablist">
                <li class="nav-item">
                    <button class="nav-link active" data-bs-toggle="tab" data-bs-target="#levelsTab">
                        <i class="bi bi-layers me-2"></i>Levels
                    </button>
                </li>
                <li class="nav-item">
                    <button class="nav-link" data-bs-toggle="tab" data-bs-target="#studentsTab">
                        <i class="bi bi-people me-2"></i>Students
                    </button>
                </li>
                <li class="nav-item">
                    <button class="nav-link" data-bs-toggle="tab" data-bs-target="#quizzesTab">
                        <i class="bi bi-question-circle me-2"></i>Quizzes
                    </button>
                </li>
                <li class="nav-item">
                    <button class="nav-link" data-bs-toggle="tab" data-bs-target="#resourcesTab">
                        <i class="bi bi-files me-2"></i>Resources
                    </button>
                </li>
            </ul>
        </div>

        <!-- Tab Content -->
        <div class="container-fluid py-4">
            <div class="tab-content">
                
                <!-- LEVELS TAB -->
                <div class="tab-pane fade show active" id="levelsTab">
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <h3 class="mb-0">Learning Levels</h3>
                        <button class="btn btn-primary" onclick="openCreateLevelModal()">
                            <i class="bi bi-plus-circle me-2"></i>Create New Level
                        </button>
                    </div>

                    <div id="levelsContainer" class="levels-list">
                        <!-- Levels will be rendered here -->
                    </div>

                    <div id="noLevels" class="empty-state" style="display: none;">
                        <i class="bi bi-layers display-4 text-muted"></i>
                        <h4>No Levels Yet</h4>
                        <p class="text-muted">Create your first learning level</p>
                        <button class="btn btn-primary" onclick="openCreateLevelModal()">
                            <i class="bi bi-plus-circle me-2"></i>Create First Level
                        </button>
                    </div>
                </div>

                <!-- STUDENTS TAB -->
                <div class="tab-pane fade" id="studentsTab">
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <h3 class="mb-0">Enrolled Students</h3>
                        <button class="btn btn-outline-primary">
                            <i class="bi bi-download me-2"></i>Export List
                        </button>
                    </div>

                    <div id="studentsContainer">
                        <!-- Students will be rendered here -->
                    </div>
                </div>

                <!-- QUIZZES TAB -->
                <div class="tab-pane fade" id="quizzesTab">
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <h3 class="mb-0">All Quizzes</h3>
                        <button class="btn btn-primary" onclick="openCreateQuizModal()">
                            <i class="bi bi-plus-circle me-2"></i>Create Quiz
                        </button>
                    </div>

                    <div id="quizzesContainer">
                        <!-- Quizzes will be rendered here -->
                    </div>
                </div>

                <!-- RESOURCES TAB -->
                <div class="tab-pane fade" id="resourcesTab">
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <h3 class="mb-0">Class Resources</h3>
                        <button class="btn btn-primary" onclick="openUploadResourceModal()">
                            <i class="bi bi-upload me-2"></i>Upload Resource
                        </button>
                    </div>

                    <div id="resourcesContainer">
                        <!-- Resources will be rendered here -->
                    </div>
                </div>
            </div>
        </div>

        <!-- CREATE LEVEL MODAL -->
        <div id="createLevelModal" class="custom-modal" style="display: none;">
            <div class="modal-overlay" onclick="closeCreateLevelModal()"></div>
            <div class="modal-content modal-lg">
                <div class="modal-header">
                    <h3>Create New Level</h3>
                    <button type="button" class="btn-close" onclick="closeCreateLevelModal()">
                        <i class="bi bi-x-lg"></i>
                    </button>
                </div>
                <div class="modal-body">
                    <asp:Label ID="lblLevelError" runat="server" CssClass="alert alert-danger" Visible="false" />

                    <div class="row g-3">
                        <div class="col-md-3">
                            <label class="form-label fw-bold">Level Number <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtLevelNumber" runat="server" CssClass="form-control form-control-lg text-center"
                                         TextMode="Number" placeholder="1" />
                            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtLevelNumber"
                                ValidationGroup="CreateLevel" CssClass="text-danger small" ErrorMessage="Required" Display="Dynamic" />
                        </div>

                        <div class="col-md-9">
                            <label class="form-label fw-bold">Level Title <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtLevelTitle" runat="server" CssClass="form-control form-control-lg"
                                         placeholder="e.g., Introduction to Variables" MaxLength="200" />
                            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtLevelTitle"
                                ValidationGroup="CreateLevel" CssClass="text-danger small" ErrorMessage="Required" Display="Dynamic" />
                        </div>
                    </div>

                    <div class="mb-3 mt-3">
                        <label class="form-label fw-bold">Description</label>
                        <asp:TextBox ID="txtLevelDescription" runat="server" TextMode="MultiLine" Rows="3"
                                     CssClass="form-control" placeholder="Brief description of what students will learn..." MaxLength="1000" />
                    </div>

                    <div class="row g-3 mb-3">
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Estimated Time (minutes)</label>
                            <asp:TextBox ID="txtEstimatedMinutes" runat="server" CssClass="form-control"
                                         TextMode="Number" Text="15" />
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold">XP Reward</label>
                            <asp:TextBox ID="txtXpReward" runat="server" CssClass="form-control"
                                         TextMode="Number" Text="50" />
                        </div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-bold">Upload Learning Material</label>
                        <asp:FileUpload ID="fileUpload" runat="server" CssClass="form-control" 
                                        accept=".pptx,.ppt,.pdf,.mp4,.avi" />
                        <small class="text-muted">Supported: PowerPoint (.pptx, .ppt), PDF, Video (.mp4, .avi)</small>
                    </div>

                    <div class="form-check mb-3">
                        <asp:CheckBox ID="chkPublishLevel" runat="server" CssClass="form-check-input" />
                        <label class="form-check-label">
                            Publish immediately (students can access)
                        </label>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" onclick="closeCreateLevelModal()">Cancel</button>
                    <asp:Button ID="btnSaveLevel" runat="server" Text="Create Level" 
                                CssClass="btn btn-primary btn-lg" ValidationGroup="CreateLevel"
                                OnClick="btnSaveLevel_Click" />
                </div>
            </div>
        </div>

        <!-- CREATE QUIZ MODAL -->
        <div id="createQuizModal" class="custom-modal" style="display: none;">
            <div class="modal-overlay" onclick="closeCreateQuizModal()"></div>
            <div class="modal-content modal-lg">
                <div class="modal-header">
                    <h3>Create Quiz for Level</h3>
                    <button type="button" class="btn-close" onclick="closeCreateQuizModal()">
                        <i class="bi bi-x-lg"></i>
                    </button>
                </div>
                <div class="modal-body">
                    <asp:Label ID="lblQuizError" runat="server" CssClass="alert alert-danger" Visible="false" />

                    <div class="mb-3">
                        <label class="form-label fw-bold">Select Level <span class="text-danger">*</span></label>
                        <asp:DropDownList ID="ddlLevelForQuiz" runat="server" CssClass="form-select form-select-lg" />
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="ddlLevelForQuiz"
                            ValidationGroup="CreateQuiz" CssClass="text-danger small" ErrorMessage="Please select a level" Display="Dynamic" />
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-bold">Quiz Title <span class="text-danger">*</span></label>
                        <asp:TextBox ID="txtQuizTitle" runat="server" CssClass="form-control form-control-lg"
                                     placeholder="e.g., Variables Quiz" MaxLength="200" />
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtQuizTitle"
                            ValidationGroup="CreateQuiz" CssClass="text-danger small" ErrorMessage="Required" Display="Dynamic" />
                    </div>

                    <div class="row g-3 mb-3">
                        <div class="col-md-4">
                            <label class="form-label fw-bold">Time Limit (min)</label>
                            <asp:TextBox ID="txtTimeLimit" runat="server" CssClass="form-control"
                                         TextMode="Number" Text="30" />
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-bold">Passing Score (%)</label>
                            <asp:TextBox ID="txtPassingScore" runat="server" CssClass="form-control"
                                         TextMode="Number" Text="70" />
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-bold">Mode</label>
                            <asp:DropDownList ID="ddlQuizMode" runat="server" CssClass="form-select">
                                <asp:ListItem Value="story" Selected="True">Story Mode</asp:ListItem>
                                <asp:ListItem Value="battle">Battle Mode</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>

                    <div class="form-check mb-3">
                        <asp:CheckBox ID="chkPublishQuiz" runat="server" CssClass="form-check-input" />
                        <label class="form-check-label">
                            Publish immediately
                        </label>
                    </div>

                    <div class="alert alert-info">
                        <i class="bi bi-info-circle me-2"></i>
                        After creating the quiz, you'll be able to add questions to it.
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" onclick="closeCreateQuizModal()">Cancel</button>
                    <asp:Button ID="btnSaveQuiz" runat="server" Text="Create Quiz & Add Questions" 
                                CssClass="btn btn-primary btn-lg" ValidationGroup="CreateQuiz"
                                OnClick="btnSaveQuiz_Click" />
                </div>
            </div>
        </div>

        <!-- Hidden Fields -->
        <asp:HiddenField ID="hfClassSlug" runat="server" />
        <asp:HiddenField ID="hfLevelsJson" runat="server" />
        <asp:HiddenField ID="hfStudentsJson" runat="server" />
        <asp:HiddenField ID="hfQuizzesJson" runat="server" />
        <asp:HiddenField ID="hfClassData" runat="server" />
    </div>

    <script type="text/javascript">
        window.CLASS_DATA = {
            classSlug: '<%= Request.QueryString["slug"] %>',
            levelsFieldId: '<%= hfLevelsJson.ClientID %>',
            studentsFieldId: '<%= hfStudentsJson.ClientID %>',
            quizzesFieldId: '<%= hfQuizzesJson.ClientID %>',
            classDataFieldId: '<%= hfClassData.ClientID %>'
        };
    </script>

    <script src="<%= ResolveUrl("~/Scripts/class-detail.js") %>"></script>
</asp:Content>


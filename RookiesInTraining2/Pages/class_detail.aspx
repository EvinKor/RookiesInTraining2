<%@ Page Title="Class Detail"
    Language="C#"
    MasterPageFile="~/MasterPages/MyMain.Master"
    AutoEventWireup="true"
    CodeBehind="class_detail.aspx.cs"
    Inherits="RookiesInTraining2.Pages.class_detail" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    
    <style>
        .class-header-gradient {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
        }
        .class-icon-large {
            width: 80px;
            height: 80px;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 1rem;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2.5rem;
        }
        .class-code-badge {
            background: rgba(255, 255, 255, 0.2);
            font-family: 'Courier New', monospace;
            font-size: 1.1rem;
            padding: 0.5rem 1rem;
            border-radius: 0.5rem;
            font-weight: 600;
        }
        .stat-pill {
            background: rgba(255, 255, 255, 0.2);
            padding: 0.75rem 1.5rem;
            border-radius: 2rem;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
        }
        .stat-pill i { font-size: 1.5rem; }
        .level-card {
            transition: all 0.3s ease;
            border: none;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
        }
        .level-card:hover {
            box-shadow: 0 4px 16px rgba(0,0,0,0.12);
            transform: translateY(-2px);
        }
        .level-number-badge {
            width: 60px;
            height: 60px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            border-radius: 1rem;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            font-weight: 700;
            color: white;
        }
        .quiz-card-hover {
            transition: all 0.3s ease;
        }
        .quiz-card-hover:hover {
            transform: translateY(-4px);
            box-shadow: 0 8px 24px rgba(0,0,0,0.15) !important;
        }
        @media (max-width: 768px) {
            .class-icon-large { width: 60px; height: 60px; font-size: 2rem; }
        }
    </style>

    <div class="class-detail-container">
        
        <!-- Class Header -->
        <div class="class-header-gradient" id="classHeader">
            <div class="container-fluid py-4">
                <div class="d-flex justify-content-between align-items-start mb-4">
                    <a href="<%= ResolveUrl("~/Pages/teacher_browse_classes.aspx") %>" class="btn btn-sm btn-outline-light">
                        <i class="bi bi-arrow-left me-2"></i>Back to Classes
                    </a>
                    <div class="dropdown">
                        <button class="btn btn-sm btn-outline-light dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                            <i class="bi bi-three-dots-vertical"></i>
                        </button>
                        <ul class="dropdown-menu dropdown-menu-end shadow">
                            <li><a class="dropdown-item" href="#"><i class="bi bi-gear me-2"></i>Class Settings</a></li>
                            <li><a class="dropdown-item" href="#"><i class="bi bi-people me-2"></i>Manage Students</a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item text-danger" href="#"><i class="bi bi-archive me-2"></i>Archive Class</a></li>
                        </ul>
                    </div>
                </div>
                
                <div class="row align-items-center g-4">
                    <div class="col-lg-8">
                        <div class="d-flex align-items-center">
                            <div class="class-icon-large me-3" id="classIconLarge">
                                <i class="bi bi-book"></i>
                            </div>
                            <div>
                                <h1 class="display-5 fw-bold mb-2" id="className">Loading...</h1>
                                <div class="d-flex flex-wrap gap-2 align-items-center">
                                    <span class="class-code-badge">
                                        <i class="bi bi-key me-1"></i>
                                        <span id="classCode">...</span>
                                    </span>
                                    <span class="badge bg-light text-dark" id="classDescription"></span>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="d-flex flex-wrap gap-2 justify-content-lg-end">
                            <span class="stat-pill">
                                <i class="bi bi-people-fill"></i>
                                <span><strong id="studentCount">0</strong> Students</span>
                            </span>
                            <span class="stat-pill">
                                <i class="bi bi-layers-fill"></i>
                                <span><strong id="levelCount">0</strong> Levels</span>
                            </span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Tab Navigation -->
        <div class="container-fluid bg-white border-bottom">
            <ul class="nav nav-pills nav-fill" role="tablist">
                <li class="nav-item">
                    <button class="nav-link active rounded-0 border-0 py-3" data-bs-toggle="tab" data-bs-target="#levelsTab">
                        <i class="bi bi-layers-fill me-2"></i>Levels
                    </button>
                </li>
                <li class="nav-item">
                    <button class="nav-link rounded-0 border-0 py-3" data-bs-toggle="tab" data-bs-target="#studentsTab">
                        <i class="bi bi-people-fill me-2"></i>Students
                    </button>
                </li>
                <li class="nav-item">
                    <button class="nav-link rounded-0 border-0 py-3" data-bs-toggle="tab" data-bs-target="#quizzesTab">
                        <i class="bi bi-question-circle-fill me-2"></i>Quizzes
                    </button>
                </li>
                <li class="nav-item">
                    <button class="nav-link rounded-0 border-0 py-3" data-bs-toggle="tab" data-bs-target="#resourcesTab">
                        <i class="bi bi-files me-2"></i>Resources
                    </button>
                </li>
            </ul>
        </div>

        <!-- Tab Content -->
        <div class="container-fluid py-4 bg-light">
            <div class="tab-content">
                
                <!-- LEVELS TAB -->
                <div class="tab-pane fade show active" id="levelsTab">
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <div>
                            <h3 class="mb-1 fw-bold"><i class="bi bi-layers-fill text-primary me-2"></i>Learning Levels</h3>
                            <p class="text-muted mb-0">Manage all levels and content for this class</p>
                        </div>
                        <button class="btn btn-primary btn-lg shadow-sm" onclick="openCreateLevelModal()">
                            <i class="bi bi-plus-circle me-2"></i>Create New Level
                        </button>
                    </div>

                    <div id="levelsContainer" class="row g-3">
                        <!-- Levels will be rendered here -->
                    </div>

                    <div id="noLevels" class="text-center py-5 bg-white rounded-3 shadow-sm" style="display: none;">
                        <i class="bi bi-layers display-1 text-muted opacity-25"></i>
                        <h4 class="mt-3 mb-2">No Levels Yet</h4>
                        <p class="text-muted mb-4">Create your first learning level to start teaching</p>
                        <button class="btn btn-primary btn-lg" onclick="openCreateLevelModal()">
                            <i class="bi bi-plus-circle me-2"></i>Create First Level
                        </button>
                    </div>
                </div>

                <!-- STUDENTS TAB -->
                <div class="tab-pane fade" id="studentsTab">
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <div>
                            <h3 class="mb-1 fw-bold"><i class="bi bi-people-fill text-success me-2"></i>Enrolled Students</h3>
                            <p class="text-muted mb-0">View and manage students in this class</p>
                        </div>
                        <div class="btn-group shadow-sm">
                            <button class="btn btn-outline-success">
                                <i class="bi bi-person-plus me-2"></i>Add Student
                            </button>
                            <button class="btn btn-outline-secondary">
                                <i class="bi bi-download me-2"></i>Export List
                            </button>
                        </div>
                    </div>

                    <div class="card border-0 shadow-sm">
                        <div class="card-body p-0">
                            <div id="studentsContainer" class="table-responsive">
                                <!-- Students table will be rendered here -->
                            </div>
                        </div>
                    </div>
                </div>

                <!-- QUIZZES TAB -->
                <div class="tab-pane fade" id="quizzesTab">
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <div>
                            <h3 class="mb-1 fw-bold"><i class="bi bi-question-circle-fill text-warning me-2"></i>All Quizzes</h3>
                            <p class="text-muted mb-0">Manage quizzes and questions for this class</p>
                        </div>
                        <button class="btn btn-primary btn-lg shadow-sm" onclick="openCreateQuizModal()">
                            <i class="bi bi-plus-circle me-2"></i>Create Quiz
                        </button>
                    </div>

                    <div id="quizzesContainer" class="row g-3">
                        <!-- Quizzes will be rendered here -->
                    </div>

                    <div id="noQuizzes" class="text-center py-5 bg-white rounded-3 shadow-sm" style="display: none;">
                        <i class="bi bi-question-circle display-1 text-muted opacity-25"></i>
                        <h4 class="mt-3 mb-2">No Quizzes Yet</h4>
                        <p class="text-muted mb-4">Create quizzes to assess student learning</p>
                        <button class="btn btn-primary btn-lg" onclick="openCreateQuizModal()">
                            <i class="bi bi-plus-circle me-2"></i>Create First Quiz
                        </button>
                    </div>
                </div>

                <!-- RESOURCES TAB -->
                <div class="tab-pane fade" id="resourcesTab">
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <div>
                            <h3 class="mb-1 fw-bold"><i class="bi bi-files text-info me-2"></i>Class Resources</h3>
                            <p class="text-muted mb-0">Upload and manage files and materials</p>
                        </div>
                        <button class="btn btn-primary btn-lg shadow-sm" onclick="openUploadResourceModal()">
                            <i class="bi bi-upload me-2"></i>Upload Resource
                        </button>
                    </div>

                    <div id="resourcesContainer" class="row g-3">
                        <!-- Resources will be rendered here -->
                    </div>

                    <div id="noResources" class="text-center py-5 bg-white rounded-3 shadow-sm">
                        <i class="bi bi-folder2-open display-1 text-muted opacity-25"></i>
                        <h4 class="mt-3 mb-2">No Resources Yet</h4>
                        <p class="text-muted mb-4">Upload files for students to download</p>
                        <button class="btn btn-primary btn-lg" onclick="openUploadResourceModal()">
                            <i class="bi bi-upload me-2"></i>Upload First Resource
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- CREATE LEVEL MODAL -->
        <div class="modal fade" id="createLevelModal" tabindex="-1" aria-labelledby="createLevelModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
                <div class="modal-content border-0 shadow-lg">
                    <div class="modal-header bg-primary text-white">
                        <h5 class="modal-title fw-bold" id="createLevelModalLabel">
                            <i class="bi bi-plus-circle me-2"></i>Create New Level
                        </h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body p-4">
                        <asp:Label ID="lblLevelError" runat="server" CssClass="alert alert-danger" Visible="false" />

                        <div class="row g-3 mb-3">
                            <div class="col-md-3">
                                <label class="form-label fw-bold">
                                    Level Number <span class="text-danger">*</span>
                                </label>
                                <asp:TextBox ID="txtLevelNumber" runat="server" 
                                             CssClass="form-control form-control-lg text-center"
                                             TextMode="Number" placeholder="1" />
                                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtLevelNumber"
                                    ValidationGroup="CreateLevel" CssClass="text-danger small d-block mt-1" 
                                    ErrorMessage="Required" Display="Dynamic" />
                            </div>

                            <div class="col-md-9">
                                <label class="form-label fw-bold">
                                    Level Title <span class="text-danger">*</span>
                                </label>
                                <asp:TextBox ID="txtLevelTitle" runat="server" 
                                             CssClass="form-control form-control-lg"
                                             placeholder="e.g., Introduction to Variables" MaxLength="200" />
                                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtLevelTitle"
                                    ValidationGroup="CreateLevel" CssClass="text-danger small d-block mt-1" 
                                    ErrorMessage="Required" Display="Dynamic" />
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-bold">Description</label>
                            <asp:TextBox ID="txtLevelDescription" runat="server" 
                                         TextMode="MultiLine" Rows="3"
                                         CssClass="form-control" 
                                         placeholder="What will students learn in this level..." MaxLength="1000" />
                        </div>

                        <div class="row g-3 mb-3">
                            <div class="col-md-6">
                                <label class="form-label fw-bold">
                                    <i class="bi bi-clock text-info me-1"></i>Estimated Minutes
                                </label>
                                <asp:TextBox ID="txtEstimatedMinutes" runat="server" 
                                             CssClass="form-control"
                                             TextMode="Number" Text="15" />
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-bold">
                                    <i class="bi bi-star text-warning me-1"></i>XP Reward
                                </label>
                                <asp:TextBox ID="txtXpReward" runat="server" 
                                             CssClass="form-control"
                                             TextMode="Number" Text="50" />
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-bold">
                                <i class="bi bi-file-earmark-arrow-up text-success me-1"></i>Upload Learning Material
                            </label>
                            <asp:FileUpload ID="fileUpload" runat="server" 
                                            CssClass="form-control form-control-lg" 
                                            accept=".pptx,.ppt,.pdf,.mp4,.avi,.mov" />
                            <div class="form-text">
                                <i class="bi bi-info-circle me-1"></i>
                                Supported: PowerPoint (.pptx, .ppt), PDF, Video (.mp4, .avi, .mov)
                            </div>
                        </div>

                        <div class="form-check form-switch mb-0">
                            <asp:CheckBox ID="chkPublishLevel" runat="server" 
                                          CssClass="form-check-input" 
                                          Checked="true" />
                            <label class="form-check-label fw-semibold">
                                <i class="bi bi-eye me-1"></i>Publish immediately (students can access)
                            </label>
                        </div>
                    </div>
                    <div class="modal-footer bg-light">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                            <i class="bi bi-x-circle me-1"></i>Cancel
                        </button>
                        <asp:Button ID="btnSaveLevel" runat="server" 
                                    Text="✓ Create Level" 
                                    CssClass="btn btn-primary btn-lg px-4" 
                                    ValidationGroup="CreateLevel"
                                    OnClick="btnSaveLevel_Click" />
                    </div>
                </div>
            </div>
        </div>

        <!-- CREATE QUIZ MODAL -->
        <div class="modal fade" id="createQuizModal" tabindex="-1" aria-labelledby="createQuizModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
                <div class="modal-content border-0 shadow-lg">
                    <div class="modal-header bg-warning text-dark">
                        <h5 class="modal-title fw-bold" id="createQuizModalLabel">
                            <i class="bi bi-question-circle-fill me-2"></i>Create Quiz for Level
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body p-4">
                        <asp:Label ID="lblQuizError" runat="server" CssClass="alert alert-danger d-none" />

                        <div class="mb-3">
                            <label class="form-label fw-bold">
                                <i class="bi bi-layers me-1"></i>Select Level <span class="text-danger">*</span>
                            </label>
                            <asp:DropDownList ID="ddlLevelForQuiz" runat="server" 
                                              CssClass="form-select form-select-lg" />
                            <asp:RequiredFieldValidator runat="server" ControlToValidate="ddlLevelForQuiz"
                                ValidationGroup="CreateQuiz" CssClass="text-danger small d-block mt-1" 
                                ErrorMessage="Please select a level" Display="Dynamic" />
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-bold">
                                Quiz Title <span class="text-danger">*</span>
                            </label>
                            <asp:TextBox ID="txtQuizTitle" runat="server" 
                                         CssClass="form-control form-control-lg"
                                         placeholder="e.g., Variables Quiz" MaxLength="200" />
                            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtQuizTitle"
                                ValidationGroup="CreateQuiz" CssClass="text-danger small d-block mt-1" 
                                ErrorMessage="Required" Display="Dynamic" />
                        </div>

                        <div class="row g-3 mb-3">
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

                        <div class="form-check form-switch mb-3">
                            <asp:CheckBox ID="chkPublishQuiz" runat="server" 
                                          CssClass="form-check-input"
                                          Checked="false" />
                            <label class="form-check-label fw-semibold">
                                <i class="bi bi-eye me-1"></i>Publish immediately
                            </label>
                        </div>

                        <div class="alert alert-info border-0 shadow-sm">
                            <div class="d-flex align-items-start">
                                <i class="bi bi-lightbulb-fill text-info me-3 fs-4"></i>
                                <div>
                                    <strong>Tip:</strong> After creating the quiz, you'll be able to add questions to it.
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer bg-light">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                            <i class="bi bi-x-circle me-1"></i>Cancel
                        </button>
                        <asp:Button ID="btnSaveQuiz" runat="server" 
                                    Text="✓ Create Quiz & Add Questions" 
                                    CssClass="btn btn-warning text-dark btn-lg px-4 fw-bold" 
                                    ValidationGroup="CreateQuiz"
                                    OnClick="btnSaveQuiz_Click" />
                    </div>
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

        // Debug: Log configuration on page load
        console.log('CLASS_DATA Configuration:', window.CLASS_DATA);
        console.log('Query String Slug:', '<%= Request.QueryString["slug"] %>');

        // Bootstrap Modal Functions - Make them globally accessible
        window.openCreateLevelModal = function() {
            const modalElement = document.getElementById('createLevelModal');
            if (modalElement) {
                // Clear any previous errors
                const errorLabel = document.getElementById('<%= lblLevelError.ClientID %>');
                if (errorLabel) {
                    errorLabel.style.display = 'none';
                    errorLabel.textContent = '';
                }
                
                // Show modal using Bootstrap
                const modal = new bootstrap.Modal(modalElement);
                modal.show();
            } else {
                console.error('createLevelModal element not found');
            }
        };

        window.openCreateQuizModal = function() {
            const modalElement = document.getElementById('createQuizModal');
            if (modalElement) {
                const modal = new bootstrap.Modal(modalElement);
                modal.show();
            }
        };

        window.openUploadResourceModal = function() {
            alert('Upload resource feature coming soon!');
        };
    </script>

    <script src="<%= ResolveUrl("~/Scripts/class-detail.js") %>"></script>
</asp:Content>

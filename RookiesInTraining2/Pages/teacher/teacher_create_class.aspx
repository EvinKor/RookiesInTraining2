<%@ Page Title="Create New Class - Teacher"
    Language="C#"
    MasterPageFile="~/MasterPages/MyMain.Master"
    AutoEventWireup="true"
    CodeBehind="teacher_create_class.aspx.cs"
    Inherits="RookiesInTraining2.Pages.teacher_create_class" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <link rel="stylesheet" href="<%= ResolveUrl("~/Content/teacher-classes.css") %>" />

    <style>
        .wizard-container {
            max-width: 900px;
            margin: 0 auto;
        }
        .wizard-card {
            border: none;
            box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.1);
            border-radius: 1rem;
            overflow: hidden;
        }
        .wizard-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 2rem;
        }
        .wizard-steps {
            display: flex;
            justify-content: space-between;
            margin: 2rem 0 0 0;
            position: relative;
        }
        .wizard-steps::before {
            content: '';
            position: absolute;
            top: 20px;
            left: 15%;
            right: 15%;
            height: 2px;
            background: rgba(255, 255, 255, 0.3);
            z-index: 0;
        }
        .wizard-step {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 0.5rem;
            position: relative;
            z-index: 1;
        }
        .step-number {
            width: 45px;
            height: 45px;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.2);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 1.25rem;
            transition: all 0.3s ease;
        }
        .wizard-step.active .step-number {
            background: white;
            color: #667eea;
            box-shadow: 0 0 0 4px rgba(255, 255, 255, 0.3);
            transform: scale(1.1);
        }
        .step-label {
            font-size: 0.875rem;
            color: rgba(255, 255, 255, 0.8);
            font-weight: 600;
        }
        .wizard-step.active .step-label {
            color: white;
        }
        .wizard-body {
            padding: 2.5rem;
            min-height: 450px;
        }
        .wizard-content {
            display: none;
        }
        .wizard-content.active {
            display: block;
            animation: fadeIn 0.3s ease-in;
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .level-card {
            background: #f8f9fa;
            border-radius: 0.75rem;
            padding: 1.5rem;
            margin-bottom: 1.5rem;
            border: 2px solid #e9ecef;
            transition: all 0.3s ease;
        }
        .level-card:hover {
            border-color: #667eea;
            box-shadow: 0 0.25rem 0.5rem rgba(102, 126, 234, 0.1);
        }
        .level-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1rem;
        }
        .level-header h5 {
            color: #667eea;
            margin: 0;
            font-weight: 700;
        }
        .icon-picker, .color-picker {
            display: flex;
            gap: 0.75rem;
            flex-wrap: wrap;
        }
        .icon-picker input[type="radio"],
        .color-picker input[type="radio"] {
            display: none;
        }
        .icon-picker label {
            width: 50px;
            height: 50px;
            border: 2px solid #dee2e6;
            border-radius: 0.5rem;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all 0.2s;
            font-size: 1.5rem;
        }
        .icon-picker input:checked + label {
            border-color: #667eea;
            background: #667eea;
            color: white;
            transform: scale(1.1);
        }
        .color-picker label {
            width: 45px;
            height: 45px;
            border-radius: 50%;
            cursor: pointer;
            border: 3px solid white;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
            transition: all 0.2s;
        }
        .color-picker input:checked + label {
            box-shadow: 0 0 0 3px #667eea;
            transform: scale(1.15);
        }
        .review-section {
            background: #f8f9fa;
            padding: 1.5rem;
            border-radius: 0.75rem;
            margin-bottom: 1.5rem;
        }
        .review-item {
            display: flex;
            justify-content: space-between;
            padding: 0.75rem 0;
            border-bottom: 1px solid #dee2e6;
        }
        .review-item:last-child {
            border-bottom: none;
        }
        .review-level-item {
            background: white;
            padding: 1rem;
            border-radius: 0.5rem;
            margin-bottom: 0.75rem;
            display: flex;
            align-items: center;
            gap: 1rem;
        }
        .review-level-number {
            width: 40px;
            height: 40px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
        }
    </style>

    <div class="container wizard-container py-5">
        
        <!-- Back Button -->
        <div class="mb-4">
            <a href="<%= ResolveUrl("~/Pages/teacher_browse_classes.aspx") %>" class="btn btn-outline-secondary">
                <i class="bi bi-arrow-left me-2"></i>Back to My Classes
            </a>
        </div>

        <!-- Wizard Card -->
        <div class="card wizard-card">
            <div class="wizard-header">
                <h2 class="mb-0 fw-bold">
                    <i class="bi bi-plus-circle me-2"></i>Create New Class
                </h2>
                <p class="mb-0 mt-2 opacity-75">Follow the steps to create your class with learning levels</p>
                
                <!-- Wizard Steps -->
                <div class="wizard-steps">
                    <div class="wizard-step active" data-step="1">
                        <div class="step-number">1</div>
                        <div class="step-label">Class Info</div>
                    </div>
                    <div class="wizard-step" data-step="2">
                        <div class="step-number">2</div>
                        <div class="step-label">Add Levels</div>
                    </div>
                    <div class="wizard-step" data-step="3">
                        <div class="step-number">3</div>
                        <div class="step-label">Review</div>
                    </div>
                </div>
            </div>
            
            <div class="wizard-body">

                <asp:Label ID="lblError" runat="server" CssClass="alert alert-danger mb-4" Visible="false" />

                <!-- STEP 1: Class Information -->
                <div id="step1" class="wizard-content active">
                    <h4 class="mb-4">Class Information</h4>
                    
                    <div class="mb-3">
                        <label for="txtClassName" class="form-label fw-bold">
                            Class Name <span class="text-danger">*</span>
                        </label>
                        <asp:TextBox ID="txtClassName" runat="server" CssClass="form-control form-control-lg" 
                                     placeholder="e.g., Introduction to Programming" MaxLength="200" />
                    </div>

                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label for="txtClassCode" class="form-label fw-bold">
                                Class Code <span class="text-danger">*</span>
                            </label>
                            <div class="input-group">
                                <asp:TextBox ID="txtClassCode" runat="server" CssClass="form-control" 
                                             placeholder="e.g., CS101" MaxLength="50" />
                                <button type="button" class="btn btn-outline-secondary" onclick="generateClassCode()">
                                    <i class="bi bi-shuffle"></i> Generate
                                </button>
                            </div>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-bold">Icon</label>
                            <div class="icon-picker">
                                <input type="radio" name="classIcon" value="code-square" id="icon1" checked>
                                <label for="icon1"><i class="bi bi-code-square"></i></label>

                                <input type="radio" name="classIcon" value="book" id="icon2">
                                <label for="icon2"><i class="bi bi-book"></i></label>

                                <input type="radio" name="classIcon" value="cpu" id="icon3">
                                <label for="icon3"><i class="bi bi-cpu"></i></label>

                                <input type="radio" name="classIcon" value="lightbulb" id="icon4">
                                <label for="icon4"><i class="bi bi-lightbulb"></i></label>
                            </div>
                            <asp:HiddenField ID="hfSelectedIcon" runat="server" Value="code-square" />
                        </div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-bold">Color</label>
                        <div class="color-picker">
                            <input type="radio" name="classColor" value="#667eea" id="color1" checked>
                            <label for="color1" style="background: #667eea;"></label>

                            <input type="radio" name="classColor" value="#0984e3" id="color2">
                            <label for="color2" style="background: #0984e3;"></label>

                            <input type="radio" name="classColor" value="#00b894" id="color3">
                            <label for="color3" style="background: #00b894;"></label>

                            <input type="radio" name="classColor" value="#e17055" id="color4">
                            <label for="color4" style="background: #e17055;"></label>
                        </div>
                        <asp:HiddenField ID="hfSelectedColor" runat="server" Value="#667eea" />
                    </div>

                    <div class="mb-3">
                        <label for="txtDescription" class="form-label fw-bold">Description (Optional)</label>
                        <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" Rows="3"
                                     CssClass="form-control" 
                                     placeholder="What will students learn in this class?" MaxLength="500" />
                    </div>
                </div>

                <!-- STEP 2: Add Levels -->
                <div id="step2" class="wizard-content" style="display: none;">
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <div>
                            <h4 class="mb-1">Add Learning Levels</h4>
                            <p class="text-muted mb-0">Create at least 3 levels for your class</p>
                        </div>
                        <span class="badge bg-info fs-6">Minimum 3 Required</span>
                    </div>

                    <div id="levelsContainer">
                        <!-- Initial 3 levels will be here -->
                    </div>

                    <div class="text-center mt-4">
                        <button type="button" class="btn btn-lg btn-outline-primary" onclick="addNewLevel()">
                            <i class="bi bi-plus-circle me-2"></i>Add Another Level
                        </button>
                        <p class="text-muted small mt-2 mb-0">You can add as many levels as you need</p>
                    </div>

                    <asp:HiddenField ID="hfLevelsData" runat="server" />
                </div>

                <!-- STEP 3: Review -->
                <div id="step3" class="wizard-content" style="display: none;">
                    <div class="text-center mb-4">
                        <i class="bi bi-clipboard-check text-success" style="font-size: 3rem;"></i>
                        <h4 class="mt-3 mb-1">Review Your Class</h4>
                        <p class="text-muted">Check everything before creating</p>
                    </div>
                    
                    <div class="review-section">
                        <div class="d-flex align-items-center mb-3">
                            <i class="bi bi-info-circle text-primary me-2 fs-5"></i>
                            <h5 class="mb-0">Class Information</h5>
                        </div>
                        <div class="review-item">
                            <span class="text-muted">Class Name:</span>
                            <strong id="reviewClassName"></strong>
                        </div>
                        <div class="review-item">
                            <span class="text-muted">Class Code:</span>
                            <strong id="reviewClassCode" class="badge bg-secondary fs-6"></strong>
                        </div>
                    </div>

                    <div class="review-section">
                        <div class="d-flex align-items-center justify-content-between mb-3">
                            <div class="d-flex align-items-center">
                                <i class="bi bi-layers text-success me-2 fs-5"></i>
                                <h5 class="mb-0">Learning Levels</h5>
                            </div>
                            <span class="badge bg-success" id="reviewLevelCount">0 Levels</span>
                        </div>
                        <div id="reviewLevels">
                            <!-- Level review will be generated -->
                        </div>
                    </div>

                    <div class="alert alert-success border-0 shadow-sm">
                        <div class="d-flex align-items-center">
                            <i class="bi bi-check-circle-fill me-3 fs-3"></i>
                            <div>
                                <h5 class="mb-1">Everything looks good!</h5>
                                <p class="mb-0 small">Click "Create Class" below to save your class and levels.</p>
                            </div>
                        </div>
                    </div>
                </div>

            </div>

            <!-- Footer Buttons -->
            <div class="card-footer bg-white border-top p-4">
                <div class="d-flex justify-content-between align-items-center">
                    <button type="button" id="btnPrevStep" class="btn btn-lg btn-outline-secondary" onclick="previousStep()" style="display: none;">
                        <i class="bi bi-arrow-left me-2"></i>Previous
                    </button>
                    <div class="d-flex gap-2">
                        <a href="<%= ResolveUrl("~/Pages/teacher_browse_classes.aspx") %>" class="btn btn-lg btn-outline-secondary">
                            <i class="bi bi-x-lg me-2"></i>Cancel
                        </a>
                        <button type="button" id="btnNextStep" class="btn btn-lg btn-primary px-4" onclick="nextStep()">
                            Next Step <i class="bi bi-arrow-right ms-2"></i>
                        </button>
                        <asp:Button ID="btnCreateClass" runat="server" 
                                    Text="Create Class"
                                    CssClass="btn btn-lg btn-success px-5" style="display: none;"
                                    OnClick="btnCreateClass_Click" />
                    </div>
                </div>
            </div>
        </div>

    </div>

    <!-- Expose IDs for JavaScript -->
    <script type="text/javascript">
        window.CLASS_DATA = {
            txtClassNameId: '<%= txtClassName.ClientID %>',
            txtClassCodeId: '<%= txtClassCode.ClientID %>',
            hfSelectedIconId: '<%= hfSelectedIcon.ClientID %>',
            hfSelectedColorId: '<%= hfSelectedColor.ClientID %>',
            hfLevelsDataId: '<%= hfLevelsData.ClientID %>'
        };
    </script>

    <!-- JavaScript -->
    <script src="<%= ResolveUrl("~/Scripts/teacher-create-class.js") %>"></script>
</asp:Content>


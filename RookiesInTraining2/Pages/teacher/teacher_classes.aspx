<%@ Page Title="My Classes - Teacher"
    Language="C#"
    MasterPageFile="~/MasterPages/MyMain.Master"
    AutoEventWireup="true"
    CodeBehind="teacher_classes.aspx.cs"
    Inherits="RookiesInTraining2.Pages.teacher_classes" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <!-- CSS -->
    <link rel="stylesheet" href="<%= ResolveUrl("~/Content/teacher-classes.css") %>" />

    <div class="teacher-classes-container">
        
        <!-- Header Section -->
        <div class="page-header">
            <div class="container-fluid py-4">
                <div class="row align-items-center">
                    <div class="col-lg-8">
                        <h1 class="mb-2">
                            <i class="bi bi-collection me-2"></i>My Classes
                        </h1>
                        <p class="text-muted mb-0">Create and manage your learning modules</p>
                    </div>
                    <div class="col-lg-4 text-lg-end mt-3 mt-lg-0">
                        <button id="btnCreateClass" class="btn btn-primary btn-lg px-4" type="button">
                            <i class="bi bi-plus-circle me-2"></i>Create New Class
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Classes Grid -->
        <div class="container-fluid py-4">
            <div class="row g-4" id="classesGrid">
                <!-- Class cards will be rendered here -->
            </div>

            <!-- Empty State -->
            <div id="emptyState" class="text-center py-5" style="display: none;">
                <i class="bi bi-collection display-1 text-muted mb-3"></i>
                <h3>No Classes Yet</h3>
                <p class="text-muted">Create your first class to start teaching!</p>
                <button class="btn btn-primary btn-lg mt-3" onclick="document.getElementById('btnCreateClass').click()">
                    <i class="bi bi-plus-circle me-2"></i>Create Your First Class
                </button>
            </div>
        </div>

        <!-- Create/Edit Class Modal - Multi-Step Wizard -->
        <div id="classModal" class="custom-modal" style="display: none;">
            <div class="modal-overlay"></div>
            <div class="modal-content modal-wizard">
                <div class="modal-header">
                    <div class="wizard-header">
                        <h3 id="modalTitle">Create New Class</h3>
                        <div class="wizard-steps">
                            <div class="wizard-step active" data-step="1">
                                <div class="step-number">1</div>
                                <div class="step-label">Class Info</div>
                            </div>
                            <div class="wizard-step" data-step="2">
                                <div class="step-number">2</div>
                                <div class="step-label">Add 5 Levels</div>
                            </div>
                            <div class="wizard-step" data-step="3">
                                <div class="step-number">3</div>
                                <div class="step-label">Review</div>
                            </div>
                        </div>
                    </div>
                    <button type="button" class="btn-close" onclick="closeClassModal()">
                        <i class="bi bi-x-lg"></i>
                    </button>
                </div>
                <div class="modal-body">
                    
                    <!-- STEP 1: Class Information -->
                    <div id="step1" class="wizard-content active">
                        <asp:Label ID="lblModalError" runat="server" CssClass="alert alert-danger" Visible="false" />
                    
                    <div class="mb-3">
                        <label for="txtClassName" class="form-label fw-bold">
                            Class Name <span class="text-danger">*</span>
                        </label>
                        <asp:TextBox ID="txtClassName" runat="server" CssClass="form-control form-control-lg" 
                                     placeholder="e.g., Introduction to C# Programming" MaxLength="200" />
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtClassName"
                            ValidationGroup="CreateClass" CssClass="text-danger small d-block mt-1"
                            ErrorMessage="Class name is required" Display="Dynamic" />
                    </div>

                    <div class="mb-3">
                        <label for="txtClassCode" class="form-label fw-bold">
                            Class Code <span class="text-danger">*</span>
                        </label>
                        <div class="input-group input-group-lg">
                            <asp:TextBox ID="txtClassCode" runat="server" CssClass="form-control" 
                                         placeholder="e.g., CS101-2025" MaxLength="50" />
                            <button class="btn btn-outline-secondary" type="button" onclick="generateClassCode()">
                                <i class="bi bi-shuffle me-1"></i>Generate
                            </button>
                        </div>
                        <small class="text-muted">Students will use this code to join your class</small>
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtClassCode"
                            ValidationGroup="CreateClass" CssClass="text-danger small d-block mt-1"
                            ErrorMessage="Class code is required" Display="Dynamic" />
                    </div>

                    <div class="mb-3">
                        <label for="txtDescription" class="form-label fw-bold">Description (Optional)</label>
                        <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" Rows="3"
                                     CssClass="form-control" placeholder="Brief description of this class..." MaxLength="500" />
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-bold">Class Icon</label>
                        <div class="icon-picker">
                            <input type="radio" name="classIcon" value="bi-book" id="icon1" checked />
                            <label for="icon1"><i class="bi bi-book"></i></label>
                            
                            <input type="radio" name="classIcon" value="bi-code-square" id="icon2" />
                            <label for="icon2"><i class="bi bi-code-square"></i></label>
                            
                            <input type="radio" name="classIcon" value="bi-laptop" id="icon3" />
                            <label for="icon3"><i class="bi bi-laptop"></i></label>
                            
                            <input type="radio" name="classIcon" value="bi-database" id="icon4" />
                            <label for="icon4"><i class="bi bi-database"></i></label>
                            
                            <input type="radio" name="classIcon" value="bi-globe" id="icon5" />
                            <label for="icon5"><i class="bi bi-globe"></i></label>
                            
                            <input type="radio" name="classIcon" value="bi-lightning" id="icon6" />
                            <label for="icon6"><i class="bi bi-lightning"></i></label>
                        </div>
                        <asp:HiddenField ID="hfSelectedIcon" runat="server" Value="bi-book" />
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-bold">Class Color</label>
                        <div class="color-picker">
                            <input type="radio" name="classColor" value="#6c5ce7" id="color1" checked />
                            <label for="color1" style="background: #6c5ce7;"></label>
                            
                            <input type="radio" name="classColor" value="#00b894" id="color2" />
                            <label for="color2" style="background: #00b894;"></label>
                            
                            <input type="radio" name="classColor" value="#fdcb6e" id="color3" />
                            <label for="color3" style="background: #fdcb6e;"></label>
                            
                            <input type="radio" name="classColor" value="#0984e3" id="color4" />
                            <label for="color4" style="background: #0984e3;"></label>
                            
                            <input type="radio" name="classColor" value="#d63031" id="color5" />
                            <label for="color5" style="background: #d63031;"></label>
                            
                            <input type="radio" name="classColor" value="#e17055" id="color6" />
                            <label for="color6" style="background: #e17055;"></label>
                        </div>
                        <asp:HiddenField ID="hfSelectedColor" runat="server" Value="#6c5ce7" />
                    </div>
                    </div>

                    <!-- STEP 2: Add Levels (Minimum 3) -->
                    <div id="step2" class="wizard-content" style="display: none;">
                        <h4 class="mb-3">Add Learning Levels <span class="badge bg-info">Minimum 3</span></h4>
                        <p class="text-muted mb-4">Each level should include learning material and will have a quiz. Click "Add Level" to add more.</p>

                        <div id="levelsContainer">
                            <!-- Level 1 -->
                            <div class="level-input-group mb-4" data-level="1">
                                <div class="level-header">
                                    <h5><i class="bi bi-1-circle me-2"></i>Level 1</h5>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label fw-bold">Level Title <span class="text-danger">*</span></label>
                                    <asp:TextBox ID="txtLevel1Title" runat="server" CssClass="form-control" 
                                                 placeholder="e.g., Introduction to Variables" MaxLength="200" />
                                </div>
                                <div class="mb-3">
                                    <label class="form-label fw-bold">Learning Material</label>
                                    <div class="material-input-group">
                                        <div class="btn-group w-100 mb-2" role="group">
                                            <input type="radio" class="btn-check" name="level1Type" id="level1Upload" value="upload" checked>
                                            <label class="btn btn-outline-primary" for="level1Upload">
                                                <i class="bi bi-upload me-1"></i>Upload File
                                            </label>
                                            <input type="radio" class="btn-check" name="level1Type" id="level1Manual" value="manual">
                                            <label class="btn btn-outline-primary" for="level1Manual">
                                                <i class="bi bi-pencil me-1"></i>Write Content
                                            </label>
                                        </div>
                                        <asp:FileUpload ID="fileLevel1" runat="server" CssClass="form-control file-upload-1" 
                                                        accept=".pdf,.pptx,.ppt,.mp4" />
                                        <asp:TextBox ID="txtLevel1Content" runat="server" TextMode="MultiLine" Rows="4"
                                                     CssClass="form-control manual-content-1" style="display:none;"
                                                     placeholder="Enter learning content here..." />
                                    </div>
                                </div>
                            </div>

                            <!-- Level 2 -->
                            <div class="level-input-group mb-4" data-level="2">
                                <div class="level-header">
                                    <h5><i class="bi bi-2-circle me-2"></i>Level 2</h5>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label fw-bold">Level Title <span class="text-danger">*</span></label>
                                    <asp:TextBox ID="txtLevel2Title" runat="server" CssClass="form-control" 
                                                 placeholder="e.g., Data Types" MaxLength="200" />
                                </div>
                                <div class="mb-3">
                                    <label class="form-label fw-bold">Learning Material</label>
                                    <div class="material-input-group">
                                        <div class="btn-group w-100 mb-2" role="group">
                                            <input type="radio" class="btn-check" name="level2Type" id="level2Upload" value="upload" checked>
                                            <label class="btn btn-outline-primary" for="level2Upload">
                                                <i class="bi bi-upload me-1"></i>Upload File
                                            </label>
                                            <input type="radio" class="btn-check" name="level2Type" id="level2Manual" value="manual">
                                            <label class="btn btn-outline-primary" for="level2Manual">
                                                <i class="bi bi-pencil me-1"></i>Write Content
                                            </label>
                                        </div>
                                        <asp:FileUpload ID="fileLevel2" runat="server" CssClass="form-control file-upload-2" 
                                                        accept=".pdf,.pptx,.ppt,.mp4" />
                                        <asp:TextBox ID="txtLevel2Content" runat="server" TextMode="MultiLine" Rows="4"
                                                     CssClass="form-control manual-content-2" style="display:none;"
                                                     placeholder="Enter learning content here..." />
                                    </div>
                                </div>
                            </div>

                            <!-- Level 3 -->
                            <div class="level-input-group mb-4" data-level="3">
                                <div class="level-header">
                                    <h5><i class="bi bi-3-circle me-2"></i>Level 3</h5>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label fw-bold">Level Title <span class="text-danger">*</span></label>
                                    <asp:TextBox ID="txtLevel3Title" runat="server" CssClass="form-control" 
                                                 placeholder="e.g., Operators" MaxLength="200" />
                                </div>
                                <div class="mb-3">
                                    <label class="form-label fw-bold">Learning Material</label>
                                    <div class="material-input-group">
                                        <div class="btn-group w-100 mb-2" role="group">
                                            <input type="radio" class="btn-check" name="level3Type" id="level3Upload" value="upload" checked>
                                            <label class="btn btn-outline-primary" for="level3Upload">
                                                <i class="bi bi-upload me-1"></i>Upload File
                                            </label>
                                            <input type="radio" class="btn-check" name="level3Type" id="level3Manual" value="manual">
                                            <label class="btn btn-outline-primary" for="level3Manual">
                                                <i class="bi bi-pencil me-1"></i>Write Content
                                            </label>
                                        </div>
                                        <asp:FileUpload ID="fileLevel3" runat="server" CssClass="form-control file-upload-3" 
                                                        accept=".pdf,.pptx,.ppt,.mp4" />
                                        <asp:TextBox ID="txtLevel3Content" runat="server" TextMode="MultiLine" Rows="4"
                                                     CssClass="form-control manual-content-3" style="display:none;"
                                                     placeholder="Enter learning content here..." />
                                    </div>
                                </div>
                            </div>

                        </div>

                        <!-- Add Level Button -->
                        <div class="text-center mt-3 mb-4">
                            <button type="button" class="btn btn-outline-primary" onclick="addNewLevel()">
                                <i class="bi bi-plus-circle me-2"></i>Add Another Level
                            </button>
                            <small class="d-block mt-2 text-muted">You can add as many levels as you need!</small>
                        </div>

                        <!-- Hidden field to store level data as JSON -->
                        <asp:HiddenField ID="hfLevelsData" runat="server" />
                    </div>

                    <!-- STEP 3: Review -->
                    <div id="step3" class="wizard-content" style="display: none;">
                        <h4 class="mb-3">Review Your Class</h4>
                        
                        <div class="review-section mb-4">
                            <h5 class="text-muted mb-3">Class Information</h5>
                            <div class="review-item">
                                <strong>Class Name:</strong>
                                <span id="reviewClassName"></span>
                            </div>
                            <div class="review-item">
                                <strong>Class Code:</strong>
                                <span id="reviewClassCode"></span>
                            </div>
                        </div>

                        <div class="review-section">
                            <h5 class="text-muted mb-3">Levels Overview</h5>
                            <div id="reviewLevels" class="review-levels">
                                <!-- Level review will be generated -->
                            </div>
                        </div>

                        <div class="alert alert-success mt-4">
                            <i class="bi bi-check-circle me-2"></i>
                            <strong>Ready to create!</strong> Click "Create Class with 5 Levels" to save everything.
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" id="btnPrevStep" class="btn btn-secondary" onclick="previousStep()" style="display: none;">
                        <i class="bi bi-arrow-left me-2"></i>Previous
                    </button>
                    <button type="button" class="btn btn-secondary" onclick="closeClassModal()">
                        Cancel
                    </button>
                    <button type="button" id="btnNextStep" class="btn btn-primary btn-lg" onclick="nextStep()">
                        Next <i class="bi bi-arrow-right ms-2"></i>
                    </button>
                    <asp:Button ID="btnSaveClass" runat="server" Text="Create Class with Levels" 
                                CssClass="btn btn-success btn-lg" style="display: none;"
                                OnClick="btnSaveClass_Click" />
                </div>
            </div>
        </div>

        <!-- Hidden Fields -->
        <asp:HiddenField ID="hfClassesJson" runat="server" />
        <asp:HiddenField ID="hfEditingClassSlug" runat="server" />
    </div>

    <!-- Expose data for JavaScript -->
    <script type="text/javascript">
        window.TEACHER_DATA = {
            teacherSlug: '<%= Session["UserSlug"] %>',
            teacherName: '<%= Session["FullName"] %>',
            classesFieldId: '<%= hfClassesJson.ClientID %>',
            hfSelectedIconId: '<%= hfSelectedIcon.ClientID %>',
            hfSelectedColorId: '<%= hfSelectedColor.ClientID %>',
            txtClassNameId: '<%= txtClassName.ClientID %>',
            txtClassCodeId: '<%= txtClassCode.ClientID %>',
            txtLevel1TitleId: '<%= txtLevel1Title.ClientID %>',
            txtLevel2TitleId: '<%= txtLevel2Title.ClientID %>',
            txtLevel3TitleId: '<%= txtLevel3Title.ClientID %>'
        };
    </script>

    <!-- JavaScript -->
    <script src="<%= ResolveUrl("~/Scripts/teacher-classes.js") %>"></script>
</asp:Content>



<%@ Page Title="Create Module - Teacher"
    Language="C#"
    MasterPageFile="~/MasterPages/MyMain.Master"
    AutoEventWireup="true"
    CodeBehind="teacher_create_module.aspx.cs"
    Inherits="RookiesInTraining2.Pages.teacher_create_module" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    
    <style>
        .wizard-container { max-width: 1000px; margin: 0 auto; padding: 2rem 0; }
        .wizard-card { border: none; box-shadow: 0 0.5rem 2rem rgba(0,0,0,0.1); border-radius: 1rem; overflow: hidden; }
        .wizard-header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 2rem; }
        .wizard-nav { display: flex; justify-content: space-between; margin-top: 1.5rem; position: relative; }
        .wizard-nav::before { content: ''; position: absolute; top: 20px; left: 10%; right: 10%; height: 2px; background: rgba(255,255,255,0.3); }
        .wizard-step { position: relative; z-index: 1; display: flex; flex-direction: column; align-items: center; gap: 0.5rem; }
        .wizard-step .step-num { width: 40px; height: 40px; border-radius: 50%; background: rgba(255,255,255,0.2); display: flex; align-items: center; justify-content: center; font-weight: 700; transition: all 0.3s; }
        .wizard-step.active .step-num { background: white; color: #667eea; box-shadow: 0 0 0 4px rgba(255,255,255,0.3); transform: scale(1.1); }
        .wizard-step .step-label { font-size: 0.875rem; color: rgba(255,255,255,0.8); font-weight: 600; }
        .wizard-step.active .step-label { color: white; }
        .wizard-body { padding: 2.5rem; min-height: 500px; }
        .step-content { display: none; }
        .step-content.active { display: block; animation: fadeIn 0.3s; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
        .level-card { background: #f8f9fa; border: 2px solid #e9ecef; border-radius: 0.75rem; padding: 1.5rem; margin-bottom: 1rem; position: relative; }
        .level-card:hover { border-color: #667eea; box-shadow: 0 4px 12px rgba(102,126,234,0.1); }
        .level-badge { position: absolute; top: 1rem; right: 1rem; }
        .icon-picker, .color-picker { display: flex; gap: 0.75rem; flex-wrap: wrap; }
        .icon-picker input, .color-picker input { display: none; }
        .icon-picker label { width: 50px; height: 50px; border: 2px solid #dee2e6; border-radius: 0.5rem; display: flex; align-items: center; justify-content: center; cursor: pointer; font-size: 1.5rem; transition: all 0.2s; }
        .icon-picker input:checked + label { border-color: #667eea; background: #667eea; color: white; transform: scale(1.1); }
        .color-picker label { width: 45px; height: 45px; border-radius: 50%; cursor: pointer; border: 3px solid white; box-shadow: 0 2px 8px rgba(0,0,0,0.15); transition: all 0.2s; }
        .color-picker input:checked + label { box-shadow: 0 0 0 3px #667eea; transform: scale(1.15); }
        .review-box { background: #f8f9fa; border-radius: 0.75rem; padding: 1.5rem; margin-bottom: 1.5rem; }
        .review-item { padding: 0.75rem 0; border-bottom: 1px solid #dee2e6; display: flex; justify-content: space-between; }
        .review-item:last-child { border-bottom: none; }
        .level-list-item { background: white; padding: 1rem; border-radius: 0.5rem; margin-bottom: 0.75rem; display: flex; align-items: center; gap: 1rem; }
        .level-num-badge { width: 36px; height: 36px; background: linear-gradient(135deg, #667eea, #764ba2); color: white; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 700; }
    </style>

    <div class="wizard-container">
        <div class="mb-4">
            <a href="<%= ResolveUrl("~/Pages/teacher/teacher_browse_classes.aspx") %>" class="btn btn-outline-secondary">
                <i class="bi bi-arrow-left me-2"></i>Back to Classes
            </a>
        </div>

        <div class="card wizard-card">
            <div class="wizard-header">
                <h2 class="mb-0 fw-bold"><i class="bi bi-plus-circle me-2"></i>Create New Class</h2>
                <p class="mb-0 mt-2 opacity-75">Build a complete learning class with info and levels</p>
                <div class="wizard-nav">
                    <div class="wizard-step active" data-step="1">
                        <div class="step-num">1</div>
                        <div class="step-label">Class Info</div>
                    </div>
                    <div class="wizard-step" data-step="2">
                        <div class="step-num">2</div>
                        <div class="step-label">Review</div>
                    </div>
                </div>
            </div>

            <div class="wizard-body">
                <asp:Label ID="lblError" runat="server" CssClass="alert alert-danger" Visible="false" />

                <!-- STEP 1: Class Info -->
                <div id="step1" class="step-content active">
                    <h4 class="mb-4">Class Information</h4>
                    
                    <div class="mb-3">
                        <label class="form-label fw-bold">Class Name <span class="text-danger">*</span></label>
                        <asp:TextBox ID="txtClassName" runat="server" CssClass="form-control form-control-lg" 
                                     placeholder="e.g., Introduction to Python" MaxLength="200" />
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-bold">Description</label>
                        <asp:TextBox ID="txtClassDescription" runat="server" TextMode="MultiLine" Rows="3"
                                     CssClass="form-control" placeholder="What will students learn?" MaxLength="500" />
                    </div>

                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-bold">Class Code <span class="text-danger">*</span></label>
                            <div class="input-group">
                                <asp:TextBox ID="txtClassCode" runat="server" CssClass="form-control" ReadOnly="true" />
                                <button type="button" class="btn btn-outline-secondary" onclick="regenerateClassCode()">
                                    <i class="bi bi-arrow-clockwise"></i>
                                </button>
                            </div>
                            <small class="text-muted">Students use this code to join</small>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-bold">Icon</label>
                            <div class="icon-picker">
                                <input type="radio" name="icon" value="book" id="i1" checked>
                                <label for="i1"><i class="bi bi-book"></i></label>
                                <input type="radio" name="icon" value="code-square" id="i2">
                                <label for="i2"><i class="bi bi-code-square"></i></label>
                                <input type="radio" name="icon" value="cpu" id="i3">
                                <label for="i3"><i class="bi bi-cpu"></i></label>
                                <input type="radio" name="icon" value="lightbulb" id="i4">
                                <label for="i4"><i class="bi bi-lightbulb"></i></label>
                            </div>
                            <asp:HiddenField ID="hfIcon" runat="server" Value="book" />
                        </div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-bold">Color</label>
                        <div class="color-picker">
                            <input type="radio" name="color" value="#667eea" id="c1" checked>
                            <label for="c1" style="background: #667eea;"></label>
                            <input type="radio" name="color" value="#0984e3" id="c2">
                            <label for="c2" style="background: #0984e3;"></label>
                            <input type="radio" name="color" value="#00b894" id="c3">
                            <label for="c3" style="background: #00b894;"></label>
                            <input type="radio" name="color" value="#e17055" id="c4">
                            <label for="c4" style="background: #e17055;"></label>
                        </div>
                        <asp:HiddenField ID="hfColor" runat="server" Value="#667eea" />
                    </div>
                </div>

                <!-- STEP 2: Review -->
                <div id="step2" class="step-content">
                    <div class="text-center mb-4">
                        <i class="bi bi-clipboard-check text-success" style="font-size: 3rem;"></i>
                        <h4 class="mt-3 mb-1">Review Your Class</h4>
                        <p class="text-muted">Check everything before creating</p>
                    </div>

                    <div class="review-box">
                        <h5 class="mb-3"><i class="bi bi-info-circle text-primary me-2"></i>Class Information</h5>
                        <div class="review-item"><span>Class Name:</span><strong id="reviewClassName"></strong></div>
                        <div class="review-item"><span>Class Code:</span><span class="badge bg-secondary" id="reviewClassCode"></span></div>
                        <div class="review-item"><span>Description:</span><span id="reviewDescription" class="text-muted"></span></div>
                        <div class="review-item"><span>Icon:</span><span id="reviewIcon">📚</span></div>
                        <div class="review-item"><span>Color:</span><span id="reviewColor" style="display: inline-block; width: 40px; height: 20px; border-radius: 4px;"></span></div>
                    </div>

                    <div class="alert alert-info border-info">
                        <div class="d-flex align-items-start">
                            <i class="bi bi-info-circle-fill me-3 fs-4"></i>
                            <div>
                                <h6 class="mb-1">About Levels & Story Mode</h6>
                                <p class="mb-0">After creating this class, you can add learning levels in the <strong>Story Mode</strong> tab. Each level will have custom slides and a quiz.</p>
                            </div>
                        </div>
                    </div>

                    <div class="alert alert-success border-0">
                        <div class="d-flex align-items-center">
                            <i class="bi bi-check-circle-fill me-3 fs-3"></i>
                            <div>
                                <h5 class="mb-1">Ready to Create!</h5>
                                <p class="mb-0">Your class will be created. You can add levels in Story Mode after creation.</p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Hidden field for draft JSON -->
                <asp:HiddenField ID="hfDraftJson" runat="server" />
            </div>

            <!-- Footer -->
            <div class="card-footer bg-white border-top p-4">
                <div class="d-flex justify-content-between">
                    <button type="button" id="btnBack" class="btn btn-lg btn-outline-secondary" onclick="goBack()" style="display: none;">
                        <i class="bi bi-arrow-left me-2"></i>Previous
                    </button>
                    <div class="ms-auto d-flex gap-2">
                        <a href="<%= ResolveUrl("~/Pages/teacher/teacher_browse_classes.aspx") %>" class="btn btn-lg btn-outline-secondary">
                            <i class="bi bi-x-lg me-2"></i>Cancel
                        </a>
                        <button type="button" id="btnNext" class="btn btn-lg btn-primary px-4" onclick="goNext()">
                            Next Step <i class="bi bi-arrow-right ms-2"></i>
                        </button>
                        <asp:Button ID="btnCreateModule" runat="server" Text="Create Class" 
                                    CssClass="btn btn-lg btn-success px-5" style="display: none;"
                                    OnClick="btnCreateModule_Click" />
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        window.WIZARD_IDS = {
            txtClassName: '<%= txtClassName.ClientID %>',
            txtClassDescription: '<%= txtClassDescription.ClientID %>',
            txtClassCode: '<%= txtClassCode.ClientID %>',
            hfIcon: '<%= hfIcon.ClientID %>',
            hfColor: '<%= hfColor.ClientID %>',
            hfDraftJson: '<%= hfDraftJson.ClientID %>',
            btnCreateModule: '<%= btnCreateModule.ClientID %>'
        };
    </script>
    <script src="<%= ResolveUrl("~/Scripts/create-module-wizard.js") %>"></script>

</asp:Content>



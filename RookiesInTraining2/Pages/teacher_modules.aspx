<%@ Page Title="My Modules" Language="C#" MasterPageFile="~/MasterPages/dashboard.Master" AutoEventWireup="true" CodeBehind="teacher_modules.aspx.cs" Inherits="RookiesInTraining2.Pages.teacher_modules" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <link rel="stylesheet" href="<%= ResolveUrl("~/Content/teacher-modules.css") %>" />

    <div class="container-fluid py-4">
        <!-- Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="mb-1">📚 My Modules</h2>
                <p class="text-muted">Create and manage learning modules with quizzes</p>
            </div>
            <button type="button" class="btn btn-primary btn-lg" onclick="openNewModuleModal()">
                <i class="bi bi-plus-circle me-2"></i>New Module
            </button>
        </div>

        <!-- Stats Cards -->
        <div class="row g-3 mb-4">
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="stat-icon bg-primary">
                        <i class="bi bi-collection"></i>
                    </div>
                    <div class="stat-info">
                        <div class="stat-value" id="totalModules">0</div>
                        <div class="stat-label">Total Modules</div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="stat-icon bg-success">
                        <i class="bi bi-check-circle"></i>
                    </div>
                    <div class="stat-info">
                        <div class="stat-value" id="publishedModules">0</div>
                        <div class="stat-label">Published</div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="stat-icon bg-warning">
                        <i class="bi bi-file-earmark-text"></i>
                    </div>
                    <div class="stat-info">
                        <div class="stat-value" id="draftModules">0</div>
                        <div class="stat-label">Drafts</div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="stat-icon bg-info">
                        <i class="bi bi-question-circle"></i>
                    </div>
                    <div class="stat-info">
                        <div class="stat-value" id="totalQuizzes">0</div>
                        <div class="stat-label">Total Quizzes</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Modules Grid -->
        <div id="modulesGrid" class="row g-4">
            <!-- Modules will be inserted here by JavaScript -->
        </div>

        <!-- Empty State -->
        <div id="emptyState" class="text-center py-5" style="display: none;">
            <i class="bi bi-collection text-muted" style="font-size: 4rem;"></i>
            <h4 class="mt-3">No Modules Yet</h4>
            <p class="text-muted">Create your first module to get started!</p>
            <button type="button" class="btn btn-primary" onclick="openNewModuleModal()">
                <i class="bi bi-plus-circle me-2"></i>Create First Module
            </button>
        </div>

        <!-- New Module Modal -->
        <div id="newModuleModal" class="custom-modal" style="display: none;">
            <div class="modal-overlay" onclick="closeNewModuleModal()"></div>
            <div class="modal-content">
                <div class="modal-header">
                    <h3>Create New Module</h3>
                    <button type="button" class="btn-close" onclick="closeNewModuleModal()">
                        <i class="bi bi-x-lg"></i>
                    </button>
                </div>
                <form id="form1" runat="server">
                    <div class="modal-body">
                        <asp:Label ID="lblError" runat="server" CssClass="alert alert-danger" Visible="false" />

                        <div class="mb-3">
                            <label for="txtTitle" class="form-label fw-bold">
                                Module Title <span class="text-danger">*</span>
                            </label>
                            <asp:TextBox ID="txtTitle" runat="server" CssClass="form-control form-control-lg" 
                                         placeholder="e.g., Introduction to JavaScript" MaxLength="200" />
                            <asp:RequiredFieldValidator ID="rfvTitle" runat="server" ControlToValidate="txtTitle"
                                ErrorMessage="Title is required" CssClass="text-danger" Display="Dynamic" 
                                ValidationGroup="CreateModule" />
                        </div>

                        <div class="mb-3">
                            <label for="txtSummary" class="form-label fw-bold">Short Summary</label>
                            <asp:TextBox ID="txtSummary" runat="server" TextMode="MultiLine" Rows="3"
                                         CssClass="form-control" 
                                         placeholder="Brief description of what students will learn..." MaxLength="500" />
                        </div>

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-bold">Icon</label>
                                <div class="icon-picker">
                                    <input type="radio" name="moduleIcon" value="book" id="icon1" checked>
                                    <label for="icon1"><i class="bi bi-book"></i></label>

                                    <input type="radio" name="moduleIcon" value="code-square" id="icon2">
                                    <label for="icon2"><i class="bi bi-code-square"></i></label>

                                    <input type="radio" name="moduleIcon" value="cpu" id="icon3">
                                    <label for="icon3"><i class="bi bi-cpu"></i></label>

                                    <input type="radio" name="moduleIcon" value="lightbulb" id="icon4">
                                    <label for="icon4"><i class="bi bi-lightbulb"></i></label>

                                    <input type="radio" name="moduleIcon" value="rocket-takeoff" id="icon5">
                                    <label for="icon5"><i class="bi bi-rocket-takeoff"></i></label>

                                    <input type="radio" name="moduleIcon" value="star" id="icon6">
                                    <label for="icon6"><i class="bi bi-star"></i></label>
                                </div>
                                <asp:HiddenField ID="hfSelectedIcon" runat="server" Value="book" />
                            </div>

                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-bold">Accent Color</label>
                                <div class="color-picker">
                                    <input type="radio" name="moduleColor" value="#667eea" id="color1" checked>
                                    <label for="color1" style="background: #667eea;"></label>

                                    <input type="radio" name="moduleColor" value="#0984e3" id="color2">
                                    <label for="color2" style="background: #0984e3;"></label>

                                    <input type="radio" name="moduleColor" value="#00b894" id="color3">
                                    <label for="color3" style="background: #00b894;"></label>

                                    <input type="radio" name="moduleColor" value="#fdcb6e" id="color4">
                                    <label for="color4" style="background: #fdcb6e;"></label>

                                    <input type="radio" name="moduleColor" value="#e17055" id="color5">
                                    <label for="color5" style="background: #e17055;"></label>

                                    <input type="radio" name="moduleColor" value="#6c5ce7" id="color6">
                                    <label for="color6" style="background: #6c5ce7;"></label>
                                </div>
                                <asp:HiddenField ID="hfSelectedColor" runat="server" Value="#667eea" />
                            </div>
                        </div>

                        <div class="mb-3">
                            <label for="txtOrder" class="form-label fw-bold">Display Order</label>
                            <asp:TextBox ID="txtOrder" runat="server" TextMode="Number" CssClass="form-control" 
                                         Text="1" />
                            <small class="text-muted">Lower numbers appear first</small>
                        </div>
                    </div>

                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" onclick="closeNewModuleModal()">
                            Cancel
                        </button>
                        <asp:Button ID="btnSaveDraft" runat="server" Text="Save Draft" 
                                    CssClass="btn btn-outline-primary" ValidationGroup="CreateModule"
                                    OnClick="btnSaveDraft_Click" />
                        <asp:Button ID="btnCreateAndAddQuizzes" runat="server" Text="Create & Add Quizzes" 
                                    CssClass="btn btn-primary" ValidationGroup="CreateModule"
                                    OnClick="btnCreateAndAddQuizzes_Click" />
                    </div>
                </form>
            </div>
        </div>

        <!-- Hidden Fields -->
        <asp:HiddenField ID="hfModulesJson" runat="server" />
    </div>

    <!-- JavaScript -->
    <script src="<%= ResolveUrl("~/Scripts/teacher-modules.js") %>"></script>
</asp:Content>


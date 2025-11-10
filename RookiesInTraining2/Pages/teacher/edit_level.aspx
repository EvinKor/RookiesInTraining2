<%@ Page Title="Edit Level - Teacher"
    Language="C#"
    MasterPageFile="~/MasterPages/MyMain.Master"
    AutoEventWireup="true"
    CodeBehind="edit_level.aspx.cs"
    Inherits="RookiesInTraining2.Pages.teacher.edit_level" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    
    <div class="container mt-4">
        <!-- Header -->
        <div class="card border-0 shadow-sm mb-4" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);">
            <div class="card-body text-white p-4">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h2 class="mb-2"><i class="bi bi-pencil me-2"></i>Edit Learning Level</h2>
                        <p class="mb-0 opacity-90">Modify level details for <strong id="className"></strong></p>
                    </div>
                    <asp:HyperLink ID="lnkBack" runat="server" CssClass="btn btn-light btn-lg">
                        <i class="bi bi-arrow-left me-2"></i>Back to Story Mode
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
                        <div class="form-control form-control-lg text-center bg-light" style="font-size: 1.5rem; font-weight: 700;">
                            <asp:Label ID="lblLevelNumber" runat="server" />
                        </div>
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
                                     CssClass="form-control" TextMode="Number" />
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-bold">XP Reward</label>
                        <asp:TextBox ID="txtXP" runat="server" 
                                     CssClass="form-control" TextMode="Number" />
                    </div>
                </div>
                
                <div class="mb-4">
                    <div class="form-check form-switch">
                        <label class="form-check-label fw-bold">Published</label>
                    </div>
                </div>
                
                <div class="mb-4">
                    <label class="form-label fw-bold">Upload New Learning Material (Optional)</label>
                    <asp:FileUpload ID="fileUpload" runat="server" 
                                    CssClass="form-control form-control-lg" 
                                    accept=".pdf,.pptx,.ppt" />
                    <small class="text-muted">
                        Current file: <asp:Label ID="lblCurrentFile" runat="server" CssClass="text-info" />
                    </small>
                </div>

                <!-- Hidden Fields -->
                <asp:HiddenField ID="hfLevelSlug" runat="server" />
                <asp:HiddenField ID="hfClassSlug" runat="server" />

            </div>
            
            <!-- Footer -->
            <div class="card-footer bg-light p-4">
                <div class="d-flex justify-content-between align-items-center">
                    <asp:HyperLink ID="lnkCancel" runat="server" CssClass="btn btn-outline-secondary btn-lg">
                        <i class="bi bi-x-circle me-2"></i>Cancel
                    </asp:HyperLink>
                    <asp:Button ID="btnSaveLevel" runat="server" 
                                Text="Save Changes" 
                                CssClass="btn btn-primary btn-lg px-5"
                                OnClick="btnSaveLevel_Click" />
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


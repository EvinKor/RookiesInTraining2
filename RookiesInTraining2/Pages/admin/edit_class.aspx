<%@ Page Title="Edit Class - Admin"
    Language="C#"
    MasterPageFile="~/MasterPages/dashboard.Master"
    AutoEventWireup="true"
    CodeBehind="edit_class.aspx.cs"
    Inherits="RookiesInTraining2.Pages.admin.edit_class" %>

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
        .icon-picker, .color-picker {
            display: flex;
            gap: 0.75rem;
            flex-wrap: wrap;
        }
        .icon-picker input, .color-picker input {
            display: none;
        }
        .icon-picker label {
            width: 50px;
            height: 50px;
            border: 2px solid #e8ecf1;
            border-radius: 0.5rem;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            font-size: 1.5rem;
            transition: all 0.2s;
            background: white;
            color: #6c757d;
        }
        .icon-picker label:hover {
            border-color: #0d6efd;
            background: #f0f4ff;
        }
        .icon-picker input:checked + label {
            border-color: #0d6efd;
            background: #0d6efd;
            color: white;
            transform: scale(1.1);
        }
        .color-picker label {
            width: 45px;
            height: 45px;
            border-radius: 50%;
            cursor: pointer;
            border: 3px solid white;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            transition: all 0.2s;
        }
        .color-picker input:checked + label {
            box-shadow: 0 0 0 3px #0d6efd;
            transform: scale(1.15);
        }
    </style>
    
    <div class="container mt-4">
        <!-- Header -->
        <div class="card border-0 shadow-sm mb-4">
            <div class="card-body p-4">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h2 class="mb-2"><i class="bi bi-pencil-square me-2 text-primary"></i>Edit Class</h2>
                        <p class="mb-0 text-muted">Update class information and settings</p>
                    </div>
                    <asp:HyperLink ID="lnkBack" runat="server" CssClass="btn btn-outline-secondary btn-lg">
                        <i class="bi bi-arrow-left me-2"></i>Back to Classes
                    </asp:HyperLink>
                </div>
            </div>
        </div>

        <!-- Error Message -->
        <asp:Label ID="lblError" runat="server" CssClass="alert alert-danger" Visible="false" />

        <!-- Form -->
        <div class="card border-0 shadow-sm">
            <div class="card-body p-4">
                
                <h4 class="mb-4"><i class="bi bi-info-circle me-2 text-primary"></i>Class Information</h4>
                
                <div class="mb-4">
                    <label class="form-label fw-bold">Class Name <span class="text-danger">*</span></label>
                    <asp:TextBox ID="txtClassName" runat="server" 
                                 CssClass="form-control form-control-lg" 
                                 placeholder="e.g., Introduction to Python" 
                                 MaxLength="200" />
                    <asp:RequiredFieldValidator ID="rfvClassName" runat="server" 
                                               ControlToValidate="txtClassName"
                                               ErrorMessage="Class name is required"
                                               CssClass="text-danger small"
                                               Display="Dynamic" />
                </div>

                <div class="mb-4">
                    <label class="form-label fw-bold">Description</label>
                    <asp:TextBox ID="txtDescription" runat="server" 
                                 TextMode="MultiLine" Rows="3"
                                 CssClass="form-control" 
                                 placeholder="What will students learn?" 
                                 MaxLength="500" />
                </div>

                <div class="mb-4">
                    <label class="form-label fw-bold">Assign Teacher <span class="text-danger">*</span></label>
                    <asp:DropDownList ID="ddlTeacher" runat="server" CssClass="form-select form-select-lg">
                    </asp:DropDownList>
                    <asp:RequiredFieldValidator ID="rfvTeacher" runat="server" 
                                               ControlToValidate="ddlTeacher" 
                                               InitialValue=""
                                               CssClass="text-danger small d-block mt-1" 
                                               ErrorMessage="Please select a teacher for this class." 
                                               Display="Dynamic" />
                    <small class="text-muted d-block mt-1">Select the teacher who will manage this class</small>
                </div>

                <div class="row mb-4">
                    <div class="col-md-6">
                        <label class="form-label fw-bold">Class Code</label>
                        <div class="input-group">
                            <asp:TextBox ID="txtClassCode" runat="server" 
                                         CssClass="form-control" />
                            <button type="button" class="btn btn-outline-secondary" onclick="regenerateClassCode(); return false;">
                                <i class="bi bi-arrow-clockwise"></i>
                            </button>
                        </div>
                        <small class="text-muted">Students use this code to join. You can regenerate it if needed.</small>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-bold">Icon</label>
                        <div class="icon-picker">
                            <input type="radio" name="icon" value="book" id="i1">
                            <label for="i1"><i class="bi bi-book"></i></label>
                            <input type="radio" name="icon" value="code-square" id="i2">
                            <label for="i2"><i class="bi bi-code-square"></i></label>
                            <input type="radio" name="icon" value="cpu" id="i3">
                            <label for="i3"><i class="bi bi-cpu"></i></label>
                            <input type="radio" name="icon" value="lightbulb" id="i4">
                            <label for="i4"><i class="bi bi-lightbulb"></i></label>
                            <input type="radio" name="icon" value="collection" id="i5">
                            <label for="i5"><i class="bi bi-collection"></i></label>
                            <input type="radio" name="icon" value="laptop" id="i6">
                            <label for="i6"><i class="bi bi-laptop"></i></label>
                        </div>
                        <asp:HiddenField ID="hfIcon" runat="server" />
                    </div>
                </div>

                <div class="mb-4">
                    <label class="form-label fw-bold">Color</label>
                    <div class="color-picker">
                        <input type="radio" name="color" value="#667eea" id="c1">
                        <label for="c1" style="background: #667eea;"></label>
                        <input type="radio" name="color" value="#0984e3" id="c2">
                        <label for="c2" style="background: #0984e3;"></label>
                        <input type="radio" name="color" value="#00b894" id="c3">
                        <label for="c3" style="background: #00b894;"></label>
                        <input type="radio" name="color" value="#e17055" id="c4">
                        <label for="c4" style="background: #e17055;"></label>
                        <input type="radio" name="color" value="#fdcb6e" id="c5">
                        <label for="c5" style="background: #fdcb6e;"></label>
                        <input type="radio" name="color" value="#6c5ce7" id="c6">
                        <label for="c6" style="background: #6c5ce7;"></label>
                        <input type="radio" name="color" value="#fd79a8" id="c7">
                        <label for="c7" style="background: #fd79a8;"></label>
                        <input type="radio" name="color" value="#55efc4" id="c8">
                        <label for="c8" style="background: #55efc4;"></label>
                    </div>
                    <asp:HiddenField ID="hfColor" runat="server" />
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
                    <asp:Button ID="btnUpdateClass" runat="server" 
                                Text="Update Class" 
                                CssClass="btn btn-primary btn-lg px-5"
                                OnClick="btnUpdateClass_Click" />
                </div>
            </div>
        </div>
    </div>

    <script>
        // Initialize on page load
        document.addEventListener('DOMContentLoaded', function() {
            // Set icon from hidden field
            const iconValue = document.getElementById('<%= hfIcon.ClientID %>').value;
            if (iconValue) {
                const iconRadio = document.querySelector(`input[name="icon"][value="${iconValue}"]`);
                if (iconRadio) {
                    iconRadio.checked = true;
                }
            }

            // Set color from hidden field
            const colorValue = document.getElementById('<%= hfColor.ClientID %>').value;
            if (colorValue) {
                const colorRadio = document.querySelector(`input[name="color"][value="${colorValue}"]`);
                if (colorRadio) {
                    colorRadio.checked = true;
                }
            }

            // Icon picker event listeners
            document.querySelectorAll('input[name="icon"]').forEach(radio => {
                radio.addEventListener('change', function() {
                    document.getElementById('<%= hfIcon.ClientID %>').value = this.value;
                });
            });

            // Color picker event listeners
            document.querySelectorAll('input[name="color"]').forEach(radio => {
                radio.addEventListener('change', function() {
                    document.getElementById('<%= hfColor.ClientID %>').value = this.value;
                });
            });
        });

        // Regenerate class code
        function regenerateClassCode() {
            const newCode = generateRandomCode(6);
            document.getElementById('<%= txtClassCode.ClientID %>').value = newCode;
        }

        function generateRandomCode(length) {
            const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
            let result = '';
            for (let i = 0; i < length; i++) {
                result += chars.charAt(Math.floor(Math.random() * chars.length));
            }
            return result;
        }
    </script>

</asp:Content>


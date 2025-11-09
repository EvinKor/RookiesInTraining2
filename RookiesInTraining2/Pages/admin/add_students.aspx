<%@ Page Title="Add Students - Admin"
    Language="C#"
    MasterPageFile="~/MasterPages/dashboard.Master"
    AutoEventWireup="true"
    CodeBehind="add_students.aspx.cs"
    Inherits="RookiesInTraining2.Pages.admin.add_students"
    EnableViewState="true" %>

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
        .card-header.bg-success {
            background-color: #28a745 !important;
            color: white !important;
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
        .bg-success {
            background-color: #28a745 !important;
        }
        .hover-item {
            transition: all 0.2s ease;
        }
        .hover-item:hover {
            background: #f8f9fa !important;
            border-color: #28a745 !important;
        }
    </style>
    
    <div class="container mt-4">
        <!-- Header -->
        <div class="card border-0 shadow-sm mb-4">
            <div class="card-body p-4">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h2 class="mb-2"><i class="bi bi-person-plus-fill me-2 text-primary"></i>Add Students to Class</h2>
                        <p class="mb-0 text-muted">
                            <strong><asp:Label ID="lblClassName" runat="server" /></strong>
                            <span class="ms-3"><i class="bi bi-code me-1"></i>Code: <asp:Label ID="lblClassCode" runat="server" /></span>
                        </p>
                    </div>
                    <asp:HyperLink ID="lnkBack" runat="server" CssClass="btn btn-outline-secondary btn-lg">
                        <i class="bi bi-arrow-left me-2"></i>Back to Class
                    </asp:HyperLink>
                </div>
            </div>
        </div>

        <!-- Search Section -->
        <div class="card border-0 shadow-sm mb-4">
            <div class="card-body p-4">
                <div class="row g-3">
                    <div class="col-md-8">
                        <label class="form-label fw-bold">Search Students</label>
                        <asp:TextBox ID="txtSearch" runat="server" 
                                     CssClass="form-control form-control-lg"
                                     placeholder="Search by name or email..." />
                    </div>
                    <div class="col-md-4 d-flex align-items-end">
                        <asp:Button ID="btnSearch" runat="server" 
                                    Text="Search" 
                                    CssClass="btn btn-primary btn-lg w-100"
                                    OnClick="btnSearch_Click" />
                    </div>
                </div>
            </div>
        </div>

        <!-- Results Section -->
        <div class="row">
            <!-- Available Students -->
            <div class="col-lg-6">
                <div class="card border-0 shadow-sm">
                    <div class="card-header bg-light border-0 py-3">
                        <h5 class="mb-0">
                            <i class="bi bi-people me-2"></i>Available Students
                            (<asp:Label ID="lblAvailableCount" runat="server" Text="0" />)
                        </h5>
                    </div>
                    <div class="card-body p-3" style="max-height: 600px; overflow-y: auto;">
                        <asp:Repeater ID="rptAvailableStudents" runat="server" OnItemCommand="rptAvailableStudents_ItemCommand">
                            <ItemTemplate>
                                <div class="d-flex align-items-center justify-content-between p-3 mb-2 border rounded hover-item">
                                    <div class="d-flex align-items-center">
                                        <div class="rounded-circle bg-primary bg-opacity-10 text-primary d-flex align-items-center justify-content-center me-3"
                                             style="width: 40px; height: 40px;">
                                            <i class="bi bi-person-fill"></i>
                                        </div>
                                        <div>
                                            <h6 class="mb-0"><%# Eval("FullName") %></h6>
                                            <small class="text-muted"><%# Eval("Email") %></small>
                                        </div>
                                    </div>
                                    <asp:LinkButton ID="btnAdd" runat="server" 
                                                   CssClass="btn btn-sm btn-success"
                                                   CommandName="Add"
                                                   CommandArgument='<%# Eval("UserSlug") %>'>
                                        <i class="bi bi-plus-circle me-1"></i>Add
                                    </asp:LinkButton>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                        
                        <asp:Label ID="lblNoAvailable" runat="server" 
                                   CssClass="text-muted text-center d-block py-5"
                                   Visible="false">
                            <i class="bi bi-search display-4 d-block mb-3 opacity-25"></i>
                            <p>No students found. Try searching or all students are already enrolled.</p>
                        </asp:Label>
                    </div>
                </div>
            </div>

            <!-- Enrolled Students -->
            <div class="col-lg-6">
                <div class="card border-0 shadow-sm">
                    <div class="card-header bg-success text-white py-3">
                        <h5 class="mb-0">
                            <i class="bi bi-people-fill me-2"></i>Enrolled Students
                            (<asp:Label ID="lblEnrolledCount" runat="server" Text="0" />)
                        </h5>
                    </div>
                    <div class="card-body p-3" style="max-height: 600px; overflow-y: auto;">
                        <asp:Repeater ID="rptEnrolledStudents" runat="server" OnItemCommand="rptEnrolledStudents_ItemCommand">
                            <ItemTemplate>
                                <div class="d-flex align-items-center justify-content-between p-3 mb-2 border rounded bg-light">
                                    <div class="d-flex align-items-center">
                                        <div class="rounded-circle bg-success bg-opacity-20 text-success d-flex align-items-center justify-content-center me-3"
                                             style="width: 40px; height: 40px;">
                                            <i class="bi bi-person-check-fill"></i>
                                        </div>
                                        <div>
                                            <h6 class="mb-0"><%# Eval("FullName") %></h6>
                                            <small class="text-muted">
                                                <%# Eval("Email") %>
                                                <i class="bi bi-clock ms-2 me-1"></i>
                                                Joined: <%# Convert.ToDateTime(Eval("EnrolledAt")).ToString("MMM dd, yyyy") %>
                                            </small>
                                        </div>
                                    </div>
                                    <asp:LinkButton ID="btnRemove" runat="server" 
                                                   CssClass="btn btn-sm btn-outline-danger"
                                                   CommandName="Remove"
                                                   CommandArgument='<%# Eval("UserSlug") %>'
                                                   OnClientClick="return confirm('Remove this student from the class?');">
                                        <i class="bi bi-x-circle me-1"></i>Remove
                                    </asp:LinkButton>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                        
                        <asp:Label ID="lblNoEnrolled" runat="server" 
                                   CssClass="text-muted text-center d-block py-5"
                                   Visible="false">
                            <i class="bi bi-people display-4 d-block mb-3 opacity-25"></i>
                            <p>No students enrolled yet. Add students from the left panel.</p>
                        </asp:Label>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script type="text/javascript">
        console.log('[AddStudents] Page loaded');
        
        // Log when page is fully ready
        document.addEventListener('DOMContentLoaded', function() {
            console.log('[AddStudents] DOM Content Loaded');
            
            // Find all Add buttons
            const addButtons = document.querySelectorAll('[id*="btnAdd"]');
            console.log('[AddStudents] Found Add buttons:', addButtons.length);
            
            // Add click listeners to track clicks
            addButtons.forEach((btn, index) => {
                console.log(`[AddStudents] Button ${index}:`, btn);
                btn.addEventListener('click', function(e) {
                    console.log('[AddStudents] ===== ADD BUTTON CLICKED =====');
                    console.log('[AddStudents] Button:', this);
                    console.log('[AddStudents] Event:', e);
                    console.log('[AddStudents] Button ID:', this.id);
                    console.log('[AddStudents] Form will postback...');
                });
            });
            
            // Find all Remove buttons
            const removeButtons = document.querySelectorAll('[id*="btnRemove"]');
            console.log('[AddStudents] Found Remove buttons:', removeButtons.length);
            
            removeButtons.forEach((btn, index) => {
                btn.addEventListener('click', function(e) {
                    console.log('[AddStudents] ===== REMOVE BUTTON CLICKED =====');
                    console.log('[AddStudents] Button:', this);
                });
            });
            
            // Check for form
            const form = document.querySelector('form[id*="form"]');
            if (form) {
                console.log('[AddStudents] Form found:', form.id);
                form.addEventListener('submit', function(e) {
                    console.log('[AddStudents] ===== FORM SUBMITTING =====');
                    console.log('[AddStudents] Form action:', this.action);
                    console.log('[AddStudents] Form method:', this.method);
                });
            } else {
                console.error('[AddStudents] ❌ NO FORM FOUND! This is the problem!');
            }
            
            // Log ViewState
            const viewState = document.querySelector('input[name="__VIEWSTATE"]');
            if (viewState) {
                console.log('[AddStudents] ViewState exists, length:', viewState.value.length);
            } else {
                console.error('[AddStudents] ❌ NO VIEWSTATE FOUND!');
            }
            
            // Log EventValidation
            const eventValidation = document.querySelector('input[name="__EVENTVALIDATION"]');
            if (eventValidation) {
                console.log('[AddStudents] EventValidation exists');
            } else {
                console.error('[AddStudents] ❌ NO EVENTVALIDATION FOUND!');
            }
        });
        
        // Log before page unload (postback)
        window.addEventListener('beforeunload', function() {
            console.log('[AddStudents] Page is unloading (postback happening)');
        });
        
        // Check for errors
        window.addEventListener('error', function(e) {
            console.error('[AddStudents] ❌ JavaScript Error:', e.message);
            console.error('[AddStudents] Error details:', e);
        });
    </script>

</asp:Content>


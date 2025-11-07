<%@ Page Title="Add Students - Teacher"
    Language="C#"
    MasterPageFile="~/MasterPages/MyMain.Master"
    AutoEventWireup="true"
    CodeBehind="add_students.aspx.cs"
    Inherits="RookiesInTraining2.Pages.teacher.add_students" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    
    <div class="container mt-4">
        <!-- Header -->
        <div class="card border-0 shadow-sm mb-4" style="background: linear-gradient(135deg, #28a745 0%, #1e7e34 100%);">
            <div class="card-body text-white p-4">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h2 class="mb-2"><i class="bi bi-person-plus-fill me-2"></i>Add Students to Class</h2>
                        <p class="mb-0 opacity-90">
                            <strong><asp:Label ID="lblClassName" runat="server" /></strong>
                            <span class="ms-3"><i class="bi bi-code me-1"></i>Code: <asp:Label ID="lblClassCode" runat="server" /></span>
                        </p>
                    </div>
                    <asp:HyperLink ID="lnkBack" runat="server" CssClass="btn btn-light btn-lg">
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

    <style>
        .hover-item {
            transition: all 0.2s ease;
        }
        .hover-item:hover {
            background: #f8f9fa;
            border-color: #28a745 !important;
        }
    </style>

</asp:Content>


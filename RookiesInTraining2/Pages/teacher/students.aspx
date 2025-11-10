<%@ Page Title="Student List - Teacher"
    Language="C#"
    MasterPageFile="~/MasterPages/MyMain.Master"
    AutoEventWireup="true"
    CodeBehind="students.aspx.cs"
    Inherits="RookiesInTraining2.Pages.teacher.students" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    
    <div class="container mt-4">
        <!-- Header -->
        <div class="card border-0 shadow-sm mb-4" style="background: linear-gradient(135deg, #28a745 0%, #1e7e34 100%);">
            <div class="card-body text-white p-4">
                <div>
                    <h2 class="mb-2"><i class="bi bi-people-fill me-2"></i>Student List</h2>
                    <p class="mb-0 opacity-90">View all students enrolled in your classes</p>
                </div>
            </div>
        </div>

        <!-- Filters and Search -->
        <div class="card border-0 shadow-sm mb-4">
            <div class="card-body">
                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label fw-bold">Search</label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="bi bi-search"></i></span>
                            <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" 
                                         placeholder="Search by name or email..." 
                                         AutoPostBack="true" OnTextChanged="txtSearch_TextChanged" />
                        </div>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-bold">Filter by Class</label>
                        <asp:DropDownList ID="ddlClassFilter" runat="server" CssClass="form-select" 
                                          AutoPostBack="true" OnSelectedIndexChanged="ddlClassFilter_SelectedIndexChanged">
                            <asp:ListItem Value="" Text="All Classes" />
                        </asp:DropDownList>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label fw-bold">&nbsp;</label>
                        <div class="form-control text-muted">
                            <asp:Label ID="lblStudentCount" runat="server" Text="0 students" />
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Error Message -->
        <asp:Label ID="lblError" runat="server" CssClass="alert alert-danger" Visible="false" />

        <!-- Students Table -->
        <div class="card border-0 shadow-sm">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead class="table-light">
                            <tr>
                                <th class="ps-4">Student</th>
                                <th>Email</th>
                                <th>Classes</th>
                                <th>Joined</th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="rptStudents" runat="server">
                                <ItemTemplate>
                                    <tr>
                                        <td class="ps-4">
                                            <div class="d-flex align-items-center">
                                                <div class="rounded-circle bg-success text-white d-flex align-items-center justify-content-center me-2" 
                                                     style="width: 40px; height: 40px; font-weight: 600;">
                                                    <%# Eval("DisplayName").ToString().Substring(0, 1).ToUpper() %>
                                                </div>
                                                <div>
                                                    <div class="fw-semibold"><%# Eval("DisplayName") %></div>
                                                    <small class="text-muted"><%# Eval("FullName") %></small>
                                                </div>
                                            </div>
                                        </td>
                                        <td><%# Eval("Email") %></td>
                                        <td>
                                            <span class="badge bg-primary"><%# Eval("ClassCount") %> class<%# Convert.ToInt32(Eval("ClassCount")) != 1 ? "es" : "" %></span>
                                        </td>
                                        <td>
                                            <small class="text-muted"><%# Eval("FirstJoined") %></small>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                </div>
                
                <!-- Empty State -->
                <asp:Label ID="lblNoStudents" runat="server" 
                          CssClass="text-muted text-center d-block py-5" 
                          Text="No students found." 
                          Visible="false" />
            </div>
        </div>
    </div>

</asp:Content>


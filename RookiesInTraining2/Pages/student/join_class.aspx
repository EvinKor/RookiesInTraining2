<%@ Page Title="Join Class - Student"
    Language="C#"
    MasterPageFile="~/MasterPages/MyMain.Master"
    AutoEventWireup="true"
    CodeBehind="join_class.aspx.cs"
    Inherits="RookiesInTraining2.Pages.student.join_class" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    
    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-6">
                <!-- Header -->
                <div class="card border-0 shadow-sm mb-4" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);">
                    <div class="card-body text-white p-4 text-center">
                        <i class="bi bi-door-open display-3 mb-3"></i>
                        <h2 class="mb-2">Join a Class</h2>
                        <p class="mb-0 opacity-90">Enter the class code provided by your teacher</p>
                    </div>
                </div>

                <!-- Join Form -->
                <div class="card border-0 shadow-sm">
                    <div class="card-body p-4">
                        <asp:Label ID="lblMessage" runat="server" CssClass="alert" Visible="false" />
                        
                        <div class="mb-4">
                            <label class="form-label fw-bold fs-5">Class Code</label>
                            <asp:TextBox ID="txtClassCode" runat="server" 
                                         CssClass="form-control form-control-lg text-center text-uppercase"
                                         placeholder="Enter 6-digit code"
                                         MaxLength="6"
                                         style="font-size: 2rem; letter-spacing: 0.5rem; font-weight: 700;" />
                            <small class="text-muted">Ask your teacher for the class code</small>
                        </div>

                        <div class="d-grid gap-2">
                            <asp:Button ID="btnJoinClass" runat="server" 
                                        Text="Join Class" 
                                        CssClass="btn btn-primary btn-lg"
                                        OnClick="btnJoinClass_Click" />
                            <asp:HyperLink ID="lnkCancel" runat="server" 
                                          NavigateUrl="~/Pages/student/dashboard_student.aspx"
                                          CssClass="btn btn-outline-secondary">
                                Cancel
                            </asp:HyperLink>
                        </div>
                    </div>
                </div>

                <!-- Info Section -->
                <div class="card border-0 bg-light mt-4">
                    <div class="card-body p-4">
                        <h6 class="mb-3"><i class="bi bi-info-circle me-2"></i>How to Join a Class</h6>
                        <ol class="small mb-0">
                            <li>Get the 6-digit class code from your teacher</li>
                            <li>Enter the code in the box above</li>
                            <li>Click "Join Class"</li>
                            <li>Start learning!</li>
                        </ol>
                    </div>
                </div>
            </div>
        </div>
    </div>

</asp:Content>


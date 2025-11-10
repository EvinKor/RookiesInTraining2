<%@ Page Title="Edit Quiz - Teacher"
    Language="C#"
    MasterPageFile="~/MasterPages/MyMain.Master"
    AutoEventWireup="true"
    CodeBehind="edit_quiz.aspx.cs"
    Inherits="RookiesInTraining2.Pages.teacher.edit_quiz" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    
    <div class="container mt-4">
        <!-- Header -->
        <div class="card border-0 shadow-sm mb-4" style="background: linear-gradient(135deg, #28a745 0%, #1e7e34 100%);">
            <div class="card-body text-white p-4">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h2 class="mb-2"><i class="bi bi-question-circle-fill me-2"></i>Edit Quiz</h2>
                        <p class="mb-0 opacity-90">
                            <strong><asp:Label ID="lblQuizTitle" runat="server" /></strong>
                        </p>
                    </div>
                    <asp:HyperLink ID="lnkBack" runat="server" CssClass="btn btn-light btn-lg">
                        <i class="bi bi-arrow-left me-2"></i>Back to Story Mode
                    </asp:HyperLink>
                </div>
            </div>
        </div>

        <!-- Quiz Settings -->
        <div class="card border-0 shadow-sm mb-4">
            <div class="card-header bg-light border-0 py-3">
                <h5 class="mb-0"><i class="bi bi-gear me-2"></i>Quiz Settings</h5>
            </div>
            <div class="card-body p-4">
                <asp:Label ID="lblError" runat="server" CssClass="alert alert-danger" Visible="false" />
                
                <div class="row g-3 mb-3">
                    <div class="col-md-6">
                        <label class="form-label fw-bold">Quiz Title <span class="text-danger">*</span></label>
                        <asp:TextBox ID="txtTitle" runat="server" 
                                     CssClass="form-control form-control-lg"
                                     MaxLength="200" />
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-bold">Quiz Mode</label>
                        <asp:DropDownList ID="ddlMode" runat="server" CssClass="form-select form-select-lg">
                            <asp:ListItem Value="story" Selected="True">Story Mode</asp:ListItem>
                            <asp:ListItem Value="battle">Battle Mode</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
                
                <div class="row g-3 mb-3">
                    <div class="col-md-6">
                        <label class="form-label fw-bold">Time Limit (minutes)</label>
                        <asp:TextBox ID="txtTimeLimit" runat="server" 
                                     CssClass="form-control" TextMode="Number" />
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-bold">Passing Score (%)</label>
                        <asp:TextBox ID="txtPassingScore" runat="server" 
                                     CssClass="form-control" TextMode="Number" />
                    </div>
                </div>
                
                <div class="form-check form-switch">
                    <label class="form-check-label fw-bold">Published</label>
                </div>
                
                <asp:HiddenField ID="hfQuizSlug" runat="server" />
                <asp:HiddenField ID="hfLevelSlug" runat="server" />
                <asp:HiddenField ID="hfClassSlug" runat="server" />
                
                <div class="mt-4">
                    <asp:Button ID="btnSaveSettings" runat="server" 
                                Text="Save Settings" 
                                CssClass="btn btn-success btn-lg" 
                                OnClick="btnSaveSettings_Click" />
                </div>
            </div>
        </div>

        <!-- Questions List -->
        <div class="card border-0 shadow-sm">
            <div class="card-header bg-light border-0 py-3">
                <div class="d-flex justify-content-between align-items-center">
                    <h5 class="mb-0"><i class="bi bi-list-check me-2"></i>Quiz Questions</h5>
                    <asp:HyperLink ID="lnkAddQuestions" runat="server" CssClass="btn btn-success">
                        <i class="bi bi-plus-circle me-2"></i>Add Questions
                    </asp:HyperLink>
                </div>
            </div>
            <div class="card-body p-4">
                <asp:Repeater ID="rptQuestions" runat="server">
                    <ItemTemplate>
                        <div class="card mb-3 border-start border-success border-4">
                            <div class="card-body">
                                <div class="d-flex align-items-start">
                                    <div class="flex-shrink-0 me-3">
                                        <span class="badge bg-success" style="font-size: 1rem; padding: 0.5rem 0.75rem;">
                                            Q<%# Eval("QuestionNumber") %>
                                        </span>
                                    </div>
                                    <div class="flex-grow-1">
                                        <p class="mb-2 fw-semibold"><%# Eval("QuestionText") %></p>
                                        <small class="text-muted">
                                            <i class="bi bi-bookmark me-1"></i>Type: <%# Eval("QuestionType") %>
                                            <i class="bi bi-star ms-3 me-1"></i>Points: <%# Eval("Points") %>
                                        </small>
                                    </div>
                                    <div class="btn-group-vertical btn-group-sm">
                                        <asp:HyperLink ID="lnkEdit" runat="server" 
                                                      CssClass="btn btn-outline-primary"
                                                      NavigateUrl='<%# $"~/Pages/teacher/edit_question.aspx?question={Eval("QuestionSlug")}&quiz={Request.QueryString["quiz"]}&class={Request.QueryString["class"]}" %>'>
                                            <i class="bi bi-pencil"></i> Edit
                                        </asp:HyperLink>
                                        <asp:LinkButton ID="btnDelete" runat="server" 
                                                       CssClass="btn btn-outline-danger"
                                                       CommandName="Delete"
                                                       CommandArgument='<%# Eval("QuestionSlug") %>'
                                                       OnCommand="DeleteQuestion_Command"
                                                       OnClientClick="return confirm('Delete this question?');">
                                            <i class="bi bi-trash"></i> Delete
                                        </asp:LinkButton>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
                
                <asp:Label ID="lblNoQuestions" runat="server" 
                           CssClass="text-muted text-center d-block py-5"
                           Visible="false">
                    <i class="bi bi-question-circle display-4 d-block mb-3 opacity-25"></i>
                    <h5 class="mb-2">No Questions Yet</h5>
                    <p class="mb-3">Add questions to make this quiz available to students</p>
                    <asp:HyperLink ID="lnkAddFirstQuestion" runat="server" CssClass="btn btn-success btn-lg">
                        <i class="bi bi-plus-circle me-2"></i>Add First Question
                    </asp:HyperLink>
                </asp:Label>
            </div>
        </div>
    </div>

</asp:Content>


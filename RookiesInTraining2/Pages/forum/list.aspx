<%@ Page Title="Forum"
    Language="C#"
    MasterPageFile="~/MasterPages/dashboard.Master"
    AutoEventWireup="true"
    CodeBehind="list.aspx.cs"
    Inherits="RookiesInTraining2.Pages.forum.list" %>

<asp:Content ID="Content1" ContentPlaceHolderID="DashboardContent" runat="server">
    <!-- Inline CSS Example (Assignment Requirement) -->
    <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 1rem; border-radius: 8px; margin-bottom: 2rem; color: white;">
        <h2 style="margin: 0;"><i class="bi bi-chat-dots me-2"></i>Community Forum</h2>
        <p style="margin: 0.5rem 0 0 0; opacity: 0.9;">Share questions, get help, and connect with other students!</p>
    </div>

    <div class="container py-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h3 class="text-light">Discussion Threads</h3>
            <a href="create.aspx" class="btn btn-primary">
                <i class="bi bi-plus-circle me-2"></i>New Thread
            </a>
        </div>

        <asp:Repeater ID="rptThreads" runat="server">
            <ItemTemplate>
                <div class="card mb-3" style="background: #111827; border-color: #1f2937;">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-start">
                            <div class="flex-grow-1">
                                <h5 class="text-light mb-2">
                                    <a href="thread.aspx?id=<%# Eval("ThreadSlug") %>" class="text-light text-decoration-none">
                                        <%# Eval("Title") %>
                                    </a>
                                </h5>
                                <p class="text-muted mb-2"><%# Eval("Content") %></p>
                                <div class="d-flex gap-3 text-muted small">
                                    <span><i class="bi bi-person"></i> <%# Eval("AuthorName") %></span>
                                    <span><i class="bi bi-clock"></i> <%# Eval("CreatedAt") %></span>
                                    <span><i class="bi bi-chat"></i> <%# Eval("PostCount") %> replies</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>

        <asp:Label ID="lblNoThreads" runat="server" Text="No threads yet. Be the first to post!" 
                   CssClass="text-muted text-center d-block py-5" Visible="false" />
    </div>
</asp:Content>


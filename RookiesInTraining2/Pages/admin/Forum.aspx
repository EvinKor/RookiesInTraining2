<%@ Page Title="Forum Moderation"
    Language="C#"
    MasterPageFile="~/MasterPages/dashboard.Master"
    AutoEventWireup="true"
    CodeBehind="Forum.aspx.cs"
    Inherits="RookiesInTraining2.Pages.ManageForum" %>

<asp:Content ID="Content1" ContentPlaceHolderID="DashboardContent" runat="server">
    
    <!-- Page Header -->
    <div class="row mb-4">
        <div class="col-12">
            <div class="d-flex align-items-center mb-3">
                <a href="dashboard_admin.aspx" class="btn btn-outline-secondary me-3">
                    <i class="bi bi-arrow-left me-2"></i>Back to Dashboard
                </a>
                <div class="flex-grow-1">
                    <h2 class="mb-1">Forum Moderation</h2>
                    <p class="text-muted mb-0">Manage forum posts and replies</p>
                </div>
            </div>
        </div>
    </div>

    <!-- Tabs -->
    <ul class="nav nav-tabs mb-4" id="forumTabs" role="tablist">
        <li class="nav-item" role="presentation">
            <button class="nav-link active" id="posts-tab" data-bs-toggle="tab" data-bs-target="#posts" type="button" role="tab">
                <i class="bi bi-chat-dots me-2"></i>Posts
            </button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link" id="replies-tab" data-bs-toggle="tab" data-bs-target="#replies" type="button" role="tab">
                <i class="bi bi-reply me-2"></i>Replies
            </button>
        </li>
    </ul>

    <!-- Tab Content -->
    <div class="tab-content" id="forumTabContent">
        <!-- Posts Tab -->
        <div class="tab-pane fade show active" id="posts" role="tabpanel">
            <div class="card border-0 shadow-sm">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th class="ps-4">Title</th>
                                    <th>Author</th>
                                    <th>Class</th>
                                    <th>Replies</th>
                                    <th>Created</th>
                                    <th class="text-end pe-4">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <asp:Repeater ID="rptPosts" runat="server" OnItemCommand="rptPosts_ItemCommand">
                                    <ItemTemplate>
                                        <tr>
                                            <td class="ps-4">
                                                <div class="fw-semibold"><%# Eval("Title") %></div>
                                                <small class="text-muted"><%# Eval("PostSlug") %></small>
                                            </td>
                                            <td><%# Eval("AuthorName") %></td>
                                            <td><%# Eval("ClassName") %></td>
                                            <td><span class="badge bg-info"><%# Eval("ReplyCount") %></span></td>
                                            <td><%# Eval("CreatedAt") %></td>
                                            <td class="text-end pe-4">
                                                <asp:LinkButton ID="btnDeletePost" runat="server" 
                                                                CommandName="DeletePost" 
                                                                CommandArgument='<%# Eval("PostSlug") %>'
                                                                CssClass="btn btn-sm btn-outline-danger"
                                                                OnClientClick="return confirm('Are you sure you want to delete this post? This will also delete all replies. This action cannot be undone.');"
                                                                title="Delete Post">
                                                    <i class="bi bi-trash"></i>
                                                </asp:LinkButton>
                                            </td>
                                        </tr>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </tbody>
                        </table>
                    </div>
                    <asp:Label ID="lblNoPosts" runat="server" CssClass="text-muted text-center d-block py-5"
                               Text="No posts found" Visible="false" />
                </div>
            </div>
        </div>

        <!-- Replies Tab -->
        <div class="tab-pane fade" id="replies" role="tabpanel">
            <div class="card border-0 shadow-sm">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th class="ps-4">Content</th>
                                    <th>Author</th>
                                    <th>Post</th>
                                    <th>Created</th>
                                    <th class="text-end pe-4">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <asp:Repeater ID="rptReplies" runat="server" OnItemCommand="rptReplies_ItemCommand">
                                    <ItemTemplate>
                                        <tr>
                                            <td class="ps-4">
                                                <div><%# Eval("Content").ToString().Length > 100 ? Eval("Content").ToString().Substring(0, 100) + "..." : Eval("Content") %></div>
                                                <small class="text-muted"><%# Eval("ReplySlug") %></small>
                                            </td>
                                            <td><%# Eval("AuthorName") %></td>
                                            <td><%# Eval("PostTitle") %></td>
                                            <td><%# Eval("CreatedAt") %></td>
                                            <td class="text-end pe-4">
                                                <asp:LinkButton ID="btnDeleteReply" runat="server" 
                                                                CommandName="DeleteReply" 
                                                                CommandArgument='<%# Eval("ReplySlug") %>'
                                                                CssClass="btn btn-sm btn-outline-danger"
                                                                OnClientClick="return confirm('Are you sure you want to delete this reply? This action cannot be undone.');"
                                                                title="Delete Reply">
                                                    <i class="bi bi-trash"></i>
                                                </asp:LinkButton>
                                            </td>
                                        </tr>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </tbody>
                        </table>
                    </div>
                    <asp:Label ID="lblNoReplies" runat="server" CssClass="text-muted text-center d-block py-5"
                               Text="No replies found" Visible="false" />
                </div>
            </div>
        </div>
    </div>

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
        .nav-tabs .nav-link {
            color: #6c757d;
            border: none;
            border-bottom: 2px solid transparent;
        }
        .nav-tabs .nav-link:hover {
            border-bottom-color: #dee2e6;
            color: #495057;
        }
        .nav-tabs .nav-link.active {
            color: #667eea;
            border-bottom-color: #667eea;
            background: transparent;
        }
    </style>

</asp:Content>


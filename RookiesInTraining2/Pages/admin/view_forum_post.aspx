<%@ Page Title="Forum Post - Admin"
    Language="C#"
    MasterPageFile="~/MasterPages/dashboard.Master"
    AutoEventWireup="true"
    CodeBehind="view_forum_post.aspx.cs"
    Inherits="RookiesInTraining2.Pages.admin.view_forum_post" %>

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
        .alert-primary {
            background-color: #e7f3ff;
            border-color: #b3d9ff;
            color: #004085;
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
        .border-primary {
            border-color: #0d6efd !important;
        }
        .text-primary {
            color: #0d6efd !important;
        }
        .bg-primary {
            background-color: #0d6efd !important;
        }
        .bg-primary.bg-opacity-10 {
            background-color: rgba(13, 110, 253, 0.1) !important;
        }
    </style>
    
    <div class="container mt-4">
        <!-- Header -->
        <div class="card border-0 shadow-sm mb-4">
            <div class="card-body p-4">
                <div class="d-flex justify-content-between align-items-center">
                    <div class="flex-grow-1">
                        <h2 class="mb-2"><i class="bi bi-chat-dots-fill me-2 text-primary"></i><asp:Label ID="lblPostTitle" runat="server" /></h2>
                        <p class="mb-0 text-muted">
                            <i class="bi bi-person me-1"></i><asp:Label ID="lblAuthor" runat="server" />
                            <i class="bi bi-clock ms-3 me-1"></i><asp:Label ID="lblDate" runat="server" />
                        </p>
                    </div>
                    <div class="d-flex gap-2">
                        <button type="button" class="btn btn-outline-primary btn-lg" data-bs-toggle="modal" data-bs-target="#editPostModal">
                            <i class="bi bi-pencil me-2"></i>Edit Post
                        </button>
                        <asp:Button ID="btnDeletePost" runat="server" Text="Delete Post" 
                                    CssClass="btn btn-outline-danger btn-lg"
                                    OnClick="btnDeletePost_Click"
                                    OnClientClick="return confirm('Are you sure you want to delete this post? This will also delete all replies. This action cannot be undone.');" />
                        <asp:HyperLink ID="lnkBack" runat="server" CssClass="btn btn-outline-secondary btn-lg">
                            <i class="bi bi-arrow-left me-2"></i>Back to Forum
                        </asp:HyperLink>
                    </div>
                </div>
            </div>
        </div>

        <!-- Original Post -->
        <div class="card border-0 shadow-sm mb-4">
            <div class="card-body p-4">
                <div class="alert alert-primary border-primary">
                    <h6 class="mb-2"><i class="bi bi-file-text me-2"></i>Original Post</h6>
                </div>
                <p id="postContentDisplay" style="white-space: pre-wrap; font-size: 1.1rem; line-height: 1.8;">
                    <asp:Label ID="lblContent" runat="server" />
                </p>
            </div>
        </div>

        <!-- Replies Section -->
        <div class="card border-0 shadow-sm mb-4">
            <div class="card-header bg-light border-0 py-3">
                <h5 class="mb-0">
                    <i class="bi bi-chat-left-text me-2"></i>Replies 
                    (<asp:Label ID="lblReplyCount" runat="server" Text="0" />)
                </h5>
            </div>
            <div class="card-body p-4">
                <asp:Repeater ID="rptReplies" runat="server" OnItemCommand="rptReplies_ItemCommand">
                    <ItemTemplate>
                        <div class="card mb-3 border-start border-primary border-4">
                            <div class="card-body">
                                <div class="d-flex align-items-start mb-2">
                                    <div class="flex-shrink-0 me-3">
                                        <div class="rounded-circle bg-primary bg-opacity-10 text-primary d-flex align-items-center justify-content-center"
                                             style="width: 40px; height: 40px;">
                                            <i class="bi bi-person-fill"></i>
                                        </div>
                                    </div>
                                    <div class="flex-grow-1">
                                        <h6 class="mb-1"><%# Eval("AuthorName") %></h6>
                                        <small class="text-muted"><%# FormatDate(Convert.ToDateTime(Eval("CreatedAt"))) %></small>
                                    </div>
                                    <div class="flex-shrink-0">
                                        <div class="btn-group" role="group">
                                            <button type="button" class="btn btn-sm btn-outline-primary edit-reply-btn" 
                                                    data-reply-slug="<%# Server.HtmlEncode(Eval("ReplySlug").ToString()) %>"
                                                    data-reply-content="<%# Server.HtmlEncode(Eval("Content").ToString()) %>"
                                                    title="Edit Reply">
                                                <i class="bi bi-pencil"></i>
                                            </button>
                                            <asp:LinkButton ID="btnDeleteReply" runat="server" 
                                                            CommandName="DeleteReply" 
                                                            CommandArgument='<%# Eval("ReplySlug") %>'
                                                            CssClass="btn btn-sm btn-outline-danger"
                                                            OnClientClick="return confirm('Are you sure you want to delete this reply? This action cannot be undone.');"
                                                            title="Delete Reply">
                                                <i class="bi bi-trash"></i>
                                            </asp:LinkButton>
                                        </div>
                                    </div>
                                </div>
                                <p class="mb-0 ms-5" style="white-space: pre-wrap;"><%# Eval("Content") %></p>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
                
                <asp:Label ID="lblNoReplies" runat="server" 
                           CssClass="text-muted text-center d-block py-4"
                           Text="No replies yet. Be the first to reply!"
                           Visible="false" />
            </div>
        </div>

        <!-- Add Reply Form -->
        <div class="card border-0 shadow-sm">
            <div class="card-header bg-success text-white py-3">
                <h5 class="mb-0"><i class="bi bi-reply-fill me-2"></i>Add Your Reply</h5>
            </div>
            <div class="card-body p-4">
                <asp:Label ID="lblReplyError" runat="server" CssClass="alert alert-danger" Visible="false" />
                
                <div class="mb-3">
                    <label class="form-label fw-bold">Your Reply <span class="text-danger">*</span></label>
                    <asp:TextBox ID="txtReply" runat="server" 
                                 TextMode="MultiLine" Rows="5"
                                 CssClass="form-control" 
                                 placeholder="Write your reply..." />
                    <asp:RequiredFieldValidator ID="rfvReply" runat="server" 
                                               ControlToValidate="txtReply"
                                               ErrorMessage="Reply content is required"
                                               CssClass="text-danger small"
                                               Display="Dynamic" />
                </div>
                
                <asp:HiddenField ID="hfPostSlug" runat="server" />
                <asp:HiddenField ID="hfClassSlug" runat="server" />
                
                <div class="text-end">
                    <asp:Button ID="btnPostReply" runat="server" 
                                Text="Post Reply" 
                                CssClass="btn btn-success btn-lg px-5"
                                OnClick="btnPostReply_Click" />
                </div>
            </div>
        </div>
    </div>

    <!-- Edit Post Modal -->
    <div class="modal fade" id="editPostModal" tabindex="-1" aria-labelledby="editPostModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="editPostModalLabel">Edit Post</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <asp:Panel ID="pnlEditPost" runat="server" DefaultButton="btnUpdatePost">
                    <div class="modal-body">
                        <asp:Label ID="lblEditPostError" runat="server" CssClass="alert alert-danger" Visible="false" />
                        
                        <div class="mb-3">
                            <label class="form-label fw-bold">Title <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtEditPostTitle" runat="server" CssClass="form-control" MaxLength="200" />
                            <asp:RequiredFieldValidator ID="rfvEditPostTitle" runat="server" 
                                ControlToValidate="txtEditPostTitle" ValidationGroup="EditPostGroup"
                                CssClass="text-danger small" ErrorMessage="Title is required." Display="Dynamic" />
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-bold">Content <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtEditPostContent" runat="server" CssClass="form-control" 
                                         TextMode="MultiLine" Rows="6" MaxLength="5000" />
                            <asp:RequiredFieldValidator ID="rfvEditPostContent" runat="server" 
                                ControlToValidate="txtEditPostContent" ValidationGroup="EditPostGroup"
                                CssClass="text-danger small" ErrorMessage="Content is required." Display="Dynamic" />
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <asp:Button ID="btnUpdatePost" runat="server" Text="Update Post" 
                                    CssClass="btn btn-primary" ValidationGroup="EditPostGroup" 
                                    OnClick="btnUpdatePost_Click" />
                    </div>
                </asp:Panel>
            </div>
        </div>
    </div>

    <!-- Edit Reply Modal -->
    <div class="modal fade" id="editReplyModal" tabindex="-1" aria-labelledby="editReplyModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="editReplyModalLabel">Edit Reply</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <asp:Panel ID="pnlEditReply" runat="server" DefaultButton="btnUpdateReply">
                    <div class="modal-body">
                        <asp:Label ID="lblEditReplyError" runat="server" CssClass="alert alert-danger" Visible="false" />
                        
                        <div class="mb-3">
                            <label class="form-label fw-bold">Content <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtEditReplyContent" runat="server" CssClass="form-control" 
                                         TextMode="MultiLine" Rows="6" MaxLength="5000" />
                            <asp:RequiredFieldValidator ID="rfvEditReplyContent" runat="server" 
                                ControlToValidate="txtEditReplyContent" ValidationGroup="EditReplyGroup"
                                CssClass="text-danger small" ErrorMessage="Content is required." Display="Dynamic" />
                        </div>

                        <asp:HiddenField ID="hfEditReplySlug" runat="server" />
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <asp:Button ID="btnUpdateReply" runat="server" Text="Update Reply" 
                                    CssClass="btn btn-primary" ValidationGroup="EditReplyGroup" 
                                    OnClick="btnUpdateReply_Click" />
                    </div>
                </asp:Panel>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Populate edit post modal when opened
            var editPostModal = document.getElementById('editPostModal');
            if (editPostModal) {
                editPostModal.addEventListener('show.bs.modal', function() {
                    document.getElementById('<%= txtEditPostTitle.ClientID %>').value = document.getElementById('<%= lblPostTitle.ClientID %>').innerText;
                    document.getElementById('<%= txtEditPostContent.ClientID %>').value = document.getElementById('<%= lblContent.ClientID %>').innerText;
                });
            }

            // Edit Reply Button Handlers - Use event delegation for dynamically created buttons
            document.addEventListener('click', function(e) {
                if (e.target.closest('.edit-reply-btn')) {
                    const btn = e.target.closest('.edit-reply-btn');
                    const replySlug = btn.getAttribute('data-reply-slug');
                    const replyContent = btn.getAttribute('data-reply-content');
                    
                    document.getElementById('<%= hfEditReplySlug.ClientID %>').value = replySlug;
                    document.getElementById('<%= txtEditReplyContent.ClientID %>').value = replyContent;
                    
                    const modal = new bootstrap.Modal(document.getElementById('editReplyModal'));
                    modal.show();
                }
            });
        });
    </script>

</asp:Content>




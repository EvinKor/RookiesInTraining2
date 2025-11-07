<%@ Page Title="Class - Student"
    Language="C#"
    MasterPageFile="~/MasterPages/MyMain.Master"
    AutoEventWireup="true"
    CodeBehind="student_class.aspx.cs"
    Inherits="RookiesInTraining2.Pages.student.student_class" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    
    <div class="container-fluid mt-4">
        <!-- Header -->
        <div class="card border-0 shadow-sm mb-4" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);">
            <div class="card-body text-white p-4">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h2 class="mb-2"><asp:Label ID="lblClassName" runat="server" /></h2>
                        <p class="mb-0 opacity-90">
                            <i class="bi bi-code me-1"></i>Code: <strong><asp:Label ID="lblClassCode" runat="server" /></strong>
                        </p>
                    </div>
                    <asp:HyperLink ID="lnkBack" runat="server" 
                                  NavigateUrl="~/Pages/student/dashboard_student.aspx"
                                  CssClass="btn btn-light btn-lg">
                        <i class="bi bi-arrow-left me-2"></i>Dashboard
                    </asp:HyperLink>
                </div>
            </div>
        </div>

        <!-- Tabs -->
        <ul class="nav nav-tabs nav-fill mb-4" role="tablist">
            <li class="nav-item" role="presentation">
                <button class="nav-link active" id="levelsTab" data-bs-toggle="tab" data-bs-target="#levelsContent"
                        type="button" role="tab">
                    <i class="bi bi-layers me-2"></i>Learning Levels
                </button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="forumTab" data-bs-toggle="tab" data-bs-target="#forumContent"
                        type="button" role="tab" onclick="loadForumPosts()">
                    <i class="bi bi-chat-dots me-2"></i>Class Forum
                </button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="progressTab" data-bs-toggle="tab" data-bs-target="#progressContent"
                        type="button" role="tab">
                    <i class="bi bi-graph-up me-2"></i>My Progress
                </button>
            </li>
        </ul>

        <!-- Tab Content -->
        <div class="tab-content">
            <!-- LEVELS TAB -->
            <div class="tab-pane fade show active" id="levelsContent" role="tabpanel">
                <div class="row g-4" id="levelsContainer">
                    <!-- Levels will be loaded here -->
                </div>
                
                <div id="noLevels" class="text-center py-5" style="display: none;">
                    <i class="bi bi-layers display-1 text-muted opacity-25"></i>
                    <h4 class="mt-3 mb-2">No Levels Available Yet</h4>
                    <p class="text-muted">Your teacher hasn't added any learning levels to this class yet.</p>
                </div>
            </div>

            <!-- FORUM TAB -->
            <div class="tab-pane fade" id="forumContent" role="tabpanel">
                <div class="card border-0 shadow-sm">
                    <div class="card-body p-4">
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <h5 class="mb-0"><i class="bi bi-chat-dots me-2"></i>Discussion Forum</h5>
                        </div>
                        
                        <div id="forumContainer">
                            <!-- Forum posts will be loaded here -->
                        </div>
                        
                        <div id="noForumPosts" class="text-center py-5" style="display: none;">
                            <i class="bi bi-chat-dots display-1 text-muted opacity-25"></i>
                            <h5 class="mt-3 mb-2">No Forum Posts Yet</h5>
                            <p class="text-muted">No discussions have been started yet.</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- PROGRESS TAB -->
            <div class="tab-pane fade" id="progressContent" role="tabpanel">
                <div class="card border-0 shadow-sm">
                    <div class="card-body p-4">
                        <h5 class="mb-4"><i class="bi bi-graph-up me-2"></i>My Progress</h5>
                        
                        <div id="progressStats" class="row g-3 mb-4">
                            <!-- Progress stats will be loaded here -->
                        </div>
                        
                        <div id="levelProgressList">
                            <!-- Individual level progress will be shown here -->
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Hidden Fields -->
    <asp:HiddenField ID="hfClassSlug" runat="server" />
    <asp:HiddenField ID="hfLevelsJson" runat="server" />
    <asp:HiddenField ID="hfForumPostsJson" runat="server" />
    <asp:HiddenField ID="hfProgressJson" runat="server" />

    <script>
        let classSlug = '<%= Request.QueryString["class"] %>';
        
        window.addEventListener('DOMContentLoaded', function() {
            loadLevels();
            loadProgress();
        });

        function loadLevels() {
            const levelsField = document.getElementById('<%= hfLevelsJson.ClientID %>');
            const container = document.getElementById('levelsContainer');
            const noLevels = document.getElementById('noLevels');
            
            if (!levelsField || !levelsField.value) {
                container.style.display = 'none';
                noLevels.style.display = 'block';
                return;
            }
            
            try {
                const levels = JSON.parse(levelsField.value);
                
                if (levels.length === 0) {
                    container.style.display = 'none';
                    noLevels.style.display = 'block';
                    return;
                }
                
                container.style.display = 'flex';
                noLevels.style.display = 'none';
                
                container.innerHTML = levels.map(level => `
                    <div class="col-md-6 col-lg-4">
                        <div class="card h-100 border-0 shadow-sm hover-shadow" style="cursor: pointer;" 
                             onclick="window.location.href='take_level.aspx?level=${level.LevelSlug}&class=${classSlug}'">
                            <div class="card-body p-4">
                                <div class="d-flex align-items-center mb-3">
                                    <div class="rounded-circle bg-primary text-white d-flex align-items-center justify-content-center me-3"
                                         style="width: 50px; height: 50px; font-size: 1.5rem; font-weight: 700;">
                                        ${level.LevelNumber}
                                    </div>
                                    <div class="flex-grow-1">
                                        <h6 class="mb-0">${escapeHtml(level.Title)}</h6>
                                    </div>
                                </div>
                                
                                <p class="text-muted small mb-3">${escapeHtml(level.Description || 'No description')}</p>
                                
                                <div class="d-flex gap-2 flex-wrap">
                                    <span class="badge bg-light text-dark">
                                        <i class="bi bi-clock text-info me-1"></i>${level.EstimatedMinutes} min
                                    </span>
                                    <span class="badge bg-light text-dark">
                                        <i class="bi bi-star text-warning me-1"></i>${level.XpReward} XP
                                    </span>
                                    ${level.IsCompleted ? 
                                        '<span class="badge bg-success"><i class="bi bi-check-circle me-1"></i>Completed</span>' :
                                        '<span class="badge bg-primary"><i class="bi bi-play-circle me-1"></i>Start</span>'}
                                </div>
                            </div>
                        </div>
                    </div>
                `).join('');
            } catch (error) {
                console.error('Error loading levels:', error);
                noLevels.style.display = 'block';
            }
        }

        function loadForumPosts() {
            const postsField = document.getElementById('<%= hfForumPostsJson.ClientID %>');
            const container = document.getElementById('forumContainer');
            const noPosts = document.getElementById('noForumPosts');
            
            if (!postsField || !postsField.value) {
                container.style.display = 'none';
                noPosts.style.display = 'block';
                return;
            }
            
            try {
                const posts = JSON.parse(postsField.value);
                
                if (posts.length === 0) {
                    container.style.display = 'none';
                    noPosts.style.display = 'block';
                    return;
                }
                
                container.style.display = 'block';
                noPosts.style.display = 'none';
                
                container.innerHTML = posts.map(post => `
                    <div class="card mb-3 hover-shadow" style="cursor: pointer;" 
                         onclick="window.location.href='../teacher/view_forum_post.aspx?post=${post.PostSlug}&class=${classSlug}'">
                        <div class="card-body">
                            <h6 class="mb-1">${escapeHtml(post.Title)}</h6>
                            <small class="text-muted">
                                <i class="bi bi-person me-1"></i>${escapeHtml(post.AuthorName || 'Anonymous')}
                                <i class="bi bi-clock ms-3 me-1"></i>${formatDate(post.CreatedAt)}
                                <i class="bi bi-chat-left ms-3 me-1"></i>${post.ReplyCount || 0} replies
                            </small>
                            <p class="mb-0 mt-2 text-muted">${truncateText(post.Content, 150)}</p>
                        </div>
                    </div>
                `).join('');
            } catch (error) {
                console.error('Error loading forum posts:', error);
            }
        }

        function loadProgress() {
            const progressField = document.getElementById('<%= hfProgressJson.ClientID %>');
            // Progress tracking implementation
        }

        function formatDate(dateString) {
            const date = new Date(dateString);
            const now = new Date();
            const diffMs = now - date;
            const diffMins = Math.floor(diffMs / 60000);
            const diffHours = Math.floor(diffMs / 3600000);
            const diffDays = Math.floor(diffMs / 86400000);
            
            if (diffMins < 1) return 'Just now';
            if (diffMins < 60) return `${diffMins} min ago`;
            if (diffHours < 24) return `${diffHours} hours ago`;
            if (diffDays < 7) return `${diffDays} days ago`;
            return date.toLocaleDateString();
        }

        function truncateText(text, maxLength) {
            if (!text) return '';
            if (text.length <= maxLength) return escapeHtml(text);
            return escapeHtml(text.substring(0, maxLength)) + '...';
        }

        function escapeHtml(text) {
            const div = document.createElement('div');
            div.textContent = text || '';
            return div.innerHTML;
        }
    </script>

    <style>
        .hover-shadow {
            transition: all 0.3s ease;
        }
        .hover-shadow:hover {
            transform: translateY(-4px);
            box-shadow: 0 8px 20px rgba(0,0,0,0.12);
        }
    </style>

</asp:Content>


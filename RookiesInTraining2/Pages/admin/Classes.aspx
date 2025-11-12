<%@ Page Title="Manage Classes"
    Language="C#"
    MasterPageFile="~/MasterPages/dashboard.Master"
    AutoEventWireup="true"
    CodeBehind="Classes.aspx.cs"
    Inherits="RookiesInTraining2.Pages.ManageClasses" %>

<asp:Content ID="Content1" ContentPlaceHolderID="DashboardContent" runat="server">
    
    <!-- Page Header -->
    <div id="pageHeader" class="row mb-4">
        <div class="col-12">
            <div class="d-flex align-items-center mb-3">
                <div class="flex-grow-1">
                    <h2 class="mb-1">Classes Management</h2>
                    <p class="text-muted mb-0">View and manage all classes in the system</p>
                </div>
                <div>
                    <asp:Button ID="btnExportCSV" runat="server" Text="Export CSV" CssClass="btn btn-outline-primary me-2" OnClick="btnExportCSV_Click" />
                    <a href="<%= ResolveUrl("~/Pages/admin/admin_create_module.aspx") %>" class="btn btn-success">
                        <i class="bi bi-plus-circle me-2"></i>Create New Class
                    </a>
                </div>
            </div>
        </div>
    </div>

    <!-- Filters and Search -->
    <div id="filtersSection" class="row mb-3">
        <div class="col-md-6">
            <div class="input-group">
                <span class="input-group-text"><i class="bi bi-search"></i></span>
                <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" placeholder="Search by class name or code..." AutoPostBack="true" OnTextChanged="txtSearch_TextChanged" />
            </div>
        </div>
        <div class="col-md-3">
            <asp:Label ID="lblClassCount" runat="server" CssClass="form-control text-muted" />
        </div>
    </div>

    <!-- Classes Grid -->
    <div id="classesGrid" class="row g-4">
        <asp:Repeater ID="rptClasses" runat="server" OnItemCommand="rptClasses_ItemCommand">
            <ItemTemplate>
                <div class="col-md-6 col-lg-4">
                    <div class="class-card" 
                         style="--class-color: <%# Eval("Color") %>; position: relative;">
                        <!-- Action Buttons (Top Right) -->
                        <div class="class-action-buttons" onclick="event.stopPropagation();">
                            <button type="button" class="btn btn-sm btn-primary" 
                                    onclick="event.stopPropagation(); editClass('<%# Eval("ClassSlug") %>'); return false;"
                                    title="Edit Class">
                                <i class="bi bi-pencil"></i>
                            </button>
                            <asp:LinkButton ID="btnDelete" runat="server" 
                                            CommandName="DeleteClass" 
                                            CommandArgument='<%# Eval("ClassSlug") %>'
                                            CssClass="btn btn-sm btn-danger"
                                            OnClientClick="event.stopPropagation(); return confirm('Are you sure you want to delete this class? This action cannot be undone and will delete all associated levels, quizzes, and forum posts.');"
                                            title="Delete Class">
                                <i class="bi bi-trash"></i>
                            </asp:LinkButton>
                        </div>
                        
                        <!-- Clickable Card Area -->
                        <div class="clickable-card" 
                             style="cursor: pointer;"
                             onclick="selectClass('<%# Eval("ClassSlug") %>', '<%# Server.HtmlEncode(Eval("ClassName").ToString()) %>')">
                            <div class="class-card-header" style="padding-right: 70px;">
                                <div class="class-icon">
                                    <i class="<%# Eval("Icon") %> fs-2"></i>
                                </div>
                                <h3 class="class-name"><%# Server.HtmlEncode(Eval("ClassName").ToString()) %></h3>
                                <span class="class-code"><%# Server.HtmlEncode(Eval("ClassCode").ToString()) %></span>
                            </div>
                            <div class="class-card-body">
                                <div class="class-stats">
                                    <div class="class-stat">
                                        <i class="bi bi-person-badge"></i>
                                        <div class="class-stat-text">
                                            <div class="class-stat-value"><%# Eval("TeacherName") %></div>
                                            <div class="class-stat-label">teacher</div>
                                        </div>
                                    </div>
                                    <div class="class-stat">
                                        <i class="bi bi-people"></i>
                                        <div class="class-stat-text">
                                            <div class="class-stat-value"><%# Eval("StudentCount") %></div>
                                            <div class="class-stat-label">students</div>
                                        </div>
                                    </div>
                                </div>
                                <div class="mt-3">
                                    <small class="text-muted">
                                        <i class="bi bi-calendar me-1"></i>Created: <%# Eval("CreatedAt") %>
                                    </small>
                                </div>
                            </div>
                            <div class="class-card-footer">
                                <i class="bi bi-arrow-right-circle me-1"></i>Click to view class details
                            </div>
                        </div>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
    
    <asp:Label ID="lblNoClasses" runat="server" CssClass="text-muted text-center d-block py-5"
               Text="No classes found" Visible="false" />

    <!-- Class Management Area (Hidden initially) -->
    <div id="classManagement" style="display: none;">
        <div class="row mb-4">
            <div class="col-12">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h3 class="mb-1"><i class="bi bi-collection me-2"></i><span id="currentClassName">Class Name</span></h3>
                        <p class="text-muted mb-0">View class details and manage content</p>
                    </div>
                    <button type="button" class="btn btn-outline-secondary" onclick="backToSelection()">
                        <i class="bi bi-arrow-left me-2"></i>Choose Different Class
                    </button>
                </div>
            </div>
        </div>

        <!-- Tabs -->
        <ul class="nav nav-tabs nav-fill mb-4" id="classTabs" role="tablist">
            <li class="nav-item" role="presentation">
                <button class="nav-link active" id="forumTabBtn" data-bs-toggle="tab" data-bs-target="#forumTab" 
                        type="button" role="tab" aria-controls="forumTab" aria-selected="true"
                        onclick="loadForumPosts(selectedClass?.ClassSlug || selectedClass?.slug);">
                    <i class="bi bi-chat-dots-fill me-2"></i>Forum
                </button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="studentsTabBtn" data-bs-toggle="tab" data-bs-target="#studentsTab"
                        type="button" role="tab" aria-controls="studentsTab" aria-selected="false">
                    <i class="bi bi-people-fill me-2"></i>Students
                </button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="storymodeTabBtn" data-bs-toggle="tab" data-bs-target="#storymodeTab"
                        type="button" role="tab" aria-controls="storymodeTab" aria-selected="false"
                        onclick="loadLevelsForClass(selectedClass?.ClassSlug || selectedClass?.slug);">
                    <i class="bi bi-book-half me-2"></i>Class Storymode
                </button>
            </li>
        </ul>

        <!-- Tab Content -->
        <div class="tab-content" id="classTabsContent">
            <!-- FORUM TAB -->
            <div class="tab-pane fade show active" id="forumTab" role="tabpanel" aria-labelledby="forumTabBtn">
                <div class="card border-0 shadow-sm">
                    <div class="card-body p-4">
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <h5 class="mb-0"><i class="bi bi-chat-dots me-2"></i>Class Forum</h5>
                            <button type="button" class="btn btn-primary" onclick="openCreatePostModal(); return false;">
                                <i class="bi bi-plus-circle me-2"></i>New Post
                            </button>
                        </div>
                        
                        <div id="forumContainer">
                            <!-- Forum posts will be loaded here by JavaScript -->
                        </div>
                        
                        <div id="noForumPosts" class="text-center py-5" style="display: none;">
                            <i class="bi bi-chat-dots display-1 text-muted opacity-25"></i>
                            <h5 class="mt-3 mb-2">No Forum Posts Yet</h5>
                            <p class="text-muted">Start a discussion with your students</p>
                            <button type="button" class="btn btn-primary" onclick="openCreatePostModal(); return false;">
                                <i class="bi bi-plus-circle me-2"></i>Create First Post
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- STUDENTS TAB -->
            <div class="tab-pane fade" id="studentsTab" role="tabpanel" aria-labelledby="studentsTabBtn">
                <div class="card border-0 shadow-sm">
                    <div class="card-body p-4">
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <h5 class="mb-0"><i class="bi bi-people me-2"></i>Class Students</h5>
                            <button type="button" class="btn btn-success btn-lg" onclick="openAddStudentsPage()">
                                <i class="bi bi-person-plus me-2"></i>Add Students
                            </button>
                        </div>
                        
                        <div class="alert alert-info">
                            <i class="bi bi-info-circle me-2"></i>
                            Click "Add Students" to manually enroll students or share the class code with your students so they can join independently.
                        </div>
                        
                        <div class="row mb-3">
                            <div class="col-md-4">
                                <div class="card bg-primary bg-opacity-10 border-primary">
                                    <div class="card-body text-center">
                                        <h6 class="text-muted mb-1">Class Code</h6>
                                        <h3 class="mb-0" id="classCodeDisplay">------</h3>
                                        <small class="text-muted">Share with students</small>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="card bg-success bg-opacity-10 border-success">
                                    <div class="card-body text-center">
                                        <h6 class="text-muted mb-1">Total Students</h6>
                                        <h3 class="mb-0" id="totalStudentsDisplay">0</h3>
                                        <small class="text-muted">Enrolled</small>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="card bg-info bg-opacity-10 border-info">
                                    <div class="card-body text-center">
                                        <h6 class="text-muted mb-1">Active Students</h6>
                                        <h3 class="mb-0" id="activeStudentsDisplay">0</h3>
                                        <small class="text-muted">Last 7 days</small>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <p class="text-muted mb-0">
                            <i class="bi bi-lightbulb me-2"></i>
                            To add or remove students, click the "Add Students" button above.
                        </p>
                    </div>
                </div>
            </div>

            <!-- STORYMODE TAB -->
            <div class="tab-pane fade" id="storymodeTab" role="tabpanel" aria-labelledby="storymodeTabBtn">
                <div class="card border-0 shadow-sm">
                    <div class="card-body p-4">
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <h5 class="mb-0"><i class="bi bi-layers me-2"></i>Learning Levels</h5>
                            <button type="button" class="btn btn-success btn-lg" onclick="openCreateLevelStorymode(); return false;">
                                <i class="bi bi-plus-circle me-2"></i>Create New Level
                            </button>
                        </div>
                        
                        <div id="levelsContainer" class="row g-3">
                            <!-- Levels will be loaded here -->
                        </div>
                        
                        <div id="noLevels" class="text-center py-5" style="display: none;">
                            <i class="bi bi-layers display-1 text-muted opacity-25"></i>
                            <h5 class="mt-3 mb-2">No Levels Yet</h5>
                            <p class="text-muted">Create the first learning level for your students</p>
                            <button type="button" class="btn btn-success btn-lg" onclick="openCreateLevelStorymode(); return false;">
                                <i class="bi bi-plus-circle me-2"></i>Create First Level
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Hidden Fields -->
    <asp:HiddenField ID="hfClassesJson" runat="server" />
    <asp:HiddenField ID="hfLevelsJson" runat="server" />
    <asp:HiddenField ID="hfForumPostsJson" runat="server" />

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
        
        /* Class Cards */
        .class-card {
            border: 1px solid #e8ecf1;
            border-radius: 1rem;
            overflow: hidden;
            transition: all 0.3s ease;
            cursor: pointer;
            height: 100%;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            background: white;
        }
        .class-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 8px 24px rgba(0,0,0,0.12);
            border-color: var(--class-color, #667eea);
        }
        .class-card-header {
            padding: 1.5rem;
            border-bottom: 3px solid var(--class-color, #667eea);
            background: linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(118, 75, 162, 0.1) 100%);
            color: #2d3748;
        }
        .class-card-body {
            padding: 1.5rem;
            background: white;
        }
        .class-card-footer {
            padding: 1rem 1.5rem;
            background: #f8f9fa;
            border-top: 1px solid #e8ecf1;
            color: #6c757d;
            font-size: 0.875rem;
        }
        .class-icon {
            font-size: 2rem;
            margin-bottom: 0.5rem;
            opacity: 0.9;
        }
        .class-name {
            font-size: 1.25rem;
            font-weight: 600;
            color: #2d3748;
            margin-bottom: 0.5rem;
        }
        .class-code {
            display: inline-block;
            padding: 0.25rem 0.75rem;
            background: white;
            border: 1px solid #e8ecf1;
            border-radius: 0.5rem;
            font-size: 0.875rem;
            color: #6c757d;
            font-weight: 500;
        }
        .class-stats {
            display: flex;
            gap: 1.5rem;
            flex-wrap: wrap;
        }
        .class-stat {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        .class-stat i {
            font-size: 1.5rem;
            color: var(--class-color, #667eea);
            opacity: 0.8;
        }
        .class-stat-text {
            display: flex;
            flex-direction: column;
        }
        .class-stat-value {
            font-weight: 600;
            color: #2d3748;
            font-size: 0.95rem;
        }
        .class-stat-label {
            font-size: 0.75rem;
            color: #6c757d;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .class-action-buttons {
            position: absolute;
            top: 8px;
            right: 8px;
            z-index: 100;
            display: flex;
            gap: 0.25rem;
            opacity: 0;
            transition: opacity 0.2s ease;
            pointer-events: none;
        }
        .class-card:hover .class-action-buttons {
            opacity: 1;
            pointer-events: auto;
        }
        .class-action-buttons .btn {
            padding: 0.35rem 0.6rem;
            box-shadow: 0 2px 4px rgba(0,0,0,0.15);
            border: none;
        }
        .class-action-buttons .btn:hover {
            transform: scale(1.05);
            box-shadow: 0 3px 6px rgba(0,0,0,0.2);
        }
        .class-action-buttons .btn-primary {
            background-color: #0d6efd;
        }
        .class-action-buttons .btn-danger {
            background-color: #dc3545;
        }
    </style>
    
    <script>
        let selectedClass = null;

        // Auto-select class from URL parameter
        window.addEventListener('DOMContentLoaded', function() {
            const urlParams = new URLSearchParams(window.location.search);
            const classSlug = urlParams.get('class');
            const tabParam = urlParams.get('tab');
            
            if (classSlug) {
                // Find the class name from the classes list
                const classesField = document.getElementById('<%= hfClassesJson.ClientID %>');
                if (classesField && classesField.value) {
                    try {
                        const classes = JSON.parse(classesField.value);
                        const foundClass = classes.find(c => c.ClassSlug === classSlug);
                        if (foundClass) {
                            selectClass(foundClass.ClassSlug, foundClass.ClassName);
                            
                            // Auto-switch to requested tab
                            if (tabParam === 'storymode') {
                                setTimeout(() => {
                                    const storymodeTab = new bootstrap.Tab(document.getElementById('storymodeTabBtn'));
                                    storymodeTab.show();
                                }, 100);
                            } else if (tabParam === 'students') {
                                setTimeout(() => {
                                    const studentsTab = new bootstrap.Tab(document.getElementById('studentsTabBtn'));
                                    studentsTab.show();
                                }, 100);
                            }
                        }
                    } catch (e) {
                        console.error('Error auto-selecting class:', e);
                    }
                }
            }
        });

        function selectClass(slug, name) {
            // Find the full class data
            const classesField = document.getElementById('<%= hfClassesJson.ClientID %>');
            if (classesField && classesField.value) {
                try {
                    const classes = JSON.parse(classesField.value);
                    const foundClass = classes.find(c => c.ClassSlug === slug);
                    if (foundClass) {
                        selectedClass = foundClass;
                    } else {
                        selectedClass = { ClassSlug: slug, ClassName: name };
                    }
                } catch (e) {
                    selectedClass = { ClassSlug: slug, ClassName: name };
                }
            } else {
                selectedClass = { ClassSlug: slug, ClassName: name };
            }
            
            // Hide selection, show management
            document.getElementById('pageHeader').style.display = 'none';
            document.getElementById('filtersSection').style.display = 'none';
            document.getElementById('classesGrid').style.display = 'none';
            document.getElementById('classManagement').style.display = 'block';
            document.getElementById('currentClassName').textContent = name;
            
            // Update Students tab info
            if (selectedClass.ClassCode) {
                document.getElementById('classCodeDisplay').textContent = selectedClass.ClassCode;
            }
            if (selectedClass.StudentCount !== undefined) {
                document.getElementById('totalStudentsDisplay').textContent = selectedClass.StudentCount;
                document.getElementById('activeStudentsDisplay').textContent = Math.floor(selectedClass.StudentCount * 0.5);
            }
            
            // Load forum posts and levels for this class
            loadForumPosts(slug);
            loadLevelsForClass(slug);
        }

        function backToSelection() {
            document.getElementById('pageHeader').style.display = 'block';
            document.getElementById('filtersSection').style.display = 'block';
            document.getElementById('classesGrid').style.display = 'flex';
            document.getElementById('classManagement').style.display = 'none';
            selectedClass = null;
        }

        function loadLevelsForClass(classSlug) {
            if (!classSlug) {
                showNoLevels();
                return;
            }
            
            const levelsField = document.getElementById('<%= hfLevelsJson.ClientID %>');
            if (!levelsField || !levelsField.value) {
                showNoLevels();
                return;
            }

            try {
                const allLevels = JSON.parse(levelsField.value);
                const classLevels = allLevels.filter(l => l.ClassSlug === classSlug);
                renderLevels(classLevels);
            } catch (error) {
                console.error('[LEVELS] Error loading levels:', error);
                showNoLevels();
            }
        }

        function renderLevels(levels) {
            const container = document.getElementById('levelsContainer');
            const noLevels = document.getElementById('noLevels');
            
            if (levels.length === 0) {
                container.style.display = 'none';
                noLevels.style.display = 'block';
                return;
            }
            
            container.style.display = 'flex';
            noLevels.style.display = 'none';
            
            container.innerHTML = levels.map(level => `
                <div class="col-12">
                    <div class="card border-0 shadow-sm mb-3">
                        <div class="card-body">
                            <div class="d-flex justify-content-between align-items-start">
                                <div class="flex-grow-1">
                                    <h5 class="mb-2">
                                        <i class="bi bi-layers me-2 text-primary"></i>${escapeHtml(level.Title)}
                                    </h5>
                                    <p class="text-muted mb-2">${escapeHtml(level.Description || 'No description')}</p>
                                    <div class="d-flex gap-2">
                                        <span class="badge bg-light text-dark">
                                            <i class="bi bi-clock text-info me-1"></i>${level.EstimatedMinutes} min
                                        </span>
                                        <span class="badge bg-light text-dark">
                                            <i class="bi bi-star text-warning me-1"></i>${level.XpReward} XP
                                        </span>
                                        ${level.IsPublished ? 
                                            '<span class="badge bg-success"><i class="bi bi-check-circle me-1"></i>Published</span>' : 
                                            '<span class="badge bg-warning text-dark"><i class="bi bi-clock me-1"></i>Draft</span>'}
                                    </div>
                                </div>
                                <div class="btn-group">
                                    <button type="button" class="btn btn-outline-primary" onclick="editLevel('${level.LevelSlug}')">
                                        <i class="bi bi-pencil me-1"></i>Edit
                                    </button>
                                    <button type="button" class="btn btn-outline-info" onclick="manageSlides('${level.LevelSlug}', '${escapeHtml(level.Title)}')">
                                        <i class="bi bi-file-slides me-1"></i>Slides
                                    </button>
                                    <button type="button" class="btn btn-outline-success" onclick="editQuiz('${level.LevelSlug}', '${level.QuizSlug || ''}')">
                                        <i class="bi bi-question-circle me-1"></i>Quiz
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            `).join('');
        }

        function showNoLevels() {
            document.getElementById('levelsContainer').style.display = 'none';
            document.getElementById('noLevels').style.display = 'block';
        }

        function loadForumPosts(classSlug) {
            const postsField = document.getElementById('<%= hfForumPostsJson.ClientID %>');
            if (!postsField || !postsField.value) {
                showNoForumPosts();
                return;
            }
            
            try {
                const allPosts = JSON.parse(postsField.value);
                const classPosts = allPosts.filter(p => p.ClassSlug === classSlug);
                renderForumPosts(classPosts);
            } catch (error) {
                console.error('[Forum] Error loading posts:', error);
                showNoForumPosts();
            }
        }

        function renderForumPosts(posts) {
            const container = document.getElementById('forumContainer');
            const noPostsDiv = document.getElementById('noForumPosts');
            
            if (posts.length === 0) {
                container.style.display = 'none';
                noPostsDiv.style.display = 'block';
                return;
            }
            
            container.style.display = 'block';
            noPostsDiv.style.display = 'none';
            
            container.innerHTML = posts.map(post => `
                <div class="card mb-3 hover-shadow">
                    <div class="card-body">
                        <div style="cursor: pointer;" onclick="viewPost('${post.PostSlug}')">
                            <div class="d-flex align-items-start">
                                <div class="flex-shrink-0 me-3">
                                    <div class="rounded-circle bg-primary bg-opacity-10 text-primary d-flex align-items-center justify-content-center"
                                         style="width: 40px; height: 40px;">
                                        <i class="bi bi-person-fill"></i>
                                    </div>
                                </div>
                                <div class="flex-grow-1">
                                    <h6 class="mb-1">${escapeHtml(post.Title)}</h6>
                                    <small class="text-muted">
                                        <i class="bi bi-person me-1"></i>${escapeHtml(post.AuthorName || 'Anonymous')}
                                        <i class="bi bi-clock ms-3 me-1"></i>${formatDate(post.CreatedAt)}
                                        <i class="bi bi-chat-left ms-3 me-1"></i>${post.ReplyCount || 0} replies
                                    </small>
                                    <p class="mb-2 mt-2 text-muted">${truncateText(post.Content, 150)}</p>
                                </div>
                            </div>
                        </div>
                        
                        ${post.TopReplies && post.TopReplies.length > 0 ? `
                            <div class="mt-3 pt-3 border-top">
                                <small class="text-muted fw-bold d-block mb-2">
                                    <i class="bi bi-chat-left-dots me-1"></i>Recent Replies:
                                </small>
                                ${post.TopReplies.map(reply => `
                                    <div class="ps-4 mb-2 border-start border-primary border-2">
                                        <small class="d-block">
                                            <strong class="text-primary">${escapeHtml(reply.AuthorName)}</strong>
                                            <span class="text-muted ms-2">${formatDate(reply.CreatedAt)}</span>
                                        </small>
                                        <small class="text-muted">${truncateText(reply.Content, 100)}</small>
                                    </div>
                                `).join('')}
                                ${post.ReplyCount > 3 ? `
                                    <small class="text-muted ps-4">+ ${post.ReplyCount - 3} more replies...</small>
                                ` : ''}
                            </div>
                        ` : ''}
                        
                        <div class="mt-3 pt-2 border-top">
                            <a href="javascript:void(0)" 
                               onclick="viewPost('${post.PostSlug}')" 
                               class="text-primary text-decoration-none small fw-semibold">
                                <i class="bi bi-reply me-1"></i>View post
                            </a>
                        </div>
                    </div>
                </div>
            `).join('');
        }

        function showNoForumPosts() {
            document.getElementById('forumContainer').style.display = 'none';
            document.getElementById('noForumPosts').style.display = 'block';
        }

        function viewPost(postSlug) {
            if (!selectedClass) {
                alert('Please select a class first.');
                return;
            }
            
            const classSlug = selectedClass.ClassSlug || selectedClass.slug;
            window.location.href = `view_forum_post.aspx?post=${postSlug}&class=${classSlug}`;
        }

        function formatDate(dateString) {
            const date = new Date(dateString);
            const now = new Date();
            const diffMs = now - date;
            const diffMins = Math.floor(diffMs / 60000);
            const diffHours = Math.floor(diffMs / 3600000);
            const diffDays = Math.floor(diffMs / 86400000);
            
            if (diffMins < 1) return 'Just now';
            if (diffMins < 60) return `${diffMins} minute${diffMins > 1 ? 's' : ''} ago`;
            if (diffHours < 24) return `${diffHours} hour${diffHours > 1 ? 's' : ''} ago`;
            if (diffDays < 7) return `${diffDays} day${diffDays > 1 ? 's' : ''} ago`;
            
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

        function editClass(classSlug) {
            window.location.href = '<%= ResolveUrl("~/Pages/admin/edit_class.aspx?class=") %>' + classSlug;
        }

        function openCreatePostModal() {
            if (!selectedClass) {
                alert('Please select a class first.');
                return;
            }
            
            const classSlug = selectedClass.ClassSlug || selectedClass.slug;
            const className = selectedClass.ClassName || selectedClass.name;
            window.location.href = `create_forum_post.aspx?class=${classSlug}&className=${encodeURIComponent(className)}`;
        }

        function openAddStudentsPage() {
            if (!selectedClass) {
                alert('Please select a class first.');
                return;
            }
            
            const classSlug = selectedClass.ClassSlug || selectedClass.slug;
            window.location.href = `add_students.aspx?class=${classSlug}`;
        }

        function openCreateLevelStorymode() {
            if (!selectedClass) {
                alert('Please select a class first.');
                return;
            }
            
            const classSlug = selectedClass.ClassSlug || selectedClass.slug;
            const className = selectedClass.ClassName || selectedClass.name;
            window.location.href = `create_level.aspx?class=${classSlug}&className=${encodeURIComponent(className)}`;
        }

        function editLevel(levelSlug) {
            if (!selectedClass) {
                alert('Please select a class first.');
                return;
            }
            
            const classSlug = selectedClass.ClassSlug || selectedClass.slug;
            window.location.href = `edit_level.aspx?level=${levelSlug}&class=${classSlug}`;
        }

        function manageSlides(levelSlug, levelTitle) {
            if (!selectedClass) {
                alert('Please select a class first.');
                return;
            }
            
            const classSlug = selectedClass.ClassSlug || selectedClass.slug;
            window.location.href = `manage_slides.aspx?level=${levelSlug}&class=${classSlug}&levelTitle=${encodeURIComponent(levelTitle)}`;
        }

        function editQuiz(levelSlug, quizSlug) {
            if (!selectedClass) {
                alert('Please select a class first.');
                return;
            }
            
            const classSlug = selectedClass.ClassSlug || selectedClass.slug;
            if (quizSlug) {
                window.location.href = `create_quiz.aspx?quiz=${quizSlug}&level=${levelSlug}&class=${classSlug}`;
            } else {
                window.location.href = `create_quiz.aspx?level=${levelSlug}&class=${classSlug}`;
            }
        }
    </script>

</asp:Content>


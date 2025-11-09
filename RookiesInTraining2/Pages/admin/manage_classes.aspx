<%@ Page Title="Manage Classes - Admin"
    Language="C#"
    MasterPageFile="~/MasterPages/dashboard.Master"
    AutoEventWireup="true"
    CodeBehind="manage_classes.aspx.cs"
    Inherits="RookiesInTraining2.Pages.admin.manage_classes" %>

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
        .class-option {
            padding: 1.5rem;
            border: 1px solid #e8ecf1;
            border-radius: 0.5rem;
            cursor: pointer;
            transition: all 0.3s ease;
            margin-bottom: 1rem;
            background: white;
        }
        .class-option:hover {
            border-color: #0d6efd;
            background: #f8f9fa;
            transform: translateY(-2px);
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .class-option.selected {
            border-color: #0d6efd;
            background: #f8f9fa;
            border-width: 2px;
        }
        .delete-class-btn {
            opacity: 0;
            transition: opacity 0.2s ease;
        }
        .class-option:hover .delete-class-btn {
            opacity: 1;
        }
        .delete-class-btn:hover {
            transform: scale(1.1);
        }
        .hover-shadow {
            transition: all 0.3s ease;
        }
        .hover-shadow:hover {
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            transform: translateY(-2px);
        }
        .text-primary {
            color: #4e73df !important;
        }
        .text-primary:hover {
            color: #224abe !important;
            text-decoration: underline !important;
        }
    </style>

    <div class="container-fluid">
        <!-- Header -->
        <div class="row mb-4">
            <div class="col-12">
                <div class="d-flex align-items-center mb-3">
                    <a href="dashboard_admin.aspx" class="btn btn-outline-secondary me-3">
                        <i class="bi bi-arrow-left me-2"></i>Back to Dashboard
                    </a>
                    <div class="flex-grow-1">
                        <h2 class="mb-1">Manage Classes</h2>
                        <p class="text-muted mb-0">Select a class to view or manage</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Class Selection -->
        <div id="classSelection" class="card border-0 shadow-sm">
            <div class="card-body p-4">
                <h4 class="mb-4"><i class="bi bi-collection me-2"></i>Choose a Class</h4>
                
                <div class="row g-3">
                <!-- Create New Class Option -->
                <div class="col-md-6 col-lg-4">
                    <div class="class-option" style="border: 2px dashed #0d6efd; background: #f8f9fa;" onclick="createNewClass()">
                        <div class="text-center">
                            <i class="bi bi-plus-circle display-4 text-primary mb-3"></i>
                            <h5 class="mb-2">Create New Class</h5>
                            <p class="text-muted mb-0">Start a brand new learning class</p>
                        </div>
                    </div>
                </div>
                
                <!-- Existing Classes -->
                <asp:Repeater ID="rptClasses" runat="server">
                    <ItemTemplate>
                        <div class="col-md-6 col-lg-4">
                            <div class="class-option" style="position: relative;">
                                <!-- Delete Button (Top Right) -->
                                <button type="button" class="btn btn-sm btn-danger delete-class-btn" 
                                        style="position: absolute; top: 10px; right: 10px; z-index: 100;"
                                        onclick="openDeleteModal('<%# Eval("ClassSlug") %>', '<%# Eval("ClassName") %>'); return false;">
                                    <i class="bi bi-trash"></i>
                                </button>
                                
                                <!-- Clickable Card Area -->
                                <div class="class-card-clickable" 
                                     onclick="selectClass('<%# Eval("ClassSlug") %>', '<%# Eval("ClassName") %>')" 
                                     style="cursor: pointer; padding-right: 50px;">
                                    <div class="d-flex align-items-start">
                                        <div class="flex-shrink-0 me-3">
                                            <div style="width: 50px; height: 50px; background: linear-gradient(135deg, <%# Eval("Color") %>, <%# Eval("Color") %>); 
                                                        border-radius: 0.75rem; display: flex; align-items: center; justify-content: center; 
                                                        font-size: 1.5rem; color: white;">
                                                <i class="<%# Eval("Icon") %>"></i>
                                            </div>
                                        </div>
                                        <div class="flex-grow-1">
                                            <h5 class="mb-1"><%# Eval("ClassName") %></h5>
                                            <p class="text-muted small mb-2"><%# Eval("Description") %></p>
                                            <div class="d-flex gap-2">
                                                <span class="badge bg-light text-dark">
                                                    <i class="bi bi-people me-1"></i><%# Eval("StudentCount") %> students
                                                </span>
                                                <span class="badge bg-light text-dark">
                                                    <i class="bi bi-layers me-1"></i><%# Eval("LevelCount") %> levels
                                                </span>
                                            </div>
                                            <div class="mt-2">
                                                <small class="text-muted">
                                                    <i class="bi bi-person-badge me-1"></i>Teacher: <%# Eval("TeacherName") %>
                                                </small>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
                </div>
            </div>
        </div>

        <!-- Class Management Area (Hidden initially) -->
        <div id="classManagement" style="display: none;">
            <div class="row mb-4">
                <div class="col-12">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h3 class="mb-1"><i class="bi bi-collection me-2"></i><span id="currentClassName">Class Name</span></h3>
                            <p class="text-muted mb-0">View class details and manage content</p>
                        </div>
                        <a href="<%= ResolveUrl("~/Pages/admin/Classes.aspx") %>" class="btn btn-outline-secondary">
                            <i class="bi bi-arrow-left me-2"></i>Choose Different Class
                        </a>
                    </div>
                </div>
            </div>

            <!-- Tabs -->
            <ul class="nav nav-tabs nav-fill mb-4" id="classTabs" role="tablist">
                <li class="nav-item" role="presentation">
                    <button class="nav-link active" id="forumTabBtn" data-bs-toggle="tab" data-bs-target="#forumTab" 
                            type="button" role="tab" aria-controls="forumTab" aria-selected="true"
                            onclick="console.log('Switched to Forum tab'); loadForumPosts(selectedClass?.ClassSlug || selectedClass?.slug);">
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
                            onclick="console.log('Switched to Storymode tab'); loadLevelsForClass(selectedClass?.ClassSlug || selectedClass?.slug);">
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
        <asp:HiddenField ID="hfSelectedClassSlug" runat="server" />
        <asp:HiddenField ID="hfClassesJson" runat="server" />
        <asp:HiddenField ID="hfLevelsJson" runat="server" />
        <asp:HiddenField ID="hfForumPostsJson" runat="server" />
        <asp:HiddenField ID="hfDeleteClassSlug" runat="server" />
        <asp:HiddenField ID="hfDeleteClassName" runat="server" />
        <asp:Button ID="btnConfirmDelete" runat="server" style="display: none;" OnClick="btnConfirmDelete_Click" />
    </div>

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
                                    console.log('Auto-switched to Story Mode tab');
                                }, 100);
                            } else if (tabParam === 'students') {
                                setTimeout(() => {
                                    const studentsTab = new bootstrap.Tab(document.getElementById('studentsTabBtn'));
                                    studentsTab.show();
                                    console.log('Auto-switched to Students tab');
                                }, 100);
                            } else {
                                // Ensure Forum tab is active by default
                                setTimeout(() => {
                                    const forumTab = new bootstrap.Tab(document.getElementById('forumTabBtn'));
                                    forumTab.show();
                                    console.log('Showing Forum tab (default)');
                                }, 50);
                            }
                        }
                    } catch (e) {
                        console.error('Error auto-selecting class:', e);
                    }
                }
            }
        });

        function selectClass(slug, name) {
            console.log('Selecting class:', slug, name);
            
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
            document.getElementById('classSelection').style.display = 'none';
            document.getElementById('classManagement').style.display = 'block';
            document.getElementById('currentClassName').textContent = name;
            document.getElementById('<%= hfSelectedClassSlug.ClientID %>').value = slug;
            
            // Update Students tab info
            if (selectedClass.ClassCode) {
                document.getElementById('classCodeDisplay').textContent = selectedClass.ClassCode;
            }
            if (selectedClass.StudentCount !== undefined) {
                document.getElementById('totalStudentsDisplay').textContent = selectedClass.StudentCount;
                // For now, assume 50% are active (you can enhance this with real data later)
                document.getElementById('activeStudentsDisplay').textContent = Math.floor(selectedClass.StudentCount * 0.5);
            }
            
            console.log('Class selected, loading data...');
            // Load forum posts and levels for this class
            loadForumPosts(slug);
            loadLevelsForClass(slug);
        }

        function backToSelection() {
            document.getElementById('classSelection').style.display = 'block';
            document.getElementById('classManagement').style.display = 'none';
            selectedClass = null;
        }

        function loadLevelsForClass(classSlug) {
            console.log('[LEVELS] Loading levels for class:', classSlug);
            
            if (!classSlug) {
                console.warn('[LEVELS] No class slug provided');
                showNoLevels();
                return;
            }
            
            // Parse levels from hidden field
            const levelsField = document.getElementById('<%= hfLevelsJson.ClientID %>');
            console.log('[LEVELS] Levels field element:', levelsField);
            console.log('[LEVELS] Levels field value:', levelsField?.value);
            
            if (!levelsField || !levelsField.value) {
                console.warn('[LEVELS] No levels data in hidden field');
                showNoLevels();
                return;
            }

            try {
                const allLevels = JSON.parse(levelsField.value);
                console.log('[LEVELS] All levels parsed:', allLevels);
                const classLevels = allLevels.filter(l => l.ClassSlug === classSlug);
                console.log('[LEVELS] Filtered levels for class:', classLevels);
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
            console.log('[Forum] Loading posts for class:', classSlug);
            
            const postsField = document.getElementById('<%= hfForumPostsJson.ClientID %>');
            if (!postsField || !postsField.value) {
                showNoForumPosts();
                return;
            }
            
            try {
                const allPosts = JSON.parse(postsField.value);
                const classPosts = allPosts.filter(p => p.ClassSlug === classSlug);
                console.log('[Forum] Found posts:', classPosts.length);
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
            
            // Get the class slug (handle both capital and lowercase property names)
            const classSlug = selectedClass.ClassSlug || selectedClass.slug;
            
            // Redirect to view post page (admin version)
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

        function createNewClass() {
            window.location.href = '<%= ResolveUrl("~/Pages/teacher/teacher_create_module.aspx") %>';
        }

        function openDeleteModal(classSlug, className) {
            if (!confirm(`Are you sure you want to delete the class "${className}"? This action cannot be undone and will delete all associated levels, quizzes, and forum posts.`)) {
                return;
            }
            
            // Set hidden field and trigger postback
            document.getElementById('<%= hfDeleteClassSlug.ClientID %>').value = classSlug;
            document.getElementById('<%= hfDeleteClassName.ClientID %>').value = className;
            __doPostBack('<%= btnConfirmDelete.UniqueID %>', '');
        }

        function openCreatePostModal() {
            if (!selectedClass) {
                alert('Please select a class first.');
                return;
            }
            
            const classSlug = selectedClass.ClassSlug || selectedClass.slug;
            const className = selectedClass.ClassName || selectedClass.name;
            
            // Redirect to admin version of create forum post
            window.location.href = `create_forum_post.aspx?class=${classSlug}&className=${encodeURIComponent(className)}`;
        }

        function openAddStudentsPage() {
            if (!selectedClass) {
                alert('Please select a class first.');
                return;
            }
            
            const classSlug = selectedClass.ClassSlug || selectedClass.slug;
            // Redirect to admin version of add students
            window.location.href = `add_students.aspx?class=${classSlug}`;
        }

        function openCreateLevelStorymode() {
            if (!selectedClass) {
                alert('Please select a class first.');
                return;
            }
            
            const classSlug = selectedClass.ClassSlug || selectedClass.slug;
            const className = selectedClass.ClassName || selectedClass.name;
            
            // Redirect to admin version of create level
            window.location.href = `create_level.aspx?class=${classSlug}&className=${encodeURIComponent(className)}`;
        }

        function editLevel(levelSlug) {
            if (!selectedClass) {
                alert('Please select a class first.');
                return;
            }
            
            const classSlug = selectedClass.ClassSlug || selectedClass.slug;
            // Redirect to admin version of edit level
            window.location.href = `edit_level.aspx?level=${levelSlug}&class=${classSlug}`;
        }

        function manageSlides(levelSlug, levelTitle) {
            if (!selectedClass) {
                alert('Please select a class first.');
                return;
            }
            
            const classSlug = selectedClass.ClassSlug || selectedClass.slug;
            // Redirect to admin version of manage slides
            window.location.href = `manage_slides.aspx?level=${levelSlug}&class=${classSlug}&levelTitle=${encodeURIComponent(levelTitle)}`;
        }

        function editQuiz(levelSlug, quizSlug) {
            if (!selectedClass) {
                alert('Please select a class first.');
                return;
            }
            
            const classSlug = selectedClass.ClassSlug || selectedClass.slug;
            // Redirect to admin version of create quiz
            if (quizSlug) {
                window.location.href = `create_quiz.aspx?quiz=${quizSlug}&level=${levelSlug}&class=${classSlug}`;
            } else {
                window.location.href = `create_quiz.aspx?level=${levelSlug}&class=${classSlug}`;
            }
        }
    </script>
</asp:Content>


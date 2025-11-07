<%@ Page Title="Manage Classes - Teacher"
    Language="C#"
    MasterPageFile="~/MasterPages/MyMain.Master"
    AutoEventWireup="true"
    CodeBehind="manage_classes.aspx.cs"
    Inherits="RookiesInTraining2.Pages.teacher.manage_classes" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    
    <style>
        .manage-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 2rem;
            border-radius: 1rem;
            margin-bottom: 2rem;
        }
        .class-selector {
            background: white;
            padding: 2rem;
            border-radius: 1rem;
            box-shadow: 0 2px 12px rgba(0,0,0,0.08);
        }
        .class-option {
            padding: 1.5rem;
            border: 2px solid #e9ecef;
            border-radius: 0.75rem;
            cursor: pointer;
            transition: all 0.3s ease;
            margin-bottom: 1rem;
        }
        .class-option:hover {
            border-color: #667eea;
            background: #f8f9ff;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.15);
        }
        .class-option.selected {
            border-color: #667eea;
            background: linear-gradient(135deg, #f8f9ff, #fff);
            border-width: 3px;
        }
        .create-new-card {
            border: 2px dashed #667eea;
            background: linear-gradient(135deg, #f8f9ff, #fff);
        }
        .create-new-card:hover {
            background: linear-gradient(135deg, #e7e9ff, #f8f9ff);
            border-width: 3px;
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
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
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
        <div class="manage-header">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h2 class="mb-2"><i class="bi bi-gear-fill me-2"></i>Manage Classes</h2>
                    <p class="mb-0 opacity-90">Select a class to manage or create a new one</p>
                </div>
                <a href="<%= ResolveUrl("~/Pages/teacher/dashboard_teacher.aspx") %>" class="btn btn-light">
                    <i class="bi bi-arrow-left me-2"></i>Back to Dashboard
                </a>
            </div>
        </div>

        <!-- Class Selection -->
        <div id="classSelection" class="class-selector">
            <h4 class="mb-4"><i class="bi bi-collection me-2"></i>Choose a Class</h4>
            
            <div class="row g-3">
                <!-- Create New Class Option -->
                <div class="col-md-6 col-lg-4">
                    <div class="class-option create-new-card" onclick="createNewClass()">
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
                                <!-- Delete Button (Top Right) - Higher z-index -->
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
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>

        <!-- Class Management Area (Hidden initially) -->
        <div id="classManagement" style="display: none;">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h3><i class="bi bi-collection me-2"></i><span id="currentClassName">Class Name</span></h3>
                <button type="button" class="btn btn-outline-secondary" onclick="backToSelection()">
                    <i class="bi bi-arrow-left me-2"></i>Choose Different Class
                </button>
            </div>

            <!-- Tabs -->
            <ul class="nav nav-tabs nav-fill mb-4" id="classTabs" role="tablist">
                <li class="nav-item" role="presentation">
                    <button class="nav-link active" id="forumTabBtn" data-bs-toggle="tab" data-bs-target="#forumTab" 
                            type="button" role="tab" aria-controls="forumTab" aria-selected="true"
                            onclick="console.log('Switched to Forum tab'); loadForumPosts(selectedClass?.slug);">
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
                            onclick="console.log('Switched to Storymode tab'); loadLevelsForClass(selectedClass?.slug);">
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

        <!-- DELETE CLASS MODAL -->
        <div class="modal fade" id="deleteClassModal" tabindex="-1">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header bg-danger text-white">
                        <h5 class="modal-title"><i class="bi bi-exclamation-triangle me-2"></i>Delete Class</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="alert alert-danger">
                            <i class="bi bi-exclamation-triangle-fill me-2"></i>
                            <strong>Warning!</strong> This action cannot be undone. This will permanently delete the class, all its levels, quizzes, and student enrollments.
                        </div>
                        
                        <p class="mb-3">Please type <strong id="deleteClassName" class="text-danger"></strong> to confirm:</p>
                        
                        <asp:TextBox ID="txtDeleteConfirm" runat="server" 
                                     CssClass="form-control form-control-lg" 
                                     placeholder="Type class name here..." />
                        
                        <asp:Label ID="lblDeleteError" runat="server" 
                                   CssClass="text-danger mt-2 d-block" 
                                   Visible="false" />
                        
                        <asp:HiddenField ID="hfDeleteClassSlug" runat="server" />
                        <asp:HiddenField ID="hfDeleteClassName" runat="server" />
                    </div>
                    <div class="modal-footer bg-light">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                            <i class="bi bi-x-circle me-1"></i>Cancel
                        </button>
                        <asp:Button ID="btnConfirmDelete" runat="server" 
                                    Text="Delete Class" 
                                    CssClass="btn btn-danger btn-lg" 
                                    OnClick="btnConfirmDelete_Click" />
                    </div>
                </div>
            </div>
        </div>

        <!-- Hidden Fields -->
        <asp:HiddenField ID="hfSelectedClassSlug" runat="server" />
        <asp:HiddenField ID="hfClassesJson" runat="server" />
        <asp:HiddenField ID="hfLevelsJson" runat="server" />
        <asp:HiddenField ID="hfForumPostsJson" runat="server" />
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
                            
                            // Auto-switch to Story Mode tab if requested, otherwise ensure Forum tab is active
                            if (tabParam === 'storymode') {
                                setTimeout(() => {
                                    const storymodeTab = new bootstrap.Tab(document.getElementById('storymodeTabBtn'));
                                    storymodeTab.show();
                                    console.log('Auto-switched to Story Mode tab');
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
                        selectedClass = { slug: slug, name: name };
                    }
                } catch (e) {
                    selectedClass = { slug: slug, name: name };
                }
            } else {
                selectedClass = { slug: slug, name: name };
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

        function createNewClass() {
            window.location.href = '<%= ResolveUrl("~/Pages/teacher/teacher_create_module.aspx") %>';
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
            console.log('[LEVELS] Levels field value length:', levelsField?.value?.length);
            
            if (!levelsField || !levelsField.value) {
                console.warn('[LEVELS] No levels data in hidden field');
                showNoLevels();
                return;
            }

            try {
                const allLevels = JSON.parse(levelsField.value);
                console.log('[LEVELS] All levels parsed:', allLevels);
                console.log('[LEVELS] All levels count:', allLevels.length);
                const classLevels = allLevels.filter(l => {
                    console.log(`[LEVELS] Checking level: ${l.LevelSlug}, ClassSlug: ${l.ClassSlug} vs ${classSlug}`);
                    return l.ClassSlug === classSlug;
                });
                console.log('[LEVELS] Filtered levels for class:', classLevels);
                console.log('[LEVELS] Filtered levels count:', classLevels.length);
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
                            <div class="d-flex align-items-center">
                                <div class="level-badge me-3" 
                                     style="width: 60px; height: 60px; background: linear-gradient(135deg, #667eea, #764ba2); 
                                            color: white; border-radius: 1rem; display: flex; align-items: center; 
                                            justify-content: center; font-size: 1.5rem; font-weight: 700;">
                                    ${level.LevelNumber}
                                </div>
                                <div class="flex-grow-1">
                                    <h5 class="mb-1">${escapeHtml(level.Title)}</h5>
                                    <p class="text-muted mb-2 small">${escapeHtml(level.Description || 'No description')}</p>
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

        function editLevel(levelSlug) {
            if (!selectedClass) return;
            window.location.href = `edit_level.aspx?level=${levelSlug}&class=${selectedClass.slug}&className=${encodeURIComponent(selectedClass.name)}`;
        }

        function manageSlides(levelSlug, levelTitle) {
            if (!selectedClass) return;
            window.location.href = `manage_slides.aspx?level=${levelSlug}&class=${selectedClass.slug}&levelTitle=${encodeURIComponent(levelTitle)}`;
        }

        function editQuiz(levelSlug, quizSlug) {
            console.log('[Quiz] Editing quiz:', { levelSlug, quizSlug });
            
            if (!selectedClass) {
                alert('Please select a class first.');
                return;
            }
            
            if (!quizSlug || quizSlug === '') {
                alert('No quiz found for this level.\n\nPlease create a quiz first or check if the level has a quiz assigned.');
                console.error('[Quiz] Missing quiz slug for level:', levelSlug);
                return;
            }
            
            window.location.href = `edit_quiz.aspx?quiz=${quizSlug}&level=${levelSlug}&class=${selectedClass.slug}`;
        }

        function renderLevels(levels) {
            const container = document.getElementById('levelsContainer');
            const noLevels = document.getElementById('noLevels');
            
            console.log('[Story Mode] Rendering levels:', levels);
            
            if (levels.length === 0) {
                container.style.display = 'none';
                noLevels.style.display = 'block';
                return;
            }
            
            container.style.display = 'flex';
            noLevels.style.display = 'none';
            
            // Debug each level's quiz
            levels.forEach(level => {
                console.log(`[Level ${level.LevelNumber}] ${level.Title} - QuizSlug = ${level.QuizSlug || 'NONE'}`);
            });
            
            container.innerHTML = levels.map(level => `
                <div class="col-12">
                    <div class="card border-0 shadow-sm mb-3">
                        <div class="card-body">
                            <div class="d-flex align-items-center">
                                <div class="level-badge me-3" 
                                     style="width: 60px; height: 60px; background: linear-gradient(135deg, #667eea, #764ba2); 
                                            color: white; border-radius: 1rem; display: flex; align-items-center; 
                                            justify-content: center; font-size: 1.5rem; font-weight: 700;">
                                    ${level.LevelNumber}
                                </div>
                                <div class="flex-grow-1">
                                    <h5 class="mb-1">${escapeHtml(level.Title)}</h5>
                                    <p class="text-muted mb-2 small">${escapeHtml(level.Description || 'No description')}</p>
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

        function openCreateLevelStorymode() {
            if (!selectedClass) {
                alert('Please select a class first.');
                return;
            }
            
            // Get the class slug (handle both capital and lowercase property names)
            const classSlug = selectedClass.ClassSlug || selectedClass.slug;
            const className = selectedClass.ClassName || selectedClass.name;
            
            console.log('[CreateLevel] Redirecting with:', { classSlug, className });
            
            // Redirect to create_level page
            window.location.href = `create_level.aspx?class=${classSlug}&className=${encodeURIComponent(className)}`;
        }

        function openCreatePostModal() {
            if (!selectedClass) {
                alert('Please select a class first.');
                return;
            }
            
            // Get the class slug (handle both capital and lowercase property names)
            const classSlug = selectedClass.ClassSlug || selectedClass.slug;
            const className = selectedClass.ClassName || selectedClass.name;
            
            // Redirect to create post page
            window.location.href = `create_forum_post.aspx?class=${classSlug}&className=${encodeURIComponent(className)}`;
        }

        function openAddStudentsPage() {
            if (!selectedClass) {
                alert('Please select a class first.');
                return;
            }
            
            // Get the class slug (handle both capital and lowercase property names)
            const classSlug = selectedClass.ClassSlug || selectedClass.slug;
            
            // Redirect to add students page
            window.location.href = `add_students.aspx?class=${classSlug}`;
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
                                <i class="bi bi-reply me-1"></i>Reply to this post
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
            
            // Redirect to view post page
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

        // Delete class functions
        function openDeleteModal(classSlug, className) {
            console.log('Opening delete modal for:', classSlug, className);
            
            // Set the class name in the modal
            document.getElementById('deleteClassName').textContent = className;
            
            // Set hidden fields
            document.getElementById('<%= hfDeleteClassSlug.ClientID %>').value = classSlug;
            document.getElementById('<%= hfDeleteClassName.ClientID %>').value = className;
            
            // Clear the input
            document.getElementById('<%= txtDeleteConfirm.ClientID %>').value = '';
            
            // Show modal
            const modal = new bootstrap.Modal(document.getElementById('deleteClassModal'));
            modal.show();
        }

        function editLevel(levelSlug) {
            if (!selectedClass) {
                alert('Please select a class first.');
                return;
            }
            
            // Get the class slug (handle both capital and lowercase property names)
            const classSlug = selectedClass.ClassSlug || selectedClass.slug;
            const className = selectedClass.ClassName || selectedClass.name;
            
            window.location.href = `edit_level.aspx?level=${levelSlug}&class=${classSlug}&className=${encodeURIComponent(className)}`;
        }

        function manageSlides(levelSlug, levelTitle) {
            if (!selectedClass) {
                alert('Please select a class first.');
                return;
            }
            
            // Get the class slug (handle both capital and lowercase property names)
            const classSlug = selectedClass.ClassSlug || selectedClass.slug;
            
            window.location.href = `manage_slides.aspx?level=${levelSlug}&class=${classSlug}&levelTitle=${encodeURIComponent(levelTitle)}`;
        }

        function editQuiz(levelSlug, quizSlug) {
            console.log('[Quiz] Editing quiz:', { levelSlug, quizSlug });
            
            if (!selectedClass) {
                alert('Please select a class first.');
                return;
            }
            
            // Get the class slug (handle both capital and lowercase property names)
            const classSlug = selectedClass.ClassSlug || selectedClass.slug;
            
            if (quizSlug) {
                window.location.href = `edit_quiz.aspx?quiz=${quizSlug}&level=${levelSlug}&class=${classSlug}`;
            } else {
                alert('No quiz found for this level. Create quiz questions first.');
            }
        }
    </script>
</asp:Content>


// ================================================
// Class Detail Page - Logic
// ================================================

(function () {
    'use strict';

    // ===== State =====
    let classData = {};
    let levels = [];
    let students = [];
    let quizzes = [];

    // ===== Initialization =====
    document.addEventListener('DOMContentLoaded', function () {
        initPage();
    });

    function initPage() {
        loadData();
        renderClassHeader();
        renderLevels();
        renderStudents();
        renderQuizzes();
        renderResources();
    }

    // ===== Data Loading =====
    function loadData() {
        try {
            if (!window.CLASS_DATA) {
                console.error('CLASS_DATA not found');
                showError('Configuration error: CLASS_DATA not found');
                return;
            }

            const classDataField = document.getElementById(window.CLASS_DATA.classDataFieldId);
            const levelsField = document.getElementById(window.CLASS_DATA.levelsFieldId);
            const studentsField = document.getElementById(window.CLASS_DATA.studentsFieldId);
            const quizzesField = document.getElementById(window.CLASS_DATA.quizzesFieldId);

            console.log('Loading data from fields:', {
                classDataField: classDataField ? 'found' : 'missing',
                classDataValue: classDataField?.value ? 'has value' : 'empty',
                levelsField: levelsField ? 'found' : 'missing',
                studentsField: studentsField ? 'found' : 'missing',
                quizzesField: quizzesField ? 'found' : 'missing'
            });

            if (classDataField && classDataField.value) {
                classData = JSON.parse(classDataField.value);
            } else {
                console.warn('No class data found in hidden field');
            }

            if (levelsField && levelsField.value) {
                levels = JSON.parse(levelsField.value);
            }

            if (studentsField && studentsField.value) {
                students = JSON.parse(studentsField.value);
            }

            if (quizzesField && quizzesField.value) {
                quizzes = JSON.parse(quizzesField.value);
            }

            console.log('Loaded class data:', {
                classData,
                levelsCount: levels.length,
                studentsCount: students.length,
                quizzesCount: quizzes.length
            });
        } catch (error) {
            console.error('Error loading data:', error);
            showError('Error loading class data: ' + error.message);
        }
    }

    // ===== Class Header Rendering =====
    function renderClassHeader() {
        const nameEl = document.getElementById('className');
        const codeEl = document.getElementById('classCode');
        
        if (!classData.ClassName) {
            console.warn('No class name found, showing error state');
            if (nameEl) nameEl.textContent = 'Class Not Found';
            if (codeEl) codeEl.textContent = 'ERROR';
            return;
        }

        // Set header background color
        const header = document.getElementById('classHeader');
        if (header && classData.Color) {
            const colorDark = darkenColor(classData.Color, 20);
            header.style.setProperty('--class-color', classData.Color);
            header.style.setProperty('--class-color-dark', colorDark);
        }

        // Set icon
        const iconLarge = document.getElementById('classIconLarge');
        if (iconLarge && classData.Icon) {
            iconLarge.innerHTML = `<i class="${classData.Icon}"></i>`;
        }

        // Set name
        if (nameEl) nameEl.textContent = classData.ClassName;

        // Set code
        if (codeEl) codeEl.textContent = classData.ClassCode;

        // Set counts
        const levelCountEl = document.getElementById('levelCount');
        if (levelCountEl) levelCountEl.textContent = levels.length;

        const studentCountEl = document.getElementById('studentCount');
        if (studentCountEl) studentCountEl.textContent = students.length;
    }

    // ===== Levels Rendering =====
    function renderLevels() {
        const container = document.getElementById('levelsContainer');
        const noLevels = document.getElementById('noLevels');

        if (!container) return;

        if (levels.length === 0) {
            container.style.display = 'none';
            if (noLevels) noLevels.style.display = 'block';
            return;
        }

        container.style.display = 'flex';
        if (noLevels) noLevels.style.display = 'none';

        container.innerHTML = '';

        // Sort by level number
        levels.sort((a, b) => a.LevelNumber - b.LevelNumber);

        levels.forEach(function (level) {
            const item = createLevelItem(level);
            container.appendChild(item);
        });
    }

    function createLevelItem(level) {
        const col = document.createElement('div');
        col.className = 'col-12';

        const contentTypeIcon = getContentTypeIcon(level.ContentType);
        const statusBadge = level.IsPublished 
            ? '<span class="badge bg-success position-absolute top-0 end-0 m-3"><i class="bi bi-check-circle me-1"></i>Published</span>'
            : '<span class="badge bg-warning text-dark position-absolute top-0 end-0 m-3"><i class="bi bi-clock me-1"></i>Draft</span>';

        // Find quiz for this level
        const levelQuiz = quizzes.find(q => q.LevelSlug === level.LevelSlug);
        const quizSection = levelQuiz ? `
            <div class="alert alert-warning border-warning mt-3 mb-0">
                <div class="d-flex align-items-center justify-content-between">
                    <div class="flex-grow-1">
                        <h6 class="mb-1"><i class="bi bi-question-circle-fill me-2"></i>${escapeHtml(levelQuiz.Title)}</h6>
                        <small class="text-muted">
                            <i class="bi bi-${levelQuiz.Mode === 'battle' ? 'lightning' : 'book'}"></i> ${levelQuiz.Mode === 'battle' ? 'Battle' : 'Story'} Mode • 
                            <i class="bi bi-clock"></i> ${levelQuiz.TimeLimit} min • 
                            <i class="bi bi-bullseye"></i> ${levelQuiz.PassingScore}% to pass • 
                            <i class="bi bi-card-list"></i> ${levelQuiz.QuestionCount} questions
                        </small>
                    </div>
                    <div class="btn-group btn-group-sm">
                        <button type="button" class="btn btn-outline-warning" onclick="editQuiz('${levelQuiz.QuizSlug}')" title="Edit Quiz">
                            <i class="bi bi-pencil"></i> Edit Quiz
                        </button>
                    </div>
                </div>
            </div>
        ` : `
            <div class="alert alert-danger border-danger mt-3 mb-0">
                <i class="bi bi-exclamation-triangle me-2"></i>No quiz assigned to this level!
                <button type="button" class="btn btn-sm btn-danger ms-2" onclick="createQuizForLevel('${level.LevelSlug}', ${level.LevelNumber}, '${escapeHtml(level.Title)}')">
                    <i class="bi bi-plus-circle me-1"></i>Create Quiz
                </button>
            </div>
        `;

        col.innerHTML = `
            <div class="card level-card border-0 shadow-sm mb-3 position-relative">
                ${statusBadge}
                <div class="card-body">
                    <div class="row align-items-start g-3">
                        <div class="col-auto">
                            <div class="level-number-badge">${level.LevelNumber}</div>
                        </div>
                        <div class="col">
                            <h5 class="card-title mb-2 fw-bold">${escapeHtml(level.Title)}</h5>
                            <p class="card-text text-muted small mb-2">
                                ${escapeHtml(level.Description) || 'No description'}
                            </p>
                            <div class="d-flex flex-wrap gap-3 mb-3">
                                <span class="badge bg-light text-dark">
                                    <i class="bi bi-clock text-info me-1"></i>${level.EstimatedMinutes} min
                                </span>
                                <span class="badge bg-light text-dark">
                                    <i class="bi bi-star-fill text-warning me-1"></i>${level.XpReward} XP
                                </span>
                                ${level.ContentType ? `<span class="badge bg-light text-dark">
                                    <i class="${contentTypeIcon} me-1"></i>${level.ContentType}
                                </span>` : ''}
                                ${level.SlideCount > 0 ? `<span class="badge bg-light text-dark">
                                    <i class="bi bi-file-slides text-primary me-1"></i>${level.SlideCount} slides
                                </span>` : ''}
                            </div>
                            ${quizSection}
                        </div>
                        <div class="col-auto">
                            <div class="btn-group-vertical" role="group">
                                <button type="button" class="btn btn-outline-primary btn-sm" onclick="viewLevel('${level.LevelSlug}')" title="View Content">
                                    <i class="bi bi-eye me-1"></i> View
                                </button>
                                <button type="button" class="btn btn-outline-secondary btn-sm" onclick="editLevel('${level.LevelSlug}')" title="Edit Level">
                                    <i class="bi bi-pencil me-1"></i> Edit
                                </button>
                                <button type="button" class="btn btn-outline-info btn-sm" onclick="manageSlides('${level.LevelSlug}')" title="Manage Slides">
                                    <i class="bi bi-file-slides me-1"></i> Slides
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        `;

        return col;
    }

    // ===== Students Rendering =====
    function renderStudents() {
        const container = document.getElementById('studentsContainer');
        if (!container) return;

        if (students.length === 0) {
            container.innerHTML = `
                <div class="text-center py-5">
                    <i class="bi bi-people display-1 text-muted opacity-25"></i>
                    <h4 class="mt-3 mb-2">No Students Enrolled Yet</h4>
                    <p class="text-muted mb-3">Share the class code for students to join</p>
                    <div class="alert alert-info d-inline-block">
                        <strong>Class Code:</strong> <code class="fs-5">${classData.ClassCode || 'N/A'}</code>
                    </div>
                </div>
            `;
            return;
        }

        let html = '<table class="table table-hover align-middle mb-0">';
        html += '<thead class="table-light"><tr>';
        html += '<th class="fw-bold">Student</th>';
        html += '<th class="fw-bold">Email</th>';
        html += '<th class="fw-bold">Joined</th>';
        html += '<th class="fw-bold text-center">Attempts</th>';
        html += '<th class="fw-bold text-center">Avg Score</th>';
        html += '<th class="fw-bold text-end">Actions</th>';
        html += '</tr></thead><tbody>';

        students.forEach(function (student) {
            const joinedDate = new Date(student.JoinedAt).toLocaleDateString();
            const initial = student.DisplayName.charAt(0).toUpperCase();

            html += '<tr>';
            html += `<td>
                        <div class="d-flex align-items-center">
                            <div class="bg-primary text-white rounded-circle d-flex align-items-center justify-content-center me-3" 
                                 style="width: 40px; height: 40px; font-weight: 700;">
                                ${initial}
                            </div>
                            <div>
                                <div class="fw-semibold">${escapeHtml(student.DisplayName)}</div>
                                <small class="text-muted">${student.UserSlug}</small>
                            </div>
                        </div>
                     </td>`;
            html += `<td class="text-muted">${escapeHtml(student.Email)}</td>`;
            html += `<td><span class="badge bg-light text-dark"><i class="bi bi-calendar3 me-1"></i>${joinedDate}</span></td>`;
            html += `<td class="text-center"><span class="badge bg-info">${student.Attempts || 0}</span></td>`;
            html += `<td class="text-center"><span class="badge ${(student.AvgScore || 0) >= 70 ? 'bg-success' : 'bg-warning'} fs-6">${student.AvgScore > 0 ? student.AvgScore + '%' : 'N/A'}</span></td>`;
            html += `<td class="text-end">
                        <button class="btn btn-sm btn-outline-primary" onclick="viewStudentProgress('${student.UserSlug}')" title="View Progress">
                            <i class="bi bi-graph-up"></i>
                        </button>
                     </td>`;
            html += '</tr>';
        });

        html += '</tbody></table>';
        container.innerHTML = html;
    }

    // ===== Quizzes Rendering =====
    function renderQuizzes() {
        const container = document.getElementById('quizzesContainer');
        const noQuizzes = document.getElementById('noQuizzes');
        
        if (!container) return;

        if (quizzes.length === 0) {
            container.style.display = 'none';
            if (noQuizzes) noQuizzes.style.display = 'block';
            return;
        }

        container.style.display = 'block';
        if (noQuizzes) noQuizzes.style.display = 'none';

        let html = '';

        quizzes.forEach(function (quiz) {
            const statusClass = quiz.Published ? 'success' : 'warning';
            const statusText = quiz.Published ? 'Published' : 'Draft';
            const modeIcon = quiz.Mode === 'battle' ? 'bi-lightning-fill' : 'bi-book-fill';
            const modeText = quiz.Mode === 'battle' ? 'Battle' : 'Story';

            html += `
                <div class="col-md-6 col-lg-4">
                    <div class="quiz-card">
                        <div class="d-flex justify-content-between align-items-start mb-3">
                            <h5 class="quiz-title mb-0">${escapeHtml(quiz.Title)}</h5>
                            <span class="badge bg-${statusClass}">${statusText}</span>
                        </div>
                        <div class="quiz-meta mb-3">
                            <span><i class="bi bi-clock"></i> ${quiz.TimeLimit} min</span>
                            <span><i class="bi bi-bullseye"></i> ${quiz.PassingScore}%</span>
                            <span><i class="${modeIcon}"></i> ${modeText}</span>
                        </div>
                        <div class="quiz-stats">
                            <div class="quiz-stat">
                                <div class="quiz-stat-value">${quiz.QuestionCount}</div>
                                <div class="quiz-stat-label">Questions</div>
                            </div>
                            <div class="quiz-stat">
                                <div class="quiz-stat-value">${quiz.AttemptCount}</div>
                                <div class="quiz-stat-label">Attempts</div>
                            </div>
                        </div>
                        <div class="mt-3 d-flex gap-2">
                            <button class="btn btn-primary btn-sm flex-fill" onclick="editQuiz('${quiz.QuizSlug}')">
                                <i class="bi bi-pencil me-1"></i>Edit
                            </button>
                            <button class="btn btn-outline-secondary btn-sm" onclick="previewQuiz('${quiz.QuizSlug}')">
                                <i class="bi bi-eye"></i>
                            </button>
                        </div>
                    </div>
                </div>
            `;
        });

        container.innerHTML = html;
    }

    // ===== Resources Rendering =====
    function renderResources() {
        const container = document.getElementById('resourcesContainer');
        const noResources = document.getElementById('noResources');
        
        if (!container || !noResources) return;

        // For now, always show empty state since we don't have a Resources table yet
        container.style.display = 'none';
        noResources.style.display = 'block';
        
        // TODO: Implement resources loading when Resources table is created
        // This would query a Resources table and display downloadable files
    }

    // ===== Modal Functions =====
    // Note: openCreateLevelModal is defined in the ASPX page to use Bootstrap Modal API
    // Only closeCreateLevelModal needs to be defined here
    
    window.closeCreateLevelModal = function () {
        const modalElement = document.getElementById('createLevelModal');
        if (modalElement) {
            const modal = bootstrap.Modal.getInstance(modalElement);
            if (modal) {
                modal.hide();
            } else {
                // Fallback if Bootstrap modal not initialized
                modalElement.style.display = 'none';
                modalElement.classList.remove('show');
                document.body.classList.remove('modal-open');
                const backdrop = document.querySelector('.modal-backdrop');
                if (backdrop) backdrop.remove();
            }
        }
    };

    window.openCreateQuizModal = function () {
        const modalElement = document.getElementById('createQuizModal');
        if (modalElement) {
            const modal = new bootstrap.Modal(modalElement);
            modal.show();
        }
    };

    window.closeCreateQuizModal = function () {
        const modalElement = document.getElementById('createQuizModal');
        if (modalElement) {
            const modal = bootstrap.Modal.getInstance(modalElement);
            if (modal) {
                modal.hide();
            } else {
                // Fallback if Bootstrap modal not initialized
                modalElement.style.display = 'none';
                modalElement.classList.remove('show');
                document.body.classList.remove('modal-open');
                const backdrop = document.querySelector('.modal-backdrop');
                if (backdrop) backdrop.remove();
            }
        }
    };

    window.showSuccessToast = function (message) {
        const toast = document.createElement('div');
        toast.className = 'toast-notification';
        toast.innerHTML = `<i class="bi bi-check-circle me-2"></i>${message}`;
        document.body.appendChild(toast);

        setTimeout(() => toast.remove(), 3000);
    };

    // ===== Action Functions =====
    window.viewLevel = function (levelSlug) {
        // TODO: Create view_level.aspx page to preview level content
        alert('View Level Feature\n\n' +
              'This will show the level content as students see it.\n' +
              'Level: ' + levelSlug + '\n\n' +
              'Feature coming soon!');
    };

    window.editLevel = function (levelSlug) {
        // TODO: Create edit level functionality
        alert('Edit Level Feature\n\n' +
              'This will allow you to edit the level details.\n' +
              'Level: ' + levelSlug + '\n\n' +
              'Feature coming soon!');
    };

    window.addQuizToLevel = function (levelSlug) {
        window.openCreateQuizModal();
        // Pre-select the level in dropdown
        const dropdown = document.querySelector('select[id*="ddlLevelForQuiz"]');
        if (dropdown) {
            dropdown.value = levelSlug;
        }
    };
    
    window.createQuizForLevel = function (levelSlug, levelNumber, levelTitle) {
        window.openCreateQuizModal();
        // Pre-select the level and auto-fill quiz title
        const dropdown = document.querySelector('select[id*="ddlLevelForQuiz"]');
        const titleInput = document.querySelector('input[id*="txtQuizTitle"]');
        
        if (dropdown) {
            dropdown.value = levelSlug;
        }
        if (titleInput) {
            titleInput.value = `${levelTitle} Quiz`;
        }
    };
    
    // ===== Slide Management =====
    let currentLevelSlug = null;
    let currentLevelTitle = null;
    let currentSlides = [];
    let editingSlideNumber = null;
    
    window.manageSlides = function (levelSlug) {
        // Find the level
        const level = levels.find(l => l.LevelSlug === levelSlug);
        if (!level) {
            alert('Level not found!');
            return;
        }
        
        currentLevelSlug = levelSlug;
        currentLevelTitle = level.Title;
        
        // Set level title in modal
        const titleSpan = document.getElementById('slideModalLevelTitle');
        if (titleSpan) titleSpan.textContent = level.Title;
        
        // Set hidden field
        const levelSlugField = document.getElementById(window.CLASS_DATA.currentLevelSlugFieldId);
        if (levelSlugField) levelSlugField.value = levelSlug;
        
        // Load slides for this level (loads from server)
        loadSlidesForLevel(levelSlug);
        
        // Initialize slide number to 1 (or next number if slides exist)
        const slideNumInput = document.querySelector('input[id*="txtSlideNumber"]');
        if (slideNumInput) {
            slideNumInput.value = currentSlides.length + 1;
        }
        
        // Open modal
        const modalElement = document.getElementById('manageSlidesModal');
        if (modalElement) {
            const modal = new bootstrap.Modal(modalElement);
            modal.show();
            console.log('Slides modal opened for level:', level.Title, 'Slides:', currentSlides.length);
        }
    };
    
    function loadSlidesForLevel(levelSlug) {
        // Load slides from hidden field (populated by server)
        try {
            const slidesField = document.getElementById(window.CLASS_DATA.slidesFieldId);
            if (slidesField && slidesField.value) {
                const allSlides = JSON.parse(slidesField.value);
                currentSlides = allSlides.map(s => ({
                    number: s.SlideNumber,
                    slug: s.SlideSlug,
                    contentType: s.ContentType,
                    content: s.ContentText,
                    mediaUrl: s.MediaUrl
                }));
            } else {
                currentSlides = [];
            }
        } catch (error) {
            console.error('Error loading slides:', error);
            currentSlides = [];
        }
        
        renderSlidesList();
        clearSlideForm();
    }
    
    function renderSlidesList() {
        const container = document.getElementById('slidesList');
        const countBadge = document.getElementById('slideCount');
        
        if (!container) return;
        
        if (countBadge) countBadge.textContent = currentSlides.length;
        
        if (currentSlides.length === 0) {
            container.innerHTML = '<p class="text-muted text-center py-5">No slides yet. Add your first slide!</p>';
            return;
        }
        
        container.innerHTML = currentSlides.map((slide, index) => `
            <div class="card mb-2 slide-item ${editingSlideNumber === slide.number ? 'border-info' : ''}" 
                 onclick="editSlide(${slide.number})">
                <div class="card-body p-3">
                    <div class="d-flex align-items-center justify-content-between">
                        <div class="flex-grow-1">
                            <h6 class="mb-1">
                                <span class="badge bg-info me-2">${slide.number}</span>
                                ${slide.contentType === 'text' ? '<i class="bi bi-text-paragraph"></i>' : 
                                  slide.contentType === 'image' ? '<i class="bi bi-image"></i>' : 
                                  slide.contentType === 'video' ? '<i class="bi bi-camera-video"></i>' : 
                                  '<i class="bi bi-code-square"></i>'}
                                <span class="text-capitalize">${slide.contentType}</span>
                            </h6>
                            <small class="text-muted text-truncate d-block" style="max-width: 300px;">
                                ${escapeHtml(slide.content?.substring(0, 50) || slide.mediaUrl || 'No content')}...
                            </small>
                        </div>
                        <div class="btn-group btn-group-sm">
                            <button type="button" class="btn btn-outline-danger" onclick="event.stopPropagation(); deleteSlide(${slide.number})">
                                <i class="bi bi-trash"></i>
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        `).join('');
    }
    
    window.addNewSlide = function() {
        editingSlideNumber = null;
        clearSlideForm();
        
        // Set next slide number
        const slideNumInput = document.querySelector('input[id*="txtSlideNumber"]');
        if (slideNumInput) {
            slideNumInput.value = currentSlides.length + 1;
        }
    };
    
    window.editSlide = function(slideNumber) {
        const slide = currentSlides.find(s => s.number === slideNumber);
        if (!slide) return;
        
        editingSlideNumber = slideNumber;
        
        // Populate form
        const slideNumInput = document.querySelector('input[id*="txtSlideNumber"]');
        const contentTypeSelect = document.querySelector('select[id*="ddlSlideContentType"]');
        const contentTextarea = document.querySelector('textarea[id*="txtSlideContent"]');
        const mediaUrlInput = document.querySelector('input[id*="txtMediaUrl"]');
        
        if (slideNumInput) slideNumInput.value = slide.number;
        if (contentTypeSelect) contentTypeSelect.value = slide.contentType;
        if (contentTextarea) contentTextarea.value = slide.content || '';
        if (mediaUrlInput) mediaUrlInput.value = slide.mediaUrl || '';
        
        toggleSlideContentFields();
        renderSlidesList();
    };
    
    window.deleteSlide = function(slideNumber) {
        if (!confirm(`Delete slide ${slideNumber}?`)) return;
        
        currentSlides = currentSlides.filter(s => s.number !== slideNumber);
        
        // Renumber slides
        currentSlides.forEach((slide, index) => {
            slide.number = index + 1;
        });
        
        renderSlidesList();
        clearSlideForm();
    };
    
    window.cancelSlideEdit = function() {
        editingSlideNumber = null;
        clearSlideForm();
        renderSlidesList();
    };
    
    function clearSlideForm() {
        const slideNumInput = document.querySelector('input[id*="txtSlideNumber"]');
        const contentTypeSelect = document.querySelector('select[id*="ddlSlideContentType"]');
        const contentTextarea = document.querySelector('textarea[id*="txtSlideContent"]');
        const mediaUrlInput = document.querySelector('input[id*="txtMediaUrl"]');
        
        if (slideNumInput) slideNumInput.value = currentSlides.length + 1;
        if (contentTypeSelect) contentTypeSelect.value = 'text';
        if (contentTextarea) contentTextarea.value = '';
        if (mediaUrlInput) mediaUrlInput.value = '';
        
        toggleSlideContentFields();
    }
    
    window.toggleSlideContentFields = function() {
        const contentType = document.querySelector('select[id*="ddlSlideContentType"]')?.value;
        const divText = document.getElementById('divTextContent');
        const divMedia = document.getElementById('divMediaUrl');
        
        if (divText) divText.style.display = (contentType === 'text' || contentType === 'html') ? 'block' : 'none';
        if (divMedia) divMedia.style.display = (contentType === 'image' || contentType === 'video') ? 'block' : 'none';
    };

    window.editQuiz = function (quizSlug) {
        window.location.href = 'add_questions.aspx?quiz=' + quizSlug;
    };

    window.previewQuiz = function (quizSlug) {
        // TODO: Create quiz_preview.aspx page
        alert('Quiz Preview Feature\n\n' +
              'This will show the quiz as students see it.\n' +
              'Quiz: ' + quizSlug + '\n\n' +
              'Feature coming soon!');
    };

    window.viewStudentProgress = function (userSlug) {
        // TODO: Create student progress page
        alert('Student Progress Feature\n\n' +
              'This will show detailed progress for:\n' +
              userSlug + '\n\n' +
              'Feature coming soon!');
    };

    // ===== Helper Functions =====
    function getContentTypeIcon(contentType) {
        switch (contentType) {
            case 'powerpoint': return 'bi-file-earmark-ppt';
            case 'pdf': return 'bi-file-earmark-pdf';
            case 'video': return 'bi-camera-video';
            case 'html': return 'bi-file-code';
            default: return 'bi-file-earmark';
        }
    }

    function darkenColor(color, percent) {
        const num = parseInt(color.replace('#', ''), 16);
        const amt = Math.round(2.55 * percent);
        const R = (num >> 16) - amt;
        const G = ((num >> 8) & 0x00FF) - amt;
        const B = (num & 0x0000FF) - amt;
        return '#' + (
            0x1000000 +
            (R < 255 ? (R < 1 ? 0 : R) : 255) * 0x10000 +
            (G < 255 ? (G < 1 ? 0 : G) : 255) * 0x100 +
            (B < 255 ? (B < 1 ? 0 : B) : 255)
        ).toString(16).slice(1);
    }

    function escapeHtml(text) {
        if (!text) return '';
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    function showError(message) {
        const nameEl = document.getElementById('className');
        if (nameEl) {
            nameEl.textContent = 'Error Loading Class';
            nameEl.style.color = '#dc3545';
        }
        
        const codeEl = document.getElementById('classCode');
        if (codeEl) {
            codeEl.textContent = message;
        }
        
        console.error('Page Error:', message);
    }

    // Close modals on ESC
    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') {
            window.closeCreateLevelModal();
            window.closeCreateQuizModal();
        }
    });

})();


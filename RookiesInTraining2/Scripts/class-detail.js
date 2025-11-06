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

        col.innerHTML = `
            <div class="card level-card border-0 shadow-sm mb-3 position-relative">
                ${statusBadge}
                <div class="card-body">
                    <div class="row align-items-center g-3">
                        <div class="col-auto">
                            <div class="level-number-badge">${level.LevelNumber}</div>
                        </div>
                        <div class="col">
                            <h5 class="card-title mb-2 fw-bold">${escapeHtml(level.Title)}</h5>
                            <p class="card-text text-muted small mb-2">
                                ${escapeHtml(level.Description) || 'No description'}
                            </p>
                            <div class="d-flex flex-wrap gap-3">
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
                                <span class="badge bg-light text-dark">
                                    <i class="bi bi-question-circle text-success me-1"></i>${level.QuizCount} quiz(zes)
                                </span>
                            </div>
                        </div>
                        <div class="col-auto">
                            <div class="btn-group" role="group">
                                <button type="button" class="btn btn-outline-primary" onclick="viewLevel('${level.LevelSlug}')" title="View">
                                    <i class="bi bi-eye"></i>
                                </button>
                                <button type="button" class="btn btn-outline-secondary" onclick="editLevel('${level.LevelSlug}')" title="Edit">
                                    <i class="bi bi-pencil"></i>
                                </button>
                                <button type="button" class="btn btn-outline-success" onclick="addQuizToLevel('${level.LevelSlug}')" title="Add Quiz">
                                    <i class="bi bi-plus-circle"></i>
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
        if (!container) return;

        if (quizzes.length === 0) {
            container.innerHTML = `
                <div class="empty-state">
                    <i class="bi bi-question-circle display-4 text-muted"></i>
                    <h4>No Quizzes Created Yet</h4>
                    <p class="text-muted">Create quizzes for your levels</p>
                    <button class="btn btn-primary" onclick="openCreateQuizModal()">
                        <i class="bi bi-plus-circle me-2"></i>Create First Quiz
                    </button>
                </div>
            `;
            return;
        }

        let html = '<div class="quizzes-grid">';

        quizzes.forEach(function (quiz) {
            const statusClass = quiz.Published ? 'success' : 'warning';
            const statusText = quiz.Published ? 'Published' : 'Draft';

            html += `
                <div class="quiz-card">
                    <div class="d-flex justify-content-between align-items-start mb-2">
                        <h5 class="quiz-title">${escapeHtml(quiz.Title)}</h5>
                        <span class="badge bg-${statusClass}">${statusText}</span>
                    </div>
                    <div class="quiz-meta">
                        <span><i class="bi bi-clock"></i> ${quiz.TimeLimit} min</span>
                        <span><i class="bi bi-bullseye"></i> ${quiz.PassingScore}% to pass</span>
                        <span><i class="bi bi-controller"></i> ${quiz.Mode}</span>
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
            `;
        });

        html += '</div>';
        container.innerHTML = html;
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
        window.location.href = 'view_level.aspx?slug=' + levelSlug;
    };

    window.editLevel = function (levelSlug) {
        alert('Edit level: ' + levelSlug + '\n\nThis would open the level editor.');
    };

    window.addQuizToLevel = function (levelSlug) {
        window.openCreateQuizModal();
        // Pre-select the level in dropdown
        const dropdown = document.querySelector('select[id*="ddlLevelForQuiz"]');
        if (dropdown) {
            dropdown.value = levelSlug;
        }
    };

    window.editQuiz = function (quizSlug) {
        window.location.href = 'teacher/add_questions.aspx?quiz=' + quizSlug;
    };

    window.previewQuiz = function (quizSlug) {
        window.open('quiz_preview.aspx?quiz=' + quizSlug, '_blank');
    };

    window.viewStudentProgress = function (userSlug) {
        alert('View progress for: ' + userSlug + '\n\nThis would show detailed student progress.');
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


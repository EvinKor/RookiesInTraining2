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
                return;
            }

            const classDataField = document.getElementById(window.CLASS_DATA.classDataFieldId);
            const levelsField = document.getElementById(window.CLASS_DATA.levelsFieldId);
            const studentsField = document.getElementById(window.CLASS_DATA.studentsFieldId);
            const quizzesField = document.getElementById(window.CLASS_DATA.quizzesFieldId);

            if (classDataField && classDataField.value) {
                classData = JSON.parse(classDataField.value);
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
        }
    }

    // ===== Class Header Rendering =====
    function renderClassHeader() {
        if (!classData.ClassName) return;

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
        const nameEl = document.getElementById('className');
        if (nameEl) nameEl.textContent = classData.ClassName;

        // Set code
        const codeEl = document.getElementById('classCode');
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
        const div = document.createElement('div');
        div.className = 'level-item position-relative';

        const contentTypeIcon = getContentTypeIcon(level.ContentType);
        const statusBadge = level.IsPublished 
            ? '<span class="level-status-badge published">Published</span>'
            : '<span class="level-status-badge draft">Draft</span>';

        div.innerHTML = `
            ${statusBadge}
            <div class="level-number-badge">${level.LevelNumber}</div>
            <div class="level-content">
                <h4 class="level-title">${escapeHtml(level.Title)}</h4>
                <p class="text-muted mb-2">${escapeHtml(level.Description) || 'No description'}</p>
                <div class="level-meta">
                    <span><i class="bi bi-clock"></i> ${level.EstimatedMinutes} min</span>
                    <span><i class="bi bi-star-fill"></i> ${level.XpReward} XP</span>
                    ${level.ContentType ? `<span><i class="${contentTypeIcon}"></i> ${level.ContentType}</span>` : ''}
                    ${level.SlideCount > 0 ? `<span><i class="bi bi-file-slides"></i> ${level.SlideCount} slides</span>` : ''}
                    <span><i class="bi bi-question-circle"></i> ${level.QuizCount} quiz(es)</span>
                </div>
            </div>
            <div class="level-actions">
                <button class="btn btn-outline-primary btn-sm" onclick="viewLevel('${level.LevelSlug}')">
                    <i class="bi bi-eye"></i>
                </button>
                <button class="btn btn-outline-secondary btn-sm" onclick="editLevel('${level.LevelSlug}')">
                    <i class="bi bi-pencil"></i>
                </button>
                <button class="btn btn-outline-success btn-sm" onclick="addQuizToLevel('${level.LevelSlug}')">
                    <i class="bi bi-plus-circle"></i> Quiz
                </button>
            </div>
        `;

        return div;
    }

    // ===== Students Rendering =====
    function renderStudents() {
        const container = document.getElementById('studentsContainer');
        if (!container) return;

        if (students.length === 0) {
            container.innerHTML = `
                <div class="empty-state">
                    <i class="bi bi-people display-4 text-muted"></i>
                    <h4>No Students Enrolled Yet</h4>
                    <p class="text-muted">Share the class code with students to let them join</p>
                </div>
            `;
            return;
        }

        let html = '<div class="students-table"><table><thead><tr>';
        html += '<th>Student</th>';
        html += '<th>Email</th>';
        html += '<th>Joined</th>';
        html += '<th>Attempts</th>';
        html += '<th>Avg Score</th>';
        html += '<th>Actions</th>';
        html += '</tr></thead><tbody>';

        students.forEach(function (student) {
            const joinedDate = new Date(student.JoinedAt).toLocaleDateString();
            const initial = student.DisplayName.charAt(0).toUpperCase();

            html += '<tr>';
            html += `<td><div class="d-flex align-items-center">
                        <div class="student-avatar">${initial}</div>
                        <strong>${escapeHtml(student.DisplayName)}</strong>
                    </div></td>`;
            html += `<td>${escapeHtml(student.Email)}</td>`;
            html += `<td>${joinedDate}</td>`;
            html += `<td>${student.Attempts}</td>`;
            html += `<td>${student.AvgScore > 0 ? student.AvgScore + '%' : 'N/A'}</td>`;
            html += `<td><button class="btn btn-sm btn-outline-primary" onclick="viewStudentProgress('${student.UserSlug}')">
                        <i class="bi bi-graph-up"></i>
                    </button></td>`;
            html += '</tr>';
        });

        html += '</tbody></table></div>';
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
    window.openCreateLevelModal = function () {
        const modal = document.getElementById('createLevelModal');
        if (modal) modal.style.display = 'flex';
    };

    window.closeCreateLevelModal = function () {
        const modal = document.getElementById('createLevelModal');
        if (modal) modal.style.display = 'none';
    };

    window.openCreateQuizModal = function () {
        const modal = document.getElementById('createQuizModal');
        if (modal) modal.style.display = 'flex';
    };

    window.closeCreateQuizModal = function () {
        const modal = document.getElementById('createQuizModal');
        if (modal) modal.style.display = 'none';
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
        window.location.href = 'add_questions.aspx?quiz=' + quizSlug;
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

    // Close modals on ESC
    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') {
            window.closeCreateLevelModal();
            window.closeCreateQuizModal();
        }
    });

})();


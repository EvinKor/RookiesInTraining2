// ================================================
// Student Dashboard - Modular Learning (Duolingo Style)
// ================================================

(function () {
    'use strict';

    // ===== State =====
    let modules = [];
    let quizzes = [];
    let badges = [];
    let summary = {};
    let currentModuleId = null;
    let userSlug = '';

    // ===== Constants =====
    const STORAGE_KEY_PREFIX = 'rookies_lastQuiz_';

    // ===== Initialization =====
    document.addEventListener('DOMContentLoaded', function () {
        initDashboard();
    });

    function initDashboard() {
        // Load data from hidden fields
        loadData();

        // Debug logging
        console.log('Dashboard initialized with:', {
            modulesCount: modules.length,
            quizzesCount: quizzes.length,
            summary: summary
        });

        // Render UI
        renderSummary();
        renderBadges();
        
        if (modules.length === 0) {
            console.warn('[StudentDashboard] No classes found, showing empty state');
            showEmptyState();
        } else {
            console.log('[StudentDashboard] Rendering', modules.length, 'classes');
            renderClassesGrid();
        }

        // Setup event listeners
        setupGlobalContinueButton();
        setupBackToModules();
        setupKeyboardNavigation();
    }

    // ===== Data Loading =====
    function loadData() {
        try {
            console.log('[StudentDashboard] Loading data...');
            
            if (!window.DASHBOARD_DATA) {
                console.error('[StudentDashboard] ❌ DASHBOARD_DATA not found on window object');
                return;
            }
            
            console.log('[StudentDashboard] DASHBOARD_DATA:', window.DASHBOARD_DATA);

            const modulesField = document.getElementById(window.DASHBOARD_DATA.modulesFieldId);
            const quizzesField = document.getElementById(window.DASHBOARD_DATA.quizzesFieldId);
            const summaryField = document.getElementById(window.DASHBOARD_DATA.summaryFieldId);
            const badgesField = document.getElementById(window.DASHBOARD_DATA.badgesFieldId);

            console.log('[StudentDashboard] Hidden fields:', {
                modulesField: modulesField?.id,
                modulesValue: modulesField?.value?.substring(0, 100),
                quizzesField: quizzesField?.id,
                summaryField: summaryField?.id,
                badgesField: badgesField?.id
            });

            if (modulesField && modulesField.value) {
                modules = JSON.parse(modulesField.value);
                console.log('[StudentDashboard] ✅ Modules loaded:', modules.length);
                console.log('[StudentDashboard] Modules data:', modules);
            } else {
                console.warn('[StudentDashboard] ⚠️ No modules data found');
            }

            if (quizzesField && quizzesField.value) {
                quizzes = JSON.parse(quizzesField.value);
                console.log('[StudentDashboard] Quizzes loaded:', quizzes.length);
            }

            if (summaryField && summaryField.value) {
                summary = JSON.parse(summaryField.value);
                console.log('[StudentDashboard] Summary loaded:', summary);
            }

            if (badgesField && badgesField.value) {
                badges = JSON.parse(badgesField.value);
                console.log('[StudentDashboard] Badges loaded:', badges.length);
            }

            userSlug = summary.StudentName || 'default';
        } catch (error) {
            console.error('[StudentDashboard] ❌ Error loading dashboard data:', error);
        }
    }

    // ===== Summary Rendering =====
    function renderSummary() {
        const nameEl = document.getElementById('studentName');
        if (nameEl) nameEl.textContent = summary.StudentName || 'Student';

        const xpEl = document.getElementById('totalXP');
        if (xpEl) xpEl.textContent = (summary.Xp || 0).toLocaleString();

        const streakEl = document.getElementById('streak');
        if (streakEl) streakEl.textContent = summary.Streak || 0;

        const completedEl = document.getElementById('completedCount');
        const totalEl = document.getElementById('totalCount');
        if (completedEl && totalEl) {
            completedEl.textContent = summary.Completed || 0;
            totalEl.textContent = summary.Total || quizzes.length;
        }

        const progressPct = summary.Total > 0
            ? Math.round((summary.Completed / summary.Total) * 100)
            : 0;

        const progressPctEl = document.getElementById('progressPct');
        if (progressPctEl) progressPctEl.textContent = progressPct;

        const progressBar = document.getElementById('overallProgress');
        if (progressBar) progressBar.style.width = progressPct + '%';
    }

    // ===== Classes Grid Rendering =====
    function renderClassesGrid() {
        const grid = document.getElementById('classesGrid');
        const noClasses = document.getElementById('noClasses');
        
        if (!grid) {
            console.error('[StudentDashboard] ❌ classesGrid element not found');
            return;
        }

        console.log('[StudentDashboard] Rendering classes grid with', modules.length, 'classes');

        if (modules.length === 0) {
            grid.style.display = 'none';
            if (noClasses) noClasses.style.display = 'block';
            return;
        }

        grid.style.display = 'flex';
        if (noClasses) noClasses.style.display = 'none';
        grid.innerHTML = '';

        modules.forEach(function (module) {
            const card = createClassCard(module);
            grid.appendChild(card);
        });
        
        console.log('[StudentDashboard] ✅ Rendered', modules.length, 'class cards');
    }
    
    function createClassCard(classData) {
        const col = document.createElement('div');
        col.className = 'col-md-6 col-lg-4';
        
        const progressPct = classData.Total > 0 
            ? Math.round((classData.Completed / classData.Total) * 100) 
            : 0;

        col.innerHTML = `
            <div class="card border-0 shadow-sm h-100 hover-shadow" style="cursor: pointer;" onclick="window.location.href='/Pages/student/student_class.aspx?class=${classData.ModuleSlug}'">
                <div class="card-body p-4">
                    <div class="d-flex align-items-start mb-3">
                        <div class="flex-shrink-0 me-3">
                            <div style="width: 60px; height: 60px; background: linear-gradient(135deg, ${classData.Color}, ${classData.Color}DD); 
                                        border-radius: 1rem; display: flex; align-items: center; justify-content: center; 
                                        font-size: 2rem; color: white;">
                                <i class="${classData.Icon}"></i>
                            </div>
                        </div>
                        <div class="flex-grow-1">
                            <h5 class="mb-1">${escapeHtml(classData.Title)}</h5>
                            <p class="text-muted small mb-0">${escapeHtml(classData.Summary || 'No description')}</p>
                        </div>
                    </div>
                    
                    <div class="mb-3">
                        <div class="d-flex justify-content-between align-items-center mb-1">
                            <small class="text-muted">Progress</small>
                            <small class="text-muted fw-bold">${classData.Completed}/${classData.Total} levels</small>
                        </div>
                        <div class="progress" style="height: 8px;">
                            <div class="progress-bar" style="width: ${progressPct}%; background: ${classData.Color};"></div>
                        </div>
                    </div>
                    
                    <div class="d-flex gap-2">
                        <span class="badge bg-light text-dark">
                            <i class="bi bi-layers me-1"></i>${classData.Total} levels
                        </span>
                        <span class="badge bg-light text-dark">
                            <i class="bi bi-star text-warning me-1"></i>${classData.TotalXp} XP
                        </span>
                    </div>
                </div>
            </div>
        `;

        return col;
    }

    // ===== Module Grid Rendering (Legacy) =====
    function renderModuleGrid() {
        // Legacy function - now uses renderClassesGrid
        renderClassesGrid();
    }

    function createModuleCard(module) {
        const card = document.createElement('div');
        card.className = 'module-card';
        card.dataset.moduleSlug = module.ModuleSlug;

        // Calculate progress percentage
        const progressPct = module.Total > 0 
            ? Math.round((module.Completed / module.Total) * 100) 
            : 0;

        // Darken color for gradient
        const colorDark = darkenColor(module.Color, 20);

        card.innerHTML = `
            <div class="module-card-header" style="--module-color: ${module.Color}; --module-color-dark: ${colorDark};">
                <i class="${module.Icon} module-icon"></i>
                <h3 class="module-title">${escapeHtml(module.Title)}</h3>
                <p class="module-summary mb-0">${escapeHtml(module.Summary)}</p>
                
                <div class="module-progress-ring">
                    <svg width="60" height="60">
                        <circle cx="30" cy="30" r="25" fill="none" stroke="rgba(255,255,255,0.3)" stroke-width="4"></circle>
                        <circle cx="30" cy="30" r="25" fill="none" stroke="white" stroke-width="4"
                                stroke-dasharray="${2 * Math.PI * 25}"
                                stroke-dashoffset="${2 * Math.PI * 25 * (1 - progressPct / 100)}"
                                transform="rotate(-90 30 30)"
                                stroke-linecap="round">
                        </circle>
                    </svg>
                    <div class="module-progress-text">${progressPct}%</div>
                </div>
            </div>
            
            <div class="module-card-body">
                <div class="module-stats">
                    <div class="module-stat">
                        <div class="module-stat-value">${module.Completed}/${module.Total}</div>
                        <div class="module-stat-label">Quizzes</div>
                    </div>
                    <div class="module-stat">
                        <div class="module-stat-value">${module.TotalXp}</div>
                        <div class="module-stat-label">Total XP</div>
                    </div>
                </div>
                
                <button class="module-action-btn" style="background: ${module.Color};" data-module-slug="${module.ModuleSlug}">
                    <i class="bi bi-play-circle-fill"></i>
                    ${module.Completed > 0 ? 'Continue' : 'Start'} Module
                </button>
            </div>
        `;

        // Click handlers - redirect to student_class.aspx
        card.addEventListener('click', function (e) {
            if (!e.target.closest('.module-action-btn')) {
                navigateToClass(module.ModuleSlug);
            }
        });

        const button = card.querySelector('.module-action-btn');
        button.addEventListener('click', function (e) {
            e.stopPropagation();
            navigateToClass(module.ModuleSlug);
        });

        return card;
    }

    // ===== Module/Class Navigation =====
    function navigateToClass(classSlug) {
        console.log('[StudentDashboard] Navigating to class:', classSlug);
        window.location.href = `/Pages/student/student_class.aspx?class=${classSlug}`;
    }

    // ===== Module Opening (Legacy - kept for compatibility) =====
    function openModule(moduleSlug) {
        // For enrolled classes, redirect to class page instead
        navigateToClass(moduleSlug);
    }

    function closeModule() {
        currentModuleId = null;
        const classesGrid = document.getElementById('classesGrid');
        if (classesGrid) classesGrid.style.display = 'flex';
        
        const quizRailSection = document.getElementById('quizRailSection');
        if (quizRailSection) quizRailSection.style.display = 'none';
    }

    // ===== Quiz Rail Rendering =====
    function renderQuizRail(moduleSlug) {
        const rail = document.getElementById('quizRail');
        if (!rail) return;

        rail.innerHTML = '';

        const moduleQuizzes = quizzes.filter(function (q) { return q.ModuleSlug === moduleSlug; });
        moduleQuizzes.sort(function (a, b) { return a.OrderNo - b.OrderNo; });

        moduleQuizzes.forEach(function (quiz) {
            const card = createQuizCard(quiz);
            rail.appendChild(card);
        });

        // Auto-scroll to in-progress or next available
        setTimeout(function () {
            autoScrollToQuiz(moduleSlug);
        }, 100);
    }

    function createQuizCard(quiz) {
        const card = document.createElement('div');
        card.className = 'level-card ' + quiz.Status;
        card.dataset.quizSlug = quiz.QuizSlug;
        card.setAttribute('tabindex', '0');
        card.setAttribute('role', 'button');
        card.setAttribute('aria-label', quiz.Title + ', Quiz ' + quiz.OrderNo);

        const ringColor = getStatusColor(quiz.Status);
        const circumference = 2 * Math.PI * 40;
        const offset = circumference - (quiz.ProgressPct / 100) * circumference;

        const ringIcon = quiz.Status === 'completed'
            ? '<i class="bi bi-check-circle-fill text-success"></i>'
            : quiz.Status === 'in_progress'
                ? '<i class="bi bi-hourglass-split text-warning"></i>'
                : quiz.Status === 'locked'
                    ? '<i class="bi bi-lock-fill text-muted"></i>'
                    : '<i class="bi bi-play-circle-fill text-primary"></i>';

        card.innerHTML = `
            <div class="card-header-progress">
                <div class="level-order">Quiz ${quiz.OrderNo}</div>
                <div class="progress-ring">
                    <svg width="100" height="100">
                        <circle class="progress-ring-bg" cx="50" cy="50" r="40"></circle>
                        <circle class="progress-ring-fill" cx="50" cy="50" r="40"
                                stroke="${ringColor}"
                                stroke-dasharray="${circumference}"
                                stroke-dashoffset="${offset}">
                        </circle>
                    </svg>
                    <div class="progress-ring-text">${quiz.ProgressPct}%</div>
                </div>
            </div>
            
            <div class="level-card-body">
                <h3 class="level-title">${escapeHtml(quiz.Title)}</h3>
                
                <div class="level-meta">
                    <span><i class="bi bi-clock"></i>~${quiz.Minutes} min</span>
                    <span><i class="bi bi-star-fill"></i>${quiz.XpReward} XP</span>
                </div>
                
                <div class="status-pill ${quiz.Status}">
                    ${ringIcon}
                    <span>${getStatusText(quiz.Status)}</span>
                </div>
                
                <button class="level-action-btn ${getButtonClass(quiz.Status)}"
                        data-quiz-slug="${quiz.QuizSlug}"
                        ${quiz.Status === 'locked' ? 'disabled' : ''}>
                    ${getButtonText(quiz.Status)}
                </button>
            </div>
            
            ${quiz.Status === 'locked' ? `
                <div class="locked-overlay">
                    <i class="bi bi-lock-fill"></i>
                    <div class="locked-text">Complete previous quiz to unlock</div>
                </div>
            ` : ''}
        `;

        // Click handler
        if (quiz.Status !== 'locked') {
            const button = card.querySelector('.level-action-btn');
            button.addEventListener('click', function (e) {
                e.stopPropagation();
                navigateToQuiz(quiz);
            });

            card.addEventListener('click', function () {
                navigateToQuiz(quiz);
            });
        }

        return card;
    }

    // ===== Badges Rendering =====
    function renderBadges() {
        const badgesGrid = document.getElementById('badgesGrid');
        const noBadges = document.getElementById('noBadges');
        if (!badgesGrid) return;

        if (badges.length === 0) {
            badgesGrid.style.display = 'none';
            if (noBadges) noBadges.style.display = 'block';
            return;
        }

        badgesGrid.style.display = 'grid';
        if (noBadges) noBadges.style.display = 'none';

        badgesGrid.innerHTML = badges.map(function (badge) {
            return `
                <div class="badge-item" title="${escapeHtml(badge.Description || badge.Name)}">
                    <i class="${badge.Icon}"></i>
                    <div class="badge-name">${escapeHtml(badge.Name)}</div>
                </div>
            `;
        }).join('');
    }

    // ===== Continue Buttons =====
    function setupGlobalContinueButton() {
        const btn = document.getElementById('btnContinue');
        if (!btn) return;

        // Find first class with incomplete levels
        const nextClass = modules.find(function (m) {
            return m.Completed < m.Total;
        });

        if (!nextClass) {
            btn.disabled = true;
            btn.innerHTML = '<i class="bi bi-check-circle-fill me-2"></i>All Caught Up!';
            return;
        }

        btn.addEventListener('click', function () {
            navigateToClass(nextClass.ModuleSlug);
        });
    }

    function setupModuleContinueButton(moduleSlug) {
        const btn = document.getElementById('btnModuleContinue');
        if (!btn) return;

        const moduleQuizzes = quizzes.filter(function (q) { return q.ModuleSlug === moduleSlug; });
        const nextQuiz = moduleQuizzes.find(function (q) {
            return q.Status === 'available' || q.Status === 'in_progress';
        });

        if (!nextQuiz) {
            btn.disabled = true;
            btn.innerHTML = '<i class="bi bi-check-circle-fill me-2"></i>Module Complete!';
            return;
        }

        btn.onclick = function () {
            scrollToQuiz(nextQuiz.QuizSlug);
        };
    }

    function setupBackToModules() {
        const btn = document.getElementById('btnBackToModules');
        if (btn) {
            btn.addEventListener('click', closeModule);
        }
    }

    // ===== Quiz Navigation =====
    function scrollToQuiz(quizSlug) {
        const card = document.querySelector('.level-card[data-quiz-slug="' + quizSlug + '"]');
        if (card) {
            card.scrollIntoView({ behavior: 'smooth', inline: 'start', block: 'nearest' });
            card.focus();
        }
    }

    function autoScrollToQuiz(moduleSlug) {
        const moduleQuizzes = quizzes.filter(function (q) { return q.ModuleSlug === moduleSlug; });
        const nextQuiz = moduleQuizzes.find(function (q) {
            return q.Status === 'available' || q.Status === 'in_progress';
        });

        if (nextQuiz) {
            scrollToQuiz(nextQuiz.QuizSlug);
        }
    }

    function navigateToQuiz(quiz) {
        // TODO: Navigate to quiz page
        console.log('Navigate to quiz:', quiz.QuizSlug);
        alert(`Starting quiz: ${quiz.Title}\n\nThis would navigate to the quiz page.\nFor now, it's just a demo.`);
        // window.location.href = `/Pages/Quiz.aspx?slug=${quiz.QuizSlug}`;
    }

    // ===== Keyboard Navigation =====
    function setupKeyboardNavigation() {
        const rail = document.getElementById('quizRail');
        if (!rail) return;

        rail.addEventListener('keydown', function (e) {
            const cards = Array.from(document.querySelectorAll('.level-card'));
            const currentIndex = cards.findIndex(function (card) {
                return card === document.activeElement;
            });

            let targetIndex = -1;

            if (e.key === 'ArrowRight') {
                targetIndex = currentIndex + 1;
                e.preventDefault();
            } else if (e.key === 'ArrowLeft') {
                targetIndex = currentIndex - 1;
                e.preventDefault();
            }

            if (targetIndex >= 0 && targetIndex < cards.length) {
                cards[targetIndex].scrollIntoView({
                    behavior: 'smooth',
                    inline: 'start',
                    block: 'nearest'
                });
                cards[targetIndex].focus();
            }
        });
    }

    // ===== Helper Functions =====
    function getStatusColor(status) {
        switch (status) {
            case 'completed': return '#198754';
            case 'in_progress': return '#fd7e14';
            case 'available': return '#0d6efd';
            case 'locked': return '#6c757d';
            default: return '#6c757d';
        }
    }

    function getStatusText(status) {
        switch (status) {
            case 'completed': return 'Completed';
            case 'in_progress': return 'In Progress';
            case 'available': return 'Available';
            case 'locked': return 'Locked';
            default: return 'Unknown';
        }
    }

    function getButtonClass(status) {
        switch (status) {
            case 'completed': return 'btn-review';
            case 'in_progress': return 'btn-resume';
            case 'available': return 'btn-start';
            default: return '';
        }
    }

    function getButtonText(status) {
        switch (status) {
            case 'completed': return 'Review';
            case 'in_progress': return 'Resume';
            case 'available': return 'Start';
            case 'locked': return 'Locked';
            default: return 'View';
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
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    function showEmptyState() {
        console.log('[StudentDashboard] Showing empty state');
        
        const noClasses = document.getElementById('noClasses');
        if (noClasses) {
            noClasses.style.display = 'block';
        }

        const classesGrid = document.getElementById('classesGrid');
        if (classesGrid) {
            classesGrid.style.display = 'none';
        }
    }

})();

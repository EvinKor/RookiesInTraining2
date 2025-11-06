// =============================================
// Teacher Browse Classes - JavaScript
// =============================================

(function () {
    'use strict';

    let classes = [];

    // Initialize
    document.addEventListener('DOMContentLoaded', function () {
        loadClasses();
        renderClasses();
        updateStats();
    });

    function loadClasses() {
        try {
            const hfClasses = document.getElementById(window.TEACHER_DATA.classesFieldId);
            if (hfClasses && hfClasses.value) {
                classes = JSON.parse(hfClasses.value);
            }
        } catch (error) {
            console.error('Error loading classes:', error);
        }
    }

    function renderClasses() {
        const grid = document.getElementById('classesGrid');
        const emptyState = document.getElementById('emptyState');

        if (!grid) return;

        if (classes.length === 0) {
            grid.style.display = 'none';
            if (emptyState) emptyState.style.display = 'block';
            return;
        }

        grid.style.display = 'flex';
        if (emptyState) emptyState.style.display = 'none';

        grid.innerHTML = '';

        classes.forEach(function (classItem) {
            const card = createClassCard(classItem);
            grid.appendChild(card);
        });
    }

    function createClassCard(classItem) {
        const col = document.createElement('div');
        col.className = 'col-md-6 col-lg-4';

        col.innerHTML = `
            <div class="class-card clickable-card" 
                 style="--class-color: ${classItem.Color}; cursor: pointer;"
                 onclick="window.location.href='class_detail.aspx?slug=${classItem.ClassSlug}'">
                <div class="class-card-header">
                    <div class="class-icon">
                        ${classItem.Icon || '📚'}
                    </div>
                    <h3 class="class-name">${escapeHtml(classItem.ClassName)}</h3>
                    <span class="class-code">${escapeHtml(classItem.ClassCode)}</span>
                </div>
                <div class="class-card-body">
                    <p class="text-muted mb-3">
                        ${escapeHtml(classItem.Description || 'No description')}
                    </p>
                    <div class="class-stats">
                        <div class="class-stat">
                            <i class="bi bi-people"></i>
                            <div class="class-stat-text">
                                <div class="class-stat-value">${classItem.StudentCount}</div>
                                <div class="class-stat-label">students</div>
                            </div>
                        </div>
                        <div class="class-stat">
                            <i class="bi bi-layers"></i>
                            <div class="class-stat-text">
                                <div class="class-stat-value">${classItem.LevelCount}</div>
                                <div class="class-stat-label">levels</div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="class-card-footer">
                    <i class="bi bi-arrow-right-circle me-1"></i>Click to view levels and manage quizzes
                </div>
            </div>
        `;

        return col;
    }

    function updateStats() {
        const totalStudents = classes.reduce((sum, c) => sum + c.StudentCount, 0);
        const totalLevels = classes.reduce((sum, c) => sum + c.LevelCount, 0);

        const totalClassesEl = document.getElementById('totalClasses');
        const totalStudentsEl = document.getElementById('totalStudents');
        const totalLevelsEl = document.getElementById('totalLevels');

        if (totalClassesEl) totalClassesEl.textContent = classes.length;
        if (totalStudentsEl) totalStudentsEl.textContent = totalStudents;
        if (totalLevelsEl) totalLevelsEl.textContent = totalLevels;
    }

    function escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

})();


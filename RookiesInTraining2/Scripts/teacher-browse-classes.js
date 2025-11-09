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
            console.log('[Classes] Loading classes...');
            console.log('[Classes] Looking for field ID:', window.TEACHER_DATA?.classesFieldId);
            
            const hfClasses = document.getElementById(window.TEACHER_DATA.classesFieldId);
            console.log('[Classes] Hidden field element:', hfClasses);
            console.log('[Classes] Hidden field value:', hfClasses?.value);
            
            if (hfClasses && hfClasses.value) {
                classes = JSON.parse(hfClasses.value);
                console.log('[Classes] Parsed classes:', classes);
                console.log('[Classes] Number of classes:', classes.length);
            } else {
                console.warn('[Classes] No classes data found in hidden field');
            }
        } catch (error) {
            console.error('[Classes] Error loading classes:', error);
        }
    }

    function renderClasses() {
        const grid = document.getElementById('classesGrid');
        const emptyState = document.getElementById('emptyState');
        const viewMoreBtn = document.getElementById('viewMoreClasses');

        if (!grid) return;

        if (classes.length === 0) {
            grid.style.display = 'none';
            if (emptyState) emptyState.style.display = 'block';
            if (viewMoreBtn) viewMoreBtn.style.display = 'none';
            return;
        }

        grid.style.display = 'flex';
        if (emptyState) emptyState.style.display = 'none';

        grid.innerHTML = '';

        // Limit to 6 classes (2 rows x 3 columns) for dashboard
        const maxClasses = 6;
        const classesToShow = classes.slice(0, maxClasses);

        classesToShow.forEach(function (classItem) {
            const card = createClassCard(classItem);
            grid.appendChild(card);
        });

        // Show "View More" button if there are more than 6 classes
        if (viewMoreBtn) {
            if (classes.length > maxClasses) {
                viewMoreBtn.style.display = 'block';
            } else {
                viewMoreBtn.style.display = 'none';
            }
        }
    }

    function createClassCard(classItem) {
        const col = document.createElement('div');
        col.className = 'col-md-6 col-lg-4';

        // Determine the icon class - ensure it has the 'bi' prefix
        const iconClass = classItem.Icon || 'bi-book';
        const fullIconClass = iconClass.startsWith('bi ') ? iconClass : 'bi ' + iconClass;
        
        console.log(`[Class Card] ${classItem.ClassName}: Icon="${iconClass}" → FullClass="${fullIconClass}"`);
        
        col.innerHTML = `
            <div class="class-card clickable-card" 
                 style="--class-color: ${classItem.Color}; cursor: pointer;"
                 onclick="window.location.href='manage_classes.aspx?class=${classItem.ClassSlug}'">
                <div class="class-card-header">
                    <div class="class-icon">
                        <i class="${fullIconClass}"></i>
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
                    <i class="bi bi-chat-dots-fill me-1"></i>Click to open Forum & Story Mode
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


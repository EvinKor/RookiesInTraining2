// ================================================
// Teacher Classes Page - Logic
// ================================================

(function () {
    'use strict';

    // ===== State =====
    let classes = [];

    // ===== Initialization =====
    document.addEventListener('DOMContentLoaded', function () {
        initPage();
    });

    function initPage() {
        loadData();
        renderClasses();
        setupEventListeners();
    }

    // ===== Data Loading =====
    function loadData() {
        try {
            if (!window.TEACHER_DATA || !window.TEACHER_DATA.classesFieldId) {
                console.error('TEACHER_DATA not found');
                return;
            }

            const classesField = document.getElementById(window.TEACHER_DATA.classesFieldId);
            if (classesField && classesField.value) {
                classes = JSON.parse(classesField.value);
            }

            console.log('Loaded classes:', classes);
        } catch (error) {
            console.error('Error loading classes:', error);
        }
    }

    // ===== Event Listeners =====
    function setupEventListeners() {
        const btnCreate = document.getElementById('btnCreateClass');
        if (btnCreate) {
            btnCreate.addEventListener('click', openClassModal);
        }

        // Icon picker
        const iconInputs = document.querySelectorAll('input[name="classIcon"]');
        iconInputs.forEach(function (input) {
            input.addEventListener('change', function () {
                const iconField = document.getElementById(window.TEACHER_DATA.hfSelectedIconId);
                if (iconField) iconField.value = this.value;
            });
        });

        // Color picker
        const colorInputs = document.querySelectorAll('input[name="classColor"]');
        colorInputs.forEach(function (input) {
            input.addEventListener('change', function () {
                const colorField = document.getElementById(window.TEACHER_DATA.hfSelectedColorId);
                if (colorField) colorField.value = this.value;
            });
        });

        // Level type toggles for initial 3 levels
        for (let i = 1; i <= 3; i++) {
            setupLevelTypeToggle(i);
        }
    }

    // ===== Add New Level Dynamically =====
    window.addNewLevel = function() {
        levelCount++;
        const container = document.getElementById('levelsContainer');
        
        const levelDiv = document.createElement('div');
        levelDiv.className = 'level-input-group mb-4 level-dynamic';
        levelDiv.setAttribute('data-level', levelCount);
        
        levelDiv.innerHTML = `
            <div class="level-header d-flex justify-content-between align-items-center">
                <h5><i class="bi bi-${levelCount}-circle me-2"></i>Level ${levelCount}</h5>
                <button type="button" class="btn btn-sm btn-danger" onclick="removeLevel(this)">
                    <i class="bi bi-trash"></i> Remove
                </button>
            </div>
            <div class="mb-3">
                <label class="form-label fw-bold">Level Title <span class="text-danger">*</span></label>
                <input type="text" class="form-control level-title" data-level="${levelCount}"
                       placeholder="e.g., Advanced Topics" maxlength="200" />
            </div>
            <div class="mb-3">
                <label class="form-label fw-bold">Learning Material</label>
                <div class="material-input-group">
                    <div class="btn-group w-100 mb-2" role="group">
                        <input type="radio" class="btn-check level-type-radio" name="level${levelCount}Type" 
                               id="level${levelCount}Upload" value="upload" checked>
                        <label class="btn btn-outline-primary" for="level${levelCount}Upload">
                            <i class="bi bi-upload me-1"></i>Upload File
                        </label>
                        <input type="radio" class="btn-check level-type-radio" name="level${levelCount}Type" 
                               id="level${levelCount}Manual" value="manual">
                        <label class="btn btn-outline-primary" for="level${levelCount}Manual">
                            <i class="bi bi-pencil me-1"></i>Write Content
                        </label>
                    </div>
                    <input type="file" class="form-control file-upload-dynamic file-upload-${levelCount}" 
                           accept=".pdf,.pptx,.ppt,.mp4" data-level="${levelCount}" />
                    <textarea class="form-control manual-content-dynamic manual-content-${levelCount}" 
                              rows="4" style="display:none;" data-level="${levelCount}"
                              placeholder="Enter learning content here..."></textarea>
                </div>
            </div>
        `;
        
        container.appendChild(levelDiv);
        setupLevelTypeToggle(levelCount);
    };

    window.removeLevel = function(button) {
        if (levelCount <= 3) {
            alert('Minimum 3 levels required!');
            return;
        }
        button.closest('.level-input-group').remove();
        levelCount--;
        // Renumber remaining levels
        renumberLevels();
    };

    function renumberLevels() {
        const levels = document.querySelectorAll('#levelsContainer .level-input-group');
        levels.forEach((level, index) => {
            const newNum = index + 1;
            level.setAttribute('data-level', newNum);
            const header = level.querySelector('.level-header h5');
            if (header) {
                header.innerHTML = `<i class="bi bi-${newNum}-circle me-2"></i>Level ${newNum}`;
            }
        });
        levelCount = levels.length;
    }

    function setupLevelTypeToggle(levelNum) {
        const uploadRadio = document.getElementById('level' + levelNum + 'Upload');
        const manualRadio = document.getElementById('level' + levelNum + 'Manual');
        const fileUpload = document.querySelector('.file-upload-' + levelNum);
        const manualContent = document.querySelector('.manual-content-' + levelNum);
        const hiddenFieldId = window.TEACHER_DATA['hfLevel' + levelNum + 'TypeId'];
        const hiddenField = hiddenFieldId ? document.getElementById(hiddenFieldId) : null;

        if (uploadRadio && manualRadio && fileUpload && manualContent) {
            uploadRadio.addEventListener('change', function() {
                if (this.checked) {
                    fileUpload.style.display = 'block';
                    manualContent.style.display = 'none';
                    if (hiddenField) hiddenField.value = 'upload';
                }
            });

            manualRadio.addEventListener('change', function() {
                if (this.checked) {
                    fileUpload.style.display = 'none';
                    manualContent.style.display = 'block';
                    if (hiddenField) hiddenField.value = 'manual';
                }
            });
        }
    }

    // ===== Rendering =====
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

        const color = classItem.Color || '#6c5ce7';
        const colorDark = darkenColor(color, 20);
        const icon = classItem.Icon || 'bi-book';
        const createdDate = new Date(classItem.CreatedAt).toLocaleDateString('en-US', {
            year: 'numeric',
            month: 'short',
            day: 'numeric'
        });

        col.innerHTML = `
            <div class="class-card" style="--class-color: ${color}; --class-color-dark: ${colorDark};">
                <div class="class-card-header">
                    <i class="${icon} class-icon"></i>
                    <h3 class="class-name">${escapeHtml(classItem.ClassName)}</h3>
                    <div class="class-code">
                        <i class="bi bi-key me-1"></i>${escapeHtml(classItem.ClassCode)}
                    </div>
                </div>
                
                <div class="class-card-body">
                    <div class="class-stats">
                        <div class="class-stat">
                            <i class="bi bi-people-fill"></i>
                            <div class="class-stat-text">
                                <div class="class-stat-value">${classItem.StudentCount}</div>
                                <div class="class-stat-label">Students</div>
                            </div>
                        </div>
                        <div class="class-stat">
                            <i class="bi bi-journal-text"></i>
                            <div class="class-stat-text">
                                <div class="class-stat-value">0</div>
                                <div class="class-stat-label">Quizzes</div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="class-actions">
                        <button class="btn btn-primary" onclick="viewClass('${classItem.ClassSlug}')">
                            <i class="bi bi-box-arrow-in-right me-1"></i>Open
                        </button>
                        <button class="btn btn-outline-secondary" onclick="manageClass('${classItem.ClassSlug}')">
                            <i class="bi bi-gear"></i>
                        </button>
                    </div>
                    
                    <div class="class-created">
                        <i class="bi bi-calendar me-1"></i>Created ${createdDate}
                    </div>
                </div>
            </div>
        `;

        return col;
    }

    // ===== Wizard State =====
    let currentStep = 1;
    let levelCount = 3; // Start with 3 levels, can add more

    // ===== Modal Functions =====
    window.openClassModal = function () {
        const modal = document.getElementById('classModal');
        if (modal) {
            currentStep = 1;
            showStep(1);
            modal.style.display = 'flex';
            // Focus first input
            setTimeout(function () {
                const firstInput = document.getElementById(window.TEACHER_DATA.txtClassNameId);
                if (firstInput) firstInput.focus();
            }, 100);
        }
    };

    window.closeClassModal = function () {
        const modal = document.getElementById('classModal');
        if (modal) {
            modal.style.display = 'none';
            currentStep = 1;
            showStep(1);
        }
    };

    window.nextStep = function() {
        if (currentStep === 1) {
            // Validate step 1
            const className = document.getElementById(window.TEACHER_DATA.txtClassNameId);
            const classCode = document.getElementById(window.TEACHER_DATA.txtClassCodeId);
            
            if (!className || !className.value.trim()) {
                alert('Please enter a class name');
                if (className) className.focus();
                return;
            }
            
            if (!classCode || !classCode.value.trim()) {
                alert('Please enter or generate a class code');
                if (classCode) classCode.focus();
                return;
            }
            
            currentStep = 2;
            showStep(2);
        }
        else if (currentStep === 2) {
            // Validate step 2 - minimum 3 levels required
            const allLevels = document.querySelectorAll('#levelsContainer .level-input-group');
            
            if (allLevels.length < 3) {
                alert('Minimum 3 levels required! You currently have ' + allLevels.length + ' level(s).');
                return;
            }
            
            // Check all level titles are filled
            for (let i = 0; i < allLevels.length; i++) {
                const level = allLevels[i];
                const titleInput = level.querySelector('.level-title, input[id*="Title"]');
                
                if (!titleInput || !titleInput.value.trim()) {
                    alert('Please fill in the title for Level ' + (i + 1));
                    if (titleInput) titleInput.focus();
                    return;
                }
            }
            
            // Save all levels data to hidden field as JSON before proceeding
            saveLevelsData();
            
            // Generate review
            generateReview();
            currentStep = 3;
            showStep(3);
        }
    };

    window.previousStep = function() {
        if (currentStep > 1) {
            currentStep--;
            showStep(currentStep);
        }
    };

    function showStep(step) {
        // Hide all steps
        document.querySelectorAll('.wizard-content').forEach(function(el) {
            el.style.display = 'none';
            el.classList.remove('active');
        });

        // Show current step
        const stepEl = document.getElementById('step' + step);
        if (stepEl) {
            stepEl.style.display = 'block';
            stepEl.classList.add('active');
        }

        // Update wizard steps indicator
        document.querySelectorAll('.wizard-step').forEach(function(el) {
            const stepNum = parseInt(el.dataset.step);
            if (stepNum <= step) {
                el.classList.add('active');
            } else {
                el.classList.remove('active');
            }
            if (stepNum === step) {
                el.classList.add('current');
            } else {
                el.classList.remove('current');
            }
        });

        // Show/hide buttons
        const btnPrev = document.getElementById('btnPrevStep');
        const btnNext = document.getElementById('btnNextStep');
        const btnSave = document.querySelector('[id*="btnSaveClass"]');

        if (btnPrev) btnPrev.style.display = step > 1 ? 'block' : 'none';
        if (btnNext) btnNext.style.display = step < 3 ? 'block' : 'none';
        if (btnSave) btnSave.style.display = step === 3 ? 'block' : 'none';
    }

    function saveLevelsData() {
        const allLevels = document.querySelectorAll('#levelsContainer .level-input-group');
        const levelsData = [];
        
        allLevels.forEach((level, index) => {
            const levelNum = index + 1;
            const titleInput = level.querySelector('.level-title, input[id*="Title"]');
            const contentTextarea = level.querySelector('.manual-content-' + levelNum + ', textarea[data-level="' + levelNum + '"]');
            const typeRadios = level.querySelectorAll('input[name="level' + levelNum + 'Type"]');
            
            let materialType = 'upload';
            typeRadios.forEach(function(radio) {
                if (radio.checked) {
                    materialType = radio.value;
                }
            });
            
            const levelData = {
                levelNumber: levelNum,
                title: titleInput ? titleInput.value.trim() : '',
                materialType: materialType,
                manualContent: (materialType === 'manual' && contentTextarea) ? contentTextarea.value : ''
            };
            
            levelsData.push(levelData);
        });
        
        // Save to hidden field
        const hfLevelsData = document.querySelector('[id$="hfLevelsData"]');
        if (hfLevelsData) {
            hfLevelsData.value = JSON.stringify(levelsData);
        }
        
        return levelsData;
    }

    function generateReview() {
        // Class info
        const classNameEl = document.getElementById(window.TEACHER_DATA.txtClassNameId);
        const classCodeEl = document.getElementById(window.TEACHER_DATA.txtClassCodeId);
        
        const className = classNameEl ? classNameEl.value : '';
        const classCode = classCodeEl ? classCodeEl.value : '';
        
        document.getElementById('reviewClassName').textContent = className;
        document.getElementById('reviewClassCode').textContent = classCode;

        // Levels
        const reviewLevels = document.getElementById('reviewLevels');
        const levelsData = saveLevelsData();
        let html = '';

        levelsData.forEach(function(levelData) {
            const materialType = levelData.materialType === 'upload' ? 'File Upload' : 'Manual Content';
            html += `
                <div class="review-level-item">
                    <div class="review-level-number">${levelData.levelNumber}</div>
                    <div>
                        <strong>${escapeHtml(levelData.title)}</strong>
                        <br><small class="text-muted"><i class="bi bi-file me-1"></i>${materialType}</small>
                    </div>
                </div>
            `;
        });

        reviewLevels.innerHTML = html;
    }

    window.generateClassCode = function () {
        const code = 'CLASS-' + Math.random().toString(36).substring(2, 8).toUpperCase();
        const codeInput = document.getElementById(window.TEACHER_DATA.txtClassCodeId);
        if (codeInput) {
            codeInput.value = code;
        }
    };

    window.viewClass = function (classSlug) {
        window.location.href = 'class_detail.aspx?slug=' + classSlug;
    };

    window.manageClass = function (classSlug) {
        // TODO: Open manage modal or navigate to settings
        alert('Manage class: ' + classSlug + '\n\nThis would open class settings.');
    };

    // ===== Helper Functions =====
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

    // Close modal on ESC key
    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') {
            window.closeClassModal();
        }
    });

})();



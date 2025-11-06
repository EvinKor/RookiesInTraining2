// =============================================
// Teacher Create Class - Wizard JavaScript
// =============================================

(function () {
    'use strict';

    let currentStep = 1;
    let levelCount = 3; // Start with 3 levels minimum

    // Initialize on page load
    document.addEventListener('DOMContentLoaded', function () {
        initializeWizard();
        setupEventListeners();
        createInitialLevels();
    });

    function initializeWizard() {
        showStep(1);
    }

    function setupEventListeners() {
        // Icon picker
        const iconInputs = document.querySelectorAll('input[name="classIcon"]');
        iconInputs.forEach(function (input) {
            input.addEventListener('change', function () {
                const iconField = document.getElementById(window.CLASS_DATA.hfSelectedIconId);
                if (iconField) iconField.value = this.value;
            });
        });

        // Color picker
        const colorInputs = document.querySelectorAll('input[name="classColor"]');
        colorInputs.forEach(function (input) {
            input.addEventListener('change', function () {
                const colorField = document.getElementById(window.CLASS_DATA.hfSelectedColorId);
                if (colorField) colorField.value = this.value;
            });
        });
    }

    function createInitialLevels() {
        const container = document.getElementById('levelsContainer');
        if (!container) return;

        // Create 3 initial levels
        for (let i = 1; i <= 3; i++) {
            const levelDiv = createLevelElement(i);
            container.appendChild(levelDiv);
        }
    }

    function createLevelElement(levelNum) {
        const div = document.createElement('div');
        div.className = 'level-card';
        div.setAttribute('data-level', levelNum);

        const canRemove = levelNum > 3;
        const removeBtn = canRemove ? `
            <button type="button" class="btn btn-sm btn-danger" onclick="removeLevel(this)">
                <i class="bi bi-trash me-1"></i>Remove
            </button>
        ` : '';

        div.innerHTML = `
            <div class="level-header">
                <h5><i class="bi bi-${levelNum}-circle me-2"></i>Level ${levelNum}</h5>
                ${removeBtn}
            </div>
            <div class="mb-3">
                <label class="form-label fw-bold">Level Title <span class="text-danger">*</span></label>
                <input type="text" class="form-control level-title" data-level="${levelNum}"
                       placeholder="e.g., Introduction to Variables" maxlength="200" />
            </div>
            <div class="mb-3">
                <label class="form-label fw-bold">Learning Material</label>
                <div class="material-input-group">
                    <div class="btn-group w-100 mb-2" role="group">
                        <input type="radio" class="btn-check" name="level${levelNum}Type" 
                               id="level${levelNum}Upload" value="upload" checked>
                        <label class="btn btn-outline-primary" for="level${levelNum}Upload">
                            <i class="bi bi-upload me-1"></i>Upload File
                        </label>
                        <input type="radio" class="btn-check" name="level${levelNum}Type" 
                               id="level${levelNum}Manual" value="manual">
                        <label class="btn btn-outline-primary" for="level${levelNum}Manual">
                            <i class="bi bi-pencil me-1"></i>Write Content
                        </label>
                    </div>
                    <input type="file" class="form-control file-upload-${levelNum}" 
                           accept=".pdf,.pptx,.ppt,.mp4" data-level="${levelNum}" />
                    <textarea class="form-control manual-content-${levelNum}" 
                              rows="4" style="display:none;" data-level="${levelNum}"
                              placeholder="Enter learning content here..."></textarea>
                </div>
            </div>
        `;

        // Setup toggle for upload/manual
        setTimeout(() => setupLevelToggle(levelNum), 100);

        return div;
    }

    function setupLevelToggle(levelNum) {
        const uploadRadio = document.getElementById('level' + levelNum + 'Upload');
        const manualRadio = document.getElementById('level' + levelNum + 'Manual');
        const fileUpload = document.querySelector('.file-upload-' + levelNum);
        const manualContent = document.querySelector('.manual-content-' + levelNum);

        if (uploadRadio && manualRadio) {
            uploadRadio.addEventListener('change', function () {
                if (this.checked) {
                    if (fileUpload) fileUpload.style.display = 'block';
                    if (manualContent) manualContent.style.display = 'none';
                }
            });

            manualRadio.addEventListener('change', function () {
                if (this.checked) {
                    if (fileUpload) fileUpload.style.display = 'none';
                    if (manualContent) manualContent.style.display = 'block';
                }
            });
        }
    }

    // Add new level
    window.addNewLevel = function () {
        levelCount++;
        const container = document.getElementById('levelsContainer');
        const levelDiv = createLevelElement(levelCount);
        container.appendChild(levelDiv);
    };

    // Remove level
    window.removeLevel = function (button) {
        if (levelCount <= 3) {
            alert('Minimum 3 levels required!');
            return;
        }
        button.closest('.level-card').remove();
        levelCount--;
        renumberLevels();
    };

    function renumberLevels() {
        const levels = document.querySelectorAll('#levelsContainer .level-card');
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

    // Wizard navigation
    window.nextStep = function () {
        if (currentStep === 1) {
            // Validate step 1
            const className = document.getElementById(window.CLASS_DATA.txtClassNameId);
            const classCode = document.getElementById(window.CLASS_DATA.txtClassCodeId);

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
            // Validate step 2
            const allLevels = document.querySelectorAll('#levelsContainer .level-card');

            console.log('Found ' + allLevels.length + ' levels');

            if (allLevels.length < 3) {
                alert('Minimum 3 levels required! You currently have ' + allLevels.length + ' level(s).');
                return;
            }

            // Check all titles filled
            for (let i = 0; i < allLevels.length; i++) {
                const titleInput = allLevels[i].querySelector('.level-title');
                if (!titleInput || !titleInput.value.trim()) {
                    alert('Please fill in title for Level ' + (i + 1));
                    if (titleInput) titleInput.focus();
                    return;
                }
            }

            // Save levels data
            saveLevelsData();

            // Generate review
            generateReview();
            currentStep = 3;
            showStep(3);
        }
    };

    window.previousStep = function () {
        if (currentStep > 1) {
            currentStep--;
            showStep(currentStep);
        }
    };

    function showStep(step) {
        // Hide all steps
        document.querySelectorAll('.wizard-content').forEach(el => {
            el.style.display = 'none';
            el.classList.remove('active');
        });

        // Show current step
        const stepEl = document.getElementById('step' + step);
        if (stepEl) {
            stepEl.style.display = 'block';
            stepEl.classList.add('active');
        }

        // Update step indicators
        document.querySelectorAll('.wizard-step').forEach(el => {
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
        const btnCreate = document.querySelector('[id*="btnCreateClass"]');

        if (btnPrev) btnPrev.style.display = step > 1 ? 'block' : 'none';
        if (btnNext) btnNext.style.display = step < 3 ? 'block' : 'none';
        if (btnCreate) btnCreate.style.display = step === 3 ? 'block' : 'none';
    }

    function saveLevelsData() {
        const allLevels = document.querySelectorAll('#levelsContainer .level-card');
        const levelsData = [];

        allLevels.forEach((level, index) => {
            const levelNum = index + 1;
            const titleInput = level.querySelector('.level-title');
            const contentTextarea = level.querySelector('textarea');
            const typeRadios = level.querySelectorAll('input[name="level' + levelNum + 'Type"]');

            let materialType = 'upload';
            typeRadios.forEach(radio => {
                if (radio.checked) materialType = radio.value;
            });

            levelsData.push({
                levelNumber: levelNum,
                title: titleInput ? titleInput.value.trim() : '',
                materialType: materialType,
                manualContent: (materialType === 'manual' && contentTextarea) ? contentTextarea.value : ''
            });
        });

        // Save to hidden field
        const hfLevelsData = document.getElementById(window.CLASS_DATA.hfLevelsDataId);
        if (hfLevelsData) {
            hfLevelsData.value = JSON.stringify(levelsData);
        }
    }

    function generateReview() {
        const classNameEl = document.getElementById(window.CLASS_DATA.txtClassNameId);
        const classCodeEl = document.getElementById(window.CLASS_DATA.txtClassCodeId);

        document.getElementById('reviewClassName').textContent = classNameEl ? classNameEl.value : '';
        document.getElementById('reviewClassCode').textContent = classCodeEl ? classCodeEl.value : '';

        // Parse levels
        const hfLevelsData = document.getElementById(window.CLASS_DATA.hfLevelsDataId);
        const levelsData = hfLevelsData ? JSON.parse(hfLevelsData.value) : [];

        // Update level count badge
        const levelCountBadge = document.getElementById('reviewLevelCount');
        if (levelCountBadge) {
            levelCountBadge.textContent = levelsData.length + ' Level' + (levelsData.length !== 1 ? 's' : '');
        }

        let html = '';
        levelsData.forEach(level => {
            const materialType = level.materialType === 'upload' ? '📄 File Upload' : '✍️ Manual Content';
            html += `
                <div class="review-level-item">
                    <div class="review-level-number">${level.levelNumber}</div>
                    <div class="flex-grow-1">
                        <strong class="d-block">${escapeHtml(level.title)}</strong>
                        <small class="text-muted">${materialType}</small>
                    </div>
                    <i class="bi bi-check-circle text-success fs-5"></i>
                </div>
            `;
        });

        document.getElementById('reviewLevels').innerHTML = html;
    }

    window.generateClassCode = function () {
        const code = 'CLASS-' + Math.random().toString(36).substring(2, 8).toUpperCase();
        const codeInput = document.getElementById(window.CLASS_DATA.txtClassCodeId);
        if (codeInput) {
            codeInput.value = code;
        }
    };

    function escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

})();


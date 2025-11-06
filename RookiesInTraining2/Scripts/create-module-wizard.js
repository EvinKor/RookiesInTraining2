// Create Module Wizard - Client-side Logic
// No jQuery dependencies - pure vanilla JS

(function() {
    'use strict';

    // State management
    let currentStep = 1;
    const draft = {
        classInfo: {
            name: '',
            description: '',
            icon: 'book',
            color: '#667eea',
            classCode: ''
        },
        levels: []
    };

    // File storage (temporary until submission)
    const fileStorage = new Map();

    // Initialize on load
    document.addEventListener('DOMContentLoaded', function() {
        initWizard();
        attachEventListeners();
        updateLevelCount();
    });

    function initWizard() {
        // Set initial class code from server
        const classCodeInput = document.getElementById(window.WIZARD_IDS.txtClassCode);
        if (classCodeInput) {
            draft.classInfo.classCode = classCodeInput.value;
        }

        // Show step 1
        showStep(1);
    }

    function attachEventListeners() {
        // Icon picker
        document.querySelectorAll('input[name="icon"]').forEach(radio => {
            radio.addEventListener('change', function() {
                draft.classInfo.icon = this.value;
                document.getElementById(window.WIZARD_IDS.hfIcon).value = this.value;
            });
        });

        // Color picker
        document.querySelectorAll('input[name="color"]').forEach(radio => {
            radio.addEventListener('change', function() {
                draft.classInfo.color = this.value;
                document.getElementById(window.WIZARD_IDS.hfColor).value = this.value;
            });
        });

        // Auto-increment level number
        const levelsList = document.getElementById('levelsList');
        if (levelsList) {
            const observer = new MutationObserver(function() {
                updateLevelNumberSuggestion();
            });
            observer.observe(levelsList, { childList: true });
        }
    }

    function updateLevelNumberSuggestion() {
        const levelNumInput = document.getElementById('txtLevelNumber');
        if (levelNumInput && draft.levels.length > 0) {
            const maxLevel = Math.max(...draft.levels.map(l => l.levelNumber));
            levelNumInput.value = maxLevel + 1;
        }
    }

    // Step navigation
    window.goNext = function() {
        if (validateCurrentStep()) {
            captureStepData();
            if (currentStep < 3) {
                showStep(currentStep + 1);
            }
        }
    };

    window.goBack = function() {
        if (currentStep > 1) {
            showStep(currentStep - 1);
        }
    };

    function showStep(step) {
        currentStep = step;

        // Update step indicators
        document.querySelectorAll('.wizard-step').forEach((el, idx) => {
            el.classList.toggle('active', idx + 1 === step);
        });

        // Update content visibility
        document.querySelectorAll('.step-content').forEach((el, idx) => {
            el.classList.toggle('active', idx + 1 === step);
        });

        // Update buttons
        const btnBack = document.getElementById('btnBack');
        const btnNext = document.getElementById('btnNext');
        const btnCreate = document.getElementById(window.WIZARD_IDS.btnCreateModule);

        console.log('Step:', step, 'btnCreate element:', btnCreate);

        if (btnBack) btnBack.style.display = step > 1 ? 'block' : 'none';
        if (btnNext) btnNext.style.display = step < 3 ? 'block' : 'none';
        if (btnCreate) {
            btnCreate.style.display = step === 3 ? 'block' : 'none';
            console.log('Create button display set to:', step === 3 ? 'block' : 'none');
        } else {
            console.error('Create Module button not found! ID:', window.WIZARD_IDS.btnCreateModule);
        }

        // Special actions per step
        if (step === 3) {
            generateReview();
            syncDraftToHiddenField();
        }
    }

    function validateCurrentStep() {
        switch (currentStep) {
            case 1:
                return validateStep1();
            case 2:
                return validateStep2();
            default:
                return true;
        }
    }

    function validateStep1() {
        const nameInput = document.getElementById(window.WIZARD_IDS.txtClassName);
        const name = nameInput.value.trim();

        if (name.length < 3 || name.length > 200) {
            alert('Class name must be between 3 and 200 characters.');
            nameInput.focus();
            return false;
        }

        return true;
    }

    function validateStep2() {
        if (draft.levels.length < 3) {
            alert('You must add at least 3 levels before proceeding.');
            return false;
        }
        return true;
    }

    function captureStepData() {
        if (currentStep === 1) {
            draft.classInfo.name = document.getElementById(window.WIZARD_IDS.txtClassName).value.trim();
            draft.classInfo.description = document.getElementById(window.WIZARD_IDS.txtClassDescription).value.trim();
            draft.classInfo.classCode = document.getElementById(window.WIZARD_IDS.txtClassCode).value.trim();
            // icon and color already captured via event listeners
        }
    }

    // Level management
    window.addLevel = function() {
        const levelNumber = parseInt(document.getElementById('txtLevelNumber').value);
        const title = document.getElementById('txtLevelTitle').value.trim();
        const description = document.getElementById('txtLevelDescription').value.trim();
        const minutes = parseInt(document.getElementById('txtEstimatedMinutes').value) || 15;
        const xp = parseInt(document.getElementById('txtXpReward').value) || 50;
        const publish = document.getElementById('chkPublishLevel').checked;
        const fileInput = document.getElementById('fileUploadLevel');

        // Validate
        if (levelNumber < 1) {
            alert('Level number must be at least 1.');
            return;
        }

        if (title.length < 3) {
            alert('Level title must be at least 3 characters.');
            document.getElementById('txtLevelTitle').focus();
            return;
        }

        // Check for duplicate level number
        if (draft.levels.some(l => l.levelNumber === levelNumber)) {
            alert(`Level ${levelNumber} already exists. Please use a different number or edit the existing level.`);
            return;
        }

        const level = {
            levelNumber: levelNumber,
            title: title,
            description: description,
            minutes: minutes,
            xp: xp,
            publish: publish,
            fileName: null,
            contentType: null
        };

        // Handle file if present
        if (fileInput.files.length > 0) {
            const file = fileInput.files[0];
            level.fileName = file.name;
            level.contentType = getContentType(file.name);
            
            // Store file temporarily
            fileStorage.set(levelNumber, file);
        }

        // Add to draft
        draft.levels.push(level);

        // Sort by level number
        draft.levels.sort((a, b) => a.levelNumber - b.levelNumber);

        // Render
        renderLevelsList();
        updateLevelCount();

        // Clear form
        clearLevelForm();
    };

    window.editLevel = function(levelNumber) {
        const level = draft.levels.find(l => l.levelNumber === levelNumber);
        if (!level) return;

        // Populate form
        document.getElementById('txtLevelNumber').value = level.levelNumber;
        document.getElementById('txtLevelTitle').value = level.title;
        document.getElementById('txtLevelDescription').value = level.description;
        document.getElementById('txtEstimatedMinutes').value = level.minutes;
        document.getElementById('txtXpReward').value = level.xp;
        document.getElementById('chkPublishLevel').checked = level.publish;

        // Remove from draft (will be re-added with updated values)
        draft.levels = draft.levels.filter(l => l.levelNumber !== levelNumber);
        fileStorage.delete(levelNumber);

        renderLevelsList();
        updateLevelCount();

        // Scroll to form
        document.querySelector('.card.border-primary').scrollIntoView({ behavior: 'smooth', block: 'start' });
    };

    window.removeLevel = function(levelNumber) {
        if (!confirm(`Remove Level ${levelNumber}?`)) return;

        draft.levels = draft.levels.filter(l => l.levelNumber !== levelNumber);
        fileStorage.delete(levelNumber);

        renderLevelsList();
        updateLevelCount();
    };

    function clearLevelForm() {
        document.getElementById('txtLevelTitle').value = '';
        document.getElementById('txtLevelDescription').value = '';
        document.getElementById('txtEstimatedMinutes').value = '15';
        document.getElementById('txtXpReward').value = '50';
        document.getElementById('chkPublishLevel').checked = true;
        document.getElementById('fileUploadLevel').value = '';
        updateLevelNumberSuggestion();
    }

    function renderLevelsList() {
        const container = document.getElementById('levelsList');
        if (!container) return;

        if (draft.levels.length === 0) {
            container.innerHTML = '<div class="alert alert-info"><i class="bi bi-info-circle me-2"></i>No levels added yet. Add at least 3 levels to continue.</div>';
            return;
        }

        container.innerHTML = draft.levels.map(level => `
            <div class="level-list-item">
                <div class="level-num-badge">${level.levelNumber}</div>
                <div class="flex-grow-1">
                    <div class="d-flex align-items-center gap-2 mb-1">
                        <strong>${escapeHtml(level.title)}</strong>
                        ${level.publish ? '<span class="badge bg-success">Published</span>' : '<span class="badge bg-secondary">Draft</span>'}
                        ${level.fileName ? `<span class="badge bg-info"><i class="bi bi-paperclip"></i> ${escapeHtml(level.fileName)}</span>` : ''}
                    </div>
                    <small class="text-muted">
                        ${escapeHtml(level.description || 'No description')} • 
                        <i class="bi bi-clock"></i> ${level.minutes} min • 
                        <i class="bi bi-star"></i> ${level.xp} XP
                    </small>
                </div>
                <div class="btn-group">
                    <button type="button" class="btn btn-sm btn-outline-primary" onclick="editLevel(${level.levelNumber})">
                        <i class="bi bi-pencil"></i>
                    </button>
                    <button type="button" class="btn btn-sm btn-outline-danger" onclick="removeLevel(${level.levelNumber})">
                        <i class="bi bi-trash"></i>
                    </button>
                </div>
            </div>
        `).join('');
    }

    function updateLevelCount() {
        const count = draft.levels.length;
        const badge = document.getElementById('levelCountBadge');
        const reviewBadge = document.getElementById('reviewLevelCount');

        if (badge) {
            badge.textContent = `${count} Level${count !== 1 ? 's' : ''}`;
            badge.className = count >= 3 ? 'badge bg-success fs-6' : 'badge bg-warning fs-6';
        }

        if (reviewBadge) {
            reviewBadge.textContent = `${count} Level${count !== 1 ? 's' : ''}`;
        }

        // Enable/disable next button on step 2
        if (currentStep === 2) {
            const btnNext = document.getElementById('btnNext');
            if (btnNext) {
                btnNext.disabled = count < 3;
            }
        }
    }

    function generateReview() {
        // Class info
        document.getElementById('reviewClassName').textContent = draft.classInfo.name || 'N/A';
        document.getElementById('reviewClassCode').textContent = draft.classInfo.classCode || 'N/A';
        document.getElementById('reviewDescription').textContent = draft.classInfo.description || 'No description provided';

        // Levels
        const levelsContainer = document.getElementById('reviewLevelsList');
        if (levelsContainer) {
            levelsContainer.innerHTML = draft.levels.map((level, idx) => `
                <div class="level-list-item ${idx === draft.levels.length - 1 ? 'mb-0' : ''}">
                    <div class="level-num-badge">${level.levelNumber}</div>
                    <div class="flex-grow-1">
                        <div class="d-flex align-items-center gap-2 mb-1">
                            <strong>${escapeHtml(level.title)}</strong>
                            ${level.publish ? '<span class="badge bg-success">Published</span>' : '<span class="badge bg-secondary">Draft</span>'}
                        </div>
                        <small class="text-muted">
                            ${level.fileName ? `<i class="bi bi-paperclip"></i> ${escapeHtml(level.fileName)} • ` : ''}
                            <i class="bi bi-clock"></i> ${level.minutes} min • 
                            <i class="bi bi-star"></i> ${level.xp} XP
                        </small>
                    </div>
                </div>
            `).join('');
        }
    }

    function syncDraftToHiddenField() {
        const hf = document.getElementById(window.WIZARD_IDS.hfDraftJson);
        if (hf) {
            hf.value = JSON.stringify(draft);
        }
    }

    // Regenerate class code
    window.regenerateClassCode = function() {
        const newCode = generateRandomCode(6);
        const input = document.getElementById(window.WIZARD_IDS.txtClassCode);
        if (input) {
            input.value = newCode;
            draft.classInfo.classCode = newCode;
        }
    };

    function generateRandomCode(length) {
        const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
        let result = '';
        for (let i = 0; i < length; i++) {
            result += chars.charAt(Math.floor(Math.random() * chars.length));
        }
        return result;
    }

    function getContentType(fileName) {
        const ext = fileName.split('.').pop().toLowerCase();
        switch (ext) {
            case 'ppt':
            case 'pptx':
                return 'powerpoint';
            case 'pdf':
                return 'pdf';
            case 'mp4':
            case 'avi':
            case 'mov':
                return 'video';
            default:
                return 'unknown';
        }
    }

    function escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    // Before form submission, ensure files are included
    const form = document.querySelector('form');
    if (form) {
        form.addEventListener('submit', function() {
            syncDraftToHiddenField();
        });
    }

})();



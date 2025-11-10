// ================================================
// Add Questions Page - Logic
// ================================================

(function () {
    'use strict';

    // ===== State =====
    let quizData = {};
    let questions = [];

    // ===== Initialization =====
    document.addEventListener('DOMContentLoaded', function () {
        initPage();
    });

    function initPage() {
        loadData();
        renderQuizInfo();
        renderQuestions();
    }

    // ===== Data Loading =====
    function loadData() {
        try {
            if (!window.QUIZ_DATA) {
                console.error('QUIZ_DATA not found');
                return;
            }

            const quizDataField = document.getElementById(window.QUIZ_DATA.quizDataFieldId);
            const questionsField = document.getElementById(window.QUIZ_DATA.questionsFieldId);

            if (quizDataField && quizDataField.value) {
                quizData = JSON.parse(quizDataField.value);
            }

            if (questionsField && questionsField.value) {
                questions = JSON.parse(questionsField.value);
            }

            console.log('Loaded quiz data:', {
                quiz: quizData,
                questionCount: questions.length
            });
        } catch (error) {
            console.error('Error loading data:', error);
        }
    }

    // ===== Quiz Info Rendering =====
    function renderQuizInfo() {
        if (!quizData.Title) return;

        const nameEl = document.getElementById('quizName');
        if (nameEl) nameEl.textContent = quizData.Title;

        const timeLimitEl = document.getElementById('quizTimeLimit');
        if (timeLimitEl) timeLimitEl.textContent = quizData.TimeLimit + ' minutes';

        const passingScoreEl = document.getElementById('quizPassingScore');
        if (passingScoreEl) passingScoreEl.textContent = quizData.PassingScore + '%';

        const modeEl = document.getElementById('quizMode');
        if (modeEl) modeEl.textContent = quizData.Mode || 'Story';

        const statusEl = document.getElementById('quizStatus');
        if (statusEl) statusEl.textContent = quizData.Published ? 'Published' : 'Draft';

        const totalEl = document.getElementById('totalQuestions');
        if (totalEl) totalEl.textContent = questions.length;

        const countEl = document.getElementById('questionCount');
        if (countEl) countEl.textContent = questions.length;
    }

    // ===== Questions Rendering =====
    function renderQuestions() {
        const container = document.getElementById('questionsContainer');
        const noQuestions = document.getElementById('noQuestions');

        if (!container) return;

        if (questions.length === 0) {
            container.style.display = 'none';
            if (noQuestions) noQuestions.style.display = 'block';
            return;
        }

        container.style.display = 'flex';
        if (noQuestions) noQuestions.style.display = 'none';

        container.innerHTML = '';

        questions.forEach(function (question, index) {
            const item = createQuestionItem(question, index + 1);
            container.appendChild(item);
        });
        
        // Remove any edit/delete buttons that might exist (safety check)
        removeActionButtons();
    }
    
    // Remove edit and delete buttons from question items
    function removeActionButtons() {
        const questionItems = document.querySelectorAll('.question-item');
        questionItems.forEach(function(item) {
            // Remove the entire question-actions div if it exists
            const actionsDiv = item.querySelector('.question-actions');
            if (actionsDiv) {
                actionsDiv.remove();
            }
            
            // Remove any buttons that contain pencil or trash icons
            const allButtons = item.querySelectorAll('button');
            allButtons.forEach(function(btn) {
                const hasPencilIcon = btn.querySelector('.bi-pencil') || btn.innerHTML.includes('bi-pencil');
                const hasTrashIcon = btn.querySelector('.bi-trash') || btn.innerHTML.includes('bi-trash');
                const hasEditOnClick = btn.getAttribute('onclick') && btn.getAttribute('onclick').includes('editQuestion');
                const hasDeleteOnClick = btn.getAttribute('onclick') && btn.getAttribute('onclick').includes('deleteQuestion');
                
                if (hasPencilIcon || hasTrashIcon || hasEditOnClick || hasDeleteOnClick) {
                    btn.remove();
                }
            });
        });
    }

    function createQuestionItem(question, number) {
        const div = document.createElement('div');
        div.className = 'question-item';

        let options = [];
        try {
            options = JSON.parse(question.OptionsJson);
        } catch (e) {
            console.error('Error parsing options:', e);
        }

        const stars = '★'.repeat(question.Difficulty) + '☆'.repeat(5 - question.Difficulty);

        let optionsHtml = '';
        options.forEach(function (option, idx) {
            const isCorrect = idx === question.AnswerIdx;
            optionsHtml += `
                <div class="option-item ${isCorrect ? 'correct' : ''}">
                    <i class="bi bi-${isCorrect ? 'check-circle-fill' : 'circle'}"></i>
                    ${escapeHtml(option)}
                </div>
            `;
        });

        div.innerHTML = `
            <div class="question-number">${number}</div>
            <div class="question-body">${escapeHtml(question.BodyText)}</div>
            <div class="question-options">
                ${optionsHtml}
            </div>
            ${question.Explanation ? `
                <div class="alert alert-info mx-5 mb-3">
                    <strong><i class="bi bi-lightbulb me-1"></i> Explanation:</strong> ${escapeHtml(question.Explanation)}
                </div>
            ` : ''}
            <div class="question-footer">
                <div class="question-meta">
                    <span class="difficulty-stars" title="Difficulty: ${question.Difficulty}/5">${stars}</span>
                    <span><i class="bi bi-list-ol me-1"></i>Order: ${question.OrderNo}</span>
                </div>
                <!-- Edit and Delete buttons removed - questions are read-only on this page -->
            </div>
        `;

        return div;
    }

    // ===== Modal Functions =====
    window.openAddQuestionModal = function () {
        const modal = document.getElementById('addQuestionModal');
        if (modal) modal.style.display = 'flex';
        
        // Reset options to 2 when opening modal
        if (window.updateOptionVisibility) {
            // Reset option visibility flags
            if (window.option3Visible !== undefined) {
                window.option3Visible = false;
            }
            if (window.option4Visible !== undefined) {
                window.option4Visible = false;
            }
            
            // Clear option 3 and 4 textboxes if they exist
            const option3 = document.querySelector('input[id*="txtOption3"]');
            const option4 = document.querySelector('input[id*="txtOption4"]');
            if (option3) option3.value = '';
            if (option4) option4.value = '';
            
            // Reset radio to first option
            const radio0 = document.getElementById('radio0');
            if (radio0) {
                radio0.checked = true;
                const correctAnswerField = document.getElementById(window.QUIZ_DATA.correctAnswerFieldId);
                if (correctAnswerField) correctAnswerField.value = '0';
            }
            
            window.updateOptionVisibility();
        }
    };

    window.closeAddQuestionModal = function () {
        const modal = document.getElementById('addQuestionModal');
        if (modal) modal.style.display = 'none';
    };

    window.showSuccessToast = function (message) {
        const toast = document.createElement('div');
        toast.className = 'toast-notification';
        toast.innerHTML = `<i class="bi bi-check-circle me-2"></i>${message}`;
        document.body.appendChild(toast);

        setTimeout(() => toast.remove(), 3000);
    };

    window.finishQuiz = function () {
        if (questions.length === 0) {
            alert('Please add at least one question before finishing.');
            return;
        }

        if (confirm('Finish editing this quiz?')) {
            history.back();
        }
    };

    window.editQuestion = function (questionSlug) {
        if (!window.QUIZ_DATA || !window.QUIZ_DATA.quizSlug) {
            console.error('Quiz data not available');
            return;
        }
        
        const quizSlug = window.QUIZ_DATA.quizSlug;
        const classSlug = getQueryParam('class');
        const levelSlug = getQueryParam('level');
        let url = `edit_question.aspx?question=${encodeURIComponent(questionSlug)}&quiz=${encodeURIComponent(quizSlug)}`;
        if (levelSlug) {
            url += `&level=${encodeURIComponent(levelSlug)}`;
        }
        if (classSlug) {
            url += `&class=${encodeURIComponent(classSlug)}`;
        }
        window.location.href = url;
    };

    function getQueryParam(name) {
        const urlParams = new URLSearchParams(window.location.search);
        return urlParams.get(name);
    }

    window.deleteQuestion = function (questionSlug) {
        if (confirm('Are you sure you want to delete this question?')) {
            // TODO: Implement delete
            alert('Delete functionality would be implemented here.');
        }
    };

    // ===== Helper Functions =====
    function escapeHtml(text) {
        if (!text) return '';
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    // Close modal on ESC
    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') {
            window.closeAddQuestionModal();
        }
    });

})();


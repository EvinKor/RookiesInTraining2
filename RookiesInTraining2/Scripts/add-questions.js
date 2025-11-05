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
                <div class="question-actions">
                    <button class="btn btn-sm btn-outline-primary" onclick="editQuestion('${question.QuestionSlug}')">
                        <i class="bi bi-pencil"></i>
                    </button>
                    <button class="btn btn-sm btn-outline-danger" onclick="deleteQuestion('${question.QuestionSlug}')">
                        <i class="bi bi-trash"></i>
                    </button>
                </div>
            </div>
        `;

        return div;
    }

    // ===== Modal Functions =====
    window.openAddQuestionModal = function () {
        const modal = document.getElementById('addQuestionModal');
        if (modal) modal.style.display = 'flex';
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
        alert('Edit question: ' + questionSlug + '\n\nThis would open the question editor.');
    };

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


<%@ Page Title="Take Quiz - Student"
    Language="C#"
    MasterPageFile="~/MasterPages/MyMain.Master"
    AutoEventWireup="true"
    CodeBehind="take_quiz.aspx.cs"
    Inherits="RookiesInTraining2.Pages.student.take_quiz" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    
    <div class="container mt-4">
        <!-- Quiz Header -->
        <div class="card border-0 shadow-sm mb-4">
            <div class="card-body p-4" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white;">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h2 class="mb-2"><asp:Label ID="lblQuizTitle" runat="server" /></h2>
                        <p class="mb-0 opacity-90">
                            <i class="bi bi-clock me-1"></i>Time Limit: <asp:Label ID="lblTimeLimit" runat="server" /> minutes
                            <span class="ms-3"><i class="bi bi-check-circle me-1"></i>Pass: <asp:Label ID="lblPassingScore" runat="server" />%</span>
                        </p>
                    </div>
                    <div class="text-end">
                        <h4 class="mb-1" id="timerDisplay">00:00</h4>
                        <small class="opacity-75">Time Remaining</small>
                    </div>
                </div>
            </div>
        </div>

        <!-- Quiz Content -->
        <div id="quizContent">
            <!-- Questions will be loaded here -->
        </div>

        <!-- Submit Button -->
        <div class="card border-0 shadow-sm mt-4">
            <div class="card-body p-4 text-center">
                <button type="button" id="btnSubmitQuiz" class="btn btn-success btn-lg" onclick="submitQuiz()">
                    <i class="bi bi-check-circle-fill me-2"></i>Submit Quiz
                </button>
                <asp:HyperLink ID="lnkCancel" runat="server" CssClass="btn btn-outline-secondary btn-lg ms-3">
                    <i class="bi bi-x-circle me-2"></i>Cancel
                </asp:HyperLink>
            </div>
        </div>
    </div>

    <!-- Results Modal -->
    <div class="modal fade" id="resultsModal" tabindex="-1" data-bs-backdrop="static">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header border-0">
                    <h5 class="modal-title">Quiz Results</h5>
                </div>
                <div class="modal-body text-center py-5">
                    <div id="resultsIcon" class="mb-3"></div>
                    <h3 id="resultsTitle" class="mb-3"></h3>
                    <div class="row g-3 mb-4">
                        <div class="col-6">
                            <div class="card bg-light">
                                <div class="card-body">
                                    <h5 id="scoreDisplay" class="mb-1">0%</h5>
                                    <small class="text-muted">Your Score</small>
                                </div>
                            </div>
                        </div>
                        <div class="col-6">
                            <div class="card bg-light">
                                <div class="card-body">
                                    <h5 id="correctDisplay" class="mb-1">0/0</h5>
                                    <small class="text-muted">Correct</small>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div id="xpEarned" class="alert alert-success" style="display: none;">
                        <i class="bi bi-star-fill me-2"></i>
                        <strong>You earned <span id="xpAmount"></span> XP!</strong>
                    </div>
                </div>
                <div class="modal-footer border-0">
                    <button type="button" class="btn btn-primary" onclick="backToLevel()">
                        <i class="bi bi-arrow-left me-2"></i>Back to Level
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Alert Modal (for info/warning messages) -->
    <div class="modal fade" id="alertModal" tabindex="-1">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header border-0">
                    <h5 class="modal-title" id="alertModalTitle">Notice</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body text-center py-4">
                    <div id="alertModalIcon" class="mb-3"></div>
                    <p id="alertModalMessage" class="mb-0"></p>
                </div>
                <div class="modal-footer border-0 justify-content-center">
                    <button type="button" class="btn btn-primary" data-bs-dismiss="modal" id="alertModalBtn">OK</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Confirm Modal (for yes/no questions) -->
    <div class="modal fade" id="confirmModal" tabindex="-1">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header border-0">
                    <h5 class="modal-title" id="confirmModalTitle">Confirm</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body text-center py-4">
                    <div id="confirmModalIcon" class="mb-3">
                        <i class="bi bi-question-circle text-warning" style="font-size: 4rem;"></i>
                    </div>
                    <p id="confirmModalMessage" class="mb-0"></p>
                </div>
                <div class="modal-footer border-0 justify-content-center">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary" id="confirmModalYes">Confirm</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Hidden Fields -->
    <asp:HiddenField ID="hfQuestionsJson" runat="server" />
    <asp:HiddenField ID="hfQuizSlug" runat="server" />
    <asp:HiddenField ID="hfLevelSlug" runat="server" />
    <asp:HiddenField ID="hfClassSlug" runat="server" />
    <asp:HiddenField ID="hfTimeLimit" runat="server" />
    <asp:HiddenField ID="hfPassingScore" runat="server" />
    <asp:HiddenField ID="hfXpReward" runat="server" />

    <script>
        let questions = [];
        let answers = {};
        let timerInterval;
        let timeRemaining = 0;

        // Modal helper functions
        function showAlertModal(title, message, type = 'info', callback = null) {
            document.getElementById('alertModalTitle').textContent = title;
            document.getElementById('alertModalMessage').textContent = message;
            
            // Set icon based on type
            const iconDiv = document.getElementById('alertModalIcon');
            if (type === 'error') {
                iconDiv.innerHTML = '<i class="bi bi-x-circle text-danger" style="font-size: 4rem;"></i>';
            } else if (type === 'warning') {
                iconDiv.innerHTML = '<i class="bi bi-exclamation-triangle text-warning" style="font-size: 4rem;"></i>';
            } else if (type === 'success') {
                iconDiv.innerHTML = '<i class="bi bi-check-circle text-success" style="font-size: 4rem;"></i>';
            } else {
                iconDiv.innerHTML = '<i class="bi bi-info-circle text-primary" style="font-size: 4rem;"></i>';
            }
            
            const modal = new bootstrap.Modal(document.getElementById('alertModal'));
            
            // If callback provided, execute it when modal is hidden
            if (callback) {
                document.getElementById('alertModal').addEventListener('hidden.bs.modal', function handler() {
                    callback();
                    document.getElementById('alertModal').removeEventListener('hidden.bs.modal', handler);
                });
            }
            
            modal.show();
        }

        function showConfirmModal(title, message, onConfirm, onCancel = null) {
            document.getElementById('confirmModalTitle').textContent = title;
            document.getElementById('confirmModalMessage').textContent = message;
            
            const modal = new bootstrap.Modal(document.getElementById('confirmModal'));
            const yesBtn = document.getElementById('confirmModalYes');
            
            // Remove old event listeners by cloning
            const newYesBtn = yesBtn.cloneNode(true);
            yesBtn.parentNode.replaceChild(newYesBtn, yesBtn);
            
            // Add new event listener
            newYesBtn.addEventListener('click', function() {
                modal.hide();
                if (onConfirm) onConfirm();
            });
            
            // Handle cancel
            if (onCancel) {
                document.getElementById('confirmModal').addEventListener('hidden.bs.modal', function handler(e) {
                    if (e.target.classList.contains('btn-secondary')) {
                        onCancel();
                    }
                    document.getElementById('confirmModal').removeEventListener('hidden.bs.modal', handler);
                });
            }
            
            modal.show();
        }

        window.addEventListener('DOMContentLoaded', function() {
            loadQuiz();
            startTimer();
        });

        function loadQuiz() {
            const questionsField = document.getElementById('<%= hfQuestionsJson.ClientID %>');
            
            if (!questionsField || !questionsField.value) {
                showAlertModal('No Questions Found', 'No questions found for this quiz!', 'error', function() {
                    window.history.back();
                });
                return;
            }
            
            try {
                questions = JSON.parse(questionsField.value);
                
                if (questions.length === 0) {
                    showAlertModal('No Questions Found', 'No questions found for this quiz!', 'error', function() {
                        window.history.back();
                    });
                    return;
                }
                
                renderQuestions();
            } catch (error) {
                console.error('Error loading quiz:', error);
                showAlertModal('Error', 'Error loading quiz. Please try again.', 'error');
            }
        }

        function renderQuestions() {
            const container = document.getElementById('quizContent');
            
            container.innerHTML = questions.map((q, index) => `
                <div class="card border-0 shadow-sm mb-3">
                    <div class="card-body p-4">
                        <div class="d-flex align-items-start mb-3">
                            <div class="rounded-circle bg-primary text-white d-flex align-items-center justify-content-center me-3"
                                 style="width: 40px; height: 40px; font-size: 1.2rem; font-weight: 700; flex-shrink: 0;">
                                ${index + 1}
                            </div>
                            <div class="flex-grow-1">
                                <h6 class="mb-0">${escapeHtml(q.QuestionText)}</h6>
                            </div>
                        </div>
                        
                        <div class="ms-5">
                            ${renderOptions(q, index)}
                        </div>
                    </div>
                </div>
            `).join('');
        }

        function renderOptions(question, questionIndex) {
            const options = [
                { key: 'A', value: question.OptionA },
                { key: 'B', value: question.OptionB },
                { key: 'C', value: question.OptionC },
                { key: 'D', value: question.OptionD }
            ].filter(opt => opt.value && opt.value.trim() !== '');
            
            return options.map(opt => `
                <div class="form-check mb-2">
                    <input class="form-check-input" type="radio" 
                           name="question_${questionIndex}" 
                           id="q${questionIndex}_${opt.key}" 
                           value="${opt.key}"
                           onchange="recordAnswer(${questionIndex}, '${opt.key}')">
                    <label class="form-check-label" for="q${questionIndex}_${opt.key}">
                        <strong>${opt.key}.</strong> ${escapeHtml(opt.value)}
                    </label>
                </div>
            `).join('');
        }

        function recordAnswer(questionIndex, answer) {
            answers[questionIndex] = answer;
        }

        function startTimer() {
            const timeLimitField = document.getElementById('<%= hfTimeLimit.ClientID %>');
            const timeLimit = parseInt(timeLimitField.value) || 30;
            timeRemaining = timeLimit * 60; // Convert to seconds
            
            updateTimerDisplay();
            
            timerInterval = setInterval(() => {
                timeRemaining--;
                updateTimerDisplay();
                
                if (timeRemaining <= 0) {
                    clearInterval(timerInterval);
                    showAlertModal('Time\'s Up!', 'Time is up! Your quiz will be submitted automatically.', 'warning', function() {
                        processQuizSubmission();
                    });
                }
            }, 1000);
        }

        function updateTimerDisplay() {
            const minutes = Math.floor(timeRemaining / 60);
            const seconds = timeRemaining % 60;
            document.getElementById('timerDisplay').textContent = 
                `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
            
            // Change color when time is running out
            const display = document.getElementById('timerDisplay');
            if (timeRemaining < 60) {
                display.style.color = '#ff6b6b';
                display.style.fontWeight = 'bold';
            }
        }

        function submitQuiz() {
            // Check if all questions are answered
            const unanswered = questions.filter((q, i) => !answers[i]).length;
            if (unanswered > 0) {
                showConfirmModal(
                    'Incomplete Quiz',
                    `You have ${unanswered} unanswered question(s). Do you want to submit anyway?`,
                    function() {
                        // User confirmed, process the submission
                        clearInterval(timerInterval);
                        processQuizSubmission();
                    }
                );
                return;
            }
            
            // All questions answered, proceed
            clearInterval(timerInterval);
            processQuizSubmission();
        }

        function processQuizSubmission() {
            // Calculate score
            let correct = 0;
            questions.forEach((q, i) => {
                if (answers[i] === q.CorrectAnswer) {
                    correct++;
                }
            });
            
            const scorePercent = Math.round((correct / questions.length) * 100);
            const passingScore = parseInt(document.getElementById('<%= hfPassingScore.ClientID %>').value);
            const passed = scorePercent >= passingScore;
            
            // Show results
            showResults(scorePercent, correct, questions.length, passed);
            
            // Save attempt to database
            saveAttempt(scorePercent, passed);
        }

        function showResults(scorePercent, correct, total, passed) {
            const modal = new bootstrap.Modal(document.getElementById('resultsModal'));
            
            // Update results display
            if (passed) {
                document.getElementById('resultsIcon').innerHTML = 
                    '<i class="bi bi-check-circle-fill text-success" style="font-size: 5rem;"></i>';
                document.getElementById('resultsTitle').innerHTML = 
                    '<span class="text-success">Congratulations! You Passed!</span>';
                
                const xpReward = document.getElementById('<%= hfXpReward.ClientID %>').value;
                document.getElementById('xpEarned').style.display = 'block';
                document.getElementById('xpAmount').textContent = xpReward;
            } else {
                document.getElementById('resultsIcon').innerHTML = 
                    '<i class="bi bi-x-circle-fill text-danger" style="font-size: 5rem;"></i>';
                document.getElementById('resultsTitle').innerHTML = 
                    '<span class="text-danger">Keep Trying!</span>';
                document.getElementById('xpEarned').style.display = 'none';
            }
            
            document.getElementById('scoreDisplay').textContent = scorePercent + '%';
            document.getElementById('correctDisplay').textContent = `${correct}/${total}`;
            
            modal.show();
        }

        function saveAttempt(scorePercent, passed) {
            const quizSlug = document.getElementById('<%= hfQuizSlug.ClientID %>').value;
            const levelSlug = document.getElementById('<%= hfLevelSlug.ClientID %>').value;
            
            // Prepare answers data
            const answersData = questions.map((q, i) => ({
                question_slug: q.QuestionSlug,
                selected_answer: answers[i] || '',
                is_correct: answers[i] === q.CorrectAnswer
            }));
            
            // Send to server
            fetch('<%= ResolveUrl("~/api/SaveQuizAttempt.ashx") %>', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    quiz_slug: quizSlug,
                    level_slug: levelSlug,
                    score: scorePercent,
                    passed: passed,
                    answers: answersData
                })
            })
            .then(response => response.json())
            .then(data => {
                if (!data.success) {
                    console.error('Error saving attempt:', data.error);
                }
            })
            .catch(error => {
                console.error('Error saving attempt:', error);
            });
        }

        function backToLevel() {
            const levelSlug = document.getElementById('<%= hfLevelSlug.ClientID %>').value;
            const classSlug = document.getElementById('<%= hfClassSlug.ClientID %>').value;
            window.location.href = `take_level.aspx?level=${levelSlug}&class=${classSlug}`;
        }

        function escapeHtml(text) {
            const div = document.createElement('div');
            div.textContent = text || '';
            return div.innerHTML;
        }

        // Prevent accidental page close
        window.addEventListener('beforeunload', function (e) {
            if (timeRemaining > 0) {
                e.preventDefault();
                e.returnValue = '';
                return '';
            }
        });
    </script>

    <style>
        .form-check-input:checked {
            background-color: #667eea;
            border-color: #667eea;
        }
        
        .form-check-input:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 0.25rem rgba(102, 126, 234, 0.25);
        }
        
        .form-check-label {
            cursor: pointer;
            padding: 0.5rem;
            border-radius: 0.375rem;
            transition: background-color 0.2s;
        }
        
        .form-check-label:hover {
            background-color: #f8f9fa;
        }

        /* Modal animations and styling */
        .modal-content {
            border: none;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
            border-radius: 1rem;
        }

        .modal-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 1rem 1rem 0 0 !important;
        }

        .modal-header .btn-close {
            filter: invert(1) brightness(100);
        }

        #alertModal .modal-header,
        #confirmModal .modal-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }

        #resultsModal .modal-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }

        .modal-body p {
            font-size: 1.1rem;
            color: #495057;
        }

        .modal-footer .btn {
            min-width: 100px;
            font-weight: 600;
        }

        /* Smooth fade animation */
        .modal.fade .modal-dialog {
            transform: scale(0.8);
            opacity: 0;
            transition: transform 0.3s ease-out, opacity 0.3s ease-out;
        }

        .modal.show .modal-dialog {
            transform: scale(1);
            opacity: 1;
        }
    </style>

</asp:Content>


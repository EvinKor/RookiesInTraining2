<%@ Page Title="Story Stage"
    Language="C#"
    MasterPageFile="~/MasterPages/dashboard.Master"
    AutoEventWireup="true"
    CodeBehind="story_stage.aspx.cs"
    Inherits="RookiesInTraining2.Pages.story_stage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="DashboardContent" runat="server">
    <div class="container py-4">
        <div class="row">
            <div class="col-12">
                <nav aria-label="breadcrumb" class="mb-4">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="story.aspx">Story Mode</a></li>
                        <li class="breadcrumb-item active" id="breadcrumbStage" runat="server">Stage</li>
                    </ol>
                </nav>

                <div id="stageInfo" runat="server" class="card mb-4" style="background: #111827; border-color: #1f2937;">
                    <div class="card-body">
                        <h2 id="stageTitle" runat="server" class="text-light"></h2>
                        <p id="stageDescription" runat="server" class="text-muted"></p>
                        <div class="d-flex gap-3">
                            <span class="badge bg-primary">
                                <i class="bi bi-star-fill"></i> <span id="stageXP" runat="server">0</span> XP
                            </span>
                            <span class="badge bg-info">
                                <i class="bi bi-clock"></i> <span id="stageTime" runat="server">0</span> min
                            </span>
                        </div>
                    </div>
                </div>

                <!-- Quiz Container -->
                <div id="quizContainer" class="card" style="background: #111827; border-color: #1f2937;">
                    <div class="card-body">
                        <div id="quizLoading" class="text-center py-5">
                            <div class="spinner-border text-primary" role="status">
                                <span class="visually-hidden">Loading...</span>
                            </div>
                        </div>

                        <div id="quizContent" style="display: none;">
                            <div class="d-flex justify-content-between align-items-center mb-4">
                                <h4 class="text-light mb-0">Quiz: <span id="quizTitle"></span></h4>
                                <div>
                                    <span class="badge bg-secondary">Question <span id="currentQuestion">1</span> of <span id="totalQuestions">0</span></span>
                                </div>
                            </div>

                            <div id="questionsContainer">
                                <!-- Questions loaded dynamically -->
                            </div>

                            <div class="mt-4 d-flex justify-content-between">
                                <button id="btnPrev" class="btn btn-outline-light" onclick="previousQuestion()" style="display: none;">
                                    <i class="bi bi-arrow-left"></i> Previous
                                </button>
                                <button id="btnNext" class="btn btn-primary" onclick="nextQuestion()">
                                    Next <i class="bi bi-arrow-right"></i>
                                </button>
                                <button id="btnSubmit" class="btn btn-success" onclick="submitQuiz()" style="display: none;">
                                    <i class="bi bi-check-circle"></i> Submit Quiz
                                </button>
                            </div>
                        </div>

                        <div id="quizResults" style="display: none;">
                            <div class="text-center py-5">
                                <h3 class="text-light mb-4">Quiz Complete!</h3>
                                <div class="mb-4">
                                    <div class="display-1 text-primary" id="finalScore">0</div>
                                    <div class="text-muted">Score</div>
                                </div>
                                <div class="mb-4">
                                    <span class="badge bg-success" id="xpEarned">+0 XP</span>
                                </div>
                                <div class="d-flex gap-2 justify-content-center">
                                    <a href="story.aspx" class="btn btn-outline-light">Back to Story</a>
                                    <button id="btnNextStage" class="btn btn-primary" onclick="unlockNextStage()" style="display: none;">
                                        Unlock Next Stage
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <asp:HiddenField ID="hfStageSlug" runat="server" />
    <asp:HiddenField ID="hfQuizData" runat="server" />
    <asp:HiddenField ID="hfQuestionsJson" runat="server" />

    <script>
        var currentQuestionIndex = 0;
        var questions = [];
        var answers = {};
        var quizData = null;

        document.addEventListener('DOMContentLoaded', function() {
            var quizDataJson = document.getElementById('<%= hfQuizData.ClientID %>').value;
            var questionsJson = document.getElementById('<%= hfQuestionsJson.ClientID %>').value;

            if (quizDataJson && questionsJson) {
                quizData = JSON.parse(quizDataJson);
                questions = JSON.parse(questionsJson);
                
                if (questions.length > 0) {
                    loadQuestion(0);
                    document.getElementById('quizLoading').style.display = 'none';
                    document.getElementById('quizContent').style.display = 'block';
                    document.getElementById('totalQuestions').textContent = questions.length;
                    document.getElementById('quizTitle').textContent = quizData.title;
                }
            }
        });

        function loadQuestion(index) {
            if (index < 0 || index >= questions.length) return;

            currentQuestionIndex = index;
            var question = questions[index];
            var container = document.getElementById('questionsContainer');
            
            container.innerHTML = `
                <div class="card mb-3" style="background: #1f2937; border-color: #374151;">
                    <div class="card-body">
                        <h5 class="text-light mb-3">${question.bodyText}</h5>
                        <div class="list-group">
                            ${question.options.map((opt, idx) => `
                                <label class="list-group-item" style="background: #111827; border-color: #374151; cursor: pointer;">
                                    <input type="radio" name="answer_${index}" value="${idx}" 
                                           ${answers[index] === idx ? 'checked' : ''}
                                           onchange="answers[${index}] = ${idx}">
                                    <span class="ms-2 text-light">${opt}</span>
                                </label>
                            `).join('')}
                        </div>
                    </div>
                </div>
            `;

            document.getElementById('currentQuestion').textContent = index + 1;
            document.getElementById('btnPrev').style.display = index > 0 ? 'block' : 'none';
            document.getElementById('btnNext').style.display = index < questions.length - 1 ? 'block' : 'none';
            document.getElementById('btnSubmit').style.display = index === questions.length - 1 ? 'block' : 'none';
        }

        function previousQuestion() {
            if (currentQuestionIndex > 0) {
                loadQuestion(currentQuestionIndex - 1);
            }
        }

        function nextQuestion() {
            if (currentQuestionIndex < questions.length - 1) {
                loadQuestion(currentQuestionIndex + 1);
            }
        }

        function submitQuiz() {
            // Calculate score
            var correct = 0;
            questions.forEach((q, idx) => {
                if (answers[idx] === q.answerIdx) {
                    correct++;
                }
            });

            var score = Math.round((correct / questions.length) * 100);
            var xpEarned = Math.round(quizData.xpReward * (score / 100));

            // Show results
            document.getElementById('quizContent').style.display = 'none';
            document.getElementById('quizResults').style.display = 'block';
            document.getElementById('finalScore').textContent = score + '%';
            document.getElementById('xpEarned').textContent = '+' + xpEarned + ' XP';

            // Submit to server
            submitQuizResults(score, xpEarned, correct, questions.length);
        }

        function submitQuizResults(score, xp, correct, total) {
            var stageSlug = document.getElementById('<%= hfStageSlug.ClientID %>').value;
            
            fetch('story_stage.aspx/CompleteStage', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    stageSlug: stageSlug,
                    score: score,
                    xpEarned: xp,
                    correctAnswers: correct,
                    totalQuestions: total
                })
            })
            .then(response => response.json())
            .then(data => {
                if (data.d && data.d.unlockNext) {
                    document.getElementById('btnNextStage').style.display = 'block';
                }
            })
            .catch(error => console.error('Error:', error));
        }

        function unlockNextStage() {
            window.location.href = 'story.aspx';
        }
    </script>
</asp:Content>


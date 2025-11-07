<%@ Page Title="Add Questions"
    Language="C#"
    MasterPageFile="~/MasterPages/MyMain.Master"
    AutoEventWireup="true"
    CodeBehind="add_questions.aspx.cs"
    Inherits="RookiesInTraining2.Pages.add_questions" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <link rel="stylesheet" href="<%= ResolveUrl("~/Content/add-questions.css") %>" />

    <div class="add-questions-container">
        
        <!-- Header -->
        <div class="page-header">
            <div class="container-fluid py-4">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <a href="javascript:history.back()" class="btn btn-sm btn-outline-light mb-2">
                            <i class="bi bi-arrow-left me-1"></i> Back
                        </a>
                        <h1 class="mb-1" id="quizTitle">Add Questions to Quiz</h1>
                        <p class="text-white-50 mb-0">Quiz: <span id="quizName">Loading...</span></p>
                    </div>
                    <button type="button" class="btn btn-light btn-lg" onclick="finishQuiz()">
                        <i class="bi bi-check-circle me-2"></i>Finish & Save
                    </button>
                </div>
            </div>
        </div>

        <!-- Questions List -->
        <div class="container-fluid py-4">
            <div class="row">
                <div class="col-lg-8">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h3>Questions (<span id="questionCount">0</span>)</h3>
                        <button type="button" class="btn btn-primary" onclick="openAddQuestionModal()">
                            <i class="bi bi-plus-circle me-2"></i>Add Question
                        </button>
                    </div>

                    <div id="questionsContainer" class="questions-list">
                        <!-- Questions will be rendered here -->
                    </div>

                    <div id="noQuestions" class="empty-state" style="display: none;">
                        <i class="bi bi-question-circle display-4 text-muted"></i>
                        <h4>No Questions Yet</h4>
                        <p class="text-muted">Add your first question to this quiz</p>
                        <button type="button" class="btn btn-primary btn-lg" onclick="openAddQuestionModal()">
                            <i class="bi bi-plus-circle me-2"></i>Add First Question
                        </button>
                    </div>
                </div>

                <!-- Sidebar -->
                <div class="col-lg-4">
                    <div class="card border-0 shadow-sm sticky-top" style="top: 20px;">
                        <div class="card-body">
                            <h5 class="card-title mb-3">Quiz Settings</h5>
                            <div class="mb-2">
                                <small class="text-muted">Time Limit</small>
                                <div class="fw-bold" id="quizTimeLimit">30 minutes</div>
                            </div>
                            <div class="mb-2">
                                <small class="text-muted">Passing Score</small>
                                <div class="fw-bold" id="quizPassingScore">70%</div>
                            </div>
                            <div class="mb-2">
                                <small class="text-muted">Mode</small>
                                <div class="fw-bold" id="quizMode">Story</div>
                            </div>
                            <hr>
                            <div class="mb-2">
                                <small class="text-muted">Total Questions</small>
                                <div class="fw-bold" id="totalQuestions">0</div>
                            </div>
                            <div class="mb-2">
                                <small class="text-muted">Status</small>
                                <div class="fw-bold" id="quizStatus">Draft</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- ADD QUESTION MODAL -->
        <div id="addQuestionModal" class="custom-modal" style="display: none;">
            <div class="modal-overlay" onclick="closeAddQuestionModal()"></div>
            <div class="modal-content modal-lg">
                <div class="modal-header">
                    <h3 id="questionModalTitle">Add New Question</h3>
                    <button type="button" class="btn-close" onclick="closeAddQuestionModal()">
                        <i class="bi bi-x-lg"></i>
                    </button>
                </div>
                <div class="modal-body">
                    <asp:Label ID="lblQuestionError" runat="server" CssClass="alert alert-danger" Visible="false" />

                    <div class="mb-3">
                        <label class="form-label fw-bold">Question Text <span class="text-danger">*</span></label>
                        <asp:TextBox ID="txtQuestionBody" runat="server" TextMode="MultiLine" Rows="3"
                                     CssClass="form-control" placeholder="Enter your question here..." MaxLength="1000" />
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtQuestionBody"
                            ValidationGroup="AddQuestion" CssClass="text-danger small" ErrorMessage="Question is required" Display="Dynamic" />
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-bold">Answer Options <span class="text-danger">*</span></label>
                        
                        <div class="option-group mb-2">
                            <div class="input-group">
                                <div class="input-group-text">
                                    <input type="radio" name="correctAnswer" value="0" id="radio0" checked>
                                </div>
                                <asp:TextBox ID="txtOption1" runat="server" CssClass="form-control" placeholder="Option 1" MaxLength="500" />
                            </div>
                        </div>

                        <div class="option-group mb-2">
                            <div class="input-group">
                                <div class="input-group-text">
                                    <input type="radio" name="correctAnswer" value="1" id="radio1">
                                </div>
                                <asp:TextBox ID="txtOption2" runat="server" CssClass="form-control" placeholder="Option 2" MaxLength="500" />
                            </div>
                        </div>

                        <div class="option-group mb-2">
                            <div class="input-group">
                                <div class="input-group-text">
                                    <input type="radio" name="correctAnswer" value="2" id="radio2">
                                </div>
                                <asp:TextBox ID="txtOption3" runat="server" CssClass="form-control" placeholder="Option 3" MaxLength="500" />
                            </div>
                        </div>

                        <div class="option-group">
                            <div class="input-group">
                                <div class="input-group-text">
                                    <input type="radio" name="correctAnswer" value="3" id="radio3">
                                </div>
                                <asp:TextBox ID="txtOption4" runat="server" CssClass="form-control" placeholder="Option 4" MaxLength="500" />
                            </div>
                        </div>

                        <small class="text-muted">Select the correct answer by clicking the radio button</small>
                        <asp:HiddenField ID="hfCorrectAnswerIdx" runat="server" Value="0" />
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-bold">Explanation (Optional)</label>
                        <asp:TextBox ID="txtExplanation" runat="server" TextMode="MultiLine" Rows="2"
                                     CssClass="form-control" placeholder="Explain why this is the correct answer..." MaxLength="1000" />
                        <small class="text-muted">Shown to students after they answer</small>
                    </div>

                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Difficulty</label>
                            <asp:DropDownList ID="ddlDifficulty" runat="server" CssClass="form-select">
                                <asp:ListItem Value="1">1 - Very Easy</asp:ListItem>
                                <asp:ListItem Value="2">2 - Easy</asp:ListItem>
                                <asp:ListItem Value="3" Selected="True">3 - Medium</asp:ListItem>
                                <asp:ListItem Value="4">4 - Hard</asp:ListItem>
                                <asp:ListItem Value="5">5 - Very Hard</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" onclick="closeAddQuestionModal()">Cancel</button>
                    <asp:Button ID="btnSaveQuestion" runat="server" Text="Add Question" 
                                CssClass="btn btn-primary btn-lg" ValidationGroup="AddQuestion"
                                OnClick="btnSaveQuestion_Click" />
                    <asp:Button ID="btnSaveAndAddAnother" runat="server" Text="Save & Add Another" 
                                CssClass="btn btn-success btn-lg" ValidationGroup="AddQuestion"
                                OnClick="btnSaveAndAddAnother_Click" />
                </div>
            </div>
        </div>

        <!-- Hidden Fields -->
        <asp:HiddenField ID="hfQuizSlug" runat="server" />
        <asp:HiddenField ID="hfQuestionsJson" runat="server" />
        <asp:HiddenField ID="hfQuizData" runat="server" />
    </div>

    <script type="text/javascript">
        window.QUIZ_DATA = {
            quizSlug: '<%= Request.QueryString["quiz"] %>',
            questionsFieldId: '<%= hfQuestionsJson.ClientID %>',
            quizDataFieldId: '<%= hfQuizData.ClientID %>',
            correctAnswerFieldId: '<%= hfCorrectAnswerIdx.ClientID %>'
        };

        // Update hidden field when radio changes
        document.addEventListener('DOMContentLoaded', function() {
            const radios = document.querySelectorAll('input[name="correctAnswer"]');
            radios.forEach(function(radio) {
                radio.addEventListener('change', function() {
                    document.getElementById(window.QUIZ_DATA.correctAnswerFieldId).value = this.value;
                });
            });
        });
    </script>

    <script src="<%= ResolveUrl("~/Scripts/add-questions.js") %>"></script>
</asp:Content>


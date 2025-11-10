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

                        <div class="option-group mb-2" id="option3Group" style="display: none;">
                            <div class="input-group">
                                <div class="input-group-text">
                                    <input type="radio" name="correctAnswer" value="2" id="radio2">
                                </div>
                                <asp:TextBox ID="txtOption3" runat="server" CssClass="form-control" placeholder="Option 3" MaxLength="500" />
                                <button type="button" class="btn btn-outline-danger" onclick="removeOption(3)" title="Remove Option 3">
                                    <i class="bi bi-x-lg"></i>
                                </button>
                            </div>
                        </div>

                        <div class="option-group mb-2" id="option4Group" style="display: none;">
                            <div class="input-group">
                                <div class="input-group-text">
                                    <input type="radio" name="correctAnswer" value="3" id="radio3">
                                </div>
                                <asp:TextBox ID="txtOption4" runat="server" CssClass="form-control" placeholder="Option 4" MaxLength="500" />
                                <button type="button" class="btn btn-outline-danger" onclick="removeOption(4)" title="Remove Option 4">
                                    <i class="bi bi-x-lg"></i>
                                </button>
                            </div>
                        </div>

                        <div id="addOptionBtnContainer" class="mb-2">
                            <button type="button" class="btn btn-outline-primary btn-sm" id="btnAddOption" onclick="addOption()">
                                <i class="bi bi-plus-circle me-1"></i>Add Option
                            </button>
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

        // Track which options are visible (options 1 and 2 are always visible)
        let option3Visible = false;
        let option4Visible = false;

        // Update hidden field when radio changes
        document.addEventListener('DOMContentLoaded', function() {
            const radios = document.querySelectorAll('input[name="correctAnswer"]');
            radios.forEach(function(radio) {
                radio.addEventListener('change', function() {
                    document.getElementById(window.QUIZ_DATA.correctAnswerFieldId).value = this.value;
                });
            });
            
            // Initialize option visibility
            updateOptionVisibility();
        });

        function addOption() {
            // Add the next available option
            if (!option3Visible && !option4Visible) {
                option3Visible = true;
            } else if (option3Visible && !option4Visible) {
                option4Visible = true;
            }
            updateOptionVisibility();
        }

        function removeOption(optionNumber) {
            // Minimum 2 options required (options 1 and 2 cannot be removed)
            if (optionNumber === 1 || optionNumber === 2) {
                return;
            }

            // Handle removal based on which option is being removed
            if (optionNumber === 4) {
                // Remove option 4 only
                document.getElementById('<%= txtOption4.ClientID %>').value = '';
                // If option 4 was selected, reset to option 1
                const radio3 = document.getElementById('radio3');
                if (radio3 && radio3.checked) {
                    document.getElementById('radio0').checked = true;
                    document.getElementById(window.QUIZ_DATA.correctAnswerFieldId).value = '0';
                }
                option4Visible = false;
            } else if (optionNumber === 3) {
                // Remove option 3 only
                document.getElementById('<%= txtOption3.ClientID %>').value = '';
                // If option 3 was selected, reset to option 1
                const radio2 = document.getElementById('radio2');
                if (radio2 && radio2.checked) {
                    document.getElementById('radio0').checked = true;
                    document.getElementById(window.QUIZ_DATA.correctAnswerFieldId).value = '0';
                }
                option3Visible = false;
            }

            updateOptionVisibility();
        }

        function updateOptionVisibility() {
            const option3Group = document.getElementById('option3Group');
            const option4Group = document.getElementById('option4Group');
            const addOptionBtnContainer = document.getElementById('addOptionBtnContainer');

            // Show/hide option 3
            if (option3Visible) {
                option3Group.style.display = 'block';
            } else {
                option3Group.style.display = 'none';
            }

            // Show/hide option 4
            if (option4Visible) {
                option4Group.style.display = 'block';
            } else {
                option4Group.style.display = 'none';
            }

            // Show/hide "Add Option" button (only show if we have less than 4 options)
            const totalVisible = 2 + (option3Visible ? 1 : 0) + (option4Visible ? 1 : 0);
            if (totalVisible < 4) {
                addOptionBtnContainer.style.display = 'block';
            } else {
                addOptionBtnContainer.style.display = 'none';
            }
        }

        // Make functions globally accessible
        window.addOption = addOption;
        window.removeOption = removeOption;
        window.updateOptionVisibility = updateOptionVisibility;
        
        // Create getters/setters to keep variables in sync with global scope
        Object.defineProperty(window, 'option3Visible', {
            get: function() { return option3Visible; },
            set: function(value) { option3Visible = value; }
        });
        Object.defineProperty(window, 'option4Visible', {
            get: function() { return option4Visible; },
            set: function(value) { option4Visible = value; }
        });
        
        // Initialize on page load
        updateOptionVisibility();
    </script>

    <script src="<%= ResolveUrl("~/Scripts/add-questions.js") %>"></script>
</asp:Content>


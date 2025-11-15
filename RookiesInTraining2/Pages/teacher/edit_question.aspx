<%@ Page Title="Edit Question - Teacher"
    Language="C#"
    MasterPageFile="~/MasterPages/MyMain.Master"
    AutoEventWireup="true"
    CodeBehind="edit_question.aspx.cs"
    Inherits="RookiesInTraining2.Pages.teacher.edit_question" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <link rel="stylesheet" href="<%= ResolveUrl("~/Content/add-questions.css") %>" />

    <div class="container mt-4">
        <!-- Header -->
        <div class="card border-0 shadow-sm mb-4" style="background: linear-gradient(135deg, #28a745 0%, #1e7e34 100%);">
            <div class="card-body text-white p-4">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h2 class="mb-2"><i class="bi bi-pencil-square me-2"></i>Edit Question</h2>
                        <p class="mb-0 opacity-90">
                            Quiz: <strong><asp:Label ID="lblQuizTitle" runat="server" /></strong>
                        </p>
                    </div>
                    <asp:HyperLink ID="lnkBack" runat="server" CssClass="btn btn-light btn-lg">
                        <i class="bi bi-arrow-left me-2"></i>Back
                    </asp:HyperLink>
                </div>
            </div>
        </div>

        <!-- Edit Question Form -->
        <div class="card border-0 shadow-sm">
            <div class="card-body p-4">
                <asp:Label ID="lblError" runat="server" CssClass="alert alert-danger" Visible="false" />

                <div class="mb-3">
                    <label class="form-label fw-bold">Question Text <span class="text-danger">*</span></label>
                    <asp:TextBox ID="txtQuestionBody" runat="server" TextMode="MultiLine" Rows="3"
                                 CssClass="form-control" placeholder="Enter your question here..." MaxLength="1000" />
                    <asp:RequiredFieldValidator runat="server" ControlToValidate="txtQuestionBody"
                        ValidationGroup="EditQuestion" CssClass="text-danger small" ErrorMessage="Question is required" Display="Dynamic" />
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

                <div class="mt-4">
                    <asp:Button ID="btnSaveQuestion" runat="server" Text="Save Changes" 
                                CssClass="btn btn-primary btn-lg me-2" ValidationGroup="EditQuestion"
                                OnClick="btnSaveQuestion_Click" />
                    <asp:Button ID="btnCancel" runat="server" Text="Cancel" 
                                CssClass="btn btn-secondary btn-lg"
                                OnClick="btnCancel_Click" />
                </div>
            </div>
        </div>

        <!-- Hidden Fields -->
        <asp:HiddenField ID="hfQuestionSlug" runat="server" />
        <asp:HiddenField ID="hfQuizSlug" runat="server" />
        <asp:HiddenField ID="hfClassSlug" runat="server" />
    </div>

    <script type="text/javascript">
        window.QUIZ_DATA = {
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
            
            // Initialize option visibility based on existing options
            initializeOptions();
        });

        function initializeOptions() {
            // Check if option 3 and 4 have values
            const option3 = document.getElementById('<%= txtOption3.ClientID %>');
            const option4 = document.getElementById('<%= txtOption4.ClientID %>');
            
            if (option3 && option3.value.trim() !== '') {
                option3Visible = true;
            }
            if (option4 && option4.value.trim() !== '') {
                option4Visible = true;
            }
            
            updateOptionVisibility();
        }

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
    </script>
</asp:Content>







<%@ Page Title="Story Mode"
    Language="C#"
    MasterPageFile="~/MasterPages/dashboard.Master"
    AutoEventWireup="true"
    CodeBehind="story.aspx.cs"
    Inherits="RookiesInTraining2.Pages.story" %>

<asp:Content ID="Content1" ContentPlaceHolderID="DashboardContent" runat="server">
    <!-- Internal CSS Example (Assignment Requirement) -->
    <style>
        .story-container {
            padding: 2rem 0;
        }
        .stage-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 12px;
            padding: 2rem;
            margin-bottom: 1.5rem;
            color: white;
            transition: transform 0.3s, box-shadow 0.3s;
            cursor: pointer;
        }
        .stage-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(0,0,0,0.3);
        }
        .stage-card.locked {
            background: linear-gradient(135deg, #2d3748 0%, #1a202c 100%);
            opacity: 0.6;
            cursor: not-allowed;
        }
        .stage-card.completed {
            background: linear-gradient(135deg, #48bb78 0%, #38a169 100%);
        }
        .stage-number {
            font-size: 3rem;
            font-weight: bold;
            opacity: 0.8;
        }
        .stage-title {
            font-size: 1.5rem;
            font-weight: 600;
            margin: 0.5rem 0;
        }
        .stage-xp {
            display: inline-block;
            background: rgba(255,255,255,0.2);
            padding: 0.25rem 0.75rem;
            border-radius: 20px;
            font-size: 0.9rem;
            margin-top: 0.5rem;
        }
        .stage-status {
            margin-top: 1rem;
            font-size: 0.9rem;
        }
    </style>

    <div class="story-container">
        <div class="container">
            <div class="row mb-4">
                <div class="col-12">
                    <h1 class="text-light mb-2">
                        <i class="bi bi-journal-bookmark me-2"></i>Story Mode
                    </h1>
                    <p class="text-muted">Complete stages sequentially to unlock the next level!</p>
                </div>
            </div>

            <div class="row" id="stagesContainer" runat="server">
                <!-- Stages will be loaded dynamically -->
            </div>

            <asp:HiddenField ID="hfStagesJson" runat="server" />
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            var stagesJson = document.getElementById('<%= hfStagesJson.ClientID %>').value;
            if (stagesJson) {
                var stages = JSON.parse(stagesJson);
                var container = document.getElementById('<%= stagesContainer.ClientID %>');
                
                stages.forEach(function(stage) {
                    var col = document.createElement('div');
                    col.className = 'col-md-6 col-lg-4';
                    
                    var card = document.createElement('div');
                    card.className = 'stage-card ' + (stage.isLocked ? 'locked' : '') + (stage.isCompleted ? 'completed' : '');
                    
                    if (!stage.isLocked) {
                        card.onclick = function() {
                            window.location.href = 'story_stage.aspx?stage=' + stage.levelSlug;
                        };
                    }
                    
                    card.innerHTML = `
                        <div class="stage-number">${stage.levelNumber}</div>
                        <div class="stage-title">${stage.title}</div>
                        <div class="text-white-50">${stage.description || ''}</div>
                        <div class="stage-xp">
                            <i class="bi bi-star-fill"></i> ${stage.xpReward} XP
                        </div>
                        <div class="stage-status">
                            ${stage.isLocked ? '<i class="bi bi-lock-fill"></i> Locked' : 
                              stage.isCompleted ? '<i class="bi bi-check-circle-fill"></i> Completed' : 
                              '<i class="bi bi-play-circle-fill"></i> Available'}
                        </div>
                    `;
                    
                    col.appendChild(card);
                    container.appendChild(col);
                });
            }
        });
    </script>
</asp:Content>


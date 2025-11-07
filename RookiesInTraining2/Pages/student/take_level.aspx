<%@ Page Title="Take Level - Student"
    Language="C#"
    MasterPageFile="~/MasterPages/MyMain.Master"
    AutoEventWireup="true"
    CodeBehind="take_level.aspx.cs"
    Inherits="RookiesInTraining2.Pages.student.take_level" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    
    <div class="container mt-4">
        <!-- Header -->
        <div class="card border-0 shadow-sm mb-4">
            <div class="card-body p-4">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h2 class="mb-2"><asp:Label ID="lblLevelTitle" runat="server" /></h2>
                        <p class="mb-0 text-muted">
                            <asp:Label ID="lblDescription" runat="server" />
                        </p>
                    </div>
                    <asp:HyperLink ID="lnkBack" runat="server" CssClass="btn btn-outline-secondary">
                        <i class="bi bi-arrow-left me-2"></i>Back to Class
                    </asp:HyperLink>
                </div>
            </div>
        </div>

        <!-- Learning Materials -->
        <div class="card border-0 shadow-sm mb-4">
            <div class="card-header bg-light border-0 py-3">
                <h5 class="mb-0"><i class="bi bi-book me-2"></i>Learning Materials</h5>
            </div>
            <div class="card-body p-4">
                <!-- Slides Viewer -->
                <div id="slidesViewer">
                    <div id="slidesContainer" class="mb-4">
                        <!-- Slides will be loaded here -->
                    </div>
                    
                    <div id="noSlides" class="text-center py-5">
                        <i class="bi bi-file-slides display-4 text-muted opacity-25"></i>
                        <h5 class="mt-3 mb-2">No Learning Materials Yet</h5>
                        <p class="text-muted">Your teacher hasn't added slides for this level yet.</p>
                    </div>
                    
                    <!-- Slide Navigation -->
                    <div id="slideNavigation" class="d-flex justify-content-between align-items-center mt-4" style="display: none !important;">
                        <button type="button" id="btnPrevSlide" class="btn btn-outline-primary" onclick="prevSlide()">
                            <i class="bi bi-arrow-left me-2"></i>Previous
                        </button>
                        <span id="slideCounter" class="text-muted">Slide 1 of 1</span>
                        <button type="button" id="btnNextSlide" class="btn btn-primary" onclick="nextSlide()">
                            Next<i class="bi bi-arrow-right ms-2"></i>
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Quiz Section -->
        <div class="card border-0 shadow-sm">
            <div class="card-header bg-success text-white py-3">
                <h5 class="mb-0"><i class="bi bi-question-circle-fill me-2"></i>Level Quiz</h5>
            </div>
            <div class="card-body p-4">
                <div class="alert alert-info">
                    <i class="bi bi-info-circle me-2"></i>
                    <strong>Ready to test your knowledge?</strong> Complete the quiz to earn XP and unlock the next level!
                </div>
                
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <p class="mb-1"><strong>Quiz:</strong> <asp:Label ID="lblQuizTitle" runat="server" /></p>
                        <p class="mb-1"><small class="text-muted">
                            <i class="bi bi-clock me-1"></i><asp:Label ID="lblTimeLimit" runat="server" /> minutes
                            <i class="bi bi-check-circle ms-3 me-1"></i>Pass: <asp:Label ID="lblPassingScore" runat="server" />%
                        </small></p>
                    </div>
                    <asp:HyperLink ID="lnkTakeQuiz" runat="server" CssClass="btn btn-success btn-lg">
                        <i class="bi bi-play-circle-fill me-2"></i>Start Quiz
                    </asp:HyperLink>
                </div>
            </div>
        </div>
    </div>

    <!-- Hidden Fields -->
    <asp:HiddenField ID="hfSlidesJson" runat="server" />
    <asp:HiddenField ID="hfLevelSlug" runat="server" />
    <asp:HiddenField ID="hfClassSlug" runat="server" />

    <script>
        let slides = [];
        let currentSlideIndex = 0;

        window.addEventListener('DOMContentLoaded', function() {
            loadSlides();
        });

        function loadSlides() {
            const slidesField = document.getElementById('<%= hfSlidesJson.ClientID %>');
            const container = document.getElementById('slidesContainer');
            const noSlides = document.getElementById('noSlides');
            const navigation = document.getElementById('slideNavigation');
            
            if (!slidesField || !slidesField.value) {
                noSlides.style.display = 'block';
                return;
            }
            
            try {
                slides = JSON.parse(slidesField.value);
                
                if (slides.length === 0) {
                    noSlides.style.display = 'block';
                    return;
                }
                
                noSlides.style.display = 'none';
                navigation.style.display = 'flex !important';
                navigation.style.display = '-webkit-flex !important';
                navigation.classList.remove('d-none');
                navigation.classList.add('d-flex');
                
                showSlide(0);
            } catch (error) {
                console.error('Error loading slides:', error);
            }
        }

        function showSlide(index) {
            if (slides.length === 0) return;
            
            currentSlideIndex = index;
            const slide = slides[index];
            const container = document.getElementById('slidesContainer');
            
            let slideHtml = '';
            
            if (slide.ContentType === 'image' && slide.MediaUrl) {
                slideHtml = `
                    <div class="text-center">
                        <img src="${slide.MediaUrl}" alt="Slide ${slide.SlideNumber}" 
                             class="img-fluid rounded shadow-sm mb-3" style="max-height: 400px;">
                        <p class="text-muted">${escapeHtml(slide.Content)}</p>
                    </div>
                `;
            } else if (slide.ContentType === 'video' && slide.MediaUrl) {
                slideHtml = `
                    <div class="ratio ratio-16x9 mb-3">
                        <iframe src="${slide.MediaUrl}" allowfullscreen></iframe>
                    </div>
                    <p class="text-muted">${escapeHtml(slide.Content)}</p>
                `;
            } else if (slide.ContentType === 'code') {
                slideHtml = `
                    <pre class="bg-dark text-white p-4 rounded"><code>${escapeHtml(slide.Content)}</code></pre>
                `;
            } else {
                slideHtml = `<div style="white-space: pre-wrap; font-size: 1.1rem; line-height: 1.8;">${escapeHtml(slide.Content)}</div>`;
            }
            
            container.innerHTML = slideHtml;
            
            // Update counter and buttons
            document.getElementById('slideCounter').textContent = `Slide ${index + 1} of ${slides.length}`;
            document.getElementById('btnPrevSlide').disabled = index === 0;
            document.getElementById('btnNextSlide').disabled = index === slides.length - 1;
        }

        function nextSlide() {
            if (currentSlideIndex < slides.length - 1) {
                showSlide(currentSlideIndex + 1);
            }
        }

        function prevSlide() {
            if (currentSlideIndex > 0) {
                showSlide(currentSlideIndex - 1);
            }
        }

        function escapeHtml(text) {
            const div = document.createElement('div');
            div.textContent = text || '';
            return div.innerHTML;
        }
    </script>

</asp:Content>


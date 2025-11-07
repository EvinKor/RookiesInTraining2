<%@ Page Title="Manage Slides - Teacher"
    Language="C#"
    MasterPageFile="~/MasterPages/MyMain.Master"
    AutoEventWireup="true"
    CodeBehind="manage_slides.aspx.cs"
    Inherits="RookiesInTraining2.Pages.teacher.manage_slides" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    
    <div class="container mt-4">
        <!-- Header -->
        <div class="card border-0 shadow-sm mb-4" style="background: linear-gradient(135deg, #17a2b8 0%, #117a8b 100%);">
            <div class="card-body text-white p-4">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h2 class="mb-2"><i class="bi bi-file-slides me-2"></i>Manage Slides</h2>
                        <p class="mb-0 opacity-90">
                            <strong><asp:Label ID="lblLevelTitle" runat="server" /></strong>
                        </p>
                    </div>
                    <asp:HyperLink ID="lnkBack" runat="server" CssClass="btn btn-light btn-lg">
                        <i class="bi bi-arrow-left me-2"></i>Back to Story Mode
                    </asp:HyperLink>
                </div>
            </div>
        </div>

        <!-- Instructions -->
        <div class="alert alert-info">
            <i class="bi bi-info-circle me-2"></i>
            <strong>Tip:</strong> Create slides to guide students through the learning material. Each slide can contain text, images, or videos.
        </div>

        <!-- Error/Success Messages -->
        <asp:Label ID="lblMessage" runat="server" CssClass="alert" Visible="false" />

        <!-- Slides List -->
        <div class="card border-0 shadow-sm mb-4">
            <div class="card-header bg-light border-0 py-3">
                <div class="d-flex justify-content-between align-items-center">
                    <h5 class="mb-0"><i class="bi bi-collection me-2"></i>Slides</h5>
                    <button type="button" class="btn btn-info" onclick="openAddSlideModal()">
                        <i class="bi bi-plus-circle me-2"></i>Add New Slide
                    </button>
                </div>
            </div>
            <div class="card-body p-4">
                <asp:Repeater ID="rptSlides" runat="server">
                    <ItemTemplate>
                        <div class="card mb-3 border-start border-info border-4">
                            <div class="card-body">
                                <div class="d-flex align-items-start">
                                    <div class="flex-shrink-0 me-3">
                                        <div class="bg-info bg-opacity-10 rounded-circle d-flex align-items-center justify-content-center text-info fw-bold"
                                             style="width: 50px; height: 50px; font-size: 1.25rem;">
                                            <%# Eval("SlideNumber") %>
                                        </div>
                                    </div>
                                    <div class="flex-grow-1">
                                        <h6 class="mb-1">Slide <%# Eval("SlideNumber") %></h6>
                                        <p class="mb-2 small">
                                            <span class="badge bg-<%# GetBadgeColor(Eval("ContentType")?.ToString()) %>">
                                                <i class="bi bi-<%# GetContentIcon(Eval("ContentType")?.ToString()) %> me-1"></i>
                                                <%# Eval("ContentType") %>
                                            </span>
                                        </p>
                                        
                                        <%# Eval("ContentType")?.ToString() == "image" && !string.IsNullOrEmpty(Eval("MediaUrl")?.ToString()) ? 
                                            $"<img src='{Eval("MediaUrl")}' alt='Slide Image' class='img-thumbnail mb-2' style='max-width: 200px; max-height: 150px;' />" : "" %>
                                        
                                        <p class="mb-0 text-muted" style="white-space: pre-wrap;"><%# TruncateText(Eval("Content")?.ToString(), 150) %></p>
                                        
                                        <%# Eval("ContentType")?.ToString() != "image" && !string.IsNullOrEmpty(Eval("MediaUrl")?.ToString()) ? 
                                            $"<p class='mb-0 mt-2 small text-info'><i class='bi bi-link-45deg'></i> {Eval("MediaUrl")}</p>" : "" %>
                                    </div>
                                    <div class="btn-group-vertical">
                                        <button type="button" class="btn btn-sm btn-outline-primary" 
                                                onclick="editSlide(<%# Eval("SlideNumber") %>, '<%# Eval("ContentType") %>', `<%# System.Web.HttpUtility.JavaScriptStringEncode(Eval("Content")?.ToString() ?? "") %>`, '<%# Eval("MediaUrl") %>')">
                                            <i class="bi bi-pencil"></i> Edit
                                        </button>
                                        <asp:LinkButton ID="btnDeleteSlide" runat="server" 
                                                       CssClass="btn btn-sm btn-outline-danger"
                                                       CommandName="Delete"
                                                       CommandArgument='<%# Eval("SlideNumber") %>'
                                                       OnCommand="DeleteSlide_Command"
                                                       OnClientClick="return confirm('Delete this slide?');">
                                            <i class="bi bi-trash"></i> Delete
                                        </asp:LinkButton>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
                
                <asp:Label ID="lblNoSlides" runat="server" 
                           CssClass="text-muted text-center d-block py-5"
                           Text="No slides yet. Click 'Add New Slide' to create your first slide."
                           Visible="false" />
            </div>
        </div>
    </div>

    <!-- Add/Edit Slide Modal -->
    <div class="modal fade" id="slideModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header bg-info text-white">
                    <h5 class="modal-title"><i class="bi bi-plus-circle me-2"></i><span id="modalTitle">Add Slide</span></h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body p-4">
                    <asp:Label ID="lblSlideError" runat="server" CssClass="alert alert-danger" Visible="false" />
                    
                    <div class="mb-3">
                        <label class="form-label fw-bold">Slide Number</label>
                        <div class="form-control form-control-lg text-center bg-light" id="displaySlideNumber" 
                             style="font-size: 1.5rem; font-weight: 700;">1</div>
                        <asp:HiddenField ID="hfSlideNumber" runat="server" Value="1" />
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label fw-bold">Content Type <span class="text-danger">*</span></label>
                        <asp:DropDownList ID="ddlContentType" runat="server" CssClass="form-select" onchange="toggleMediaFields()">
                            <asp:ListItem Value="text">Text</asp:ListItem>
                            <asp:ListItem Value="image">Image</asp:ListItem>
                            <asp:ListItem Value="video">Video</asp:ListItem>
                            <asp:ListItem Value="code">Code</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label fw-bold">Content <span class="text-danger">*</span></label>
                        <asp:TextBox ID="txtContent" runat="server" 
                                     TextMode="MultiLine" Rows="8"
                                     CssClass="form-control" 
                                     placeholder="Enter slide content here..." />
                        <small class="text-muted">For text/code content, or image caption/alt text</small>
                    </div>
                    
                    <div id="uploadImageSection" class="mb-3" style="display: none;">
                        <label class="form-label fw-bold">Upload Image <span class="text-danger">*</span></label>
                        <asp:FileUpload ID="fileUploadImage" runat="server" 
                                        CssClass="form-control form-control-lg" 
                                        accept="image/*" />
                        <small class="text-muted">Supported: JPG, PNG, GIF, SVG (Max 5MB)</small>
                    </div>
                    
                    <div id="mediaUrlSection" class="mb-3">
                        <label class="form-label fw-bold">Media URL (Optional)</label>
                        <asp:TextBox ID="txtMediaUrl" runat="server" 
                                     CssClass="form-control"
                                     placeholder="e.g., https://example.com/video.mp4" />
                        <small class="text-muted">For videos or external media URLs</small>
                    </div>
                    
                    <asp:HiddenField ID="hfLevelSlug" runat="server" />
                    <asp:HiddenField ID="hfClassSlug" runat="server" />
                    <asp:HiddenField ID="hfEditingSlideNumber" runat="server" Value="0" />
                </div>
                <div class="modal-footer bg-light">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                        <i class="bi bi-x-circle me-1"></i>Cancel
                    </button>
                    <asp:Button ID="btnSaveSlide" runat="server" 
                                Text="Save Slide" 
                                CssClass="btn btn-info btn-lg" 
                                OnClick="btnSaveSlide_Click" />
                </div>
            </div>
        </div>
    </div>

    <script>
        function openAddSlideModal() {
            document.getElementById('modalTitle').textContent = 'Add New Slide';
            document.getElementById('<%= hfEditingSlideNumber.ClientID %>').value = '0';
            
            // Get next slide number
            const slideCards = document.querySelectorAll('.card .bg-info');
            const nextNumber = slideCards.length + 1;
            
            // Update both display and hidden field
            document.getElementById('displaySlideNumber').textContent = nextNumber;
            document.getElementById('<%= hfSlideNumber.ClientID %>').value = nextNumber;
            
            // Clear form
            document.getElementById('<%= txtContent.ClientID %>').value = '';
            document.getElementById('<%= txtMediaUrl.ClientID %>').value = '';
            document.getElementById('<%= ddlContentType.ClientID %>').selectedIndex = 0;
            
            // Reset media fields
            toggleMediaFields();
            
            const modal = new bootstrap.Modal(document.getElementById('slideModal'));
            modal.show();
        }

        function editSlide(slideNumber, contentType, content, mediaUrl) {
            document.getElementById('modalTitle').textContent = 'Edit Slide ' + slideNumber;
            document.getElementById('<%= hfEditingSlideNumber.ClientID %>').value = slideNumber;
            
            // Update both display and hidden field
            document.getElementById('displaySlideNumber').textContent = slideNumber;
            document.getElementById('<%= hfSlideNumber.ClientID %>').value = slideNumber;
            
            document.getElementById('<%= txtContent.ClientID %>').value = content || '';
            document.getElementById('<%= txtMediaUrl.ClientID %>').value = mediaUrl || '';
            
            const select = document.getElementById('<%= ddlContentType.ClientID %>');
            for (let i = 0; i < select.options.length; i++) {
                if (select.options[i].value === contentType) {
                    select.selectedIndex = i;
                    break;
                }
            }
            
            // Update media field visibility
            toggleMediaFields();
            
            const modal = new bootstrap.Modal(document.getElementById('slideModal'));
            modal.show();
        }

        function toggleMediaFields() {
            const contentType = document.getElementById('<%= ddlContentType.ClientID %>').value;
            const uploadSection = document.getElementById('uploadImageSection');
            const urlSection = document.getElementById('mediaUrlSection');
            
            if (contentType === 'image') {
                uploadSection.style.display = 'block';
                urlSection.style.display = 'none';
            } else if (contentType === 'video') {
                uploadSection.style.display = 'none';
                urlSection.style.display = 'block';
            } else {
                uploadSection.style.display = 'none';
                urlSection.style.display = 'none';
            }
        }
    </script>

</asp:Content>


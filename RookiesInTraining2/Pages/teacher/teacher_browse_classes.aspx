<%@ Page Title="Browse Classes - Teacher"
    Language="C#"
    MasterPageFile="~/MasterPages/MyMain.Master"
    AutoEventWireup="true"
    CodeBehind="teacher_browse_classes.aspx.cs"
    Inherits="RookiesInTraining2.Pages.teacher_browse_classes" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <link rel="stylesheet" href="<%= ResolveUrl("~/Content/teacher-classes.css") %>" />

    <div class="teacher-classes-container">
        
        <!-- Header Section -->
        <div class="page-header">
            <div class="container-fluid py-5">
                <div class="row align-items-center">
                    <div class="col-lg-8">
                        <h1 class="mb-2">
                            <i class="bi bi-collection me-2"></i>My Classes
                        </h1>
                        <p class="mb-0" style="opacity: 0.9;">Browse and manage your classes</p>
                    </div>
                    <div class="col-lg-4 text-lg-end mt-3 mt-lg-0">
                        <a href="<%= ResolveUrl("~/Pages/teacher/teacher_create_module.aspx") %>" 
                           class="btn btn-light btn-lg px-4 shadow-sm">
                            <i class="bi bi-plus-circle me-2"></i>Create New Class
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <!-- Stats Cards -->
        <div class="container-fluid py-4">
            <div class="row g-3 mb-4">
                <div class="col-md-4">
                    <div class="stat-card">
                        <div class="stat-icon bg-primary">
                            <i class="bi bi-collection"></i>
                        </div>
                        <div class="stat-info">
                            <div class="stat-value" id="totalClasses">0</div>
                            <div class="stat-label">Total Classes</div>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="stat-card">
                        <div class="stat-icon bg-success">
                            <i class="bi bi-people"></i>
                        </div>
                        <div class="stat-info">
                            <div class="stat-value" id="totalStudents">0</div>
                            <div class="stat-label">Total Students</div>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="stat-card">
                        <div class="stat-icon bg-info">
                            <i class="bi bi-layers"></i>
                        </div>
                        <div class="stat-info">
                            <div class="stat-value" id="totalLevels">0</div>
                            <div class="stat-label">Total Levels</div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Classes Grid -->
            <div class="row g-4" id="classesGrid">
                <!-- Class cards will be rendered here -->
            </div>

            <!-- Empty State -->
            <div id="emptyState" class="text-center py-5" style="display: none;">
                <i class="bi bi-collection display-1 text-muted mb-3"></i>
                <h3>No Classes Yet</h3>
                <p class="text-muted">Create your first class to start teaching!</p>
                <a href="<%= ResolveUrl("~/Pages/teacher/teacher_create_module.aspx") %>" 
                   class="btn btn-primary btn-lg mt-3">
                    <i class="bi bi-plus-circle me-2"></i>Create Your First Class
                </a>
            </div>
        </div>

        <!-- Hidden Fields -->
        <asp:HiddenField ID="hfClassesJson" runat="server" />
    </div>

    <!-- Expose data for JavaScript -->
    <script type="text/javascript">
        window.TEACHER_DATA = {
            teacherSlug: '<%= Session["UserSlug"] %>',
            teacherName: '<%= Session["FullName"] %>',
            classesFieldId: '<%= hfClassesJson.ClientID %>'
        };
    </script>

    <!-- JavaScript -->
    <script src="<%= ResolveUrl("~/Scripts/teacher-browse-classes.js") %>"></script>
</asp:Content>


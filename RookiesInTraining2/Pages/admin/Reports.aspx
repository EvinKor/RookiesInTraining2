<%@ Page Title="Reports"
    Language="C#"
    MasterPageFile="~/MasterPages/dashboard.Master"
    AutoEventWireup="true"
    CodeBehind="Reports.aspx.cs"
    Inherits="RookiesInTraining2.Pages.AdminReports" %>

<asp:Content ID="Content1" ContentPlaceHolderID="DashboardContent" runat="server">
    <!-- Page Header -->
    <div class="row mb-4">
        <div class="col-12">
            <div class="d-flex align-items-center justify-content-between mb-3">
                <div>
                    <h2 class="mb-1">System Reports & Analytics</h2>
                    <p class="text-muted mb-0">Comprehensive insights into students, teachers, and classes</p>
                </div>
                <div class="d-flex gap-2">
                    <asp:Button ID="btnExportCsv" runat="server" Text="Export CSV" CssClass="btn btn-primary" OnClick="btnExportCsv_Click" />
                    <asp:Button ID="btnPrint" runat="server" Text="Print" CssClass="btn btn-outline-secondary" OnClick="btnPrint_Click" />
                </div>
            </div>
        </div>
    </div>

    <!-- Summary Panel -->
    <div class="row g-3 mb-4">
        <div class="col-md-2">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-body text-center">
                    <i class="bi bi-people-fill text-primary fs-1 mb-2"></i>
                    <h3 class="mb-0"><asp:Label ID="lblTotalStudents" runat="server" Text="0" /></h3>
                    <small class="text-muted">Total Students</small>
                </div>
            </div>
        </div>
        <div class="col-md-2">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-body text-center">
                    <i class="bi bi-person-check-fill text-success fs-1 mb-2"></i>
                    <h3 class="mb-0"><asp:Label ID="lblActiveStudents" runat="server" Text="0" /></h3>
                    <small class="text-muted">Active Students</small>
                </div>
            </div>
        </div>
        <div class="col-md-2">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-body text-center">
                    <i class="bi bi-mortarboard-fill text-info fs-1 mb-2"></i>
                    <h3 class="mb-0"><asp:Label ID="lblTotalTeachers" runat="server" Text="0" /></h3>
                    <small class="text-muted">Total Teachers</small>
                </div>
            </div>
        </div>
        <div class="col-md-2">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-body text-center">
                    <i class="bi bi-person-check text-success fs-1 mb-2"></i>
                    <h3 class="mb-0"><asp:Label ID="lblActiveTeachers" runat="server" Text="0" /></h3>
                    <small class="text-muted">Active Teachers</small>
                </div>
            </div>
        </div>
        <div class="col-md-2">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-body text-center">
                    <i class="bi bi-book-fill text-warning fs-1 mb-2"></i>
                    <h3 class="mb-0"><asp:Label ID="lblTotalClasses" runat="server" Text="0" /></h3>
                    <small class="text-muted">Total Classes</small>
                </div>
            </div>
        </div>
        <div class="col-md-2">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-body text-center">
                    <i class="bi bi-graph-up-arrow text-danger fs-1 mb-2"></i>
                    <h3 class="mb-0"><asp:Label ID="lblActiveClasses" runat="server" Text="0" /></h3>
                    <small class="text-muted">Active Classes</small>
                </div>
            </div>
        </div>
    </div>

    <!-- Filters -->
    <div class="card border-0 shadow-sm mb-4">
        <div class="card-body">
            <div class="row g-3 align-items-end">
                <div class="col-md-2">
                    <label class="form-label fw-semibold">Time Period</label>
                    <asp:DropDownList ID="ddlTimePeriod" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlTimePeriod_SelectedIndexChanged">
                        <asp:ListItem Text="Last 7 Days" Value="7" />
                        <asp:ListItem Text="Last 30 Days" Value="30" Selected="True" />
                        <asp:ListItem Text="Last 90 Days" Value="90" />
                        <asp:ListItem Text="Custom" Value="custom" />
                    </asp:DropDownList>
                </div>
                <div class="col-md-2">
                    <label class="form-label fw-semibold">Start Date</label>
                    <asp:TextBox ID="txtStartDate" runat="server" CssClass="form-control" TextMode="Date" />
                </div>
                <div class="col-md-2">
                    <label class="form-label fw-semibold">End Date</label>
                    <asp:TextBox ID="txtEndDate" runat="server" CssClass="form-control" TextMode="Date" />
                </div>
                <div class="col-md-2">
                    <label class="form-label fw-semibold">Search</label>
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" placeholder="Name or Email" />
                </div>
                <div class="col-md-2">
                    <label class="form-label fw-semibold">Status</label>
                    <asp:DropDownList ID="ddlStatusFilter" runat="server" CssClass="form-select">
                        <asp:ListItem Text="All" Value="" Selected="True" />
                        <asp:ListItem Text="Active" Value="active" />
                        <asp:ListItem Text="Blocked" Value="blocked" />
                    </asp:DropDownList>
                </div>
                <div class="col-md-2">
                    <asp:Button ID="btnApplyFilters" runat="server" Text="Apply Filters" CssClass="btn btn-success w-100" OnClick="btnApplyFilters_Click" />
                </div>
            </div>
        </div>
    </div>

    <!-- Tabs Navigation -->
    <ul class="nav nav-tabs mb-4" id="reportTabs" role="tablist">
        <li class="nav-item" role="presentation">
            <button class="nav-link active" id="students-tab" data-bs-toggle="tab" data-bs-target="#students" type="button" role="tab">
                <i class="bi bi-people me-2"></i>Students
            </button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link" id="teachers-tab" data-bs-toggle="tab" data-bs-target="#teachers" type="button" role="tab">
                <i class="bi bi-mortarboard me-2"></i>Teachers
            </button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link" id="classes-tab" data-bs-toggle="tab" data-bs-target="#classes" type="button" role="tab">
                <i class="bi bi-book me-2"></i>Classes
            </button>
        </li>
    </ul>

    <!-- Tab Content -->
    <div class="tab-content" id="reportTabContent">
        <!-- Students Tab -->
        <div class="tab-pane fade show active" id="students" role="tabpanel">
            <!-- Student Metrics -->
            <div class="row g-3 mb-4">
                <div class="col-md-3">
                    <div class="card border-0 shadow-sm">
                        <div class="card-body">
                            <h6 class="text-muted mb-2">New Students (24h)</h6>
                            <h3 class="mb-0"><asp:Label ID="lblNewStudents24h" runat="server" Text="0" /></h3>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card border-0 shadow-sm">
                        <div class="card-body">
                            <h6 class="text-muted mb-2">New Students (Week)</h6>
                            <h3 class="mb-0"><asp:Label ID="lblNewStudentsWeek" runat="server" Text="0" /></h3>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card border-0 shadow-sm">
                        <div class="card-body">
                            <h6 class="text-muted mb-2">New Students (Month)</h6>
                            <h3 class="mb-0"><asp:Label ID="lblNewStudentsMonth" runat="server" Text="0" /></h3>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card border-0 shadow-sm">
                        <div class="card-body">
                            <h6 class="text-muted mb-2">Blocked Students</h6>
                            <h3 class="mb-0"><asp:Label ID="lblBlockedStudents" runat="server" Text="0" /></h3>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Student Progress Summary -->
            <div class="card border-0 shadow-sm mb-4">
                <div class="card-header bg-transparent border-0 py-3">
                    <h5 class="mb-0"><i class="bi bi-graph-up me-2"></i>Student Progress Summary</h5>
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-6">
                            <p class="mb-2"><strong>Students who completed Level 1:</strong> <asp:Label ID="lblLevel1Complete" runat="server" Text="0" /></p>
                            <p class="mb-2"><strong>Students who completed Level 2:</strong> <asp:Label ID="lblLevel2Complete" runat="server" Text="0" /></p>
                            <p class="mb-2"><strong>Students who completed Level 3:</strong> <asp:Label ID="lblLevel3Complete" runat="server" Text="0" /></p>
                        </div>
                        <div class="col-md-6">
                            <p class="mb-2"><strong>Average Progress:</strong> <asp:Label ID="lblAvgProgress" runat="server" Text="0%" /></p>
                            <p class="mb-2"><strong>Students with 100% Progress:</strong> <asp:Label ID="lblFullProgress" runat="server" Text="0" /></p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Students GridView -->
            <div class="card border-0 shadow-sm">
                <div class="card-header bg-transparent border-0 py-3 d-flex justify-content-between align-items-center">
                    <h5 class="mb-0"><i class="bi bi-table me-2"></i>Students List</h5>
                    <asp:Label ID="lblStudentCount" runat="server" CssClass="text-muted small" />
                </div>
                <div class="card-body p-0">
                    <asp:GridView ID="gvStudents" runat="server" CssClass="table table-hover mb-0" 
                        AutoGenerateColumns="false" GridLines="None" AllowPaging="true" PageSize="20"
                        AllowSorting="true" OnPageIndexChanging="gvStudents_PageIndexChanging"
                        OnSorting="gvStudents_Sorting" PagerSettings-Mode="NumericFirstLast">
                        <HeaderStyle CssClass="table-light" />
                        <PagerStyle CssClass="pagination justify-content-center" />
                        <Columns>
                            <asp:BoundField DataField="StudentID" HeaderText="Student ID" SortExpression="user_slug" />
                            <asp:BoundField DataField="Name" HeaderText="Name" SortExpression="full_name" />
                            <asp:BoundField DataField="Email" HeaderText="Email" SortExpression="email" />
                            <asp:BoundField DataField="Role" HeaderText="Role" />
                            <asp:BoundField DataField="EnrollmentDate" HeaderText="Enrollment Date" SortExpression="created_at" HtmlEncode="false" DataFormatString="{0:yyyy-MM-dd}" />
                            <asp:BoundField DataField="Progress" HeaderText="Progress (%)" SortExpression="progress" />
                            <asp:BoundField DataField="Status" HeaderText="Status" SortExpression="is_blocked" />
                        </Columns>
                    </asp:GridView>
                    <asp:Label ID="lblNoStudents" runat="server" CssClass="text-center text-muted d-block py-4" Text="No students found" Visible="false" />
                </div>
            </div>
        </div>

        <!-- Teachers Tab -->
        <div class="tab-pane fade" id="teachers" role="tabpanel">
            <!-- Teacher Metrics -->
            <div class="row g-3 mb-4">
                <div class="col-md-3">
                    <div class="card border-0 shadow-sm">
                        <div class="card-body">
                            <h6 class="text-muted mb-2">New Teachers (24h)</h6>
                            <h3 class="mb-0"><asp:Label ID="lblNewTeachers24h" runat="server" Text="0" /></h3>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card border-0 shadow-sm">
                        <div class="card-body">
                            <h6 class="text-muted mb-2">New Teachers (Week)</h6>
                            <h3 class="mb-0"><asp:Label ID="lblNewTeachersWeek" runat="server" Text="0" /></h3>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card border-0 shadow-sm">
                        <div class="card-body">
                            <h6 class="text-muted mb-2">New Teachers (Month)</h6>
                            <h3 class="mb-0"><asp:Label ID="lblNewTeachersMonth" runat="server" Text="0" /></h3>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card border-0 shadow-sm">
                        <div class="card-body">
                            <h6 class="text-muted mb-2">Total Classes Created</h6>
                            <h3 class="mb-0"><asp:Label ID="lblTotalClassesCreated" runat="server" Text="0" /></h3>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Teachers GridView -->
            <div class="card border-0 shadow-sm">
                <div class="card-header bg-transparent border-0 py-3 d-flex justify-content-between align-items-center">
                    <h5 class="mb-0"><i class="bi bi-table me-2"></i>Teachers List</h5>
                    <asp:Label ID="lblTeacherCount" runat="server" CssClass="text-muted small" />
                </div>
                <div class="card-body p-0">
                    <asp:GridView ID="gvTeachers" runat="server" CssClass="table table-hover mb-0" 
                        AutoGenerateColumns="false" GridLines="None" AllowPaging="true" PageSize="20"
                        AllowSorting="true" OnPageIndexChanging="gvTeachers_PageIndexChanging"
                        OnSorting="gvTeachers_Sorting" PagerSettings-Mode="NumericFirstLast">
                        <HeaderStyle CssClass="table-light" />
                        <PagerStyle CssClass="pagination justify-content-center" />
                        <Columns>
                            <asp:BoundField DataField="TeacherID" HeaderText="Teacher ID" SortExpression="user_slug" />
                            <asp:BoundField DataField="Name" HeaderText="Name" SortExpression="full_name" />
                            <asp:BoundField DataField="Email" HeaderText="Email" SortExpression="email" />
                            <asp:BoundField DataField="Role" HeaderText="Role" />
                            <asp:BoundField DataField="ClassesCreated" HeaderText="Classes Created" SortExpression="classes_created" />
                            <asp:BoundField DataField="ActiveSince" HeaderText="Active Since" SortExpression="created_at" HtmlEncode="false" DataFormatString="{0:yyyy-MM-dd}" />
                            <asp:BoundField DataField="NumberOfStudents" HeaderText="Number of Students" SortExpression="student_count" />
                        </Columns>
                    </asp:GridView>
                    <asp:Label ID="lblNoTeachers" runat="server" CssClass="text-center text-muted d-block py-4" Text="No teachers found" Visible="false" />
                </div>
            </div>
        </div>

        <!-- Classes Tab -->
        <div class="tab-pane fade" id="classes" role="tabpanel">
            <!-- Class Metrics -->
            <div class="row g-3 mb-4">
                <div class="col-md-4">
                    <div class="card border-0 shadow-sm">
                        <div class="card-body">
                            <h6 class="text-muted mb-2">Inactive Classes</h6>
                            <h3 class="mb-0"><asp:Label ID="lblInactiveClasses" runat="server" Text="0" /></h3>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card border-0 shadow-sm">
                        <div class="card-body">
                            <h6 class="text-muted mb-2">Average Students per Class</h6>
                            <h3 class="mb-0"><asp:Label ID="lblAvgStudentsPerClass" runat="server" Text="0" /></h3>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card border-0 shadow-sm">
                        <div class="card-body">
                            <h6 class="text-muted mb-2">Most Popular Class</h6>
                            <h5 class="mb-0"><asp:Label ID="lblMostPopularClass" runat="server" Text="N/A" /></h5>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Classes GridView -->
            <div class="card border-0 shadow-sm">
                <div class="card-header bg-transparent border-0 py-3 d-flex justify-content-between align-items-center">
                    <h5 class="mb-0"><i class="bi bi-table me-2"></i>Classes List</h5>
                    <asp:Label ID="lblClassCount" runat="server" CssClass="text-muted small" />
                </div>
                <div class="card-body p-0">
                    <asp:GridView ID="gvClasses" runat="server" CssClass="table table-hover mb-0" 
                        AutoGenerateColumns="false" GridLines="None" AllowPaging="true" PageSize="20"
                        AllowSorting="true" OnPageIndexChanging="gvClasses_PageIndexChanging"
                        OnSorting="gvClasses_Sorting" PagerSettings-Mode="NumericFirstLast">
                        <HeaderStyle CssClass="table-light" />
                        <PagerStyle CssClass="pagination justify-content-center" />
                        <Columns>
                            <asp:BoundField DataField="ClassID" HeaderText="Class ID" SortExpression="class_slug" />
                            <asp:BoundField DataField="ClassName" HeaderText="Class Name" SortExpression="class_name" />
                            <asp:BoundField DataField="Teacher" HeaderText="Teacher" SortExpression="teacher_name" />
                            <asp:BoundField DataField="ClassCode" HeaderText="Class Code" SortExpression="class_code" />
                            <asp:BoundField DataField="TotalStudents" HeaderText="Total Students" SortExpression="total_students" />
                            <asp:BoundField DataField="ActiveStudents" HeaderText="Active Students" SortExpression="active_students" />
                            <asp:BoundField DataField="EnrollmentDate" HeaderText="Enrollment Date" SortExpression="created_at" HtmlEncode="false" DataFormatString="{0:yyyy-MM-dd}" />
                        </Columns>
                    </asp:GridView>
                    <asp:Label ID="lblNoClasses" runat="server" CssClass="text-center text-muted d-block py-4" Text="No classes found" Visible="false" />
                </div>
            </div>
        </div>

    </div>

    <asp:Label ID="lblPageError" runat="server" CssClass="alert alert-danger d-none" />
    <asp:Label ID="lblPageMessage" runat="server" CssClass="alert alert-success d-none" />

    <style>
        body {
            background: #f5f7fa !important;
        }
        .card {
            background: #ffffff;
            border: 1px solid #e8ecf1;
        }
        .card-header {
            background: #ffffff !important;
            border-bottom: 1px solid #e8ecf1;
        }
        h2, h3, h4, h5, h6 {
            color: #2d3748 !important;
        }
        .table th, .table td {
            vertical-align: middle;
        }
        .nav-tabs .nav-link {
            color: #6c757d;
        }
        .nav-tabs .nav-link.active {
            color: #0d6efd;
            font-weight: 600;
        }
    </style>

</asp:Content>

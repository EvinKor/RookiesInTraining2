<%@ Page Title="Manage Classes"
    Language="C#"
    MasterPageFile="~/MasterPages/dashboard.Master"
    AutoEventWireup="true"
    CodeBehind="Classes.aspx.cs"
    Inherits="RookiesInTraining2.Pages.ManageClasses" %>

<asp:Content ID="Content1" ContentPlaceHolderID="DashboardContent" runat="server">
    
    <!-- Page Header -->
    <div class="row mb-4">
        <div class="col-12">
            <div class="d-flex align-items-center mb-3">
                <div class="flex-grow-1">
                    <h2 class="mb-1">Classes Management</h2>
                    <p class="text-muted mb-0">View and manage all classes in the system</p>
                </div>
                <div>
                    <asp:Button ID="btnExportCSV" runat="server" Text="Export CSV" CssClass="btn btn-outline-primary me-2" OnClick="btnExportCSV_Click" />
                    <a href="<%= ResolveUrl("~/Pages/admin/admin_create_module.aspx") %>" class="btn btn-success">
                        <i class="bi bi-plus-circle me-2"></i>Create New Class
                    </a>
                </div>
            </div>
        </div>
    </div>

    <!-- Filters and Search -->
    <div class="row mb-3">
        <div class="col-md-6">
            <div class="input-group">
                <span class="input-group-text"><i class="bi bi-search"></i></span>
                <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" placeholder="Search by class name or code..." AutoPostBack="true" OnTextChanged="txtSearch_TextChanged" />
            </div>
        </div>
        <div class="col-md-3">
            <asp:Label ID="lblClassCount" runat="server" CssClass="form-control text-muted" />
        </div>
    </div>

    <!-- Classes Grid -->
    <div class="row g-4">
        <asp:Repeater ID="rptClasses" runat="server" OnItemCommand="rptClasses_ItemCommand">
            <ItemTemplate>
                <div class="col-md-6 col-lg-4">
                    <div class="class-card clickable-card" 
                         style="--class-color: <%# Eval("Color") %>; cursor: pointer;"
                         onclick="window.location.href='<%# ResolveUrl("~/Pages/admin/manage_classes.aspx?class=" + Server.UrlEncode(Eval("ClassSlug").ToString())) %>'">
                        <div class="class-card-header">
                            <div class="class-icon">
                                <i class="<%# Eval("Icon") %> fs-2"></i>
                            </div>
                            <h3 class="class-name"><%# Server.HtmlEncode(Eval("ClassName").ToString()) %></h3>
                            <span class="class-code"><%# Server.HtmlEncode(Eval("ClassCode").ToString()) %></span>
                        </div>
                        <div class="class-card-body">
                            <div class="class-stats">
                                <div class="class-stat">
                                    <i class="bi bi-person-badge"></i>
                                    <div class="class-stat-text">
                                        <div class="class-stat-value"><%# Eval("TeacherName") %></div>
                                        <div class="class-stat-label">teacher</div>
                                    </div>
                                </div>
                                <div class="class-stat">
                                    <i class="bi bi-people"></i>
                                    <div class="class-stat-text">
                                        <div class="class-stat-value"><%# Eval("StudentCount") %></div>
                                        <div class="class-stat-label">students</div>
                                    </div>
                                </div>
                            </div>
                            <div class="mt-3">
                                <small class="text-muted">
                                    <i class="bi bi-calendar me-1"></i>Created: <%# Eval("CreatedAt") %>
                                </small>
                            </div>
                        </div>
                        <div class="class-card-footer">
                            <i class="bi bi-arrow-right-circle me-1"></i>Click to view class details
                        </div>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
    
    <asp:Label ID="lblNoClasses" runat="server" CssClass="text-muted text-center d-block py-5"
               Text="No classes found" Visible="false" />

    <style>
        body {
            background: #f5f7fa !important;
        }
        .card {
            background: white;
            border: 1px solid #e8ecf1;
        }
        h2, h3, h4, h5, h6 {
            color: #2d3748 !important;
        }
        
        /* Class Cards */
        .class-card {
            border: 1px solid #e8ecf1;
            border-radius: 1rem;
            overflow: hidden;
            transition: all 0.3s ease;
            cursor: pointer;
            height: 100%;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            background: white;
        }
        .class-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 8px 24px rgba(0,0,0,0.12);
            border-color: var(--class-color, #667eea);
        }
        .class-card-header {
            padding: 1.5rem;
            border-bottom: 3px solid var(--class-color, #667eea);
            background: linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(118, 75, 162, 0.1) 100%);
            color: #2d3748;
        }
        .class-card-body {
            padding: 1.5rem;
            background: white;
        }
        .class-card-footer {
            padding: 1rem 1.5rem;
            background: #f8f9fa;
            border-top: 1px solid #e8ecf1;
            color: #6c757d;
            font-size: 0.875rem;
        }
        .class-icon {
            font-size: 2rem;
            margin-bottom: 0.5rem;
            opacity: 0.9;
        }
        .class-name {
            font-size: 1.25rem;
            font-weight: 600;
            color: #2d3748;
            margin-bottom: 0.5rem;
        }
        .class-code {
            display: inline-block;
            padding: 0.25rem 0.75rem;
            background: white;
            border: 1px solid #e8ecf1;
            border-radius: 0.5rem;
            font-size: 0.875rem;
            color: #6c757d;
            font-weight: 500;
        }
        .class-stats {
            display: flex;
            gap: 1.5rem;
            flex-wrap: wrap;
        }
        .class-stat {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        .class-stat i {
            font-size: 1.5rem;
            color: var(--class-color, #667eea);
            opacity: 0.8;
        }
        .class-stat-text {
            display: flex;
            flex-direction: column;
        }
        .class-stat-value {
            font-weight: 600;
            color: #2d3748;
            font-size: 0.95rem;
        }
        .class-stat-label {
            font-size: 0.75rem;
            color: #6c757d;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
    </style>

</asp:Content>


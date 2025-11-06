<%@ Page Title="Create Thread"
    Language="C#"
    MasterPageFile="~/MasterPages/dashboard.Master"
    AutoEventWireup="true"
    CodeBehind="create.aspx.cs"
    Inherits="RookiesInTraining2.Pages.forum.create" %>

<asp:Content ID="Content1" ContentPlaceHolderID="DashboardContent" runat="server">
    <div class="container py-4">
        <nav aria-label="breadcrumb" class="mb-4">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="list.aspx">Forum</a></li>
                <li class="breadcrumb-item active">Create Thread</li>
            </ol>
        </nav>

        <div class="row justify-content-center">
            <div class="col-md-8">
                <div class="card" style="background: #111827; border-color: #1f2937;">
                    <div class="card-body">
                        <h3 class="text-light mb-4">Create New Thread</h3>

                        <div class="mb-3">
                            <label for="<%= txtTitle.ClientID %>" class="form-label text-light">Title</label>
                            <asp:TextBox ID="txtTitle" runat="server" CssClass="form-control" 
                                         MaxLength="200" required="true" />
                            <asp:RequiredFieldValidator ID="rfvTitle" runat="server" 
                                ControlToValidate="txtTitle" 
                                ErrorMessage="Title is required" 
                                CssClass="text-danger" Display="Dynamic" />
                        </div>

                        <div class="mb-3">
                            <label for="<%= txtContent.ClientID %>" class="form-label text-light">Content</label>
                            <asp:TextBox ID="txtContent" runat="server" CssClass="form-control" 
                                         TextMode="MultiLine" Rows="8" required="true" />
                            <asp:RequiredFieldValidator ID="rfvContent" runat="server" 
                                ControlToValidate="txtContent" 
                                ErrorMessage="Content is required" 
                                CssClass="text-danger" Display="Dynamic" />
                        </div>

                        <asp:Label ID="lblError" runat="server" CssClass="text-danger" Visible="false" />

                        <div class="d-flex gap-2">
                            <asp:Button ID="btnSubmit" runat="server" Text="Create Thread" 
                                       CssClass="btn btn-primary" OnClick="btnSubmit_Click" />
                            <a href="list.aspx" class="btn btn-outline-secondary">Cancel</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>


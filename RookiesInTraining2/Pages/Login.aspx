<%@ Page Title="Login"
    Language="C#"
    MasterPageFile="~/MasterPages/MyMain.master"
    AutoEventWireup="true"
    CodeBehind="Login.aspx.cs"
    Inherits="RookiesInTraining2.Pages.Login" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

  <div class="container d-flex justify-content-center align-items-center" style="min-height: 90vh;">
    <div class="card shadow-lg border-0 rounded-4" style="max-width: 420px; width: 100%;">
      <div class="card-body p-4">
        <div class="text-center mb-4">
          <div class="d-inline-flex align-items-center justify-content-center bg-primary text-white rounded-circle mb-2" style="width: 60px; height: 60px;">
            <span class="fw-bold fs-4">R</span>
          </div>
          <h4 class="fw-semibold mb-1">Welcome Back</h4>
          <p class="text-muted small mb-0">Sign in to continue</p>
        </div>

        <asp:ValidationSummary ID="vsLogin" runat="server" ValidationGroup="LoginGroup"
          CssClass="alert alert-danger py-2" HeaderText="Please fix the following:" DisplayMode="BulletList" />

        <div class="form-floating mb-3">
          <asp:TextBox ID="txtLoginEmail" runat="server" CssClass="form-control" TextMode="Email" placeholder="Email" />
          <label for="txtLoginEmail">Email address</label>
          <asp:RequiredFieldValidator runat="server" ControlToValidate="txtLoginEmail"
            ValidationGroup="LoginGroup" CssClass="text-danger small d-block mt-1" ErrorMessage="Email is required." />
        </div>

        <div class="form-floating mb-3">
          <asp:TextBox ID="txtLoginPassword" runat="server" CssClass="form-control" TextMode="Password" placeholder="Password" />
          <label for="txtLoginPassword">Password</label>
          <asp:RequiredFieldValidator runat="server" ControlToValidate="txtLoginPassword"
            ValidationGroup="LoginGroup" CssClass="text-danger small d-block mt-1" ErrorMessage="Password is required." />
        </div>

        <asp:Label ID="lblLoginError" runat="server" CssClass="text-danger small d-block mb-2" />

        <asp:Button ID="btnLogin" runat="server" Text="Sign In"
          CssClass="btn btn-primary w-100 py-2 fw-semibold"
          ValidationGroup="LoginGroup" OnClick="btnLogin_Click" />

        <div class="text-center mt-3">
          <span class="text-muted small">Don’t have an account?</span>
          <a href="<%: ResolveUrl("~/Pages/Register.aspx") %>" class="text-decoration-none fw-semibold">Register</a>
        </div>
      </div>
    </div>
  </div>

</asp:Content>

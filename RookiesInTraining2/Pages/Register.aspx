<%@ Page Title="Register"
    Language="C#"
    MasterPageFile="~/MasterPages/MyMain.master"
    AutoEventWireup="true"
    CodeBehind="Register.aspx.cs"
    Inherits="RookiesInTraining2.Pages.Register" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

  <style>
    .role-selector {
      display: flex;
      gap: 1rem;
      margin-top: 0.5rem;
    }
    .role-selector label {
      flex: 1;
      padding: 0.75rem 1rem;
      border: 2px solid #dee2e6;
      border-radius: 0.5rem;
      cursor: pointer;
      transition: all 0.3s ease;
      text-align: center;
      font-weight: 500;
    }
    .role-selector label:hover {
      border-color: #0d6efd;
      background-color: #f8f9fa;
    }
    .role-selector input[type="radio"]:checked + label {
      border-color: #0d6efd;
      background-color: #e7f1ff;
      color: #0d6efd;
    }
    .role-selector input[type="radio"] {
      position: absolute;
      opacity: 0;
      pointer-events: none;
    }
  </style>

  <div class="container d-flex justify-content-center align-items-center" style="min-height: 90vh;">
    <div class="card shadow-lg border-0 rounded-4" style="max-width: 450px; width: 100%;">
      <div class="card-body p-4">
        <div class="text-center mb-4">
          <div class="d-inline-flex align-items-center justify-content-center bg-success text-white rounded-circle mb-2" style="width: 60px; height: 60px;">
            <span class="fw-bold fs-4">R</span>
          </div>
          <h4 class="fw-semibold mb-1">Create Account</h4>
          <p class="text-muted small mb-0">Join Rookies in Training today</p>
        </div>

        <asp:ValidationSummary ID="vsRegister" runat="server" ValidationGroup="RegGroup"
          CssClass="alert alert-danger py-2" HeaderText="Please fix the following:" DisplayMode="BulletList" />

        <div class="form-floating mb-3">
          <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" placeholder="Full Name" />
          <label for="txtFullName">Full Name</label>
          <asp:RequiredFieldValidator runat="server" ControlToValidate="txtFullName"
            ValidationGroup="RegGroup" CssClass="text-danger small d-block mt-1" ErrorMessage="Full name is required." />
        </div>

        <div class="form-floating mb-3">
          <asp:TextBox ID="txtRegEmail" runat="server" CssClass="form-control" TextMode="Email" placeholder="Email" />
          <label for="txtRegEmail">Email address</label>
          <asp:RequiredFieldValidator runat="server" ControlToValidate="txtRegEmail"
            ValidationGroup="RegGroup" CssClass="text-danger small d-block mt-1" ErrorMessage="Email is required." />
        </div>

        <div class="form-floating mb-3">
          <asp:TextBox ID="txtRegPassword" runat="server" CssClass="form-control" TextMode="Password" placeholder="Password" />
          <label for="txtRegPassword">Password</label>
          <asp:RequiredFieldValidator runat="server" ControlToValidate="txtRegPassword"
            ValidationGroup="RegGroup" CssClass="text-danger small d-block mt-1" ErrorMessage="Password is required." />
        </div>

        <div class="form-floating mb-3">
          <asp:TextBox ID="txtRegConfirm" runat="server" CssClass="form-control" TextMode="Password" placeholder="Confirm Password" />
          <label for="txtRegConfirm">Confirm Password</label>
          <asp:CompareValidator runat="server" ControlToValidate="txtRegConfirm" ControlToCompare="txtRegPassword"
            ValidationGroup="RegGroup" CssClass="text-danger small d-block mt-1" ErrorMessage="Passwords do not match." />
        </div>

        <div class="alert alert-info mb-4">
          <small><i class="bi bi-info-circle me-1"></i><strong>Note:</strong> Only student accounts can be created through registration. Teacher accounts must be created by an administrator.</small>
        </div>

        <asp:Label ID="lblRegError" runat="server" CssClass="text-danger small d-block mb-2" />

        <asp:Button ID="btnRegister" runat="server" Text="Create Account"
          CssClass="btn btn-success w-100 py-2 fw-semibold"
          ValidationGroup="RegGroup" OnClick="btnRegister_Click" />

        <div class="text-center mt-3">
          <span class="text-muted small">Already registered?</span>
          <a href="<%: ResolveUrl("~/Pages/Login.aspx") %>" class="text-decoration-none fw-semibold">Sign in</a>
        </div>
      </div>
    </div>
  </div>

</asp:Content>

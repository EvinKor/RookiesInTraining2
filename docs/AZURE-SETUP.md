# Azure Deployment Setup Guide

## Prerequisites

1. Azure Subscription
2. Azure SQL Database
3. Azure App Service (Windows)
4. Azure Blob Storage (optional, for file uploads)

## Step 1: Create Azure Resources

### Azure SQL Database

1. Go to Azure Portal → Create Resource → SQL Database
2. Configure:
   - **Database name**: `RookiesDatabase`
   - **Server**: Create new server
   - **Pricing tier**: Basic (for dev) or Standard S1 (for production)
   - **Collation**: SQL_Latin1_General_CP1_CI_AS
3. Note the connection string format:
   ```
   Server=tcp:{server-name}.database.windows.net,1433;Initial Catalog=RookiesDatabase;Persist Security Info=False;User ID={username};Password={password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;
   ```

### Azure App Service

1. Go to Azure Portal → Create Resource → Web App
2. Configure:
   - **Runtime stack**: .NET Framework 4.7
   - **Operating System**: Windows
   - **App Service Plan**: Create new (Basic B1 minimum)
3. After creation, go to **Configuration** → **Application settings**

### Azure Blob Storage (Optional)

1. Go to Azure Portal → Create Resource → Storage Account
2. Configure:
   - **Performance**: Standard
   - **Replication**: LRS (for dev) or GRS (for production)
3. Create a container named `uploads`

## Step 2: Deploy Database Schema

1. Connect to Azure SQL Database using SQL Server Management Studio
2. Run `ALL_TABLES_FORMATTED.sql` to create all tables
3. Run any additional migration scripts
4. Seed initial data if needed

## Step 3: Configure App Service

### Connection Strings

In Azure Portal → App Service → Configuration → Connection strings:

Add:
- **Name**: `ConnectionString`
- **Value**: Your Azure SQL connection string
- **Type**: SQLAzure

### Application Settings

In Azure Portal → App Service → Configuration → Application settings:

Add:
```
Azure:Blob:ConnectionString = <Your blob storage connection string>
Azure:Blob:Container = uploads
Azure:SignalR:Enabled = false
AI:Provider = Mock
AI:Endpoint = 
AI:ApiKey = 
```

## Step 4: Update Web.config

Create `Web.Release.config` transform:

```xml
<?xml version="1.0" encoding="utf-8"?>
<configuration xmlns:xdt="http://schemas.microsoft.com/XML-Document-Transform">
  <connectionStrings>
    <add name="ConnectionString" 
         connectionString="REPLACE_WITH_AZURE_SQL_CONNECTION_STRING"
         xdt:Transform="SetAttributes" xdt:Locator="Match(name)" />
  </connectionStrings>
  <system.web>
    <compilation xdt:Transform="RemoveAttributes(debug)" />
    <customErrors mode="RemoteOnly" xdt:Transform="SetAttributes(mode)" />
  </system.web>
</configuration>
```

**Note**: For Web Forms, connection strings should be set in Azure Portal, not in Web.config transforms (for security).

## Step 5: Publish from Visual Studio

1. Right-click project → **Publish**
2. Select **Azure** → **Azure App Service (Windows)**
3. Select your App Service
4. Click **Publish**

### Alternative: Publish Profile

1. Download publish profile from Azure Portal:
   - App Service → **Get publish profile**
2. In Visual Studio:
   - Right-click project → **Publish**
   - **Import Profile** → Select downloaded `.publishsettings` file

## Step 6: Configure WebSockets (for SignalR)

1. In Azure Portal → App Service → **Configuration**
2. Under **General settings**, enable **Web sockets**
3. Click **Save**

## Step 7: Health Check Endpoint

Create a simple health check page:

**Pages/health.aspx**:
```aspx
<%@ Page Language="C#" %>
<%
    Response.ContentType = "application/json";
    Response.Write("{\"status\":\"healthy\",\"timestamp\":\"" + DateTime.UtcNow.ToString("o") + "\"}");
%>
```

Access at: `https://{your-app}.azurewebsites.net/Pages/health.aspx`

## Step 8: Environment Variables

For production, set these in Azure Portal → Configuration:

| Key | Value | Description |
|-----|-------|-------------|
| `ASPNETCORE_ENVIRONMENT` | `Production` | Environment name |
| `ConnectionStrings:Default` | (Azure SQL) | Database connection |
| `Azure:Blob:ConnectionString` | (Blob Storage) | File storage |
| `Azure:Blob:Container` | `uploads` | Container name |

## Troubleshooting

### Database Connection Issues

1. Check firewall rules in Azure SQL:
   - Allow Azure services: **Yes**
   - Add your IP address
2. Verify connection string format
3. Check SQL Server authentication (not Windows Auth)

### Deployment Issues

1. Check build configuration: **Release**
2. Verify .NET Framework version matches (4.7.2)
3. Check application logs in Azure Portal

### SignalR Issues

1. Ensure WebSockets enabled
2. For scale-out, consider Azure SignalR Service
3. Check CORS settings if needed

## Cost Estimation (Monthly)

- **Azure SQL Basic**: ~$5/month
- **App Service Basic B1**: ~$13/month
- **Blob Storage**: ~$0.02/GB
- **Total (Dev)**: ~$18-20/month

## Security Checklist

- [ ] Use Azure Key Vault for secrets (recommended)
- [ ] Enable HTTPS only
- [ ] Set up SQL firewall rules
- [ ] Use managed identity if possible
- [ ] Enable application insights for monitoring
- [ ] Set up backup schedule for database

## Next Steps

1. Set up CI/CD pipeline (Azure DevOps or GitHub Actions)
2. Configure custom domain
3. Set up SSL certificate
4. Enable Application Insights
5. Configure auto-scaling if needed

---

**Note**: This is a Web Forms application (.NET Framework), not ASP.NET Core. Some Azure features may work differently than with Core applications.


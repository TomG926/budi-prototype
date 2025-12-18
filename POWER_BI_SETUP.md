# Power BI REST API Setup Guide

This guide explains how to configure Power BI REST API integration for pushing CSV data to Power BI.

## Prerequisites

1. Azure Active Directory (Azure AD) account with Power BI access
2. Power BI Pro or Premium license (for workspace access)
3. Ability to create Azure AD App Registrations

## Step 1: Create Azure AD App Registration

1. Go to [Azure Portal](https://portal.azure.com)
2. Navigate to **Azure Active Directory** > **App registrations**
3. Click **New registration**
4. Fill in:
   - **Name**: `Budi Prototype Power BI`
   - **Supported account types**: Accounts in this organizational directory only
   - **Redirect URI**: Leave blank (not needed for service principal)
5. Click **Register**

## Step 2: Create Client Secret

1. In your new App Registration, go to **Certificates & secrets**
2. Click **New client secret**
3. Add description (e.g., "Power BI API Access")
4. Choose expiration (recommend 24 months for development)
5. Click **Add**
6. **IMPORTANT**: Copy the **Value** immediately (you won't see it again)

## Step 3: Grant Power BI API Permissions

1. In your App Registration, go to **API permissions**
2. Click **Add a permission**
3. Select **Power BI Service**
4. Choose **Application permissions** (not Delegated)
5. Select these permissions:
   - `Dataset.ReadWrite.All`
   - `Workspace.Read.All` (if using workspace)
6. Click **Add permissions**
7. Click **Grant admin consent** (requires admin privileges)

## Step 4: Get Your Tenant ID

1. In Azure Portal, go to **Azure Active Directory** > **Overview**
2. Copy the **Tenant ID**

## Step 5: Configure Rails Application

### Option A: Using Rails Encrypted Credentials (Recommended)

```bash
EDITOR="code --wait" bin/rails credentials:edit
```

Add the following:

```yaml
power_bi:
  tenant_id: "your-tenant-id-here"
  client_id: "your-client-id-here"
  client_secret: "your-client-secret-value-here"
  workspace_id: "your-workspace-id-here"  # Optional, use "myorg" for default workspace
```

### Option B: Using Environment Variables

Set these environment variables in your `.env` file or system:

```bash
export POWER_BI_TENANT_ID="your-tenant-id"
export POWER_BI_CLIENT_ID="your-client-id"
export POWER_BI_CLIENT_SECRET="your-client-secret"
export POWER_BI_WORKSPACE_ID="your-workspace-id"  # Optional
```

Then update `app/services/power_bi_service.rb` to read from ENV:

```ruby
@tenant_id = ENV['POWER_BI_TENANT_ID'] || Rails.application.credentials.dig(:power_bi, :tenant_id)
@client_id = ENV['POWER_BI_CLIENT_ID'] || Rails.application.credentials.dig(:power_bi, :client_id)
# ... etc
```

## Step 6: Get Workspace ID (Optional)

If you want to use a specific Power BI workspace:

1. Go to [Power BI Service](https://app.powerbi.com)
2. Navigate to your workspace
3. Look at the URL: `https://app.powerbi.com/groups/YOUR_WORKSPACE_ID/...`
4. Copy the workspace ID from the URL

If you don't specify a workspace, the default workspace will be used.

## Step 7: Test the Integration

1. Upload a CSV file through the Rails app
2. Check the upload status - it should show "Power BI Connected" when successful
3. Go to Power BI Service and verify the dataset was created
4. Create a report and use AI visuals:
   - **Key Influencers** - to find what drives metrics
   - **Anomaly Detection** - to find outliers in time series
   - **Smart Narrative** - to get natural language insights
   - **Decomposition Tree** - to drill down into factors

## Troubleshooting

### Authentication Errors

- Verify tenant ID, client ID, and client secret are correct
- Ensure admin consent was granted for API permissions
- Check that the client secret hasn't expired

### Dataset Creation Fails

- Verify `Dataset.ReadWrite.All` permission is granted
- Check that workspace ID is correct (if specified)
- Ensure app registration has proper Power BI service access

### Rows Not Appearing in Power BI

- Check Rails logs for errors: `tail -f log/development.log`
- Verify data format matches the schema
- Power BI has a 10,000 row limit per push operation (handled automatically in batches)

## Security Best Practices

1. **Never commit credentials to Git** - use encrypted credentials or environment variables
2. **Rotate client secrets regularly** - especially if compromised
3. **Use least privilege** - only grant necessary Power BI permissions
4. **Monitor API usage** - check Azure AD logs for suspicious activity
5. **Store secrets securely** - use Azure Key Vault in production

## Support

For issues:
- Check Rails logs: `log/development.log`
- Check Power BI service health: https://status.powerbi.com
- Azure AD documentation: https://docs.microsoft.com/azure/active-directory
- Power BI REST API docs: https://docs.microsoft.com/rest/api/power-bi/


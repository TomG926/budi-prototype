# Quick Guide: Getting Power BI Credentials

Follow these steps to get your Power BI REST API credentials from Azure Portal.

## Step 1: Get Your Azure AD Tenant ID

1. Go to [Azure Portal](https://portal.azure.com)
2. Sign in with your Azure account
3. In the top search bar, search for **"Azure Active Directory"** or **"Microsoft Entra ID"**
4. Click on **Azure Active Directory** (or Microsoft Entra ID)
5. On the Overview page, you'll see **Tenant ID** - copy this value

**This is your `tenant_id`**

---

## Step 2: Create Azure AD App Registration

1. Still in Azure Active Directory, click on **App registrations** in the left menu
2. Click **+ New registration** button at the top
3. Fill in the form:
   - **Name**: `Budi Prototype Power BI` (or any name you prefer)
   - **Supported account types**: Select **"Accounts in this organizational directory only"**
   - **Redirect URI**: Leave blank (we don't need it for service principal authentication)
4. Click **Register**

**After registration, you'll see the App Registration page. Keep this open - you'll need the Application (client) ID next.**

---

## Step 3: Get Client ID

1. On your App Registration page (from Step 2), you should already be on the **Overview** page
2. Look for **Application (client) ID** - this is a GUID (e.g., `12345678-abcd-1234-efgh-123456789abc`)
3. Copy this value

**This is your `client_id`**

---

## Step 4: Create Client Secret

1. Still in your App Registration, click **Certificates & secrets** in the left menu
2. Under **Client secrets**, click **+ New client secret**
3. Fill in:
   - **Description**: `Power BI API Access` (or any description)
   - **Expires**: Choose **24 months** (or your preference)
4. Click **Add**
5. **IMPORTANT**: A **Value** will appear - **COPY IT IMMEDIATELY** (you won't be able to see it again after leaving this page!)
   - The value will look like: `abcd1234~EFGH5678-ijkl9012-MNOP3456-qrst7890`

**This is your `client_secret`**

⚠️ **Save this securely** - if you lose it, you'll need to create a new one.

---

## Step 5: Grant Power BI API Permissions

1. Still in your App Registration, click **API permissions** in the left menu
2. Click **+ Add a permission**
3. Select **APIs my organization uses**
4. Search for **"Power BI Service"** and select it
5. Select **Application permissions** (NOT Delegated)
6. Check the following permissions:
   - ✅ **Dataset.ReadWrite.All**
   - ✅ **Workspace.Read.All** (optional, only needed if using a specific workspace)
7. Click **Add permissions**
8. **Important**: Click **Grant admin consent for [Your Organization]** button
   - You may need admin privileges for this
   - This step is REQUIRED for the app to work

---

## Step 6: Get Power BI Workspace ID (Optional)

**Skip this step if you want to use your default workspace (recommended for testing).**

If you want to use a specific Power BI workspace:

1. Go to [Power BI Service](https://app.powerbi.com)
2. Navigate to your workspace (or create one)
3. Look at the URL in your browser - it will look like:
   ```
   https://app.powerbi.com/groups/YOUR_WORKSPACE_ID/...
   ```
4. Copy the `YOUR_WORKSPACE_ID` part from the URL

**This is your `workspace_id`** (optional - you can use `"myorg"` or leave it blank to use your default workspace)

---

## Step 7: Configure Rails Credentials

Now that you have all the values, configure Rails:

1. Open your terminal in WSL:
   ```bash
   cd ~/code/budi-prototype
   EDITOR="code --wait" bin/rails credentials:edit
   ```

2. Add this structure (replace with your actual values):
   ```yaml
   power_bi:
     tenant_id: "your-actual-tenant-id-here"
     client_id: "your-actual-client-id-here"
     client_secret: "your-actual-client-secret-here"
     workspace_id: "myorg"  # or your workspace ID, or leave blank
   ```

3. Save and close the editor

---

## Example Credentials Format

Your credentials file should look something like this:

```yaml
# aws:
#   access_key_id: 123
#   secret_access_key: 345

power_bi:
  tenant_id: "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
  client_id: "12345678-abcd-1234-efgh-123456789abc"
  client_secret: "abcd1234~EFGH5678-ijkl9012-MNOP3456-qrst7890"
  workspace_id: "myorg"
```

---

## Troubleshooting

### "Power BI authentication failed"
- Double-check tenant_id, client_id, and client_secret
- Make sure client_secret hasn't expired
- Verify admin consent was granted for API permissions

### "Failed to create Power BI dataset"
- Ensure `Dataset.ReadWrite.All` permission is granted
- Check that admin consent was granted
- Verify you have Power BI Pro or Premium license

### Can't find Tenant ID
- Make sure you're in the correct Azure AD directory
- Check if you have multiple tenants - select the correct one

### Client Secret not showing
- You can only see the secret value ONCE when you create it
- If lost, delete the old secret and create a new one

---

## Test Your Configuration

After setting up credentials:

1. Upload a new CSV file through the web interface
2. Check the upload status page
3. You should see "Power BI Connected" status
4. The dataset ID will be displayed
5. Go to Power BI Service to see your dataset

---

## Security Notes

- ✅ Never commit credentials to Git
- ✅ Use encrypted Rails credentials (which you are)
- ✅ Rotate client secrets regularly
- ✅ Use least privilege (only grant necessary permissions)
- ✅ Consider using Azure Key Vault in production


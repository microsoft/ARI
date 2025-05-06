# Running ARI with GitHub Actions

This guide explains how to use GitHub Actions to run Azure Resource Inventory automatically, providing an alternative to Azure Automation Accounts.

## Overview

GitHub Actions offers a flexible way to automate the execution of Azure Resource Inventory on a schedule or in response to events. This can be useful if:

- You want to avoid creating and maintaining Azure Automation Accounts
- You're already using GitHub for infrastructure-as-code (e.g., Terraform, Bicep)
- You want to store your inventory reports alongside your infrastructure code
- You prefer a Git-based workflow for managing automation

## Prerequisites

To use this approach, you'll need:

1. A GitHub repository
2. An Azure service principal or user-assigned identity with appropriate permissions
3. GitHub Secrets to store your Azure credentials securely

## Setting Up Azure Authentication

### Using service principal

1. Create a service principal in Azure:

```bash
az ad sp create-for-rbac --name "ARI-GitHub-Action" --role "Reader" --scopes "/subscriptions/YOUR_SUBSCRIPTION_ID" --sdk-auth
```

2. Save the JSON output from this command. It will look similar to:

```json
{
  "clientId": "YOUR_CLIENT_ID",
  "clientSecret": "YOUR_CLIENT_SECRET",
  "subscriptionId": "YOUR_SUBSCRIPTION_ID",
  "tenantId": "YOUR_TENANT_ID",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
```
3. In your GitHub repository, go to Settings → Secrets and variables → Actions

4. Create these repository secrets:
   - `AZURE_CLIENT_ID`: The client ID from the JSON
   - `AZURE_CLIENT_SECRET`: The client secret from the JSON
   - `AZURE_TENANT_ID`: The tenant ID from the JSON
   - `AZURE_SUBSCRIPTION_ID`: The subscription ID from the JSON







### Using user-assigned identity
1. Create a user-assigned identity in Azure:
``` bash
az identity create --name <identity-name> --resource-group <resource-group-name>
```

The output of this command will look similar to this:
``` json
{
  "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "clientResourceGroup": "myResourceGroup",
  "id": "/subscriptions/<subscription-id>/resourcegroups/myResourceGroup/providers/Microsoft.ManagedIdentity/userAssignedIdentities/myIdentity",
  "location": "eastus",
  "name": "myIdentity",
  "principalId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "resourceGroup": "myResourceGroup",
  "tags": {},
  "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "type": "Microsoft.ManagedIdentity/userAssignedIdentities"
}
```

You should save this for later steps.

2. Assign reader role with appropiate scope:
``` bash
az role assignment create --assignee <principal-id> --role "Reader" --scope <scope>
```
The scope of the role assignement will define if ARI will be able to find resources. It is adviseable to use the subscription/management group that contains everything you want to document.

3. Create Federated Credentials  
To log in with the created user-assigned identity, we need to create a federated credential, to be able to use OIDC to connect.
``` bash
az identity federated-credential create
  --identity-name "myManagedIdentity"
  --resource-group "myResourceGroup"
  --issuer "https://token.actions.githubusercontent.com" 
  --subject "repo:myorg/myrepo:ref:refs/heads/main"
  --name "github-federation"
  # Issuer will differ if you use GitHub Enterprise server.
```
You can also follow the the Microsoft Learn documentation: [MS Learn/Configure a federated identity credential on a user-assigned managed identity](https://learn.microsoft.com/en-gb/entra/workload-id/workload-identity-federation-create-trust-user-assigned-managed-identity?pivots=identity-wif-mi-methods-azp#github-actions-deploying-azure-resources)


4. (Optional) Retrieve identity parameters  
If you forgot to save the output of the user-assigned identity, you can retrieve the necessary fields using the following commands:

``` bash
az identity show --name <identity-name> --resource-group <resource-group>
``` 

5. Set GitHub Secrets  
  You can either set GitHub secrets using the online interface, or using GitHub CLI.

  - If you want to set it using the online   graphical interface:
    - In your GitHub repository, go to Settings → Secrets and variables → Actions
    

  -  If you want to set it using GitHub CLI:
      - Make sure that you have GitHub CLI installed
      - Create repository secrets using the following template:  
      
    gh secret set <secret-name> -b <secret-value> -R <owner>/<repo-name>

  - Set the required secrets:
      - `AZURE_CLIENT_ID`: The client ID from the JSON
      - `AZURE_TENANT_ID`: The tenant ID from the JSON
      - `AZURE_SUBSCRIPTION_ID`: The subscription ID from the JSON
  
## GitHub Action Workflow Template For Service Principal

Create a file named `.github/workflows/azure-inventory.yml` in your repository with the following content:

```yaml
name: Azure Resource Inventory

on:
  schedule:
    # Run weekly on Monday at 8:00 AM UTC
    - cron: '0 8 * * 1'
  # Allow manual trigger
  workflow_dispatch:
    inputs:
      subscriptionId:
        description: 'Specific subscription ID (optional)'
        required: false
        default: '00000000-0000-0000-0000-000000000000'
      resourceGroup:
        description: 'Specific resource group (optional)'
        required: false
        default: 'test-rg'
      reportName:
        description: 'Custom report name (optional)'
        required: false
        default: 'TestInventory'

jobs:
  run-inventory:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3

      - name: Login to Azure
        uses: azure/login@v2
        with:
          creds: '{"clientId":"${{ secrets.AZURE_CLIENT_ID }}","clientSecret":"${{ secrets.AZURE_CLIENT_SECRET }}","subscriptionId":"${{ secrets.AZURE_SUBSCRIPTION_ID }}","tenantId":"${{ secrets.AZURE_TENANT_ID }}"}'
          enable-AzPSSession: true

      - name: Install ARI and dependencies
        shell: pwsh
        run: |
          Install-Module -Name AzureResourceInventory -Force -Scope CurrentUser
          Install-Module -Name Az.Accounts -Force -Scope CurrentUser
          Install-Module -Name ImportExcel -Force -Scope CurrentUser
          Import-Module AzureResourceInventory

      - name: Run ARI
        shell: pwsh
        run: |
          $params = @{}

          # If subscription ID is provided
          if ("${{ github.event.inputs.subscriptionId }}" -ne "") {
            $params.Add("SubscriptionID", "${{ github.event.inputs.subscriptionId }}")
          }

          # If resource group is provided
          if ("${{ github.event.inputs.resourceGroup }}" -ne "") {
            $params.Add("ResourceGroup", "${{ github.event.inputs.resourceGroup }}")
          }

          # Set report name
          if ("${{ github.event.inputs.reportName }}" -ne "") {
            $params.Add("ReportName", "${{ github.event.inputs.reportName }}")
          } else {
            $params.Add("ReportName", "AzureInventory_$(Get-Date -Format 'yyyyMMdd')")
          }

          # Add any other parameters you want to use here
          # For example: $params.Add("SecurityCenter", $true)

          # Run ARI
          Invoke-ARI @params

          # Create artifacts directory
          New-Item -Path "$env:GITHUB_WORKSPACE/ari-reports" -ItemType Directory -Force

          # Move reports to artifacts directory
          Move-Item -Path "$HOME/AzureResourceInventory/*.xlsx" -Destination "$env:GITHUB_WORKSPACE/ari-reports/" -Force

          if (Test-Path "$HOME/AzureResourceInventory/*.xml") {
            Move-Item -Path ""$HOME/AzureResourceInventory/*.xml" -Destination "$env:GITHUB_WORKSPACE/ari-reports/" -Force
          }

      - name: Upload Reports as Artifacts
        uses: actions/upload-artifact@v4
        with:
          name: ARI-Reports
          path: ari-reports/
          retention-days: 90

      # Optional: Upload to Azure Storage
      # - name: Upload to Azure Storage
      #   shell: pwsh
      #   run: |
      #     $storageAccount = "yourstorageaccount"
      #     $container = "ari-reports"
      #
      #     # Create the storage context
      #     $ctx = New-AzStorageContext -StorageAccountName $storageAccount -UseConnectedAccount
      #
      #     # Upload files to Azure Storage
      #     Get-ChildItem -Path "$env:GITHUB_WORKSPACE/ari-reports" -File | ForEach-Object {
      #       Set-AzStorageBlobContent -File $_.FullName -Container $container -Blob $_.Name -Context $ctx -Force
      #     }

      # Optional: Send email notification
      # - name: Send Email Notification
      #   uses: dawidd6/action-send-mail@v3
      #   with:
      #     server_address: smtp.gmail.com
      #     server_port: 465
      #     username: ${{ secrets.EMAIL_USERNAME }}
      #     password: ${{ secrets.EMAIL_PASSWORD }}
      #     subject: Azure Resource Inventory Report
      #     body: Azure Resource Inventory has completed. Reports are attached.
      #     to: recipient@example.com
      #     from: Azure Inventory <sender@example.com>
```

## GitHub Action Workflow Template For User-Assigned Identity

Create a file named `.github/workflows/azure-inventory.yml` in your repository with the following content:

```yaml
name: Azure Resource Inventory

on:
  schedule:
    # Run weekly on Monday at 8:00 AM UTC
    - cron: '0 8 * * 1'
  # Allow manual trigger
  workflow_dispatch:
    inputs:
      subscriptionId:
        description: 'Specific subscription ID (optional)'
        required: false
        default: '00000000-0000-0000-0000-000000000000'
      resourceGroup:
        description: 'Specific resource group (optional)'
        required: false
        default: 'test-rg'
      reportName:
        description: 'Custom report name (optional)'
        required: false
        default: 'TestInventory'

jobs:
  run-inventory:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3

      - name: Login to Azure
        uses: azure/login@v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
          enable-AzPSSession: true

      - name: Install ARI and dependencies
        shell: pwsh
        run: |
          Install-Module -Name AzureResourceInventory -Force -Scope CurrentUser
          Install-Module -Name Az.Accounts -Force -Scope CurrentUser
          Install-Module -Name ImportExcel -Force -Scope CurrentUser
          Import-Module AzureResourceInventory

      - name: Run ARI
        shell: pwsh
        run: |
          $params = @{}

          # If subscription ID is provided
          if ("${{ github.event.inputs.subscriptionId }}" -ne "") {
            $params.Add("SubscriptionID", "${{ github.event.inputs.subscriptionId }}")
          }

          # If resource group is provided
          if ("${{ github.event.inputs.resourceGroup }}" -ne "") {
            $params.Add("ResourceGroup", "${{ github.event.inputs.resourceGroup }}")
          }

          # Set report name
          if ("${{ github.event.inputs.reportName }}" -ne "") {
            $params.Add("ReportName", "${{ github.event.inputs.reportName }}")
          } else {
            $params.Add("ReportName", "AzureInventory_$(Get-Date -Format 'yyyyMMdd')")
          }

          # Add any other parameters you want to use here
          # For example: $params.Add("SecurityCenter", $true)

          # Run ARI
          Invoke-ARI @params

          # Create artifacts directory
          New-Item -Path "$env:GITHUB_WORKSPACE/ari-reports" -ItemType Directory -Force

          # Move reports to artifacts directory
          Move-Item -Path "$HOME/AzureResourceInventory/*.xlsx" -Destination "$env:GITHUB_WORKSPACE/ari-reports/" -Force

          if (Test-Path "$HOME/AzureResourceInventory/*.xml") {
            Move-Item -Path ""$HOME/AzureResourceInventory/*.xml" -Destination "$env:GITHUB_WORKSPACE/ari-reports/" -Force
          }

      - name: Upload Reports as Artifacts
        uses: actions/upload-artifact@v4
        with:
          name: ARI-Reports
          path: ari-reports/
          retention-days: 90

      # Optional: Upload to Azure Storage
      # - name: Upload to Azure Storage
      #   shell: pwsh
      #   run: |
      #     $storageAccount = "yourstorageaccount"
      #     $container = "ari-reports"
      #
      #     # Create the storage context
      #     $ctx = New-AzStorageContext -StorageAccountName $storageAccount -UseConnectedAccount
      #
      #     # Upload files to Azure Storage
      #     Get-ChildItem -Path "$env:GITHUB_WORKSPACE/ari-reports" -File | ForEach-Object {
      #       Set-AzStorageBlobContent -File $_.FullName -Container $container -Blob $_.Name -Context $ctx -Force
      #     }

      # Optional: Send email notification
      # - name: Send Email Notification
      #   uses: dawidd6/action-send-mail@v3
      #   with:
      #     server_address: smtp.gmail.com
      #     server_port: 465
      #     username: ${{ secrets.EMAIL_USERNAME }}
      #     password: ${{ secrets.EMAIL_PASSWORD }}
      #     subject: Azure Resource Inventory Report
      #     body: Azure Resource Inventory has completed. Reports are attached.
      #     to: recipient@example.com
      #     from: Azure Inventory <sender@example.com>
```

## Customizing the Workflow

You can customize the workflow in several ways:

### Scheduling

The default schedule runs the workflow weekly on Monday at 8:00 AM UTC. Modify the `cron` expression to change the schedule:

```yaml
schedule:
  - cron: '0 8 * * 1'  # Monday at 8:00 AM UTC
```

### ARI Parameters

You can add any ARI parameters in the PowerShell script section. For example:

```powershell
# Add parameters
$params.Add("SecurityCenter", $true)
$params.Add("IncludeTags", $true)
$params.Add("DiagramFullEnvironment", $true)
```

### Storage Options

The template includes two storage options:

1. **GitHub Artifacts**: Enabled by default, stores reports for 90 days
2. **Azure Storage**: Commented out by default, can be enabled to store reports in Azure Blob Storage

## Examples

### Running for Specific Subscriptions

To inventory specific subscriptions, you can modify the workflow:

```yaml
- name: Run ARI for multiple subscriptions
  shell: pwsh
  run: |
    $subscriptionIds = @(
      "00000000-0000-0000-0000-000000000000",
      "11111111-1111-1111-1111-111111111111"
    )

    foreach ($subId in $subscriptionIds) {
      Invoke-ARI -SubscriptionID $subId -ReportName "AzureInventory_${subId}_$(Get-Date -Format 'yyyyMMdd')"
    }
```

### Adding Email Notifications

You can add email notifications using GitHub Actions by uncommenting the email notification section in the workflow:

```yaml
- name: Send Email Notification
  uses: dawidd6/action-send-mail@v3
  with:
    server_address: smtp.gmail.com
    server_port: 465
    username: ${{ secrets.EMAIL_USERNAME }}
    password: ${{ secrets.EMAIL_PASSWORD }}
    subject: Azure Resource Inventory Report
    body: Azure Resource Inventory has completed. Reports are attached.
    to: recipient@example.com
    from: Azure Inventory <sender@example.com>
```

Before using this feature, make sure to add the following secrets to your repository:

- `EMAIL_USERNAME`: Your email username/address
- `EMAIL_PASSWORD`: Your email password or app-specific password

## Troubleshooting

### Authentication Issues

If you encounter authentication errors:

1. Check that your service principal/user-assigned identity has the required permissions
2. Verify the secrets are correctly set in GitHub

### Missing Reports

If reports aren't generated:

1. Check the workflow logs for errors
2. Ensure the service principal/user-assigned identity has at least Reader access to the subscriptions
3. Try running with the `-Debug` parameter for detailed logging

## Comparison with Azure Automation

### GitHub Actions Advantages

- No need to create and maintain an Azure Automation Account
- Easier integration with infrastructure-as-code workflows
- Report history maintained as GitHub artifacts
- Simplified manual triggering with parameters

### Azure Automation Advantages

- Native Azure integration
- Potentially better for large environments
- Can use managed identities for authentication
- Better integration with Azure Monitor and Log Analytics

## Conclusion

GitHub Actions provides a flexible alternative to Azure Automation for running ARI on a schedule. This approach is particularly useful for teams already using GitHub for infrastructure management, allowing them to keep their inventory process alongside their infrastructure code.

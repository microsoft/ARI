# Running ARI with Azure DevOps Pipelines

This guide explains how to use Azure DevOps Pipelines to run Azure Resource Inventory automatically, providing another automation option besides Azure Automation Accounts and GitHub Actions.

## Overview

Azure DevOps Pipelines offer a robust way to automate the execution of Azure Resource Inventory on a schedule or in response to events. This can be useful if:

- You're already using Azure DevOps for your development and operations workflows
- You want to integrate Azure inventory reporting into your existing CI/CD processes
- You prefer Azure DevOps for centralized pipeline management
- You're working in an enterprise environment with Azure DevOps as the standard

## Prerequisites

To use this approach, you'll need:

1. An Azure DevOps organization and project
2. An Azure service connection with appropriate permissions
3. A repository to store your pipeline configuration

## Setting Up Azure Authentication

### Create a Service Connection

1. Navigate to your Azure DevOps project
2. Go to **Project Settings** → **Service connections**
3. Click **New service connection**
4. Select **Azure Resource Manager**
5. Choose **Service principal (automatic)** for authentication
6. Select your subscription and provide a name for the connection (e.g., "ARI-ServiceConnection")
7. Set an appropriate scope (subscription level is usually sufficient)
8. Click **Save**

This creates a service principal in your Azure AD tenant with Reader access to the subscription.

### Adjust Permissions (if needed)

If you need to inventory multiple subscriptions or management groups:

1. Navigate to the Azure Portal
2. Go to the relevant subscription or management group
3. Select **Access control (IAM)**
4. Add the service principal with the **Reader** role at the appropriate scope

## Azure DevOps Pipeline YAML

Create a new file in your repository named `azure-pipelines/ari-inventory.yml` with the following content:

```yaml
trigger: none # Don't trigger on code changes

schedules:
- cron: "0 8 * * 1" # Run weekly on Monday at 8:00 AM UTC
  displayName: Weekly Run
  branches:
    include:
    - main
  always: true # Run even when there are no code changes

parameters:
- name: subscriptionId
  displayName: 'Specific subscription ID (optional)'
  type: string
  default: ''
- name: resourceGroup
  displayName: 'Specific resource group (optional)'
  type: string
  default: ''
- name: reportName
  displayName: 'Custom report name (optional)'
  type: string
  default: 'AzureInventory'

pool:
  vmImage: 'windows-latest'

variables:
  azureServiceConnection: 'ARI-ServiceConnection' # Replace with your service connection name

steps:
- task: AzureCLI@2
  displayName: 'Install and Run Azure Resource Inventory'
  inputs:
    azureSubscription: $(azureServiceConnection)
    scriptType: 'ps'
    scriptLocation: 'inlineScript'
    inlineScript: |
      # Install required modules
      Install-Module -Name AzureResourceInventory -Force -Scope CurrentUser
      Install-Module -Name Az.Accounts -Force -Scope CurrentUser
      Install-Module -Name ImportExcel -Force -Scope CurrentUser
      
      # Import ARI module
      Import-Module AzureResourceInventory
      
      # Prepare parameters
      $params = @{}
      
      # If subscription ID is provided
      if ("${{ parameters.subscriptionId }}" -ne "") {
        $params.Add("SubscriptionID", "${{ parameters.subscriptionId }}")
      }
      
      # If resource group is provided
      if ("${{ parameters.resourceGroup }}" -ne "") {
        $params.Add("ResourceGroup", "${{ parameters.resourceGroup }}")
      }
      
      # Set report name
      if ("${{ parameters.reportName }}" -ne "") {
        $params.Add("ReportName", "${{ parameters.reportName }}")
      } else {
        $params.Add("ReportName", "AzureInventory_$(Get-Date -Format 'yyyyMMdd')")
      }
      
      # Add any other parameters you want to use here
      # For example: 
      # $params.Add("SecurityCenter", $true)
      # $params.Add("IncludeTags", $true)
      # $params.Add("DiagramFullEnvironment", $true)
      
      # Run ARI
      Invoke-ARI @params
      
      # Create artifacts directory
      New-Item -Path "$(Build.ArtifactStagingDirectory)/ari-reports" -ItemType Directory -Force
      
      # Move reports to artifacts directory
      Move-Item -Path "*.xlsx" -Destination "$(Build.ArtifactStagingDirectory)/ari-reports/" -Force
      
      if (Test-Path "*.drawio") {
        Move-Item -Path "*.drawio" -Destination "$(Build.ArtifactStagingDirectory)/ari-reports/" -Force
      }

- task: PublishBuildArtifacts@1
  displayName: 'Publish Inventory Reports'
  inputs:
    PathtoPublish: '$(Build.ArtifactStagingDirectory)/ari-reports'
    ArtifactName: 'ARI-Reports'
    publishLocation: 'Container'

# Optional: Upload to Azure Storage
# - task: AzureCLI@2
#   displayName: 'Upload Reports to Azure Storage'
#   inputs:
#     azureSubscription: $(azureServiceConnection)
#     scriptType: 'ps'
#     scriptLocation: 'inlineScript'
#     inlineScript: |
#       $storageAccount = "yourstorageaccount"
#       $container = "ari-reports"
#       
#       # Create storage context
#       $ctx = New-AzStorageContext -StorageAccountName $storageAccount
#       
#       # Upload files to Azure Storage
#       Get-ChildItem -Path "$(Build.ArtifactStagingDirectory)/ari-reports" -File | ForEach-Object {
#         Set-AzStorageBlobContent -File $_.FullName -Container $container -Blob $_.Name -Context $ctx -Force
#       }
```

## Setting Up the Pipeline

1. Navigate to your Azure DevOps project
2. Go to **Pipelines** → **Pipelines**
3. Click **New pipeline**
4. Select your repository source
5. Choose **Existing Azure Pipelines YAML file**
6. Select the `azure-pipelines/ari-inventory.yml` file
7. Click **Continue**
8. Review the pipeline and click **Save** (or **Save and run** if you want to run it immediately)

## Customizing the Pipeline

You can customize the pipeline in several ways:

### Scheduling

The default schedule runs the pipeline weekly on Monday at 8:00 AM UTC. Modify the `cron` expression to change the schedule:

```yaml
schedules:
- cron: "0 8 * * 1" # Run weekly on Monday at 8:00 AM UTC
```

### ARI Parameters

You can add any ARI parameters in the PowerShell script section. For example:

```powershell
# Add parameters
$params.Add("SecurityCenter", $true)
$params.Add("IncludeTags", $true)
$params.Add("DiagramFullEnvironment", $true)
```

### Running Manually

You can run the pipeline manually with specific parameters:

1. Navigate to the pipeline in Azure DevOps
2. Click **Run pipeline**
3. Enter values for any parameters
4. Click **Run**

## Advanced Configurations

### Multiple Subscriptions

To inventory multiple subscriptions:

```powershell
$subscriptionIds = @(
  "00000000-0000-0000-0000-000000000000",
  "11111111-1111-1111-1111-111111111111"
)

foreach ($subId in $subscriptionIds) {
  Invoke-ARI -SubscriptionID $subId -ReportName "AzureInventory_${subId}_$(Get-Date -Format 'yyyyMMdd')"
}
```

### Email Notifications

You can set up email notifications for pipeline completions:

1. Navigate to your Azure DevOps project
2. Go to **Project Settings** → **Notifications**
3. Add a new subscription for "A run stage completes"
4. Configure the notification to your requirements

For more advanced notifications, consider using Azure Logic Apps to send detailed emails with attachments.

### Azure DevOps Release Pipeline

Instead of using the YAML pipeline, you can create a classic release pipeline:

1. Create a new release pipeline
2. Add an Azure PowerShell task
3. Configure the task to run the ARI commands
4. Add a schedule trigger
5. Configure artifact storage as needed

## Storing Reports

### Azure DevOps Artifacts

The pipeline automatically stores reports as pipeline artifacts. These are accessible from the pipeline run results and are retained based on your Azure DevOps retention settings.

### Azure Storage

The template includes a commented-out section for uploading reports to Azure Blob Storage. Uncomment and configure this section to store reports in your own storage account.

### SharePoint/OneDrive

For enterprise environments, you might want to store reports in SharePoint or OneDrive. You can add a PowerShell task to upload files using the PnP PowerShell module.

## Troubleshooting

### Authentication Issues

If you encounter authentication errors:

1. Verify the service connection is valid
2. Check that the service principal has the necessary permissions
3. Confirm the scope settings are correct

### Missing Reports

If reports aren't generated:

1. Check the pipeline logs for errors
2. Ensure all modules are installed correctly
3. Verify that PowerShell execution policy isn't blocking the script

## Comparison with Other Automation Options

### Azure DevOps vs. GitHub Actions

- Azure DevOps offers deeper integration with Azure services
- DevOps has more enterprise features for governance and compliance
- GitHub Actions may be simpler for open-source projects

### Azure DevOps vs. Azure Automation

- Azure DevOps provides better pipeline visualization and history
- Azure Automation offers native integration with Azure Monitor
- DevOps provides more flexible scheduling options

## Conclusion

Azure DevOps Pipelines provide a powerful way to automate Azure Resource Inventory, especially for organizations already using Azure DevOps for their DevOps workflows. This approach integrates well with existing CI/CD processes and offers robust scheduling, reporting, and storage options. 
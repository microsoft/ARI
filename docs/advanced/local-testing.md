# Testing Automation Workflows Locally

This guide demonstrates how to test the GitHub Actions and Azure DevOps Pipeline workflows locally before deploying them to your environment.

## Testing GitHub Actions Locally

GitHub Actions workflows can be tested locally using the [act](https://github.com/nektos/act) tool, which runs your GitHub Actions workflows locally using Docker.

### Installing act

You can install `act` on different platforms:

**macOS (with Homebrew):**
```bash
brew install act
```

**Linux and Windows (with Go):**
```bash
go install github.com/nektos/act@latest
```

### Preparing a Test Workflow

When testing ARI workflows locally, you might want to create a simplified version that doesn't require Azure credentials or actual API calls:

```yaml
name: Test Azure Resource Inventory

on:
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

      - name: Simulate Azure Login
        run: |
          echo "Azure login simulated for local testing"

      - name: Simulate ARI Installation and Run
        shell: bash
        run: |
          echo "Installing ARI modules (simulation for testing)"
          echo "Running Invoke-ARI with parameters:"
          echo "- ReportName: ${{ github.event.inputs.reportName }}"
          echo "- SubscriptionID: ${{ github.event.inputs.subscriptionId }}"
          echo "- ResourceGroup: ${{ github.event.inputs.resourceGroup }}"
          
          # Create dummy report files
          mkdir -p ari-reports
          echo "This is a test Excel report" > ari-reports/test_report.xlsx
          echo "This is a test diagram file" > ari-reports/test_diagram.drawio
          
          # List the created files
          echo "Created files:"
          ls -la ari-reports/
          
          echo "Workflow execution completed successfully"
```

Save this file as `.github/workflows/test-ari.yml`.

### Running the Test Workflow

Run the workflow using `act`:

```bash
act -j run-inventory workflow_dispatch
```

If you're using an Apple M1/M2 Mac, you might need to specify the platform architecture:

```bash
act -j run-inventory workflow_dispatch --container-architecture linux/amd64
```

You should see output showing each step of the workflow being executed locally.

### Common Issues with act

1. **Platform unsupported**: If you see a "skipping unsupported platform" warning, you can specify a platform:
   ```bash
   act -P ubuntu-latest=catthehacker/ubuntu:act-latest
   ```

2. **Missing secrets**: For workflows that need secrets, you can provide them via a file:
   ```bash
   act --secret-file my.secrets
   ```

3. **Artifact uploads**: The artifact upload step might fail in `act`. You can remove or modify this step for local testing.

## Testing Azure DevOps Pipelines Locally

There's no direct equivalent to `act` for Azure DevOps Pipelines, but you can create simulation scripts to test the core functionality.

### PowerShell Simulation Script

Create a PowerShell script to simulate the pipeline execution:

```powershell
param(
    [string]$SubscriptionId = "00000000-0000-0000-0000-000000000000",
    [string]$ResourceGroup = "test-rg",
    [string]$ReportName = "TestInventory"
)

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "Simulating Azure DevOps Pipeline for Azure Resource Inventory" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan

Write-Host "Input Parameters:" -ForegroundColor Yellow
Write-Host "- SubscriptionID: $SubscriptionId" -ForegroundColor Yellow
Write-Host "- ResourceGroup: $ResourceGroup" -ForegroundColor Yellow
Write-Host "- ReportName: $ReportName" -ForegroundColor Yellow
Write-Host "========================================================" -ForegroundColor Cyan

# Step 1: Simulate Azure login
Write-Host "Step 1: Simulating Azure CLI login..." -ForegroundColor Green
Write-Host "Az.Accounts connection simulation completed"
Write-Host "========================================================" -ForegroundColor Cyan

# Step 2: Simulate PowerShell module installation
Write-Host "Step 2: Simulating PowerShell module installation..." -ForegroundColor Green
Write-Host "Install-Module -Name AzureResourceInventory -Force -Scope CurrentUser"
Write-Host "Install-Module -Name Az.Accounts -Force -Scope CurrentUser"
Write-Host "Install-Module -Name ImportExcel -Force -Scope CurrentUser"
Write-Host "Module installation simulation completed"
Write-Host "========================================================" -ForegroundColor Cyan

# Step 3: Simulate ARI execution
Write-Host "Step 3: Simulating ARI execution..." -ForegroundColor Green

# Prepare parameters in PowerShell style
$params = @{}

if ($SubscriptionId -ne "") {
    $params.Add("SubscriptionID", $SubscriptionId)
}

if ($ResourceGroup -ne "") {
    $params.Add("ResourceGroup", $ResourceGroup)
}

if ($ReportName -ne "") {
    $params.Add("ReportName", $ReportName)
}

Write-Host "PowerShell parameter hashtable:"
$params | ForEach-Object {
    $params.GetEnumerator() | ForEach-Object {
        Write-Host "   $($_.Key): $($_.Value)"
    }
}

Write-Host "Invoke-ARI with parameters would be executed here"
Write-Host "ARI execution simulation completed"
Write-Host "========================================================" -ForegroundColor Cyan

# Step 4: Create simulated artifact files
Write-Host "Step 4: Creating simulated artifact files..." -ForegroundColor Green
$artifactDir = "ari-reports"
if (-not (Test-Path $artifactDir)) {
    New-Item -Path $artifactDir -ItemType Directory -Force | Out-Null
}

$excelContent = "This is a simulated Excel report for $ReportName"
$diagramContent = "This is a simulated diagram file for $ReportName"

$excelPath = Join-Path $artifactDir "$ReportName.xlsx"
$diagramPath = Join-Path $artifactDir "$ReportName.drawio"

$excelContent | Out-File -FilePath $excelPath -Force
$diagramContent | Out-File -FilePath $diagramPath -Force

Write-Host "Created artifact files:"
Get-ChildItem -Path $artifactDir | Format-Table Name, Length, LastWriteTime
Write-Host "========================================================" -ForegroundColor Cyan

Write-Host "Azure DevOps Pipeline simulation completed successfully!" -ForegroundColor Green
```

Save this as `azure-pipelines-local-test/simulate-pipeline.ps1`.

### Running the PowerShell Simulation

Run the simulation script:

```bash
pwsh -File azure-pipelines-local-test/simulate-pipeline.ps1 -SubscriptionId "your-subscription-id" -ResourceGroup "your-resource-group" -ReportName "YourReportName"
```

### Bash Simulation Script

For environments without PowerShell, create a Bash simulation script:

```bash
#!/bin/bash

# Script to simulate Azure DevOps pipeline execution locally
echo "========================================================"
echo "Simulating Azure DevOps Pipeline for Azure Resource Inventory"
echo "========================================================"

# Parameters
SUBSCRIPTION_ID=${1:-"00000000-0000-0000-0000-000000000000"}
RESOURCE_GROUP=${2:-"test-rg"}
REPORT_NAME=${3:-"TestInventory"}

echo "Input Parameters:"
echo "- SubscriptionID: $SUBSCRIPTION_ID"
echo "- ResourceGroup: $RESOURCE_GROUP"
echo "- ReportName: $REPORT_NAME"
echo "========================================================"

# Step 1: Simulate Azure login
echo "Step 1: Simulating Azure CLI login..."
echo "az login simulation completed"
echo "========================================================"

# Step 2: Simulate PowerShell module installation
echo "Step 2: Simulating PowerShell module installation..."
echo "Install-Module -Name AzureResourceInventory -Force -Scope CurrentUser"
echo "Install-Module -Name Az.Accounts -Force -Scope CurrentUser"
echo "Install-Module -Name ImportExcel -Force -Scope CurrentUser"
echo "Module installation simulation completed"
echo "========================================================"

# Step 3: Simulate ARI execution
echo "Step 3: Simulating ARI execution..."
echo "Invoke-ARI -SubscriptionID \"$SUBSCRIPTION_ID\" -ResourceGroup \"$RESOURCE_GROUP\" -ReportName \"$REPORT_NAME\""
echo "ARI execution simulation completed"
echo "========================================================"

# Step 4: Create simulated artifact files
echo "Step 4: Creating simulated artifact files..."
mkdir -p ari-reports
echo "This is a test Excel report for $REPORT_NAME" > "ari-reports/${REPORT_NAME}.xlsx"
echo "This is a test diagram file for $REPORT_NAME" > "ari-reports/${REPORT_NAME}.drawio"

echo "Created artifact files:"
ls -la ari-reports/
echo "========================================================"

echo "Azure DevOps Pipeline simulation completed successfully!"
```

Save this as `azure-pipelines-local-test/simulate-pipeline.sh`.

### Running the Bash Simulation

Make the script executable and run it:

```bash
chmod +x azure-pipelines-local-test/simulate-pipeline.sh
./azure-pipelines-local-test/simulate-pipeline.sh "your-subscription-id" "your-resource-group" "YourReportName"
```

## Beyond Local Testing

While local testing is useful for basic validation, some aspects of workflows can only be tested in their actual environments:

1. **Azure Authentication**: Real authentication can only be tested with actual credentials
2. **Service Connections**: Azure DevOps service connections require the actual Azure DevOps environment
3. **Artifact Storage**: Storage of artifacts works differently in the real environments

For complete validation, consider using:

1. **Feature Branches**: Test your workflows on feature branches before merging to main
2. **Test Organizations**: Create test Azure DevOps organizations/projects for pipeline testing
3. **Test Repositories**: Use separate repositories for testing GitHub Actions

## Conclusion

While both GitHub Actions and Azure DevOps Pipelines offer powerful automation capabilities, GitHub Actions provides better local testing options through tools like `act`. For Azure DevOps Pipelines, simulation scripts offer a way to test core functionality, but complete testing requires the actual Azure DevOps environment. 
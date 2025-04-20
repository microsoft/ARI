#
# PowerShell script to simulate Azure DevOps Pipeline execution locally
#

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
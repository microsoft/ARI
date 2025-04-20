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
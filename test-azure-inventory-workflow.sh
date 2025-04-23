#!/bin/bash

echo "========================================================"
echo "Testing Azure Inventory GitHub Action Workflow Locally"
echo "========================================================"

# Input parameters
SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
RESOURCE_GROUP="test-rg"
REPORT_NAME="TestInventory"

echo "Input Parameters:"
echo "- SubscriptionID: $SUBSCRIPTION_ID"
echo "- ResourceGroup: $RESOURCE_GROUP"
echo "- ReportName: $REPORT_NAME"
echo "========================================================"

# Step 1: Clean up any previous test artifacts
echo "Step 1: Cleaning up previous test artifacts..."
if [ -d "ari-reports" ]; then
    echo "Removing existing ari-reports directory..."
    rm -rf ari-reports
fi
echo "Cleanup completed"
echo "========================================================"

# Step 2: Simulate Azure login
echo "Step 2: Simulating Azure login..."
echo "Azure login simulated for local testing"
echo "========================================================"

# Step 3: Simulate ARI Installation and Run
echo "Step 3: Simulating ARI Installation and Run..."
echo "Installing ARI modules (simulation for testing)"
echo "Running Invoke-ARI with parameters:"
echo "- ReportName: $REPORT_NAME"
echo "- SubscriptionID: $SUBSCRIPTION_ID"
echo "- ResourceGroup: $RESOURCE_GROUP"
echo "========================================================"

# Step 4: Create dummy report files
echo "Step 4: Creating dummy report files..."
mkdir -p ari-reports
echo "This is a test Excel report for $REPORT_NAME" > "ari-reports/${REPORT_NAME}.xlsx"
echo "This is a test diagram file for $REPORT_NAME" > "ari-reports/${REPORT_NAME}.drawio"

echo "Created files:"
ls -la ari-reports/
echo "========================================================"

echo "Azure Inventory workflow test completed successfully!"
echo "In a real GitHub Actions run, these files would be uploaded as artifacts"
echo "========================================================"

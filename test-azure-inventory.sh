#!/bin/bash

echo "Testing Azure Inventory workflow locally using act..."

# Check if act is installed
if ! command -v act &> /dev/null; then
    echo "Error: 'act' is not installed."
    echo "Please install act to test GitHub Actions locally:"
    echo "  macOS: brew install act"
    echo "  Other: https://github.com/nektos/act#installation"
    exit 1
fi

# Run act to test the workflow locally
echo "Running the run-inventory job with workflow_dispatch event"
act -j run-inventory -W .github/workflows/azure-inventory.yml -e workflow_dispatch.json --container-architecture linux/amd64

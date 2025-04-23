#!/bin/bash

echo "Testing GitHub Actions workflow locally using act..."

# Check if act is installed
if ! command -v act &> /dev/null; then
    echo "Error: 'act' is not installed."
    echo "Please install act to test GitHub Actions locally:"
    echo "  macOS: brew install act"
    echo "  Other: https://github.com/nektos/act#installation"
    exit 1
fi

# Run act to test the workflow locally
# Note: This will only build the docs, not deploy them
echo "Running the build-and-deploy job (deployment requires GitHub Pages setup)"
act -j build-and-deploy -W .github/workflows/documentation.yml --container-architecture linux/amd64
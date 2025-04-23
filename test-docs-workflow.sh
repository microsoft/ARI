#!/bin/bash

echo "========================================================"
echo "Testing Documentation GitHub Action Workflow Locally"
echo "========================================================"

# Step 1: Clean up any previous build
echo "Step 1: Cleaning up previous build..."
if [ -d "site" ]; then
    echo "Removing existing site directory..."
    rm -rf site
fi
echo "Cleanup completed"
echo "========================================================"

# Step 2: Install dependencies
echo "Step 2: Installing dependencies..."
if pip list | grep -q "mkdocs"; then
    echo "MkDocs already installed"
else
    echo "Installing MkDocs and dependencies..."
    pip install -r requirements.txt
fi
echo "Dependencies installation completed"
echo "========================================================"

# Step 3: Build the site
echo "Step 3: Building MkDocs site..."
mkdocs build
if [ $? -eq 0 ]; then
    echo "MkDocs site built successfully"
else
    echo "Error building MkDocs site"
    exit 1
fi
echo "========================================================"

# Step 4: Verify the site structure
echo "Step 4: Verifying site structure..."
if [ -d "site" ]; then
    echo "Site directory exists"
    echo "Files in site directory:"
    ls -la site
else
    echo "Error: Site directory not found"
    exit 1
fi
echo "========================================================"

# Step 5: Test serving the site locally
echo "Step 5: Testing local server (will run for 5 seconds)..."
mkdocs serve &
SERVER_PID=$!
sleep 5
kill $SERVER_PID
echo "Local server test completed"
echo "========================================================"

echo "Documentation workflow test completed successfully!"
echo "To view the site locally, run: mkdocs serve"
echo "To deploy to GitHub Pages, push changes to the main branch"
echo "========================================================"

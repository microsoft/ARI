#!/bin/bash

# Install dependencies if not already installed
if ! command -v mkdocs &> /dev/null; then
    echo "Installing MkDocs and dependencies..."
    pip install -r requirements.txt
else
    echo "MkDocs already installed."
fi

# Serve the documentation locally
echo "Starting MkDocs server. Access the documentation at http://127.0.0.1:8000"
mkdocs serve 
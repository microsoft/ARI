# Azure Resource Inventory Documentation

This directory contains the source files for the Azure Resource Inventory (ARI) documentation site.

## Overview

The documentation is built using [MkDocs](https://www.mkdocs.org/) with the [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/) theme. The documentation is automatically built and deployed to GitHub Pages using GitHub Actions when changes are pushed to the main branch.

## Directory Structure

- `docs/` - Contains all documentation source files
  - `index.md` - Home page of the documentation
  - `getting-started/` - Installation and quick start guides
  - `user-guide/` - Usage guides and reference
  - `features/` - Documentation for specific features
  - `advanced/` - Advanced topics and configuration
  - `development/` - Development guides and contributing
  - `about/` - License, authors, and related information

## Testing Documentation Locally

To test the documentation locally:

1. Create a virtual environment:
   ```bash
   python -m venv docs-venv
   source docs-venv/bin/activate  # On Windows: docs-venv\Scripts\activate
   ```

2. Install the dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Run MkDocs:
   ```bash
   mkdocs serve
   ```

4. Open your browser and go to `http://127.0.0.1:8000`

Alternatively, run the included script:
```bash
./test-docs.sh
```

## GitHub Actions Workflow

The documentation is automatically built and deployed to GitHub Pages using the GitHub Actions workflow defined in `.github/workflows/documentation.yml`.

To test the workflow locally:

1. Install [act](https://github.com/nektos/act)
2. Run the included script:
   ```bash
   ./test-workflow.sh
   ```

## Contributing to Documentation

When adding new content:

1. Create Markdown files in the appropriate directories
2. Update the navigation in the `mkdocs.yml` file
3. Test locally to ensure everything works correctly
4. Submit a pull request

## Formatting Guidelines

- Use Markdown formatting for all documentation
- Follow a consistent structure with headers (# for main title, ## for sections, etc.)
- Use code blocks with syntax highlighting for code examples (```powershell)
- Use relative links to reference other documentation pages
- Add images to the `images/` directory and reference them with relative paths

## Useful Commands

- `mkdocs build` - Build the documentation site
- `mkdocs serve` - Start the live-reloading docs server
- `mkdocs gh-deploy` - Deploy the documentation to GitHub Pages (manual deployment) 
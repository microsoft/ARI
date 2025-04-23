# Documentation Update

## Description

This PR adds a comprehensive documentation system using MkDocs with the Material theme.

## Changes Made

- Added MkDocs with Material theme configuration
- Created documentation structure with the following sections:
  - Getting Started (Installation and Quick Start)
  - User Guide (Basic Usage, Parameters, Common Scenarios)
  - Features (Excel Reports and more)
  - Advanced (Automation and Resource Types)
- Added GitHub Actions workflow for automatic documentation deployment
- Added local testing scripts (`test-docs.sh` and `test-workflow.sh`)

## Testing

- Documentation has been tested locally with `mkdocs serve`
- GitHub workflow has been tested locally with `act`

## Deployment Instructions

1. Review the documentation content for accuracy and completeness
2. Make any required adjustments to the content or structure
3. Once merged, the GitHub workflow will deploy the documentation to GitHub Pages
4. Enable GitHub Pages in repository settings:
   - Go to Settings > Pages
   - Select "GitHub Actions" as the source
   - The documentation will be available at `https://[organization].github.io/ARI/`

## Screenshots

(If applicable, add screenshots of the documentation site)

## Checklist

- [ ] Documentation content is accurate and up-to-date
- [ ] All links work correctly
- [ ] Documentation navigation is intuitive
- [ ] GitHub workflow is correctly configured
- [ ] MkDocs configuration is correctly set up
- [ ] Documentation renders correctly in local testing 
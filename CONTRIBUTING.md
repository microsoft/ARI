# Contributing to Azure Resource Inventory

<div align="center">
  <img src="images/ARI_Logo.png" width="250">
  <h3>Guidelines for Community Contributions</h3>
  
  [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/microsoft/ARI/pulls)
  [![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](CODE_OF_CONDUCT.md)
</div>

## Table of Contents

- [Getting Started](#getting-started)
- [Contribution Workflow](#contribution-workflow)
- [Development Guidelines](#development-guidelines)
- [Project Structure](#project-structure)
  - [Core Modules](#core-modules)
  - [Inventory Modules](#inventory-modules)
  - [Diagram Modules](#diagram-modules)
  - [Extras Modules](#extras-modules)
  - [Script File Modules](#script-file-modules)
- [Getting Help](#getting-help)

## Getting Started

Thank you for considering contributing to Azure Resource Inventory (ARI)! We welcome contributions from the community and are excited to see what you can bring to the project.

Before you begin, please familiarize yourself with the [README.md](README.md) file to understand the purpose and functionality of ARI.

## Contribution Workflow

Follow these steps to contribute to ARI:

<table>
<tr>
<td width="60%">

1. **Fork the Repository**
   
   Start by forking the repository to your GitHub account using the "Fork" button at the top right of the repository page.

2. **Clone Your Fork**
   
   ```bash
   git clone https://github.com/your-username/ARI.git
   cd ARI
   ```

3. **Create a Branch**
   
   Create a new branch for your contribution:
   
   ```bash
   git checkout -b feature/your-feature-name
   ```
   
   Use a descriptive name that reflects your contribution.

4. **Make Your Changes**
   
   Implement your changes, ensuring they follow the [Development Guidelines](#development-guidelines).

5. **Test Your Changes**
   
   Test your changes thoroughly to ensure they work as expected and don't break existing functionality.

6. **Commit Changes**
   
   ```bash
   git add .
   git commit -m "Add feature: your feature description"
   ```
   
   Write clear, concise commit messages that describe your changes.

7. **Push to Your Fork**
   
   ```bash
   git push origin feature/your-feature-name
   ```

8. **Submit a Pull Request**
   
   Go to the original ARI repository and click "New Pull Request". Select your fork and branch, then provide a detailed description of your changes.

9. **Address Review Feedback**
   
   Be responsive to any feedback provided by maintainers and make necessary changes.

## Development Guidelines

To maintain code quality and consistency:

- **Follow PowerShell Best Practices**: Follow [Microsoft's PowerShell Best Practices](https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/cmdlet-development-guidelines)
- **Document Your Code**: Add comments to explain complex logic and update documentation if needed
- **Keep It Modular**: Make sure your code follows the modular approach of ARI
- **Error Handling**: Include appropriate error handling and logging
- **Backward Compatibility**: Ensure your changes don't break existing functionality
- **Test Thoroughly**: Test in various environments (Windows, Linux, Cloud Shell)

## Project Structure

ARI follows a modular structure. Understanding the purpose of each module will help you determine where your contribution fits.

### Core Modules

| Module | Description |
|--------|-------------|
| **ARIInventoryLoop.psm1** | Handles looping through Azure Resource Graph to extract resources |
| **ARILoginSession.psm1** | Manages authentication using Azure PowerShell |
| **ARITestPS.psm1** | Tests and validates the PowerShell environment |
| **ARIGetSubs.psm1** | Extracts subscriptions from a specified tenant |
| **ARIExtraJobs.psm1** | Manages additional jobs like diagram creation and security processing |

### Inventory Modules

| Module | Description |
|--------|-------------|
| **ARIResourceDataPull.psm1** | Main module for resource extraction using Azure Resource Graph |
| **ARIResourceReport.psm1** | Main module for building the Excel report |
| **ARISubInv.psm1** | Processes subscription data and creates the subscriptions sheet |
| **ARISecCenterInv.psm1** | Processes and creates the Security Center sheet |
| **ARIQuotaInv.psm1** | Processes and creates the quota sheet |
| **ARIPolicyInv.psm1** | Processes and creates the policy sheet |
| **ARIAPIInv.psm1** | Manages API inventory for various Azure services |
| **ARIAdvisoryInv.psm1** | Processes and creates the advisory sheet |

### Diagram Modules

| Module | Description |
|--------|-------------|
| **ARIDrawIODiagram.psm1** | Creates Draw.io diagrams based on resources |
| **ARIDiagramSubscription.psm1** | Manages subscription-related diagrams |
| **ARIDiagramOrganization.psm1** | Manages organization topology in diagrams |
| **ARIDiagramNetwork.psm1** | Manages network topology in diagrams |

### Extras Modules

| Module | Description |
|--------|-------------|
| **ARIReportCharts.psm1** | Creates the main dashboard and overview sheet |
| **ARIExcelDetails.psm1** | Adds header comments and additional details to reports |

### Script File Modules

| Category | Description |
|----------|-------------|
| **Analytics** | Scripts for processing AI and Analytics resources |
| **APIs** | Scripts for processing data captured through REST API |
| **Compute** | Scripts for processing compute resources (VMs, VMSS, etc.) |
| **Containers** | Scripts for processing container resources (AKS, Azure Containers) |
| **Data** | Scripts for processing SQL resources (MySQL, SQL, etc.) |
| **Infrastructure** | Scripts for processing core infrastructure resources |
| **Integration** | Scripts for processing service integration resources |
| **Networking** | Scripts for processing core Azure Networking |
| **Storage** | Scripts for processing Azure Storage Services |

The main module **AzureResourceInventory.psm1** orchestrates the entire process of resource extraction, reporting, and diagram creation.

## Getting Help

If you have questions or need help with your contribution:

- **Open an Issue**: Create a new issue in the [GitHub repository](https://github.com/microsoft/ARI/issues)
- **Documentation**: Refer to the [README.md](README.md) and other documentation
- **Community Discussions**: Check existing discussions in the Issues tab

---

Thank you for contributing to Azure Resource Inventory! Your efforts help make cloud administration easier for the entire Azure community.

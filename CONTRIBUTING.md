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
   - [Public Modules](#Public-Modules)
      - [PublicFunctions](#PublicFunctions)
      - [Diagram](#Diagram)
      - [Jobs](#Jobs)
   - [Private Modules](#Private-Modules)
      - [0.MainFunctions](#0.MainFunctions)
      - [1.ExtractionFunctions](#1.ExtractionFunctions)
         - [ResourceDetails](#1.ExtractionFunctions/ResourceDetails)
      - [2.ProcessingFunctions](#2.ProcessingFunctions)
      - [3.ReportingFunctions](#3.ReportingFunctions)
         - [StyleFunctions](#3.ReportingFunctions/StyleFunctions)
   - [Resource Types](#Resource-Types)
      - [Resource Type Modules](#Resource-Type-Modules)
      - [Resource Type Subfolders](#Resource-Type-Subfolders)
- [Getting Help](#getting-help)

## Getting Started

Thank you for considering contributing to Azure Resource Inventory (ARI)! We welcome contributions from the community and are excited to see what you can bring to the project.

Before you begin, please familiarize yourself with the [README.md](README.md) file to understand the purpose and functionality of ARI.

If you wish to contribute by adding a new Resource Type to ARI, you may jump to the [Resource Types](#Resource-Types) section of this document.

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

The main module **AzureResourceInventory.psm1** is only responsible for dot sourcing all the .ps1 modules.

### Public Modules

This modules will be loaded and the functions will be exposed to the user session


#### PublicFunctions

| Script File         | Description                                                                 |
|---------------------|-----------------------------------------------------------------------------|
| `Invoke-ARI.ps1`    | Entry point script to invoke Azure Resource Inventory operations.          |


#### Diagram

| Script File                        | Description                                                                 |
|------------------------------------|-----------------------------------------------------------------------------|
| `Build-ARIDiagramSubnet.ps1`       | Builds diagrams for Azure subnets.                                         |
| `Set-ARIDiagramFile.ps1`           | Configures the file settings for diagram generation.                       |
| `Start-ARIDiagramJob.ps1`          | Initiates the job for creating diagrams.                                   |
| `Start-ARIDiagramNetwork.ps1`      | Starts the process for generating network diagrams.                        |
| `Start-ARIDiagramOrganization.ps1` | Generates diagrams for organizational structures.                          |
| `Start-ARIDiagramSubscription.ps1` | Creates diagrams for Azure subscriptions.                                  |
| `Start-ARIDrawIODiagram.ps1`       | Generates diagrams compatible with Draw.io.                                |


#### Jobs

| Script File                     | Description                                                                 |
|---------------------------------|-----------------------------------------------------------------------------|
| `Start-ARIAdvisoryJob.ps1`      | Initiates the advisory-related job for ARI operations.                      |
| `Start-ARIPolicyJob.ps1`        | Starts the job for processing Azure Policy-related tasks.                   |
| `Start-ARISecCenterJob.ps1`     | Initiates the job for handling Azure Security Center insights.              |
| `Start-ARISubscriptionJob.ps1`  | Starts the job for processing subscription-specific tasks.                  |
| `Wait-ARIJob.ps1`               | Waits for the completion of ARI jobs and monitors their status.             |


### Private Modules

This modules will be loaded and the functions will be available for the script and other functions to consume, but will not be exposed to the user session

#### 0.MainFunctions

| Script File                          | Description                                                                 |
|--------------------------------------|-----------------------------------------------------------------------------|
| `Clear-ARICacheFolder.ps1`           | Clears the ARI cache folder to ensure a clean state for operations.         |
| `Clear-ARIMemory.ps1`                | Frees up memory used by ARI during operations.                              |
| `Connect-ARILoginSession.ps1`        | Establishes a login session with Azure for ARI operations.                  |
| `Get-ARIUnsupportedData.ps1`         | Retrieves data that is not currently supported by ARI.                      |
| `Set-ARIFolder.ps1`                  | Configures the folder structure for ARI operations.                         |
| `Set-ARIReportPath.ps1`              | Sets the path for storing ARI-generated reports.                            |
| `Start-ARIExtractionOrchestration.ps1` | Initiates the orchestration process for resource extraction.                |
| `Start-ARIProcessOrchestration.ps1`  | Starts the orchestration of ARI's processing tasks.                         |
| `Start-ARIReporOrchestration.ps1`    | Begins the orchestration for generating ARI reports.                        |
| `Test-ARIPS.ps1`                     | Tests the PowerShell environment and prerequisites for ARI operations.      |


#### 1.ExtractionFunctions

| Script File                          | Description                                                                 |
|--------------------------------------|-----------------------------------------------------------------------------|
| `Get-ARIAPIResources.ps1`            | Extracts resources using Azure APIs.                                        |
| `Get-ARIManagementGroups.ps1`        | Retrieves Azure Management Group data.                                      |
| `Get-ARISubscriptions.ps1`           | Retrieves subscription details from Azure.                                  |
| `Invoke-ARIInventoryLoop.ps1`        | Executes the inventory loop for resource extraction.                        |
| `Start-ARIGraphExtraction.ps1`       | Initiates the extraction of Azure Resource Graph data.                      |


#### 1.ExtractionFunctions/ResourceDetails

| Script File                          | Description                                                                 |
|--------------------------------------|-----------------------------------------------------------------------------|
| `Get-ARIVMQuotas.ps1`                | Retrieves quota details for Azure Virtual Machines.                         |
| `Get-ARIVMSkuDetails.ps1`            | Retrieves SKU details for Azure Virtual Machines.                           |


#### 2.ProcessingFunctions

| Script File                          | Description                                                                 |
|--------------------------------------|-----------------------------------------------------------------------------|
| `Build-ARICacheFiles.ps1`            | Builds cache files for ARI operations.                                      |
| `Invoke-ARIAdvisoryJob.ps1`          | Executes advisory-related processing jobs.                                  |
| `Invoke-ARIDrawIOJob.ps1`            | Executes jobs for generating Draw.io diagrams.                              |
| `Invoke-ARIPolicyJob.ps1`            | Executes policy-related processing jobs.                                    |
| `Invoke-ARISecurityCenterJob.ps1`    | Executes jobs related to Azure Security Center insights.                    |
| `Invoke-ARISubJob.ps1`               | Executes subscription-specific processing jobs.                             |
| `Start-ARIAutProcessJob.ps1`         | Initiates automated processing jobs for ARI.                                |
| `Start-ARIExtraJobs.ps1`             | Starts additional processing jobs for extended functionality.               |
| `Start-ARIProcessJob.ps1`            | Initiates the main processing jobs for ARI operations.                      |


#### 3.ReportingFunctions

| Script File                          | Description                                                                 |
|--------------------------------------|-----------------------------------------------------------------------------|
| `Build-ARIAdvisoryReport.ps1`        | Generates advisory reports based on processed data.                         |
| `Build-ARIPolicyReport.ps1`          | Generates policy compliance reports.                                        |
| `Build-ARIQuotaReport.ps1`           | Generates quota usage reports.                                              |
| `Build-ARISecCenterReport.ps1`       | Generates reports for Azure Security Center insights.                       |
| `Build-ARISubsReport.ps1`            | Generates subscription-specific reports.                                    |
| `Start-ARIExcelJob.ps1`              | Initiates Excel-related reporting jobs.                                     |
| `Start-ARIExtraReports.ps1`          | Starts additional reporting jobs for extended functionality.                |

#### 3.ReportingFunctions/StyleFunctions

| Script File                          | Description                                                                 |
|--------------------------------------|-----------------------------------------------------------------------------|
| `Build-ARIExcelChart.ps1`            | Creates Excel charts for visualizing report data.                           |
| `Build-ARIExcelComObject.ps1`        | Manages Excel COM objects for report generation.                            |
| `Build-ARIExcelinitialBlock.ps1`     | Sets up the initial block for Excel report customization.                   |
| `Out-ARIReportResults.ps1`           | Outputs the final report results to Excel or other formats.                 |
| `Retirement.kql`                     | Contains KQL queries for data retirement analysis.                          |
| `Start-ARIExcelCustomization.ps1`    | Customizes Excel reports with specific formatting and styles.               |
| `Start-ARIExcelOrdening.ps1`         | Orders and organizes data in Excel reports.                                 |
| `Support.json`                       | Provides configuration or metadata support for reporting functions.         |





Each module is designed to handle specific tasks, ensuring a clean and modular approach to ARI's functionality.



### Resource Types

#### Resource Type Modules

The supported resource types by Azure Resource Inventory are defined by the "Resource Type Modules", we made sure to create this structure to be as simple as possible. 

So anyone could contribute by creating new modules for new resource types.

There is a Resource Type Module file for every single resource type supported by ARI, the structure of resource type module itself is explained in the "Module-template.tpl", located in Modules/Public/InventoryModules.

Once you create the module file, it must be placed in the correct folder structure under Modules/Public/InventoryModules. The subfolder structure follows the official Azure documentation for Resource Providers: [azure-services-resource-providers](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/azure-services-resource-providers)


#### Resource Type Subfolders

| Category       | Description                                                                 |
|----------------|-----------------------------------------------------------------------------|
| **AI**         | Scripts for processing AI services like Azure AI, Computer Vision, and more. |
| **Analytics**  | Scripts for processing analytics services like Databricks, Data Explorer, and Purview. |
| **APIs**       | Scripts for processing data captured through REST APIs.                    |
| **Compute**    | Scripts for processing compute resources such as VMs and VM Scale Sets.    |
| **Container**  | Scripts for processing container resources like AKS and Azure Container Instances. |
| **Database**   | Scripts for processing database services like SQL, MySQL, and Cosmos DB.   |
| **Hybrid**     | Scripts for processing hybrid cloud resources like Azure Arc.              |
| **Integration**| Scripts for processing service integration resources like Logic Apps and Service Bus. |
| **IoT**        | Scripts for processing IoT resources like IoT Hub and Azure Digital Twins. |
| **Management** | Scripts for processing management and governance resources like Azure Policy. |
| **Monitoring** | Scripts for processing monitoring services like Azure Monitor and Log Analytics. |
| **Network_1**  | Scripts for processing core networking resources like VNets and NSGs.      |
| **Network_2**  | Scripts for processing advanced networking resources like Azure Firewall and WAF. |
| **Security**   | Scripts for processing security services like Azure Security Center and Sentinel. |
| **Storage**    | Scripts for processing Azure Storage services like Blob, File, and Queue.  |
| **Web**        | Scripts for processing web services like App Services and Azure Functions. |




## Getting Help

If you have questions or need help with your contribution:

- **Open an Issue**: Create a new issue in the [GitHub repository](https://github.com/microsoft/ARI/issues)
- **Documentation**: Refer to the [README.md](README.md) and other documentation
- **Community Discussions**: Check existing discussions in the Issues tab

---

Thank you for contributing to Azure Resource Inventory! Your efforts help make cloud administration easier for the entire Azure community.

---

---

# Contributing to Azure Resource Inventory (ARI)

Thank you for considering contributing to Azure Resource Inventory (ARI)! We welcome contributions from the community and are excited to see what you can bring to the project.

## How to Contribute

1. **Fork the Repository**: Start by forking the repository to your GitHub account.

2. **Clone the Repository**: Clone your forked repository to your local machine.
    ```sh
    git clone https://github.com/your-username/ARI.git
    cd ARI
    ```

3. **Create a Branch**: Create a new branch for your feature or bug fix.
    ```sh
    git checkout -b feature/your-feature-name
    ```

4. **Make Changes**: Make your changes to the codebase. Ensure that your code follows the project's coding standards and includes appropriate documentation.

5. **Commit Changes**: Commit your changes with a clear and concise commit message.
    ```sh
    git add .
    git commit -m "Add feature: your feature description"
    ```

6. **Push Changes**: Push your changes to your forked repository.
    ```sh
    git push origin feature/your-feature-name
    ```

7. **Create a Pull Request**: Open a pull request from your branch to the main repository. Provide a detailed description of your changes and any relevant information.

8. **Review Process**: Your pull request will be reviewed by the maintainers. Be prepared to make any necessary changes based on feedback.

## Code of Conduct

Please note that this project is released with a Contributor Code of Conduct. By participating in this project, you agree to abide by its terms.

## File Descriptions

Here is a brief description of each file/module in the project:

### Core Modules

- **ARIInventoryLoop.psm1**: Handles looping through the Azure Resource Graph to extract resources.
- **ARILoginSession.psm1**: Manages the authentication process using Azure CLI.
- **ARITestPS.psm1**: Tests and validates the PowerShell environment.
- **ARIGetSubs.psm1**: Extracts subscriptions from a specified tenant.
- **ARIExtraJobs.psm1**: Manages additional jobs such as diagram creation and security center processing.

### Inventory Modules

- **ARIResourceDataPull.psm1**: Main module for resource extraction using Azure Resource Graph.
- **ARIResourceReport.psm1**: Main module for building the Excel report.
- **ARISubInv.psm1**: Processes and creates the subscriptions sheet based on resources and subscriptions.
- **ARISecCenterInv.psm1**: Processes and creates the Security Center sheet based on security resources.
- **ARIQuotaInv.psm1**: Processes and creates the quota sheet based on quotas used.
- **ARIPolicyInv.psm1**: Processes and creates the policy sheet based on advisor resources.
- **ARIAPIInv.psm1**: Manages API inventory for various Azure services.
- **ARIAdvisoryInv.psm1**: Processes and creates the advisory sheet based on advisor resources.

### Diagram Modules

- **ARIDrawIODiagram.psm1**: Creates a Draw.io diagram based on resources.
- **ARIDiagramSubscription.psm1**: Manages subscription-related diagrams.
- **ARIDiagramOrganization.psm1**: Manages organization topology in the Draw.io diagram.
- **ARIDiagramNetwork.psm1**: Manages network topology in the Draw.io diagram.

### Extras Modules

- **ARIReportCharts.psm1**: Creates the main dashboard and overview sheet in the Excel report.
- **ARIExcelDetails.psm1**: Adds header comments and additional details to the Excel report.

### Script File Modules

- **Analytics**: The main script files, responsible for processing Azure data and creating the Excel Tables for AI and Analytics resources.
- **APIs**: The main script files, responsible for processing Azure data and creating the Excel Tables for data captured trough REST API.
- **Compute**: The main script files, responsible for processing Azure data and creating the Excel Tables for main compute (VMs, VMSS..) resources.
- **Containers**: The main script files, responsible for processing Azure data and creating the Excel Tables for container resources (AKS, Azure Containers...).
- **Data**: The main script files, responsible for processing Azure data and creating the Excel Tables for SQL resources (MySQL, SQL...).
- **Infrastructure**: The main script files, responsible for processing Azure data and creating the Excel Tables for core infrastructure resources.
- **Integration**: The main script files, responsible for processing Azure data and creating the Excel Tables for service integration resources.
- **Networking**: The main script files, responsible for processing Azure data and creating the Excel Tables for core Azure Networking.
- **Storage**: The main script files, responsible for processing Azure data and creating the Excel Tables for Azure Storage Services (ANF, Storage Accounts...).

### Main Module

- **AzureResourceInventory.psm1**: The main module that orchestrates the entire process of resource extraction, reporting, and diagram creation.

## Getting Help

If you have any questions or need help, feel free to open an issue on GitHub or reach out to the maintainers.

Thank you for contributing to Azure Resource Inventory (ARI)! We appreciate your support and look forward to your contributions.

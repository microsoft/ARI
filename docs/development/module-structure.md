# Module Structure

This page provides an overview of the Azure Resource Inventory (ARI) module structure, explaining how the different components work together.

## Overview

The ARI module is organized into a hierarchical structure with the main module file (`AzureResourceInventory.psm1`) loading a collection of specialized modules and functions.

```
AzureResourceInventory
├── AzureResourceInventory.psd1      # Module manifest
├── AzureResourceInventory.psm1      # Main module file
├── Modules/                         # Module components
│   ├── Private/                     # Internal helper functions
│   │   └── ...
│   └── Public/                      # Exported functions
│       ├── PublicFunctions/         # Main functionality
│       │   ├── Diagram/             # Network diagram generation
│       │   │   └── ...
│       │   ├── Jobs/                # Background job handling
│       │   │   └── ...
│       │   ├── Invoke-ARI.ps1       # Main command implementation
│       │   └── ...
│       └── InventoryModules/        # Resource-specific modules
│           ├── AI/                  # AI resource modules
│           ├── Analytics/           # Analytics resource modules
│           ├── Compute/             # Compute resource modules
│           └── ...
└── docs/                            # Documentation
```

## Main Components

### Module Entry Points

- **AzureResourceInventory.psd1**: The module manifest that defines metadata, dependencies, and exported functions.
- **AzureResourceInventory.psm1**: The root module file that loads all submodules and defines the module's behavior.

### Functional Organization

The module is organized into two main categories:

1. **Public Functions**: Exported functions that users can directly call.
2. **Private Functions**: Internal helper functions used by the public functions.

## Public Function Types

### Core Functions

- **Invoke-ARI**: The main function that orchestrates the inventory process.
- **Invoke-AzureRAMPInventory**: Alias function for backward compatibility.

### Job Management Functions

Functions that handle background job processing for parallel execution:

- **Start-ARIAdvisoryJob**: Manages collecting Azure Advisor recommendations.
- **Start-ARIPolicyJob**: Handles Azure Policy data collection.
- **Start-ARISecCenterJob**: Collects Security Center information.
- **Start-ARISubscriptionJob**: Manages subscription data collection.
- **Wait-ARIJob**: Waits for job completion and handles results.

### Diagram Functions

Functions dedicated to creating network diagrams:

- **Build-ARIDiagramSubnet**: Creates subnet-level diagrams.
- **Set-ARIDiagramFile**: Prepares diagram file structure.
- **Start-ARIDiagramJob**: Manages diagram generation jobs.
- **Start-ARIDiagramNetwork**: Generates network topology diagrams.
- **Start-ARIDiagramOrganization**: Creates organizational hierarchy diagrams.
- **Start-ARIDiagramSubscription**: Generates subscription-level diagrams.
- **Start-ARIDrawIODiagram**: Converts data to Draw.io format.

## Inventory Modules

The `InventoryModules` directory contains specialized modules for each Azure resource type, organized by service category:

- **AI**: Cognitive Services, Machine Learning, etc.
- **Analytics**: Databricks, Event Hubs, Synapse, etc.
- **Compute**: Virtual Machines, VMSS, AVD, etc.
- **Container**: AKS, Container Instances, Container Registry, etc.
- **Database**: SQL, CosmosDB, MySQL, PostgreSQL, etc.
- **Integration**: API Management, Service Bus, etc.
- **Network**: VNets, NSGs, Load Balancers, etc.
- **Security**: Key Vault, etc.
- **Storage**: Storage Accounts, etc.
- **Web**: App Service, etc.

Each resource type module follows a standard pattern:

```powershell
function global:Get-ARIResourceName {
    # Input parameters and validation
    # Resource collection logic
    # Data transformation
    # Return inventory data
}
```

## Execution Flow

When `Invoke-ARI` is called, the following process occurs:

1. **Authentication and Validation**: Verify credentials and parameters.
2. **Subscription Enumeration**: Identify target subscriptions.
3. **Resource Collection**: Start jobs to collect resources by type.
4. **Data Aggregation**: Combine results from all collection jobs.
5. **Report Generation**: Create Excel report with collected data.
6. **Diagram Creation**: Generate network diagrams if not skipped.

## Adding New Resource Types

To add support for a new Azure resource type:

1. Identify the appropriate category in `Modules/Public/InventoryModules/`.
2. Create a new `.ps1` file following existing patterns.
3. Implement the collection logic for the resource type.
4. Add any necessary Excel formatting rules.
5. Update the resource types documentation.

## Customizing Output

The module uses the `ImportExcel` module to generate Excel reports. The formatting and structure are defined in the individual resource modules, with common formatting functions in the private modules.

## Testing and Debugging

The module includes a `-Debug` parameter that enables detailed logging. This is particularly useful when developing new features or troubleshooting issues.

## Performance Considerations

For large environments, consider:

- Using the `-Lite` parameter to generate simpler reports.
- Using the `-SkipDiagram` parameter to skip network diagram generation.
- Using the `-SkipAdvisory`, `-SkipPolicy`, or other skip parameters to reduce data collection. 
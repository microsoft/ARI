# Azure Resource Inventory User Guide

<div align="center">
  <img src="images/ARI_Logo.png" width="250">
  <h3>How to install, configure, and use ARI</h3>
</div>

## Table of Contents

- [Installation](#installation)
- [Basic Usage](#basic-usage)
- [Command Reference](#command-reference)
  - [Common Parameters](#common-parameters)
  - [Common Scenarios](#common-scenarios)
- [Multi-Tenant Support](#multi-tenant-support)
- [Working with Network Diagrams](#working-with-network-diagrams)

## Installation

ARI is available as a PowerShell module that can be installed directly from the PowerShell Gallery:

```powershell
Install-Module -Name AzureResourceInventory
```

<p align="center">
  <img src="images/InstallARI.gif" width="700" style="border: 1px solid #ccc;">
</p>

## Basic Usage

Once installed, you can run ARI with a simple command:

```powershell
Invoke-ARI
```

This will authenticate you to Azure and begin collecting inventory data from all accessible subscriptions.

<p align="center">
  <img src="images/RunningARI.gif" width="700" style="border: 1px solid #ccc;">
</p>

## Command Reference

### Common Parameters

| Parameter | Description | Usage | Category |
|-----------|-------------|-------|----------|
| **Core Parameters** |  |  |  |
| TenantID | Specify the tenant ID for inventory | `-TenantID <ID>` | Scope |
| SubscriptionID | Specify subscription(s) to inventory | `-SubscriptionID <ID>` | Scope |
| ResourceGroup | Specify resource group(s) to inventory | `-ResourceGroup <NAME>` | Scope |
| ManagementGroup | Inventory all subscriptions in a management group | `-ManagementGroup <ID>` | Scope |
| **Data Collection** |  |  |  |
| IncludeTags | Include resource tags | `-IncludeTags` | Content |
| SecurityCenter | Include Security Center data | `-SecurityCenter` | Content |
| SkipAdvisory | Skip Azure Advisory collection | `-SkipAdvisory` | Content |
| QuotaUsage | Include quota usage information | `-QuotaUsage` | Content |
| **Authentication** |  |  |  |
| DeviceLogin | Use device login authentication | `-DeviceLogin` | Auth |
| AzureEnvironment | Specify Azure cloud environment | `-AzureEnvironment <NAME>` | Auth |
| **Report Options** |  |  |  |
| ReportName | Custom report filename | `-ReportName <NAME>` | Output |
| ReportDir | Custom directory for report | `-ReportDir "<Path>"` | Output |
| Lite | Lightweight Excel (no charts) | `-Lite` | Output |
| Online | Use online modules from GitHub | `-Online` | Config |
| **Diagram Options** |  |  |  |
| Diagram | Create Draw.IO diagram | `-Diagram` | Diagram |
| SkipDiagram | Skip diagram creation | `-SkipDiagram` | Diagram |
| DiagramFullEnvironment | Include all network components | `-DiagramFullEnvironment` | Diagram |
| **Automation** |  |  |  |
| Automation | Run using an Automation Account | `-Automation` | Automation |
| StorageAccount | Storage account for automation | `-StorageAccount` | Automation |
| StorageContainer | Container for automation output | `-StorageContainer` | Automation |
| **Other** |  |  |  |
| Debug | Run in debug mode | `-Debug` | Debug |
| TagKey | Filter resources by tag key | `-TagKey <NAME>` | Filter |
| TagValue | Filter resources by tag value | `-TagValue <NAME>` | Filter |

### Common Scenarios

#### Running in Azure Cloud Shell

The simplest way to run ARI is directly in Azure Cloud Shell, where authentication is already handled:

```powershell
Invoke-ARI -Debug
```

#### Inventory a Specific Tenant and Subscription

To target a specific tenant and subscription:

```powershell
Invoke-ARI -TenantID <Azure-Tenant-ID> -SubscriptionID <Subscription-ID>
```

> If you do not specify a subscription, ARI will inventory all subscriptions in the selected tenant.

#### Include Resource Tags

By default, ARI does not include resource tags. To include them:

```powershell
Invoke-ARI -TenantID <Azure-Tenant-ID> -IncludeTags
```

#### Include Security Center Data

To include Security Center assessments:

```powershell
Invoke-ARI -TenantID <Azure-Tenant-ID> -SecurityCenter
```

#### Skip Azure Advisor Data

To skip collection of Azure Advisor recommendations (which can speed up the process):

```powershell
Invoke-ARI -TenantID <Azure-Tenant-ID> -SkipAdvisory
```

#### Skip Network Diagram Generation

To skip the creation of network diagrams (faster execution):

```powershell
Invoke-ARI -TenantID <Azure-Tenant-ID> -SkipDiagram
```

## Multi-Tenant Support

If you have access to multiple Azure tenants, ARI will detect this and provide a menu of available tenants:

<p align="center">
  <img src="images/multitenant.png" width="600" style="border: 1px solid #ddd;">
</p>

You can either select from this menu or specify the tenant directly using the `-TenantID` parameter:

<p align="center">
  <img src="images/tenantID.png" width="600" style="border: 1px solid #ddd;">
</p>

## Working with Network Diagrams

ARI can generate detailed network topology diagrams in Draw.io format (.xml).

### Diagram Location

By default, the diagram files are saved to:

- Windows: `C:\AzureResourceInventory\`
- Linux/CloudShell: `$HOME/AzureResourceInventory/`

<p align="center">
  <img src="images/ARIFiles.png" width="600" style="border: 1px solid #ddd;">
</p>

### Opening Diagrams

To view the generated diagram:

1. Open [draw.io](https://app.diagrams.net/) in your browser
2. Select "Open Existing Diagram"
3. Navigate to your ARI output folder and select the XML file

<p align="center">
  <img src="images/drawioopen.png" width="600" style="border: 1px solid #ddd;">
</p>

### Diagram Features

The diagrams provide interactive features:

- Hover over resources to see details
- Click on components to select them
- Zoom in/out to explore complex environments
- Export to various formats including PNG, PDF, and SVG

---

For more detailed information, visit the [project repository](https://github.com/microsoft/ARI).

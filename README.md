---
ArtifactType: Excel spreadsheet with the full Azure environment
Language: PowerShell
Platform: Windows / Linux / Mac
Tags: PowerShell, Azure, Inventory, Excel Report, Customer Engineer
---

<div align="center">

# Azure Resource Inventory (ARI)

<img src="images/ARI_Logo.png" width="300">

### A powerful PowerShell module for generating comprehensive Azure environment reports

[![GitHub](https://img.shields.io/github/license/microsoft/ARI)](https://github.com/microsoft/ARI/blob/main/LICENSE)
[![GitHub repo size](https://img.shields.io/github/repo-size/microsoft/ARI)](https://github.com/microsoft/ARI)
[![GitHub last commit](https://img.shields.io/github/last-commit/microsoft/ARI)](https://github.com/microsoft/ARI/commits/main)
[![GitHub top language](https://img.shields.io/github/languages/top/microsoft/ARI)](https://github.com/microsoft/ARI)
[![Azure](https://badgen.net/badge/icon/azure?icon=azure&label)](https://azure.microsoft.com)

</div>

## 📋 Table of Contents

- [Overview](#-overview)
- [Key Features](#-key-features)
- [Getting Started](#-getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Quick Start](#quick-start)
- [Usage Guide](#-usage-guide)
  - [Basic Commands](#basic-commands)
  - [Common Scenarios](#common-scenarios)
- [Parameters Reference](#-parameters-reference)
- [Output Examples](#-output-examples)
  - [Excel Report](#excel-report)
  - [Network Topology View](#network-topology-view)
  - [Organization View](#organization-view)
  - [Resources View](#resources-view)
- [Important Notes](#-important-notes)
- [Authors & Acknowledgments](#-authors--acknowledgments)
- [Contributing](#-contributing)
- [License](#-license)

## 🔍 Overview

Azure Resource Inventory (ARI) is a comprehensive PowerShell module that generates detailed Excel reports of any Azure environment you have read access to. It is designed for Cloud Administrators and technical professionals who need an easy and fast way to document their Azure environments.

<p align="center">
  <img src="images/ARIv35-Overview.png" width="700">
</p>

## ✨ Key Features

- **Complete Resource Documentation**: Detailed inventory of all Azure resources
- **Interactive Excel Reports**: Well-formatted spreadsheets with resources organized by type
- **Visual Network Diagrams**: Generate interactive topology maps of your Azure environment
- **Security Analysis**: Integration with Azure Security Center (optional)
- **Cross-Platform Support**: Works on Windows, Linux, Mac, and Azure Cloud Shell
- **Automation-Ready**: Can be deployed via Azure Automation Accounts
- **Low-Impact**: Read-only operations with no changes to your environment


## 🚀 Getting Started

### Prerequisites

- PowerShell 7.0+ (recommended) or PowerShell 5.1
- Azure Account with read access to resources you want to inventory
- Administrator privileges during script execution (for module installation)

### Installation

Install the module directly from PowerShell Gallery:

```powershell
Install-Module -Name AzureResourceInventory
```

<p align="center">
  <img src="images/InstallARI.gif" width="700">
</p>


### Quick Start

To generate a basic inventory report:

```powershell
Import-Module AzureResourceInventory
```

<p align="center">
  <img src="images/ImportingARI.gif" width="700">
</p>


```powershell
Invoke-ARI
```

<p align="center">
  <img src="images/RunningARI.gif" width="700">
</p>

## 📖 Usage Guide

### Basic Commands

Run ARI with specific tenant:

```powershell
Invoke-ARI -TenantID <Azure-Tenant-ID>
```

Scope to specific subscription:

```powershell
Invoke-ARI -TenantID <Azure-Tenant-ID> -SubscriptionID <Subscription-ID>
```

Include resource tags in the report:

```powershell
Invoke-ARI -TenantID <Azure-Tenant-ID> -IncludeTags
```

### Common Scenarios

**Run in Azure Cloud Shell:**

```powershell
Invoke-ARI -Debug
```

**Include Security Center Data:**

```powershell
Invoke-ARI -TenantID <Azure-Tenant-ID> -SubscriptionID <Subscription-ID> -SecurityCenter
```

**Skip Azure Advisor Data Collection:**

```powershell
Invoke-ARI -TenantID <Azure-Tenant-ID> -SubscriptionID <Subscription-ID> -SkipAdvisory
```

**Skip Network Diagram Generation:**

```powershell
Invoke-ARI -TenantID <Azure-Tenant-ID> -SkipDiagram
```

### Automation Account Integration

If you want to automatically run ARI, there is a way to do it using Automation Accounts:

<p align="center">
  <img src="images/Automation.png" width="600">
</p>

See the [Automation Guide](https://github.com/microsoft/ARI/blob/main/docs/advanced/automation.md) for implementation details.

## 📝 Parameters Reference

| Parameter | Description | Usage |
|-----------|-------------|-------|
| **Core Parameters** | | |
| TenantID | Specify the tenant ID for inventory | `-TenantID <ID>` |
| SubscriptionID | Specify subscription(s) to inventory | `-SubscriptionID <ID>` |
| ResourceGroup | Limit inventory to specific resource group(s) | `-ResourceGroup <NAME>` |
| **Authentication** | | |
| AppId | Application ID for service principal auth | `-AppId <ID>` |
| Secret | Secret for service principal authentication | `-Secret <VALUE>` |
| CertificatePath | Certificate path for service principal | `-CertificatePath <PATH>` |
| DeviceLogin | Use device login authentication | `-DeviceLogin` |
| **Scope Control** | | |
| ManagementGroup | Inventory all subscriptions in management group | `-ManagementGroup <ID>` |
| TagKey | Filter resources by tag key | `-TagKey <NAME>` |
| TagValue | Filter resources by tag value | `-TagValue <NAME>` |
| **Content Options** | | |
| SecurityCenter | Include Security Center data | `-SecurityCenter` |
| IncludeTags | Include resource tags | `-IncludeTags` |
| SkipPolicy | Skip Azure Policy collection | `-SkipPolicy` |
| SkipVMDetails | Skip Azure VM Extra Details collection | `-SkipVMDetails` |
| SkipAdvisory | Skip Azure Advisory collection | `-SkipAdvisory` |
| IncludeCosts | Includes Azure Cost details for the Subscriptions (Requires the module Az.CostManagement) | `-IncludeCosts` |
| SkipVMDetails | Skip extra details for the VM Families (Quota, vCPUs and memory) | `-SkipVMDetails` |
| **Output Options** | | |
| ReportName | Custom report filename | `-ReportName <NAME>` |
| ReportDir | Custom directory for report | `-ReportDir "<Path>"` |
| Lite | Use lightweight Excel generation (no charts) | `-Lite` |
| **Diagram Options** | | |
| SkipDiagram | Skip diagram creation | `-SkipDiagram` |
| DiagramFullEnvironment | Include all network components in diagram | `-DiagramFullEnvironment` |
| **Other Options** | | |
| Debug | Run in debug mode | `-Debug` |
| NoAutoUpdate | Skip the auto update of the ARI Module | `-NoAutoUpdate` |
| AzureEnvironment | Specify Azure cloud environment | `-AzureEnvironment <NAME>` |
| Automation | Run using Automation Account | `-Automation` |
| StorageAccount | Storage account for automation output | `-StorageAccount <NAME>` |
| StorageContainer | Storage container for automation output | `-StorageContainer <NAME>` |

## 📊 Output Examples

### Excel Report

<p align="center">
  <img src="images/ARIv3ExcelExample.png" width="800">
</p>

### Network Topology View

<p align="center">
  <img src="images/DrawioImage.png" width="700">
</p>

Interactive features show resource details on hover:

<p align="center">
  <img src="images/ARIv3DrawioHover.png" width="400">
  <img src="images/ARIv3DrawioPeer.png" width="400">
</p>

### Organization View

<p align="center">
  <img src="images/DrawioOrganization.png" width="700">
</p>

### Resources View

<p align="center">
  <img src="images/drawiosubs.png" width="700">
</p>

## ⚠️ Important Notes

> **Very Important:** ARI will not upgrade existing PowerShell modules. Ensure you have the required modules installed.

> **CloudShell Limitation:** When running in Azure CloudShell, the Excel output will not have auto-fit columns and you may see warnings during execution. The inventory results will still be correct.

<p align="center">
  <img src="images/cloudshell-warning-lib.png" width="600">
</p>

### Our Test Environment

| Tool | Version |
|------|---------|
| Windows | 11 22H2 |
| PowerShell | 7.4.4 |

### Output Details

- Default output location:
  - Windows: `C:\AzureResourceInventory\`
  - Linux/CloudShell: `$HOME/AzureResourceInventory/`
- Output filename format: `AzureResourceInventory_Report_yyyy-MM-dd_HH_mm.xlsx`
- Diagram filename format: `AzureResourceInventory_Diagram_yyyy-MM-dd_HH_mm.xml` (Draw.io format)

## 👥 Authors & Acknowledgments

- **Claudio Merola** (<claudio.merola@microsoft.com>)
- **Renato Gregio**

Special thanks to **Doug Finke**, the author of PowerShell [ImportExcel](https://github.com/dfinke/ImportExcel) module.

## 🤝 Contributing

Please read our [CONTRIBUTING.md](CONTRIBUTING.md) which outlines all policies, procedures, and requirements for contributing to this project.

## 📜 License

Copyright (c) 2025 Microsoft Corporation. All rights reserved.

Licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft trademarks or logos is subject to and must follow [Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks). Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship. Any use of third-party trademarks or logos are subject to those third-party's policies.

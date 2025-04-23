# Installation Guide

Azure Resource Inventory (ARI) is a PowerShell module that can be installed directly from the PowerShell Gallery. This guide will walk you through the necessary steps to get ARI up and running on your system.

## Prerequisites

Before installing ARI, ensure you have the following prerequisites:

- **PowerShell Version**:
  - PowerShell 7.0 or newer (recommended)
  - PowerShell 5.1 (minimum requirement)

- **Azure Account**:
  - An Azure account with read access to the resources you want to inventory

- **Required PowerShell Modules**:
  - ImportExcel
  - Az.Accounts
  - Az.ResourceGraph
  - Az.Storage
  - Az.Compute

## Installation Methods

### Method 1: Install from PowerShell Gallery (Recommended)

The easiest way to install ARI is directly from the PowerShell Gallery:

```powershell
Install-Module -Name AzureResourceInventory
```

<div align="center">
<img src="../../images/InstallARI.gif" width="700">
</div>

If you encounter any permission issues during installation, try running PowerShell as an administrator or add the `-Scope CurrentUser` parameter:

```powershell
Install-Module -Name AzureResourceInventory -Scope CurrentUser
```

### Method 2: Manual Installation

If you prefer to install the module manually:

1. Download the latest release from the [GitHub Releases page](https://github.com/microsoft/ARI/releases)
2. Extract the ZIP file to your PowerShell modules directory (typically `$HOME\Documents\PowerShell\Modules\`)
3. Ensure the module folder is named "AzureResourceInventory"

## Verification

To verify that ARI is installed correctly, run:

```powershell
Get-Module -ListAvailable AzureResourceInventory
```

You should see the AzureResourceInventory module listed with its version number.

## Importing the Module

After installation, you need to import the module before using it:

```powershell
Import-Module AzureResourceInventory
```

<div align="center">
<img src="../../images/ImportingARI.gif" width="700">
</div>

## Updating ARI

To update to the latest version of ARI from the PowerShell Gallery:

```powershell
Update-Module -Name AzureResourceInventory
```

## Troubleshooting Installation Issues

If you encounter issues during installation:

1. **Module Dependencies**: Ensure all required modules are installed:
   ```powershell
   Install-Module -Name ImportExcel, Az.Accounts, Az.ResourceGraph, Az.Storage, Az.Compute
   ```

2. **Permission Issues**: Try running PowerShell as Administrator or using `-Scope CurrentUser`

3. **Internet Connection**: Ensure you have an active internet connection to access the PowerShell Gallery

4. **PowerShellGet Version**: Update PowerShellGet if needed:
   ```powershell
   Install-Module -Name PowerShellGet -Force
   ```

## Next Steps

Now that you've installed ARI, proceed to the [Quick Start Guide](quick-start.md) to generate your first Azure inventory report. 
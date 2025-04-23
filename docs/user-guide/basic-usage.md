# Basic Usage

This guide covers the fundamental usage patterns for Azure Resource Inventory (ARI). For a quick start, see the [Quick Start Guide](../getting-started/quick-start.md).

## Command Structure

The basic syntax for ARI is:

```powershell
Invoke-ARI [parameters]
```

## Authentication

ARI supports multiple authentication methods:

### Interactive Login

```powershell
# ARI will prompt for interactive login if not already authenticated
Invoke-ARI
```

### Specific Tenant

```powershell
Invoke-ARI -TenantID "00000000-0000-0000-0000-000000000000"
```

### Service Principal

```powershell
Invoke-ARI -TenantID "00000000-0000-0000-0000-000000000000" -AppId "00000000-0000-0000-0000-000000000000" -Secret "your-client-secret"
```

### Certificate-Based Authentication

```powershell
Invoke-ARI -TenantID "00000000-0000-0000-0000-000000000000" -AppId "00000000-0000-0000-0000-000000000000" -CertificatePath "C:\Certificates\cert.pfx"
```

### Device Code Authentication

```powershell
Invoke-ARI -TenantID "00000000-0000-0000-0000-000000000000" -DeviceLogin
```

## Scoping Your Inventory

ARI can be scoped to different levels:

### All Accessible Resources

```powershell
Invoke-ARI
```

### Specific Subscription

```powershell
Invoke-ARI -SubscriptionID "00000000-0000-0000-0000-000000000000"
```

### Specific Resource Group

```powershell
Invoke-ARI -SubscriptionID "00000000-0000-0000-0000-000000000000" -ResourceGroup "MyResourceGroup"
```

### Management Group

```powershell
Invoke-ARI -ManagementGroup "MyManagementGroup"
```

### Tag-Based Filtering

```powershell
# Resources with specific tag key
Invoke-ARI -TagKey "Environment"

# Resources with specific tag value
Invoke-ARI -TagValue "Production"

# Resources with specific tag key and value
Invoke-ARI -TagKey "Environment" -TagValue "Production"
```

## Report Content Control

Control what information is included in your reports:

### Include Resource Tags

```powershell
Invoke-ARI -IncludeTags
```

### Include Security Center Data

```powershell
Invoke-ARI -SecurityCenter
```

### Skip Azure Policy Data

```powershell
Invoke-ARI -SkipPolicy
```

### Skip Azure VM Details

```powershell
Invoke-ARI -SkipVMDetails
```

### Skip Azure Advisory Collection

```powershell
Invoke-ARI -SkipAdvisory
```

### Include Cost Data

```powershell
# Note: Requires Az.CostManagement module
Invoke-ARI -IncludeCosts
```

## Report Output Options

Customize how the report is generated and saved:

### Custom Report Name

```powershell
Invoke-ARI -ReportName "MyAzureInventory"
```

### Custom Output Directory

```powershell
Invoke-ARI -ReportDir "C:\Reports"
```

### Lightweight Report Format

```powershell
# Generate report without charts for faster processing
Invoke-ARI -Lite
```

## Diagram Options

Control network diagram generation:

### Skip Diagram Creation

```powershell
Invoke-ARI -SkipDiagram
```

### Include All Network Components

```powershell
Invoke-ARI -DiagramFullEnvironment
```

## Other Common Options

Additional options to control ARI behavior:

### Debug Mode

```powershell
# Run in debug mode for detailed logging
Invoke-ARI -Debug
```

### Prevent Automatic Updates

```powershell
# Skip automatic module updates
Invoke-ARI -NoAutoUpdate
```

### Specify Azure Environment

```powershell
# For non-standard Azure environments
Invoke-ARI -AzureEnvironment "AzureUSGovernment"
```

## Using Cloud Shell

When running in Azure Cloud Shell, it's recommended to use:

```powershell
Invoke-ARI -Debug
```

This helps to work around certain limitations in the Cloud Shell environment. 
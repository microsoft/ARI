# Troubleshooting Guide

This guide helps you diagnose and resolve common issues with Azure Resource Inventory.

## Common Issues and Solutions

### Installation Issues

#### Module Not Found

**Issue**: `Import-Module AzureResourceInventory` results in "Module not found" error.

**Solutions**:
1. Verify the module is installed:
   ```powershell
   Get-Module -ListAvailable AzureResourceInventory
   ```
2. If not installed, install it:
   ```powershell
   Install-Module -Name AzureResourceInventory -Scope CurrentUser
   ```
3. If installed but still not found, check your PSModulePath:
   ```powershell
   $env:PSModulePath -split ';'
   ```

#### Permission Issues During Installation

**Issue**: "Access denied" or permission errors during installation.

**Solutions**:
1. Run PowerShell as Administrator
2. Use the CurrentUser scope:
   ```powershell
   Install-Module -Name AzureResourceInventory -Scope CurrentUser
   ```

#### Missing Dependencies

**Issue**: Error about missing required modules.

**Solution**: Install the required dependencies:
```powershell
Install-Module -Name ImportExcel, Az.Accounts, Az.ResourceGraph, Az.Storage, Az.Compute -Scope CurrentUser
```

### Authentication Issues

#### Unable to Connect to Azure

**Issue**: Authentication errors when running ARI.

**Solutions**:
1. Ensure you're logged in:
   ```powershell
   Connect-AzAccount
   ```
2. Verify you have access to the subscriptions:
   ```powershell
   Get-AzSubscription
   ```
3. If using service principal, verify credentials and permissions:
   ```powershell
   Connect-AzAccount -ServicePrincipal -TenantId $tenantId -ApplicationId $appId -Credential $credential
   ```

#### Tenant or Subscription Not Found

**Issue**: Specified tenant or subscription not found.

**Solutions**:
1. Verify the IDs with:
   ```powershell
   Get-AzTenant
   Get-AzSubscription
   ```
2. Check for typos in the IDs
3. Ensure you have access to the specified tenant/subscription

### Execution Issues

#### ARI Runs Slowly

**Issue**: ARI takes a long time to complete.

**Solutions**:
1. Use lightweight mode:
   ```powershell
   Invoke-ARI -Lite
   ```
2. Skip diagram generation:
   ```powershell
   Invoke-ARI -SkipDiagram
   ```
3. Skip advisory collection:
   ```powershell
   Invoke-ARI -SkipAdvisory
   ```
4. Limit to specific subscriptions:
   ```powershell
   Invoke-ARI -SubscriptionID "00000000-0000-0000-0000-000000000000"
   ```

#### Memory Errors

**Issue**: Out of memory errors during execution.

**Solutions**:
1. Close other memory-intensive applications
2. Use the `-Lite` parameter to reduce memory usage
3. Scope to fewer subscriptions at a time
4. Skip diagram generation with `-SkipDiagram`

#### PowerShell Crashes

**Issue**: PowerShell crashes during ARI execution.

**Solutions**:
1. Update to the latest PowerShell version
2. Update ARI and all dependencies:
   ```powershell
   Update-Module AzureResourceInventory
   Update-Module Az.* 
   ```
3. Run with debug enabled to identify the issue:
   ```powershell
   Invoke-ARI -Debug
   ```

### Output Issues

#### Excel Report Format Problems

**Issue**: Excel report formatting issues or errors.

**Solutions**:
1. Ensure you have Excel installed for best results
2. Try the `-Lite` parameter for simpler formatting
3. Update the ImportExcel module:
   ```powershell
   Update-Module ImportExcel
   ```

#### Missing Resources in Report

**Issue**: Some resources are missing from the inventory.

**Solutions**:
1. Verify you have read access to those resources
2. Check if resources are in filtered subscriptions or resource groups
3. Run with `-Debug` to see what's being collected
4. For newly created resources, they might not be visible to Resource Graph yet

#### Diagram Generation Fails

**Issue**: Error generating network diagrams.

**Solutions**:
1. Skip diagram generation:
   ```powershell
   Invoke-ARI -SkipDiagram
   ```
2. Run with debug to identify the issue:
   ```powershell
   Invoke-ARI -Debug
   ```
3. Ensure you have permissions to view network resources

### Cloud Shell Issues

#### CloudShell Timeout

**Issue**: Azure CloudShell times out during execution.

**Solutions**:
1. Use the `-Lite` and `-SkipDiagram` parameters
2. Scope to fewer subscriptions
3. Increase CloudShell timeout in settings (if possible)
4. Run ARI in an Azure VM instead

#### Excel Formatting in CloudShell

**Issue**: Excel formatting warnings in CloudShell.

**Solution**: This is expected in CloudShell. The inventory will be correct, but some formatting and auto-fit columns might not work properly. Use `-Debug` parameter in CloudShell.

## Advanced Troubleshooting

### Detailed Logging

For detailed troubleshooting information:

```powershell
Invoke-ARI -Debug
```

This will display detailed information about each step of the process.

### Module Version Check

If you encounter issues, verify you're using the latest version:

```powershell
Get-Module -ListAvailable AzureResourceInventory
```

Update to the latest version:

```powershell
Update-Module AzureResourceInventory
```

### Testing Specific Components

Test Azure Resource Graph access:

```powershell
Search-AzGraph -Query "Resources | project name, type, location | limit 10"
```

Test Excel generation capability:

```powershell
Import-Module ImportExcel
$data = @([pscustomobject]@{Name="Test"; Value="Value"})
$data | Export-Excel -Path "test.xlsx"
```

## Getting Help

If you've tried the solutions above and still have issues:

1. Check the [GitHub Issues](https://github.com/microsoft/ARI/issues) to see if it's a known issue
2. Submit a new issue with detailed information about your problem
3. Include error messages and the output of running ARI with the `-Debug` parameter 
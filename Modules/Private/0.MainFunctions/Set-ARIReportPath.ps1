<#
.Synopsis
Set the report path for Azure Resource Inventory

.DESCRIPTION
This module sets the default paths for report generation in Azure Resource Inventory.

.Link
https://github.com/microsoft/ARI/Modules/Private/0.MainFunctions/Set-ARIReportPath.ps1

.COMPONENT
This PowerShell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.0
First Release Date: 15th Oct, 2024
Authors: Claudio Merola

#>
function Set-ARIReportPath {
    Param($ReportDir)

    if ($ReportDir)
        {
            $DefaultPath = $ReportDir
            $DiagramCache = Join-Path $ReportDir "DiagramCache"
            $ReportCache = Join-Path $ReportDir 'ReportCache'
        }
    elseif (Resolve-Path -Path 'C:\' -ErrorAction SilentlyContinue)
        {
            $DefaultPath = Join-Path "C:\" "AzureResourceInventory"
            $DiagramCache = Join-Path "C:\" "AzureResourceInventory" "DiagramCache"
            $ReportCache = Join-Path "C:\" "AzureResourceInventory"'ReportCache'
        }
    else
        {
            $DefaultPath = Join-Path "$HOME" "AzureResourceInventory"
            $DiagramCache = Join-Path "$HOME" "AzureResourceInventory" "DiagramCache"
            $ReportCache = Join-Path "$HOME" "AzureResourceInventory" 'ReportCache'
        }

    $ReportPath = @{
        'DefaultPath' = $DefaultPath;
        'DiagramCache' = $DiagramCache;
        'ReportCache' = $ReportCache
    }
    
    return $ReportPath
}
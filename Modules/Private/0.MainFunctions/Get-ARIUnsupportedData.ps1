<#
.Synopsis
Retrieve unsupported data for Azure Resource Inventory

.DESCRIPTION
This module retrieves unsupported data from a predefined JSON file for Azure Resource Inventory.

.Link
https://github.com/microsoft/ARI/Modules/Private/0.MainFunctions/Get-ARIUnsupportedData.ps1

.COMPONENT
This PowerShell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.0
First Release Date: 15th Oct, 2024
Authors: Claudio Merola

#>
function Get-ARIUnsupportedData {

    $SupportedDataPath = (get-item $PSScriptRoot).parent
    $SupportFile = Join-Path $SupportedDataPath '3.ReportingFunctions' 'StyleFunctions' 'Support.json'
    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Validating file: '+$SupportFile)

    $Unsupported = Get-Content -Path $SupportFile | ConvertFrom-Json

    return $Unsupported
}
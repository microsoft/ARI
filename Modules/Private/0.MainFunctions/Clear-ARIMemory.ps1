<#
.Synopsis
Clear memory for Azure Resource Inventory

.DESCRIPTION
This module clears memory to optimize performance for Azure Resource Inventory.

.Link
https://github.com/microsoft/ARI/Modules/Private/0.MainFunctions/Clear-ARIMemory.ps1

.COMPONENT
This PowerShell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.0
First Release Date: 15th Oct, 2024
Authors: Claudio Merola

#>
function Clear-ARIMemory {

    [System.GC]::GetTotalMemory($true) | Out-Null
    Start-Sleep -Milliseconds 100
    [System.GC]::Collect() | Out-Null
    Start-Sleep -Milliseconds 100
}
<#
.Synopsis
Module responsible for retrieving Azure VM SKU details.

.DESCRIPTION
This module retrieves details about Azure VM SKUs available in specific locations.

.Link
https://github.com/microsoft/ARI/Modules/Private/1.ExtractionFunctions/ResourceDetails/Get-ARIVMSkuDetails.ps1

.COMPONENT
This PowerShell Module is part of Azure Resource Inventory (ARI).

.NOTES
Version: 3.6.0
First Release Date: 15th Oct, 2024
Authors: Claudio Merola
#>
function Get-ARIVMSkuDetails {
    Param ($Resources, $Debug)
    if ($Debug.IsPresent)
        {
            $DebugPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'Continue'
        }

    $vm = $Resources | Where-Object {$_.TYPE -in 'microsoft.compute/virtualmachines','microsoft.compute/virtualmachinescalesets'}

    $VMskuData = Foreach($location in ($vm | Select-Object -ExpandProperty location -Unique))
        {
            $tmp = [PSCustomObject]@{
                Location    = $location
                SKUs        = Get-AzComputeResourceSku $location -InformationAction SilentlyContinue -ProgressAction SilentlyContinue
            }
            $tmp
        }

    $VMSkuDetails = [PSCustomObject]@{
        'type'          = 'ARI/VM/SKU'
        'properties'    = $VMskuData
    }

    return $VMSkuDetails
}
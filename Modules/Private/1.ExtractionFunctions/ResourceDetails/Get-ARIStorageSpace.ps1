<#
.Synopsis
Module responsible for retrieving Azure Storage Space details.

.DESCRIPTION
This module retrieves Azure Storage Space details for specific subscriptions and locations.

.Link
https://github.com/microsoft/ARI/Modules/Private/1.ExtractionFunctions/ResourceDetails/Get-ARIStorageSpace.ps1

.COMPONENT
This PowerShell Module is part of Azure Resource Inventory (ARI).

.NOTES
Version: 3.6.12
First Release Date: 15th Oct, 2024
Authors: Claudio Merola
#>

function Get-AriStorageSpace {
    Param ($Subscriptions, $Resources)

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Getting Storage Space Details')

    $StorageAccounts = ($Resources | Where-Object {$_.Type -in 'microsoft.storage/storageaccounts'})

    $Data = foreach ($Storage in $StorageAccounts)
        {
            try{
                $Capacity = Get-AzMetric -ResourceId $Storage.id -MetricName "UsedCapacity" -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -InformationAction SilentlyContinue -Debug:$false

                $object = [PSCustomObject] @{
                    id = $Storage.id
                    CapacityGB = (($Capacity.Data.Average[0] / 1024) /1024) /1024
                }
            }
            catch{
                $object = [PSCustomObject] @{
                    id = $Storage.id
                    CapacityGB = 'Unavailable'
                }
            }

            $object
        }

    Clear-Variable -Name StorageAccounts

    $StorageData = [PSCustomObject]@{
        'type'          = 'ARI/STORAGE/CAPACITY'
        'properties'    = $Data
    }

    return $StorageData
}
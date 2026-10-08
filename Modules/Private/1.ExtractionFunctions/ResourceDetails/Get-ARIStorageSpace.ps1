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
Version: 3.6.16
First Release Date: 15th Oct, 2024
Authors: Claudio Merola
#>

function Get-AriStorageSpace {
    Param ($Subscriptions, $Resources)

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Getting Storage Space Details')

    $StorageAccounts = ($Resources | Where-Object {$_.Type -in 'microsoft.storage/storageaccounts'})

    try
        {
            $Token = Get-AzAccessToken -AsSecureString -InformationAction SilentlyContinue -WarningAction SilentlyContinue -Debug:$false
            $Header = @{ 'Authorization' = 'Bearer ' + ($Token.Token | ConvertFrom-SecureString -AsPlainText) }
            $ArmUrl = (Get-AzContext).Environment.ResourceManagerUrl.TrimEnd('/')
        }
    catch
        {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Error: ' + $_.Exception.Message)
            $Header = $null
        }

    # Same request Get-AzMetric makes by default: last hour, hourly grain, average
    $Requests = if ($Header)
        {
            foreach ($Storage in $StorageAccounts)
                {
                    [PSCustomObject]@{ Key = $Storage.id; Uri = ($ArmUrl + $Storage.id + '/providers/Microsoft.Insights/metrics?metricnames=UsedCapacity&api-version=2023-10-01') }
                }
        }

    $Responses = Invoke-ARIRestParallel -Requests $Requests -Header $Header

    $Data = foreach ($Storage in $StorageAccounts)
        {
            $Average = @($Responses[$Storage.id].value[0].timeseries[0].data)[0].average
            if ($null -ne $Average)
                {
                    $object = [PSCustomObject] @{
                        id = $Storage.id
                        CapacityGB = (($Average / 1024) /1024) /1024
                    }
                }
            else
                {
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

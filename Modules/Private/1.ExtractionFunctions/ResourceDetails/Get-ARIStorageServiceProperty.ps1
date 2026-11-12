<#
.Synopsis
Module responsible for retrieving Azure Storage blob and file service properties.

.DESCRIPTION
Fetches blobServices/default and fileServices/default for every storage account in
parallel, so the Storage inventory module can read soft delete settings without
calling Azure once per account from inside its processing job.

.Link
https://github.com/microsoft/ARI/Modules/Private/1.ExtractionFunctions/ResourceDetails/Get-ARIStorageServiceProperty.ps1

.COMPONENT
This PowerShell Module is part of Azure Resource Inventory (ARI).

.NOTES
Version: 3.6.16
First Release Date: 9th Oct, 2026
Authors: Robin Pieterse
#>

function Get-ARIStorageServiceProperty {
    Param ($Resources)

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Getting Storage Service Properties')

    $StorageAccounts = ($Resources | Where-Object {$_.Type -in 'microsoft.storage/storageaccounts'})

    try
        {
            $Token = Get-AzAccessToken -AsSecureString -InformationAction SilentlyContinue -WarningAction SilentlyContinue -Debug:$false
            $Header = @{ 'Authorization' = 'Bearer ' + ($Token.Token | ConvertFrom-SecureString -AsPlainText) }
            $ArmUrl = (Get-AzContext -Debug:$false).Environment.ResourceManagerUrl.TrimEnd('/')
        }
    catch
        {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Error: ' + $_.Exception.Message)
            $Header = $null
        }

    $Requests = if ($Header)
        {
            foreach ($Storage in $StorageAccounts)
                {
                    [PSCustomObject]@{ Key = "$($Storage.id)|Blob"; Uri = ($ArmUrl + $Storage.id + '/blobServices/default?api-version=2023-05-01') }
                    [PSCustomObject]@{ Key = "$($Storage.id)|File"; Uri = ($ArmUrl + $Storage.id + '/fileServices/default?api-version=2023-05-01') }
                }
        }

    $Responses = Invoke-ARIRestParallel -Requests $Requests -Header $Header

    $Data = foreach ($Storage in $StorageAccounts)
        {
            [PSCustomObject]@{
                id   = $Storage.id
                Blob = $Responses["$($Storage.id)|Blob"].properties
                File = $Responses["$($Storage.id)|File"].properties
            }
        }

    return [PSCustomObject]@{
        'type'          = 'ARI/STORAGE/SERVICES'
        'properties'    = $Data
    }
}

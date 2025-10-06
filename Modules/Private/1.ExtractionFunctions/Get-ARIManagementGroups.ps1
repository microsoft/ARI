<#
.Synopsis
Module responsible for retrieving Azure Management Groups.

.DESCRIPTION
This module retrieves Azure Management Groups and their associated subscriptions.

.Link
https://github.com/microsoft/ARI/Modules/Private/1.ExtractionFunctions/Get-ARIManagementGroups.ps1

.COMPONENT
This PowerShell Module is part of Azure Resource Inventory (ARI).

.NOTES
Version: 3.6.11
First Release Date: 15th Oct, 2024
Authors: Claudio Merola
#>
function Get-ARIManagementGroups {
    Param ($ManagementGroup,$Subscriptions)

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Management group name: ' + $ManagementGroup)

    $GraphQuery = "resourcecontainers | where type == 'microsoft.resources/subscriptions' | mv-expand managementGroupParent = properties.managementGroupAncestorsChain | where managementGroupParent.name =~ '$($ManagementGroup)'"
    $QueryResult = Search-AzGraph -Query $GraphQuery -first 1000 -Debug:$false
    $LocalResults = $QueryResult

    if ($LocalResults.Count -lt 1) {
        Write-Host "ERROR:" -NoNewline -ForegroundColor Red
        Write-Host "No Subscriptions found for Management Group: $ManagementGroup!"
        Write-Host ""
        Write-Host "Please check the Management Group name and try again."
        Write-Host ""
        Exit
    }
    else {
        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Subscriptions found for Management Group: ' + $LocalResults.Count)
        $FinalSubscriptions = foreach ($Sub in $Subscriptions)
            {
                if ($Sub.name -in $LocalResults.name)
                    {
                        $Sub
                    }
            }
    }
    return $FinalSubscriptions
}
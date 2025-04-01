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
Version: 3.6.0
First Release Date: 15th Oct, 2024
Authors: Claudio Merola
#>
function Get-ARIManagementGroups {
    Param ($ManagementGroup)

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Management group name supplied: ' + $ManagmentGroupName)
    $ReportCounter = 1
    $LocalResults = @()

    $group = Get-AzManagementGroupEntity
    $group = $group | Where-Object { $_.DisplayName -eq $ManagementGroup }
    if ($group.Count -lt 1)
    {
        Write-Host "ERROR:" -NoNewline -ForegroundColor Red
        Write-Host "Management Group $ManagementGroup not found!"
        Write-Host ""
        Write-Host "Please check the Management Group name and try again."
        Write-Host ""
        Exit
    }
    else
    {
        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Management groups found: ' + $group.count)
        foreach ($item in $group)
        {
            $GraphQuery = "resourcecontainers | where type == 'microsoft.resources/subscriptions' | mv-expand managementGroupParent = properties.managementGroupAncestorsChain | where managementGroupParent.name =~ '$($item.DisplayName)'"
            $QueryResult = Search-AzGraph -Query $GraphQuery -first 1000
            $LocalResults += $QueryResult

            while ($QueryResult.SkipToken) {
                $ReportCounterVar = [string]$ReportCounter
                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Extracting Next 1000 Subscriptions. Loop Number: ' + $ReportCounterVar)
                $QueryResult = Search-AzGraph -Query $GraphQuery -SkipToken $QueryResult.SkipToken -Subscription $FSubscri -first 1000
                $LocalResults += $QueryResult
                $ReportCounter ++
            }
            Write-Progress -Id 1 -activity "Running Subscription Inventory Job" -Status "$Looper / $Loop of Subscription Jobs" -Completed
        }
    }
    return $LocalResults
}
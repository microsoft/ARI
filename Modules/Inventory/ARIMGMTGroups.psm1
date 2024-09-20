function Get-ARIManagementGroups {
    Param ($ManagementGroup, $Debug)
    if ($Debug.IsPresent)
        {
            $DebugPreference = 'Continue'
            $ErrorActionPreference = 'Continue'
        }
    else
        {
            $ErrorActionPreference = "silentlycontinue"
        }
    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Management group name supplied: ' + $ManagmentGroupName)
    $ReportCounter = 1
    $LocalResults = @()
    $group = Get-AzManagementGroup -GroupName $ManagementGroup
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
            $GraphQuery = "resourcecontainers | where type == 'microsoft.resources/subscriptions' | mv-expand managementGroupParent = properties.managementGroupAncestorsChain | where managementGroupParent.name =~ '$($item.name)' | summarize count()"
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
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
    $group = az account management-group entities list --query "[?name =='$ManagementGroup']" | ConvertFrom-Json
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
            $Subscriptions = @()
            $GraphQuery = "resourcecontainers | where type == 'microsoft.resources/subscriptions' | mv-expand managementGroupParent = properties.managementGroupAncestorsChain | where managementGroupParent.name =~ '$($item.name)' | summarize count()"
            $EnvSize = az graph query -q $GraphQuery --output json --only-show-errors | ConvertFrom-Json
            $EnvSizeNum = $EnvSize.data.'count_'

            if ($EnvSizeNum -ge 1) {
                $Loop = $EnvSizeNum / 1000
                $Loop = [math]::ceiling($Loop)
                $Looper = 0
                $Limit = 0

                while ($Looper -lt $Loop) {
                    $GraphQuery = "resourcecontainers | where type == 'microsoft.resources/subscriptions' | mv-expand managementGroupParent = properties.managementGroupAncestorsChain | where managementGroupParent.name =~ '$($item.name)' | project id = subscriptionId"
                    $Resource = (az graph query -q $GraphQuery --skip $Limit --first 1000 --output json --only-show-errors).tolower() | ConvertFrom-Json

                    foreach ($Sub in $Resource.data) {
                        $Subscriptions += az account show --subscription $Sub.id --output json --only-show-errors | ConvertFrom-Json
                    }

                    Start-Sleep 2
                    $Looper ++
                    Write-Progress -Id 1 -activity "Running Subscription Inventory Job" -Status "$Looper / $Loop of Subscription Jobs" -PercentComplete (($Looper / $Loop) * 100)
                    $Limit = $Limit + 1000
                }
            }
            Write-Progress -Id 1 -activity "Running Subscription Inventory Job" -Status "$Looper / $Loop of Subscription Jobs" -Completed
        }
    }
    return $Subscriptions
}
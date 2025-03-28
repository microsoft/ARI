function Get-ARICostInventory {
    Param($Subscriptions, $Days, $Debug, $Granularity)

    if ($Debug.IsPresent) 
        {
            $DebugPreference = 'Continue'
            $ErrorActionPreference = 'Continue'
        } 
    else 
        {
            $ErrorActionPreference = "silentlycontinue"
        }

    $Today = Get-Date
    $EndDate = Get-Date -Year $Today.Year -Month $Today.Month -Day $Today.Day -Hour 23 -Minute 59 -Second 59 -Millisecond 0

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss') + ' - ' + 'Creating Cost Inventory Job')

    Start-Job -Name 'Cost Inventory' -ScriptBlock {

        $Grouping = @()
        $GTemp = @{Name='ResourceType';Type='Dimension'}
        $Grouping += $GTemp
        $GTemp = @{Name='ResourceGroup';Type='Dimension'}
        $Grouping += $GTemp

        $Hash = @{name="PreTaxCost";function="Sum"}
        $MHash = @{totalCost=$Hash}

        $EndDate = $($args[1])
        $Days = $($args[2])
        if ($Days -ge 365)
            {
                $StartDate = Get-date -Year $EndDate.AddYears(-1).Year -Month 1 -Day 1 -Hour 0 -Minute 0 -Second 0 -Millisecond 1
                $EndDate = Get-Date -Year $StartDate.Year -Month 12 -Day 31 -Hour 23 -Minute 59 -Second 59 -Millisecond 0
            }
        else
            {
                $StartDate = ($EndDate).AddDays(-$Days)
            }  

        $job = @()
        Foreach ($Subscription in $($args[0]))
            {

                $Sub = $Subscription.id
                $Scope = ('/subscriptions/'+$Sub+'/')

                New-Variable -Name ('SubRun'+$Sub)
                New-Variable -Name ('SubJob'+$Sub)

                Set-Variable -Name ('SubRun'+$Sub) -Value ([PowerShell]::Create()).AddScript({param($Scope,$StartDate,$EndDate,$Grouping,$MHash,$Granularity)
                    Invoke-AzCostManagementQuery -Type ActualCost -Scope $Scope -Timeframe Custom -DatasetGranularity $Granularity -DatasetGrouping $Grouping -DatasetAggregation $MHash -TimePeriodFrom $StartDate -TimePeriodTo $EndDate
                }).AddArgument($Scope).AddArgument($StartDate).AddArgument($EndDate).AddArgument($Grouping).AddArgument($MHash).AddArgument($($args[3]))
                
                Set-Variable -Name ('SubJob'+$Sub) -Value ((get-variable -name ('SubRun'+$Sub)).Value).BeginInvoke()
                $job += (get-variable -name ('SubJob'+$Sub)).Value

                Start-Sleep -Milliseconds 250
            }

        while ($job.IsCompleted -contains $false) {Start-Sleep -Milliseconds 100}

        Foreach ($Subscription in $($args[0]))
            {
                $Sub = $Subscription.id
                New-Variable -Name ('SubValue'+$Sub)
                Set-Variable -Name ('SubValue'+$Sub) -Value (((get-variable -name ('SubRun'+$Sub)).Value).EndInvoke((get-variable -name ('SubJob'+$Sub)).Value))
            }        

        Foreach ($Subscription in $($args[0]))
            {
                $Sub = $Subscription.id
                Remove-Variable -name ('SubRun'+$Sub)
            }     

        $Result = @()
        Foreach ($Subscription in $($args[0]))
            {
                $Sub = $Subscription.id 
                $Results = (get-variable -name ('SubValue'+$Sub)).Value
                $obj = @{
                        'Subscription'  = $Subscription.name;
                        'SubscriptionId'  = $Subscription.id;
                        'ActualCost'    = $Results
                        }
                $Result += $obj
            }

        $Result

        } -ArgumentList $Subscriptions, $EndDate, $Days, $Granularity | Out-Null

}
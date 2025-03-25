function Invoke-ARIPolicyJob {
    Param($Subscriptions, $PolicySetDef, $PolicyAssign, $PolicyDef, $ARIModule, $Automation, $Debug)
    if ($Debug.IsPresent)
        {
            $DebugPreference = 'Continue'
            $ErrorActionPreference = 'Continue'
        }
    else
        {
            $ErrorActionPreference = "silentlycontinue"
        }

    if ($Automation.IsPresent)
        {
            Write-Output ('Starting Policy Job')
            Start-ThreadJob -Name 'Policy' -ScriptBlock {

                import-module $($args[4])

                $PolResult = Start-ARIPolicyJob -Subscriptions $($args[0]) -PolicySetDef $($args[1]) -PolicyAssign $($args[2]) -PolicyDef $($args[3])

                $PolResult

            } -ArgumentList $Subscriptions, $PolicySetDef, $PolicyAssign, $PolicyDef, $ARIModule | Out-Null
        }
    else
        {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting Policy Job.')
            Start-Job -Name 'Policy' -ScriptBlock {

                import-module $($args[4])

                $PolResult = Start-ARIPolicyJob -Subscriptions $($args[0]) -PolicySetDef $($args[1]) -PolicyAssign $($args[2]) -PolicyDef $($args[3])

                $PolResult

            } -ArgumentList $Subscriptions, $PolicySetDef, $PolicyAssign, $PolicyDef, $ARIModule | Out-Null
        }
}
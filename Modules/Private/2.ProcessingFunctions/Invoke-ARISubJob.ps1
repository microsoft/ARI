function Invoke-ARISubJob {
    Param($Subscriptions, $Automation, $Resources, $ARIModule, $Debug)
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
            Write-Output ('Starting Subscription Job')
            Start-ThreadJob -Name 'Subscriptions' -ScriptBlock {

                import-module $($args[2])

                $SubResult = Start-ARISubscriptionJob -Subscriptions $($args[0]) -Resources $($args[1])

                $SubResult

            } -ArgumentList $Subscriptions, $Resources, $ARIModule | Out-Null
        }
    else
        {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting Subscription Job.')
            Start-Job -Name 'Subscriptions' -ScriptBlock {

                import-module $($args[2])

                $SubResult = Start-ARISubscriptionJob -Subscriptions $($args[0]) -Resources $($args[1])

                $SubResult

            } -ArgumentList $Subscriptions, $Resources, $ARIModule | Out-Null
        }

}
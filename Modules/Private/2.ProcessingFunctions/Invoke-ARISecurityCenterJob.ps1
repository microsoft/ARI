function Invoke-ARISecurityCenterJob {
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
            Write-Output ('Starting SecurityCenter Job')
            Start-ThreadJob  -Name 'Security' -ScriptBlock {

                import-module $($args[2])

                $SecResult = Start-ARISecCenterJob -Subscriptions $($args[0]) -Security $($args[1])

                $SecResult

            } -ArgumentList $Subscriptions , $SecurityCenter, $ARIModule | Out-Null
        }
    else
        {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting SecurityCenter Job.')
            Start-Job -Name 'Security' -ScriptBlock {

                import-module $($args[2])

                $SecResult = Start-ARISecCenterJob -Subscriptions $($args[0]) -Security $($args[1])

                $SecResult

            } -ArgumentList $Subscriptions , $SecurityCenter, $ARIModule | Out-Null
        }
}
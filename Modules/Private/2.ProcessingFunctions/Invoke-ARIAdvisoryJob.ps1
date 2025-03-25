function Invoke-ARIAdvisoryJob {
    Param($Advisories, $ARIModule, $Automation, $Debug)
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
            Write-Output ('Starting Advisory Job')
            Start-ThreadJob -Name 'Advisory' -ScriptBlock {

                import-module $($args[1])

                $AdvResult = Start-ARIAdvisoryJob -Advisories $($args[0])

                $AdvResult

            } -ArgumentList $Advisories, $ARIModule | Out-Null
        }
    else
        {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting Advisory Job.')
            Start-Job -Name 'Advisory' -ScriptBlock {

                import-module $($args[1])

                $AdvResult = Start-ARIAdvisoryJob -Advisories $($args[0])

                $AdvResult

            } -ArgumentList $Advisories, $ARIModule | Out-Null
        }
}
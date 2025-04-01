<#
.Synopsis
Module responsible for invoking advisory processing jobs.

.DESCRIPTION
This module starts jobs to process advisory data for Azure Resources, either in automation or manual mode.

.Link
https://github.com/microsoft/ARI/Modules/Private/2.ProcessingFunctions/Invoke-ARIAdvisoryJob.ps1

.COMPONENT
This PowerShell Module is part of Azure Resource Inventory (ARI).

.NOTES
Version: 3.6.0
First Release Date: 15th Oct, 2024
Authors: Claudio Merola
#>

function Invoke-ARIAdvisoryJob {
    Param($Advisories, $ARIModule, $Automation)

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
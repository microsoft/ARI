<#
.Synopsis
Module responsible for invoking Security Center processing jobs.

.DESCRIPTION
This module starts jobs to process Azure Security Center data for subscriptions and resources, either in automation or manual mode.

.Link
https://github.com/microsoft/ARI/Modules/Private/2.ProcessingFunctions/Invoke-ARISecurityCenterJob.ps1

.COMPONENT
This PowerShell Module is part of Azure Resource Inventory (ARI).

.NOTES
Version: 3.6.0
First Release Date: 15th Oct, 2024
Authors: Claudio Merola
#>

function Invoke-ARISecurityCenterJob {
    Param($Subscriptions, $Automation, $Resources, $ARIModule)

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
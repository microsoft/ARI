<#
.Synopsis
Module for Extra Reports

.DESCRIPTION
This script processes and creates additional report sheets such as Quotas, Security Center, Policies, and Advisory.

.Link
https://github.com/microsoft/ARI/Modules/Private/3.ReportingFunctions/Start-ARIExtraReports.ps1

.COMPONENT
This PowerShell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.0
First Release Date: 15th Oct, 2024
Authors: Claudio Merola
#>

function Start-ARIExtraReports {
    Param($File, $Quotas, $SecurityCenter, $SkipPolicy, $SkipAdvisory, $IncludeCosts, $TableStyle)

    Write-Progress -activity 'Azure Inventory' -Status "70% Complete." -PercentComplete 70 -CurrentOperation "Reporting Extra Resources.."

    <################################################ QUOTAS #######################################################>

    if(![string]::IsNullOrEmpty($Quotas))
        {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Generating Quota Usage Sheet.')
            Write-Progress -Id 1 -activity 'Azure Resource Inventory Quota Usage' -Status "50% Complete." -PercentComplete 50 -CurrentOperation "Building Quota Sheet"

            Build-ARIQuotaReport -File $File -AzQuota $Quotas -TableStyle $TableStyle

            Write-Progress -Id 1 -activity 'Azure Resource Inventory Quota Usage' -Status "100% Complete." -Completed
        }

    <################################################ SECURITY CENTER #######################################################>

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Checking if Should Generate Security Center Sheet.')
    if ($SecurityCenter.IsPresent) {
        if(get-job | Where-Object {$_.Name -eq 'Security'})
            {
                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Generating Security Center Sheet.')

                while (get-job -Name 'Security' | Where-Object { $_.State -eq 'Running' }) {
                    Write-Progress -Id 1 -activity 'Processing Security Center Advisories' -Status "50% Complete." -PercentComplete 50
                    Start-Sleep -Seconds 2
                }

                $Sec = Receive-Job -Name 'Security'
                Remove-Job -Name 'Security' | Out-Null

                Build-ARISecCenterReport -File $File -Sec $Sec -TableStyle $TableStyle

                Write-Progress -Id 1 -activity 'Processing Security Center Advisories'  -Status "100% Complete." -Completed
            }

    }

    <################################################ POLICY #######################################################>

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Checking if Should Generate Policy Sheet.')
    if (!$SkipPolicy.IsPresent) {
        if(get-job | Where-Object {$_.Name -eq 'Policy'})
            {
                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Generating Policy Sheet.')

                while (get-job -Name 'Policy' | Where-Object { $_.State -eq 'Running' }) {
                    Write-Progress -Id 1 -activity 'Processing Policies' -Status "50% Complete." -PercentComplete 50
                    Start-Sleep -Seconds 2
                }

                $Pol = Receive-Job -Name 'Policy'
                Remove-Job -Name 'Policy' | Out-Null

                Build-ARIPolicyReport -File $File -Pol $Pol -TableStyle $TableStyle

                Write-Progress -Id 1 -activity 'Processing Policies'  -Status "100% Complete." -Completed

                Start-Sleep -Milliseconds 200
            }
    }

    <################################################ ADVISOR #######################################################>

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Checking if Should Generate Advisory Sheet.')
    if (!$SkipAdvisory.IsPresent) {
        if (get-job | Where-Object {$_.Name -eq 'Advisory'})
            {
                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Generating Advisor Sheet.')

                while (get-job -Name 'Advisory' | Where-Object { $_.State -eq 'Running' }) {
                    Write-Progress -Id 1 -activity 'Processing Advisories' -Status "50% Complete." -PercentComplete 50
                    Start-Sleep -Seconds 2
                }

                $Adv = Receive-Job -Name 'Advisory'
                Remove-Job -Name 'Advisory' | Out-Null

                Build-ARIAdvisoryReport -File $File -Adv $Adv -TableStyle $TableStyle

                Write-Progress -Id 1 -activity 'Processing Advisories'  -Status "100% Complete." -Completed

                Start-Sleep -Milliseconds 200
            }
    }

    <################################################################### SUBSCRIPTIONS ###################################################################>

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Generating Subscription sheet.')

    Write-Progress -activity 'Azure Resource Inventory Subscriptions' -Status "50% Complete." -PercentComplete 50 -CurrentOperation "Building Subscriptions Sheet"

    while (get-job -Name 'Subscriptions' | Where-Object { $_.State -eq 'Running' }) {
        Write-Progress -Id 1 -activity 'Processing Subscriptions' -Status "50% Complete." -PercentComplete 50
        Start-Sleep -Seconds 2
    }

    $AzSubs = Receive-Job -Name 'Subscriptions'
    Remove-Job -Name 'Subscriptions' | Out-Null

    Build-ARISubsReport -File $File -Sub $AzSubs -IncludeCosts $IncludeCosts -TableStyle $TableStyle

    Clear-ARIMemory

    Write-Progress -activity 'Azure Resource Inventory Subscriptions' -Status "100% Complete." -Completed

    Write-Progress -activity 'Azure Inventory' -Status "80% Complete." -PercentComplete 80 -CurrentOperation "Completed Extra Resources Reporting.."
}
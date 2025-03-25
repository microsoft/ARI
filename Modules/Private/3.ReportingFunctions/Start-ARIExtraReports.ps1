function Start-ARIExtraReports {
    Param($File, $Quotas, $SecurityCenter, $SkipPolicy, $SkipAdvisory, $TableStyle, $Debug)
    if ($Debug.IsPresent)
        {
            $DebugPreference = 'Continue'
            $ErrorActionPreference = 'Continue'
        }
    else
        {
            $ErrorActionPreference = "silentlycontinue"
        }

    <################################################ QUOTAS #######################################################>

    if(![string]::IsNullOrEmpty($Quotas))
        {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Generating Quota Usage Sheet.')
            Write-Progress -activity 'Azure Resource Inventory Quota Usage' -Status "50% Complete." -PercentComplete 50 -CurrentOperation "Building Quota Sheet"

            Build-ARIQuotaReport -File $File -AzQuota $Quotas -TableStyle $TableStyle

            Write-Progress -activity 'Azure Resource Inventory Quota Usage' -Status "100% Complete." -Completed
        }

    <################################################ SECURITY CENTER #######################################################>

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Checking if Should Generate Security Center Sheet.')
    if ($SecurityCenter.IsPresent) {
        if($OldJobs | Where-Object {$_.Name -eq 'Security'})
            {
                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Generating Security Center Sheet.')

                while (get-job -Name 'Security' | Where-Object { $_.State -eq 'Running' }) {
                    Write-Progress -Id 1 -activity 'Processing Security Center Advisories' -Status "50% Complete." -PercentComplete 50
                    Start-Sleep -Seconds 2
                }
                Write-Progress -Id 1 -activity 'Processing Security Center Advisories'  -Status "100% Complete." -Completed

                $Sec = Receive-Job -Name 'Security'

                Build-ARISecCenterReport -File $File -Sec $Sec -TableStyle $TableStyle
            }

    }

    <################################################ POLICY #######################################################>

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Checking if Should Generate Policy Sheet.')
    if (!$SkipPolicy.IsPresent) {
        if($OldJobs | Where-Object {$_.Name -eq 'Policy'})
            {
                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Generating Policy Sheet.')

                while (get-job -Name 'Policy' | Where-Object { $_.State -eq 'Running' }) {
                    Write-Progress -Id 1 -activity 'Processing Policies' -Status "50% Complete." -PercentComplete 50
                    Start-Sleep -Seconds 2
                }
                Write-Progress -Id 1 -activity 'Processing Policies'  -Status "100% Complete." -Completed

                $Pol = Receive-Job -Name 'Policy'

                Build-ARIPolicyReport -File $File -Pol $Pol -TableStyle $TableStyle

                Start-Sleep -Milliseconds 200
            }
    }

    <################################################ ADVISOR #######################################################>

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Checking if Should Generate Advisory Sheet.')
    if (!$SkipAdvisory.IsPresent) {
        if ($OldJobs | Where-Object {$_.Name -eq 'Policy'})
            {
                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Generating Advisor Sheet.')

                while (get-job -Name 'Advisory' | Where-Object { $_.State -eq 'Running' }) {
                    Write-Progress -Id 1 -activity 'Processing Advisories' -Status "50% Complete." -PercentComplete 50
                    Start-Sleep -Seconds 2
                }
                Write-Progress -Id 1 -activity 'Processing Advisories'  -Status "100% Complete." -Completed

                $Adv = Receive-Job -Name 'Advisory'

                Build-ARIAdvisoryReport -File $File -Adv $Adv -TableStyle $TableStyle

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

    Build-ARISubsReport -File $File -Sub $AzSubs -TableStyle $TableStyle

    Clear-ARIMemory

    Write-Progress -activity 'Azure Resource Inventory Subscriptions' -Status "100% Complete." -Completed
}
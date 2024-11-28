function Start-ARIExtraJobs {
    Param ($SkipDiagram, $SkipAdvisory, $SkipPolicy, $SecurityCenter, $Subscriptions, $Resources, $Advisories, $DDFile, $DiagramCache, $FullEnv, $ResourceContainers, $Security, $PolicyDef, $PolicySetDef, $PolicyAssign, $Automation, $Debug)
    if ($Debug.IsPresent)
        {
            $DebugPreference = 'Continue'
            $ErrorActionPreference = 'Continue'
        }
    else
        {
            $ErrorActionPreference = "silentlycontinue"
        }

    <######################################################### DRAW IO DIAGRAM JOB ######################################################################>

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Checking if Draw.io Diagram Job Should be Run.')
    if (!$SkipDiagram.IsPresent) {
        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting Draw.io Diagram Processing Job.')
        Start-job -Name 'DrawDiagram' -ScriptBlock {

            Import-Module AzureResourceInventory

            $DiagramCache = $($args[5])

            $TempPath = $DiagramCache.split("DiagramCache\")[0]

            $Logfile = ($TempPath+'DiagramLogFile.log')

            ('DrawIOCoreJob - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Starting Draw.IO Job') | Out-File -FilePath $LogFile -Append

            ('DrawIOCoreJob - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Calling Draw.IO Thread') | Out-File -FilePath $LogFile -Append
            try
                {
                    Invoke-ARIDrawIODiagram -Subscriptions $($args[0]) -Resources $($args[1]) -Advisories $($args[2]) -DDFile $($args[3]) -DiagramCache $($args[4]) -FullEnvironment $($args[5]) -ResourceContainers $($args[6])

                }
            catch
                {
                    ('DrawIOCoreJob - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+$_.Exception.Message) | Out-File -FilePath $LogFile -Append
                }
            ('DrawIOCoreJob - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Draw.IO Ended.') | Out-File -FilePath $LogFile -Append

        } -ArgumentList $Subscriptions, $Resources, $Advisories, $DDFile, $DiagramCache, $FullEnv, $ResourceContainers | Out-Null
    }

    <######################################################### VISIO DIAGRAM JOB ######################################################################>
    <#
    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Checking if Visio Diagram Job Should be Run.')
    if ($Diagram.IsPresent) {
        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting Visio Diagram Processing Job.')
        Start-job -Name 'VisioDiagram' -ScriptBlock {

            If ($($args[5]) -eq $true) {
                $ModuSeq = (New-Object System.Net.WebClient).DownloadString($($args[7]) + '/Extras/VisioDiagram.ps1')
            }
            Else {
                $ModuSeq0 = New-Object System.IO.StreamReader($($args[0]) + '\Extras\VisioDiagram.ps1')
                $ModuSeq = $ModuSeq0.ReadToEnd()
                $ModuSeq0.Dispose()
            }

            $ScriptBlock = [Scriptblock]::Create($ModuSeq)

            $VisioRun = ([PowerShell]::Create()).AddScript($ScriptBlock).AddArgument($($args[1])).AddArgument($($args[2])).AddArgument($($args[3])).AddArgument($($args[4]))

            $VisioJob = $VisioRun.BeginInvoke()

            while ($VisioJob.IsCompleted -contains $false) {}

            $VisioRun.EndInvoke($VisioJob)

            $VisioRun.Dispose()

        } -ArgumentList $PSScriptRoot, $Subscriptions, $Resources, $Advisories, $DFile, $RunOnline, $Repo, $RawRepo   | Out-Null
    }
    #>

    <######################################################### SECURITY CENTER JOB ######################################################################>

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Checking If Should Run Security Center Job.')
    if (![string]::IsNullOrEmpty($SecurityCenter))
        {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting Security Job.')
            if ($Automation.IsPresent)
                {
                    Write-Output ('Starting SecurityCenter Job')
                    Start-ThreadJob  -Name 'Security' -ScriptBlock {

                        Import-Module AzureResourceInventory

                        $SecResult = Invoke-ARISecCenterProcessing -Subscriptions $($args[0]) -Security $($args[1])

                        $SecResult

                    } -ArgumentList $Subscriptions , $SecurityCenter | Out-Null
                }
            else
                {
                    Start-Job -Name 'Security' -ScriptBlock {

                        Import-Module AzureResourceInventory

                        $SecResult = Invoke-ARISecCenterProcessing -Subscriptions $($args[0]) -Security $($args[1])

                        $SecResult

                    } -ArgumentList $Subscriptions , $SecurityCenter | Out-Null
                }
        }

    <######################################################### POLICY JOB ######################################################################>

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Checking If Should Run Policy Job.')
    if (!$SkipPolicy.IsPresent) {
        if (![string]::IsNullOrEmpty($PolicyAssign) -and ![string]::IsNullOrEmpty($PolicyDef))
            {
                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting Policy Processing Job.')
                if ($Automation.IsPresent)
                    {
                        Write-Output ('Starting Policy Job')
                        Start-ThreadJob -Name 'Policy' -ScriptBlock {

                            Import-Module AzureResourceInventory

                            $PolResult = Invoke-ARIPolicyProcessing -Subscriptions $($args[0]) -PolicySetDef $($args[1]) -PolicyAssign $($args[2]) -PolicyDef $($args[3])

                            $PolResult

                        } -ArgumentList $Subscriptions, $PolicySetDef, $PolicyAssign, $PolicyDef | Out-Null
                    }
                else
                    {
                        Start-Job -Name 'Policy' -ScriptBlock {

                            Import-Module AzureResourceInventory

                            $PolResult = Invoke-ARIPolicyProcessing -Subscriptions $($args[0]) -PolicySetDef $($args[1]) -PolicyAssign $($args[2]) -PolicyDef $($args[3])

                            $PolResult

                        } -ArgumentList $Subscriptions, $PolicySetDef, $PolicyAssign, $PolicyDef | Out-Null
                    }
            }
    }

    <######################################################### ADVISORY JOB ######################################################################>

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Checking If Should Run Advisory Job.')
    if (!$SkipAdvisory.IsPresent) {
        if (![string]::IsNullOrEmpty($Advisories))
            {
                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting Advisory Processing Job.')
                if ($Automation.IsPresent)
                    {
                        Write-Output ('Starting Advisory Job')
                        Start-ThreadJob -Name 'Advisory' -ScriptBlock {
        
                            Import-Module AzureResourceInventory
        
                            $AdvResult = Invoke-ARIAdvisoryProcessing -Advisories $args
        
                            $AdvResult
        
                        } -ArgumentList $Advisories | Out-Null
                    }
                else
                    {
                        Start-Job -Name 'Advisory' -ScriptBlock {
        
                            Import-Module AzureResourceInventory
        
                            $AdvResult = Invoke-ARIAdvisoryProcessing -Advisories $args
        
                            $AdvResult
        
                        } -ArgumentList $Advisories | Out-Null
                    }
            }
    }

    <######################################################### SUBSCRIPTIONS JOB ######################################################################>

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting Subscriptions job.')
    if ($Automation.IsPresent)
        {
            Write-Output ('Starting Subscription Job')
            Start-ThreadJob -Name 'Subscriptions' -ScriptBlock {

                Import-Module AzureResourceInventory

                $SubResult = Invoke-ARISubsProcessing -Subscriptions $($args[0]) -Resources $($args[1])

                $SubResult

            } -ArgumentList $Subscriptions, $Resources | Out-Null
        }
    else
        {
            Start-Job -Name 'Subscriptions' -ScriptBlock {

                Import-Module AzureResourceInventory

                $SubResult = Invoke-ARISubsProcessing -Subscriptions $($args[0]) -Resources $($args[1])

                $SubResult

            } -ArgumentList $Subscriptions, $Resources | Out-Null
        }
}

function Start-ARIExtraReports {
    Param($File, $QuotaUsage, $SecurityCenter, $SkipPolicy, $SkipAdvisory, $TableStyle, $Debug)
    if ($Debug.IsPresent)
        {
            $DebugPreference = 'Continue'
            $ErrorActionPreference = 'Continue'
        }
    else
        {
            $ErrorActionPreference = "silentlycontinue"
        }

    if($QuotaUsage.IsPresent)
        {
            get-job -Name 'Quota Usage' | Wait-Job

            $AzQuota = Receive-Job -Name 'Quota Usage'

            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Generating Quota Usage sheet for: ' + $AzQuota.count + ' Subscriptions/Regions.')

            Write-Progress -activity 'Azure Resource Inventory Quota Usage' -Status "50% Complete." -PercentComplete 50 -CurrentOperation "Building Quota Sheet"

            Build-ARIQuotaReport -File $File -AzQuota $AzQuota -TableStyle $TableStyle

            Write-Progress -activity 'Azure Resource Inventory Quota Usage' -Status "100% Complete." -Completed
        }

    <################################################ SECURITY CENTER #######################################################>

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Checking if Should Generate Security Center Sheet.')
    if ($SecurityCenter.IsPresent) {
        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Generating Security Center Sheet.')

        while (get-job -Name 'Security' | Where-Object { $_.State -eq 'Running' }) {
            Write-Progress -Id 1 -activity 'Processing Security Center Advisories' -Status "50% Complete." -PercentComplete 50
            Start-Sleep -Seconds 2
        }
        Write-Progress -Id 1 -activity 'Processing Security Center Advisories'  -Status "100% Complete." -Completed

        $Sec = Receive-Job -Name 'Security'

        Build-ARISecCenterReport -File $File -Sec $Sec -TableStyle $TableStyle

    }

    <################################################ POLICY #######################################################>

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Checking if Should Generate Policy Sheet.')
    if (!$SkipPolicy.IsPresent) {
        if(get-job -Name 'Policy')
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
        if (get-job -Name 'Advisory')
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

    $AzSubs = Receive-Job -Name 'Subscriptions'

    Build-ARISubsReport -File $File -Sub $AzSubs -TableStyle $TableStyle

    [System.GC]::GetTotalMemory($true) | out-null

    Write-Progress -activity 'Azure Resource Inventory Subscriptions' -Status "100% Complete." -Completed
}
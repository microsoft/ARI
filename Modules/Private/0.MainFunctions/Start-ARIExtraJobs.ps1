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

    #$ARIModule = 'AzureResourceInventory'
    $ARIModule = 'C:\usr\src\PSModules\AzureResourceInventory\AzureResourceInventory'
    #$ARIModule = 'C:\Users\clvieira\OneDrive - Microsoft\Repos\ARI\ARI\AzureResourceInventory'

    <######################################################### DRAW IO DIAGRAM JOB ######################################################################>

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Checking if Draw.io Diagram Job Should be Run.')
    if (!$SkipDiagram.IsPresent) {
        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting Draw.io Diagram Processing Job.')
        if ($Automation.IsPresent)
            {
                Write-Output "Invoking Draw.Io main function."

                try
                    {
                        Start-ARIDrawIODiagram -Subscriptions $Subscriptions -Resources $Resources -Advisories $Advisories -DDFile $DDFile -DiagramCache $DiagramCache -FullEnvironment $FullEnv -ResourceContainers $ResourceContainers -Automation $Automation -ARIModule $ARIModule
                    }
                catch
                    {
                        Write-Output ($_.Exception.Message)
                    }
            }
        Else
            {
                Start-job -Name 'DrawDiagram' -ScriptBlock {

                    import-module $($args[8])

                    $DiagramCache = $($args[4])
                    $TempPath = $DiagramCache.split("DiagramCache\")[0]
                    $LogFile = ($TempPath+'DiagramLogFile.log')

                    ('DrawIOCoreJob - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Starting Draw.IO Job') | Out-File -FilePath $LogFile -Append
                    try
                        {
                            Start-ARIDrawIODiagram -Subscriptions $($args[0]) -Resources $($args[1]) -Advisories $($args[2]) -DDFile $($args[3]) -DiagramCache $($args[4]) -FullEnvironment $($args[5]) -ResourceContainers $($args[6]) -Automation $($args[7]) -ARIModule $($args[8])
                        }
                    catch
                        {
                            ('DrawIOCoreJob - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+$_.Exception.Message) | Out-File -FilePath $LogFile -Append
                        }
                    ('DrawIOCoreJob - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Draw.IO Ended.') | Out-File -FilePath $LogFile -Append

                } -ArgumentList $Subscriptions, $Resources, $Advisories, $DDFile, $DiagramCache, $FullEnv, $ResourceContainers, $Automation, $ARIModule | Out-Null
            }
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

                        import-module $($args[2])

                        $SecResult = Start-ARISecCenterJob -Subscriptions $($args[0]) -Security $($args[1])

                        $SecResult

                    } -ArgumentList $Subscriptions , $SecurityCenter, $ARIModule | Out-Null
                }
            else
                {
                    Start-Job -Name 'Security' -ScriptBlock {

                        import-module $($args[2])

                        $SecResult = Start-ARISecCenterJob -Subscriptions $($args[0]) -Security $($args[1])

                        $SecResult

                    } -ArgumentList $Subscriptions , $SecurityCenter, $ARIModule | Out-Null
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

                            import-module $($args[4])

                            $PolResult = Start-ARIPolicyJob -Subscriptions $($args[0]) -PolicySetDef $($args[1]) -PolicyAssign $($args[2]) -PolicyDef $($args[3])

                            $PolResult

                        } -ArgumentList $Subscriptions, $PolicySetDef, $PolicyAssign, $PolicyDef, $ARIModule | Out-Null
                    }
                else
                    {
                        Start-Job -Name 'Policy' -ScriptBlock {

                            import-module $($args[4])

                            $PolResult = Start-ARIPolicyJob -Subscriptions $($args[0]) -PolicySetDef $($args[1]) -PolicyAssign $($args[2]) -PolicyDef $($args[3])

                            $PolResult

                        } -ArgumentList $Subscriptions, $PolicySetDef, $PolicyAssign, $PolicyDef, $ARIModule | Out-Null
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

                            import-module $($args[1])

                            $AdvResult = Start-ARIAdvisoryJob -Advisories $($args[0])

                            $AdvResult

                        } -ArgumentList $Advisories, $ARIModule | Out-Null
                    }
                else
                    {
                        Start-Job -Name 'Advisory' -ScriptBlock {

                            import-module $($args[1])

                            $AdvResult = Start-ARIAdvisoryJob -Advisories $($args[0])

                            $AdvResult

                        } -ArgumentList $Advisories, $ARIModule | Out-Null
                    }
            }
    }

    <######################################################### SUBSCRIPTIONS JOB ######################################################################>

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting Subscriptions job.')
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
            Start-Job -Name 'Subscriptions' -ScriptBlock {

                import-module $($args[2])

                $SubResult = Start-ARISubscriptionJob -Subscriptions $($args[0]) -Resources $($args[1])

                $SubResult

            } -ArgumentList $Subscriptions, $Resources, $ARIModule | Out-Null
        }
}
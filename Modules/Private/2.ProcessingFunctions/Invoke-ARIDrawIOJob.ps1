<#
.Synopsis
Module responsible for invoking Draw.IO diagram generation jobs.

.DESCRIPTION
This module starts jobs to generate Draw.IO diagrams for Azure Resources, including resource relationships and advisory data.

.Link
https://github.com/microsoft/ARI/Modules/Private/2.ProcessingFunctions/Invoke-ARIDrawIOJob.ps1

.COMPONENT
This PowerShell Module is part of Azure Resource Inventory (ARI).

.NOTES
Version: 3.6.0
First Release Date: 15th Oct, 2024
Authors: Claudio Merola
#>

function Invoke-ARIDrawIOJob {
    Param($Subscriptions, $Resources, $Advisories, $DDFile, $DiagramCache, $FullEnv, $ResourceContainers, $Automation, $ARIModule)

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
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting Draw.IO Job.')
            Start-job -Name 'DrawDiagram' -ScriptBlock {

                import-module $($args[8])

                $DiagramCache = $($args[4])
                $TempPath = (get-item $DiagramCache).parent
                $LogFile = Join-Path $TempPath 'DiagramLogFile.log'

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
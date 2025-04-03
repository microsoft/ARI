<#
.Synopsis
Module responsible for starting additional processing jobs for Azure Resources.

.DESCRIPTION
This module handles the execution of extra jobs such as Draw.IO diagrams, Security Center processing, Policy evaluations, and Advisory processing for Azure Resources.

.Link
https://github.com/microsoft/ARI/Modules/Private/2.ProcessingFunctions/Start-ARIExtraJobs.ps1

.COMPONENT
This PowerShell Module is part of Azure Resource Inventory (ARI).

.NOTES
Version: 3.6.0
First Release Date: 15th Oct, 2024
Authors: Claudio Merola
#>

function Start-ARIExtraJobs {
    Param ($SkipDiagram, 
            $SkipAdvisory, 
            $SkipPolicy, 
            $SecurityCenter, 
            $Subscriptions, 
            $Resources, 
            $Advisories, 
            $DDFile, 
            $DiagramCache, 
            $FullEnv, 
            $ResourceContainers, 
            $Security, 
            $PolicyDef, 
            $PolicySetDef, 
            $PolicyAssign, 
            $Automation,
            $IncludeCosts,
            $CostData)

    $ARIModule = 'AzureResourceInventory'
    #$ARIModule = 'C:\usr\src\PSModules\AzureResourceInventory\AzureResourceInventory'

    <######################################################### DRAW IO DIAGRAM JOB ######################################################################>

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Checking if Draw.io Diagram Job Should be Run.')
    if (!$SkipDiagram.IsPresent) {
        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting Draw.io Diagram Processing Job.')
        Invoke-ARIDrawIOJob -Subscriptions $Subscriptions -Resources $Resources -Advisories $Advisories -DDFile $DDFile -DiagramCache $DiagramCache -FullEnv $FullEnv -ResourceContainers $ResourceContainers -Automation $Automation -ARIModule $ARIModule
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
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting Security Processing Job.')
            Invoke-ARISecurityCenterJob -Subscriptions $Subscriptions -Automation $Automation -Resources $Resources -SecurityCenter $SecurityCenter -ARIModule $ARIModule
        }

    <######################################################### POLICY JOB ######################################################################>

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Checking If Should Run Policy Job.')
    if (!$SkipPolicy.IsPresent) {
        if (![string]::IsNullOrEmpty($PolicyAssign) -and ![string]::IsNullOrEmpty($PolicyDef))
            {
                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting Policy Processing Job.')
                Invoke-ARIPolicyJob -Subscriptions $Subscriptions -PolicySetDef $PolicySetDef -PolicyAssign $PolicyAssign -PolicyDef $PolicyDef -ARIModule $ARIModule -Automation $Automation
            }
    }

    <######################################################### ADVISORY JOB ######################################################################>

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Checking If Should Run Advisory Job.')
    if (!$SkipAdvisory.IsPresent) {
        if (![string]::IsNullOrEmpty($Advisories))
            {
                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting Advisory Processing Job.')
                Invoke-ARIAdvisoryJob -Advisories $Advisories -ARIModule $ARIModule -Automation $Automation
            }
    }

    <######################################################### SUBSCRIPTIONS JOB ######################################################################>

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting Subscriptions Processing job.')
    Invoke-ARISubJob -Subscriptions $Subscriptions -Automation $Automation -Resources $Resources -CostData $CostData -ARIModule $ARIModule
}
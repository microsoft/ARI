<#
.Synopsis
Diagram Module for Draw.io

.DESCRIPTION
This script processes and creates a Draw.io Diagram based on resources present in the extraction variable $Resources.

.Link
https://github.com/microsoft/ARI/Modules/Public/PublicFunctions/Diagram/Start-ARIDrawIODiagram.ps1

.COMPONENT
This PowerShell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.0
First Release Date: 15th Oct, 2024
Authors: Claudio Merola

#>
function Start-ARIDrawIODiagram {
    param($Subscriptions, $Resources, $Advisories, $DDFile, $DiagramCache, $FullEnvironment, $ResourceContainers, $Automation, $ARIModule)

    $TempPath = (get-item $DiagramCache).parent

    $Logfile = Join-Path $TempPath 'DiagramLogFile.log'

    $ARIModuleVersion = (get-module -Name AzureResourceInventory).Version.ToString()

    ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - ################################################ Starting AzureResourceInventory Diagram ##################################') | Out-File -FilePath $LogFile -Append

    ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - AzureResourceInventory Module Version: ' + $ARIModuleVersion) | Out-File -FilePath $LogFile -Append

    ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Calling Start-ARIDiagramJob Function') | Out-File -FilePath $LogFile -Append

    Start-ARIDiagramJob -Resources $Resources -Automation $Automation

    ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Setting Draw.IO Diagram File') | Out-File -FilePath $LogFile -Append 

    $XMLFiles = @()

    ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Setting XML files to be clean') | Out-File -FilePath $LogFile -Append 

    $XMLFiles += Join-Path $DiagramCache 'Organization.xml'
    $XMLFiles += Join-Path $DiagramCache 'Subscriptions.xml'

    ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Cleaning old files') | Out-File -FilePath $LogFile -Append 

    foreach($File in $XMLFiles)
        {
            Remove-Item -Path $File -ErrorAction SilentlyContinue
        }

    ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Starting Subscription Jobs') | Out-File -FilePath $LogFile -Append 

    if ($Automation.IsPresent) {
        ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Starting Subscription Thread Job') | Out-File -FilePath $LogFile -Append 
        Start-ThreadJob -Name 'Diagram_Subscriptions' -ScriptBlock {
            try
            {
                Start-ARIDiagramSubscription -Subscriptions $($args[0]) -Resources $($args[1]) -DiagramCache $($args[2]) -LogFile $($args[3])
            }
            catch
            {
                ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Error: ' + $_.Exception.Message) | Out-File -FilePath $($args[3]) -Append
            }
        } -ArgumentList $Subscriptions, $Resources, $DiagramCache, $Logfile
    }
    else
    {
        ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Starting Subscription Job') | Out-File -FilePath $LogFile -Append 
        Start-Job -Name 'Diagram_Subscriptions' -ScriptBlock {
            try
                {
                    Import-Module $($args[4])
                    Start-ARIDiagramSubscription -Subscriptions $($args[0]) -Resources $($args[1]) -DiagramCache $($args[2]) -LogFile $($args[3])
                }
            catch
                {
                    ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Error: ' + $_.Exception.Message) | Out-File -FilePath $($args[3]) -Append
                }
        } -ArgumentList $Subscriptions, $Resources, $DiagramCache, $Logfile, $ARIModule
    }

    ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Starting Organization Jobs') | Out-File -FilePath $LogFile -Append 

    if ($Automation.IsPresent) {
        ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Starting Organization Thread Job') | Out-File -FilePath $LogFile -Append 
        Start-ThreadJob -Name 'Diagram_Organization' -ScriptBlock {
            try
            {
                Start-ARIDiagramOrganization -ResourceContainers $($args[0]) -DiagramCache $($args[1]) -LogFile $($args[2])
            }
            catch
            {
                ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Error: ' + $_.Exception.Message) | Out-File -FilePath $($args[2]) -Append
            }
        } -ArgumentList $ResourceContainers, $DiagramCache, $Logfile
    }
    else
    {
        ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Starting Organization Job') | Out-File -FilePath $LogFile -Append 
        Start-Job -Name 'Diagram_Organization' -ScriptBlock {
            try
            {
                Import-Module $($args[3])
                Start-ARIDiagramOrganization -ResourceContainers $($args[0]) -DiagramCache $($args[1]) -LogFile $($args[2])
            }
            catch
            {
                ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Error: ' + $_.Exception.Message) | Out-File -FilePath $($args[2]) -Append
            }
        } -ArgumentList $ResourceContainers, $DiagramCache, $Logfile, $ARIModule
    }

    ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Waiting Variables Job to Continue') | Out-File -FilePath $LogFile -Append 

    Get-Job -Name 'DiagramVariables' | Wait-Job

    $Job = Receive-Job -Name 'DiagramVariables'

    Get-Job -Name 'DiagramVariables' | Remove-Job

    ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Starting Network Topology Jobs') | Out-File -FilePath $LogFile -Append 

    if ($Automation.IsPresent) {
        ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Starting Network Topology Thread Job') | Out-File -FilePath $LogFile -Append 
        Start-ThreadJob -Name 'Diagram_NetworkTopology' -ScriptBlock {
            try
            {
                Start-ARIDiagramNetwork -Subscriptions $($args[0]) -Job $($args[1]) -Advisories $($args[2]) -DiagramCache $($args[3]) -FullEnvironment $($args[4]) -DDFile $($args[5]) -XMLFiles $($args[6]) -LogFile $($args[7]) -Automation $($args[8])
            }
            catch
            {
                ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Error: ' + $_.Exception.Message) | Out-File -FilePath $($args[7]) -Append
            }
        } -ArgumentList $Subscriptions, $Job, $Advisories, $DiagramCache, $FullEnvironment, $DDFile, $XMLFiles, $Logfile, $Automation
    }
    else
    {
        ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Starting Network Topology Job') | Out-File -FilePath $LogFile -Append 
        Start-Job -Name 'Diagram_NetworkTopology' -ScriptBlock {
            try
            {
                Import-Module $($args[9])
                Start-ARIDiagramNetwork -Subscriptions $($args[0]) -Job $($args[1]) -Advisories $($args[2]) -DiagramCache $($args[3]) -FullEnvironment $($args[4]) -DDFile $($args[5]) -XMLFiles $($args[6]) -LogFile $($args[7]) -Automation $($args[8]) -ARIModule $($args[9])
            }
            catch
            {
                ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Error: ' + $_.Exception.Message) | Out-File -FilePath $($args[7]) -Append
            }
        } -ArgumentList $Subscriptions, $Job, $Advisories, $DiagramCache, $FullEnvironment, $DDFile, $XMLFiles, $Logfile, $Automation, $ARIModule
    }

    ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Waiting for Jobs') | Out-File -FilePath $LogFile -Append 

    (Get-Job | Where-Object {$_.name -like 'Diagram_*'}) | Wait-Job

    ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Merging XML Files') | Out-File -FilePath $LogFile -Append 
    Set-ARIDiagramFile -XMLFiles $XMLFiles -DDFile $DDFile -LogFile $LogFile

    ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Getting Log Details from Jobs') | Out-File -FilePath $LogFile -Append

    Foreach ($DiagramJob in (Get-Job | Where-Object {$_.name -like 'Diagram_*'})) {
        $Logger = Receive-Job -Name $DiagramJob.Name
        Foreach ($LogEntry in $Logger) {
            $LogEntry | Out-File -FilePath $LogFile -Append
        }
    }

    ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Removing old jobs') | Out-File -FilePath $LogFile -Append

    (Get-Job | Where-Object {$_.name -like 'Diagram_*'}) | Remove-Job

    ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Diagram Complete') | Out-File -FilePath $LogFile -Append 
}

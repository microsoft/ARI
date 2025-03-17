<#
.Synopsis
Diagram Module for Draw.io

.DESCRIPTION
This script process and creates a Draw.io Diagram based on resources present in the extraction variable $Resources. 

.Link
https://github.com/microsoft/ARI/Modules/Public/PublicFunctions/Diagram/Start-ARIDrawIODiagram.psm1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.0
First Release Date: 15th Oct, 2024
Authors: Claudio Merola 

#>
function Start-ARIDrawIODiagram {
    param($Subscriptions, $Resources, $Advisories, $DDFile, $DiagramCache, $FullEnvironment, $ResourceContainers, $Automation, $ARIModule)

    $TempPath = (get-item $DiagramCache).parent

    $Logfile = Join-Path $TempPath 'DiagramLogFile.log'

    ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Calling Start-ARIDiagramJob Function') | Out-File -FilePath $LogFile -Append

    Write-Output "Starting Draw.IO Diagram"

    Start-ARIDiagramJob -Resources $Resources -Automation $Automation

    ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Starting Draw.IO file') | Out-File -FilePath $LogFile -Append 

    $XMLFiles = @()

    ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Setting XML files to be clean') | Out-File -FilePath $LogFile -Append 

    $XMLFiles += Join-Path $DiagramCache 'Organization.xml'
    $XMLFiles += Join-Path $DiagramCache 'Subscriptions.xml'

    ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Cleaning old files') | Out-File -FilePath $LogFile -Append 

    Write-Output "Cleaning old files"

    foreach($File in $XMLFiles)
        {
            Remove-Item -Path $File -ErrorAction SilentlyContinue
        }

    ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Starting Subscription Jobs') | Out-File -FilePath $LogFile -Append 

    if ($Automation.IsPresent) {
        ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Starting Subscription Thread Job') | Out-File -FilePath $LogFile -Append 
        Start-ThreadJob -Name 'Diagram_Subscriptions' -ScriptBlock {
            Start-ARIDiagramSubscription -Subscriptions $($args[0]) -Resources $($args[1]) -DiagramCache $($args[2]) -LogFile $($args[3])
        } -ArgumentList $Subscriptions, $Resources, $DiagramCache, $Logfile
    }
    else
    {
        ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Starting Subscription Job') | Out-File -FilePath $LogFile -Append 
        Start-Job -Name 'Diagram_Subscriptions' -ScriptBlock {
            Import-Module $($args[4])
            Start-ARIDiagramSubscription -Subscriptions $($args[0]) -Resources $($args[1]) -DiagramCache $($args[2]) -LogFile $($args[3])
        } -ArgumentList $Subscriptions, $Resources, $DiagramCache, $Logfile, $ARIModule
    }

    ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Starting Organization Jobs') | Out-File -FilePath $LogFile -Append 

    if ($Automation.IsPresent) {
        ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Starting Organization Thread Job') | Out-File -FilePath $LogFile -Append 
        Start-ThreadJob -Name 'Diagram_Organization' -ScriptBlock {
            Start-ARIDiagramOrganization -ResourceContainers $($args[0]) -DiagramCache $($args[1]) -LogFile $($args[2])
        } -ArgumentList $ResourceContainers, $DiagramCache, $Logfile
    }
    else
    {
        ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Starting Organization Job') | Out-File -FilePath $LogFile -Append 
        Start-Job -Name 'Diagram_Organization' -ScriptBlock {
            Import-Module $($args[3])
            Start-ARIDiagramOrganization -ResourceContainers $($args[0]) -DiagramCache $($args[1]) -LogFile $($args[2])
        } -ArgumentList $ResourceContainers, $DiagramCache, $Logfile, $ARIModule
    }

    ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Waiting Variables Job to complete') | Out-File -FilePath $LogFile -Append 

    Get-Job -Name 'DiagramVariables' | Wait-Job

    $Job = Receive-Job -Name 'DiagramVariables'

    Get-Job -Name 'DiagramVariables' | Remove-Job

    ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Starting Network Topology Jobs') | Out-File -FilePath $LogFile -Append 

    if ($Automation.IsPresent) {
        ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Starting Network Topology Thread Job') | Out-File -FilePath $LogFile -Append 
        Start-ThreadJob -Name 'Diagram_NetworkTopology' -ScriptBlock {
            Start-ARIDiagramNetwork -Subscriptions $($args[0]) -Job $($args[1]) -Advisories $($args[2]) -DiagramCache $($args[3]) -FullEnvironment $($args[4]) -DDFile $($args[5]) -XMLFiles $($args[6]) -LogFile $($args[7]) -Automation $($args[8])
        } -ArgumentList $Subscriptions, $Job, $Advisories, $DiagramCache, $FullEnvironment, $DDFile, $XMLFiles, $Logfile, $Automation
    }
    else
    {
        ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Starting Network Topology Job') | Out-File -FilePath $LogFile -Append 
        Start-Job -Name 'Diagram_NetworkTopology' -ScriptBlock {
            Import-Module $($args[9])
            Start-ARIDiagramNetwork -Subscriptions $($args[0]) -Job $($args[1]) -Advisories $($args[2]) -DiagramCache $($args[3]) -FullEnvironment $($args[4]) -DDFile $($args[5]) -XMLFiles $($args[6]) -LogFile $($args[7]) -Automation $($args[8]) -ARIModule $($args[9])
        } -ArgumentList $Subscriptions, $Job, $Advisories, $DiagramCache, $FullEnvironment, $DDFile, $XMLFiles, $Logfile, $Automation, $ARIModule
    }

    ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Waiting for Jobs to complete') | Out-File -FilePath $LogFile -Append 

    (Get-Job | Where-Object {$_.name -like 'Diagram_*'}) | Wait-Job

    ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Starting to process files') | Out-File -FilePath $LogFile -Append 

    if($Automation.IsPresent)
        {
            Start-ThreadJob -Name 'DiagramFile_Process' -ScriptBlock {
                #Set-ARIDiagramFile -XMLFiles $($args[0]) -DDFile $($args[1]) -LogFile $($args[2])
            } -ArgumentList $XMLFiles, $DDFile, $LogFile
        }
    else
        {
            Set-ARIDiagramFile -XMLFiles $XMLFiles -DDFile $DDFile -LogFile $LogFile
        }

    ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Cleaning old jobs') | Out-File -FilePath $LogFile -Append 

    (Get-Job | Where-Object {$_.name -like 'Diagram_*'}) | Remove-Job

    ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Diagram Complete') | Out-File -FilePath $LogFile -Append 
}

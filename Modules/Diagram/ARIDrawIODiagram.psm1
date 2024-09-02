<#
.Synopsis
Diagram Module for Draw.io

.DESCRIPTION
This script process and creates a Draw.io Diagram based on resources present in the extraction variable $Resources. 

.Link
https://github.com/microsoft/ARI/Modules/Extras/DrawIODiagram.psm1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 4.0.1
First Release Date: 15th Oct, 2024
Authors: Claudio Merola 

#>
function Invoke-ARIDrawIODiagram {
    param($Subscriptions, $Resources, $Advisories, $DDFile, $DiagramCache, $FullEnvironment, $ResourceContainers)

    $TempPath = $DiagramCache.split("DiagramCache\")[0]

    $Logfile = ($TempPath+'DiagramLogFile.log')

    ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Starting Draw.IO file') | Out-File -FilePath $LogFile -Append 

    $XMLFiles = @()

    ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Setting XML files to be clean') | Out-File -FilePath $LogFile -Append 

    $XMLFiles += ($DiagramCache+'Organization.xml')
    $XMLFiles += ($DiagramCache+'Subscriptions.xml')

    ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Cleaning old files') | Out-File -FilePath $LogFile -Append 

    foreach($File in $XMLFiles)
        {
            Remove-Item -Path $File -ErrorAction SilentlyContinue
        }

    ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Starting Organization Function') | Out-File -FilePath $LogFile -Append 

    Invoke-ARIDiagramOrganization -ResourceContainers $ResourceContainers -DiagramCache $DiagramCache -LogFile $Logfile

    ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Starting Network Topology Function') | Out-File -FilePath $LogFile -Append 

    Invoke-ARIDiagramNetwork -Subscriptions $Subscriptions -Resources $Resources -Advisories $Advisories -DiagramCache $DiagramCache -FullEnvironment $FullEnvironment -DDFile $DDFile -XMLFiles $XMLFiles -LogFile $Logfile

    ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Starting Subscription Function') | Out-File -FilePath $LogFile -Append 

    Invoke-ARIDiagramSubscription -Subscriptions $Subscriptions -Resources $Resources -DiagramCache $DiagramCache -LogFile $Logfile

    ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Waiting for Jobs to complete') | Out-File -FilePath $LogFile -Append 

    (Get-Job | Where-Object {$_.name -like 'Diagram_*'}) | Wait-Job

    ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Starting to process files') | Out-File -FilePath $LogFile -Append 

    foreach($File in $XMLFiles)
        {
            $oldxml = New-Object XML
            $oldxml.Load($File)

            $newxml = New-Object XML
            $newxml.Load($DDFile)

            $oldxml.DocumentElement.InsertAfter($oldxml.ImportNode($newxml.SelectSingleNode('mxfile'), $true), $afternode)

            $oldxml.Save($DDFile)

            Remove-Item -Path $File
        }

    ('DrawIOCoreFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Cleaning old jobs') | Out-File -FilePath $LogFile -Append 

    (Get-Job | Where-Object {$_.name -like 'Diagram_*'}) | Remove-Job
}

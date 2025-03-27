<#
.Synopsis
File Module for Draw.io Diagram

.DESCRIPTION
This module is used for setting and managing files in the Draw.io Diagram.

.Link
https://github.com/microsoft/ARI/Modules/Public/PublicFunctions/Diagram/Set-ARIDiagramFile.ps1

.COMPONENT
This PowerShell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.0
First Release Date: 15th Oct, 2024
Authors: Claudio Merola

#>
function Set-ARIDiagramFile {
    Param ($XMLFiles, $DDFile, $LogFile)
    try 
    {
        ('DrawIOFileJob - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Merging XML Files ') | Out-File -FilePath $LogFile -Append 
        foreach($File in $XMLFiles)
        {
            $oldxml = New-Object XML
            $oldxml.Load($File)

            $newxml = New-Object XML
            $newxml.Load($DDFile)

            $oldxml.DocumentElement.InsertAfter($oldxml.ImportNode($newxml.SelectSingleNode('mxfile'), $true), $afternode)

            $oldxml.Save($DDFile)

            Remove-Item -Path $File

            Start-Sleep -Milliseconds 200
        }
    }
    catch
    {
        ('DrawIOFileJob - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Error: ' + $_.Exception.Message) | Out-File -FilePath $LogFile -Append 
    }
}
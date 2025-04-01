<#
.Synopsis
Set up folders for Azure Resource Inventory

.DESCRIPTION
This module creates and validates the necessary folders for Azure Resource Inventory.

.Link
https://github.com/microsoft/ARI/Modules/Private/0.MainFunctions/Set-ARIFolder.ps1

.COMPONENT
This PowerShell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.0
First Release Date: 15th Oct, 2024
Authors: Claudio Merola

#>
function Set-ARIFolder {
    Param($DefaultPath, $DiagramCache, $ReportCache)

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Checking report folder: ' + $DefaultPath )
    try {
        if ((Test-Path -Path $DefaultPath -PathType Container) -eq $false) {
            New-Item -Type Directory -Force -Path $DefaultPath | Out-Null
        }
        if ((Test-Path -Path $DiagramCache -PathType Container) -eq $false) {
            New-Item -Type Directory -Force -Path $DiagramCache | Out-Null
        }
        if ((Test-Path -Path $ReportCache -PathType Container) -eq $false) {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Creating Folder for Cache Files.')
            New-Item -Type Directory -Force -Path $ReportCache | Out-Null
        }
    }
    catch
        {
            Write-Output ($_.Exception.Message)
        }
    
}
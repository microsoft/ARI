<#
.Synopsis
Clear cache folder for Azure Resource Inventory

.DESCRIPTION
This module clears the cache folder for Azure Resource Inventory.

.Link
https://github.com/microsoft/ARI/Modules/Private/0.MainFunctions/Clear-ARICacheFolder.ps1

.COMPONENT
This PowerShell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.0
First Release Date: 15th Oct, 2024
Authors: Claudio Merola

#>

function Clear-ARICacheFolder {
    Param($ReportCache)

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Clearing Cache Folder.')
    $CacheFiles = Get-ChildItem -Path $ReportCache -Recurse
    Foreach ($CacheFile in $CacheFiles)
        {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Removing Cache File: '+$CacheFile.FullName)
            Remove-Item -Path $CacheFile.FullName -Force
        }
}
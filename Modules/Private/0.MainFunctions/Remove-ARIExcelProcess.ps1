<#
.Synopsis
Forcefully stops Excel process.

.DESCRIPTION
This module forcefully stops the Excel process.

.Link
https://github.com/microsoft/ARI/Modules/Private/0.MainFunctions/Remove-ARIExcelProcess.ps1

.COMPONENT
This PowerShell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.0
First Release Date: 15th Oct, 2024
Authors: Claudio Merola

#>

function Remove-ARIExcelProcess {

    if (Get-Process -Name "excel" -ErrorAction Ignore | Where-Object { $_.CommandLine -like '*/automation*' } )
        {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss') + ' - Stopping Excel process.')
            Get-Process -Name "excel" -ErrorAction Ignore | Where-Object { $_.CommandLine -like '*/automation*' } | Stop-Process -Force
        }
}
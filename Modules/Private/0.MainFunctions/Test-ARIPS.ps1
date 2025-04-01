<#
.Synopsis
Test Powershell environment

.DESCRIPTION
This module is used to test and validate the Powershell environment.

.Link
https://github.com/microsoft/ARI/Modules/Private/0.MainFunctions/Test-ARIPS.ps1

.COMPONENT
This PowerShell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.0
First Release Date: 15th Oct, 2024
Authors: Claudio Merola

#>
function Test-ARIPS {
    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting Test-ARIPS function')
    $CShell = try{Get-CloudShellTip}catch{$null}
    if ($CShell) {
        Write-Host 'Azure CloudShell Identified.' -ForegroundColor Cyan
        $PlatOS          = 'Azure CloudShell'
    }
    else
    {
        if ($PSVersionTable.Platform -eq 'Unix') {
            Write-Host "PowerShell Unix Identified." -ForegroundColor Cyan
            $PlatOS          = 'PowerShell Unix'

        }
        else {
            Write-Host "PowerShell Desktop Identified." -ForegroundColor Cyan
            $PlatOS          = 'PowerShell Desktop'

        }
    }
    return $PlatOS
}
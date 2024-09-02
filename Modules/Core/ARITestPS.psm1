<#
.Synopsis
Test Powershell environment

.DESCRIPTION
This module is use to test and validate the Powershell environment.

.Link
https://github.com/microsoft/ARI/Modules/Core/Test-ARIPS.psm1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 4.0.1
First Release Date: 15th Oct, 2024
Authors: Claudio Merola

#>
function Test-ARIPS {
    Param($Debug)
    if ($Debug.IsPresent)
        {
            $DebugPreference = 'Continue'
            $ErrorActionPreference = 'Continue'
        }
    else
        {
            $ErrorActionPreference = "silentlycontinue"
        }
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
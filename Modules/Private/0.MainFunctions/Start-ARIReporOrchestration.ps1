<#
.Synopsis
Main module for Excel Report Building

.DESCRIPTION
This module is the main module for building the Excel Report.

.Link
https://github.com/microsoft/ARI/Modules/Inventory/ARIResourceReport.psm1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.5.1
First Release Date: 15th Oct, 2024
Authors: Claudio Merola

#>
Function Start-ARIReporOrchestration {
    Param($ReportCache,
    $SecurityCenter,
    $File,
    $Quotas,
    $SkipPolicy,
    $SkipAdvisory,
    $Automation,
    $DataActive,
    $TableStyle,
    $Debug)

    if ($Debug.IsPresent)
        {
            $DebugPreference = 'Continue'
            $ErrorActionPreference = 'Continue'
        }
    else
        {
            $ErrorActionPreference = "silentlycontinue"
        }

    <############################################################## REPORT CREATION ###################################################################>

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting Resource Reporting Cache.')
    Start-ARIExcelJob -ReportCache $ReportCache -DataActive $DataActive -TableStyle $TableStyle -File $File -Debug $Debug

    <############################################################## EXTRA REPORTS ###################################################################>

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting Default Data Reporting.')

    Start-ARIExtraReports -File $File -Quotas $Quotas -SecurityCenter $SecurityCenter -SkipPolicy $SkipPolicy -SkipAdvisory $SkipAdvisory -TableStyle $TableStyle -Debug $Debug

}
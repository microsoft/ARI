<#
.Synopsis
Module for Subscription Report

.DESCRIPTION
This script processes and creates the Subscription sheet in the Excel report.

.Link
https://github.com/microsoft/ARI/Modules/Private/3.ReportingFunctions/Build-ARISubsReport.ps1

.COMPONENT
This PowerShell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.0
First Release Date: 15th Oct, 2024
Authors: Claudio Merola
#>

function Build-ARISubsReport {
    param($File, $Sub, $TableStyle)
    $TableName = ('SubsTable_'+($Sub.Subscription | Select-Object -Unique).count)
    $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

    $Sub |
        ForEach-Object { [PSCustomObject]$_ } |
        Select-Object 'Subscription',
        'Resource Group',
        'Location',
        'Resource Type',
        'Resources' | Export-Excel -Path $File -WorksheetName 'Subscriptions' -TableName $TableName -AutoSize -MaxAutoSizeRows 100 -TableStyle $TableStyle -Style $Style -Numberformat '0' -MoveToEnd
}
<#
.Synopsis
Module for Advisory Report

.DESCRIPTION
This script processes and creates the Advisory sheet in the Excel report.

.Link
https://github.com/microsoft/ARI/Modules/Private/3.ReportingFunctions/Build-ARIAdvisoryReport.ps1

.COMPONENT
This PowerShell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.0
First Release Date: 15th Oct, 2024
Authors: Claudio Merola
#>

function Build-ARIAdvisoryReport {
    param($File, $Adv, $TableStyle)
    $condtxtadv = @()
    $condtxtadv += New-ConditionalText High -Range E:E
    $condtxtadv += New-ConditionalText Security -Range D:D -BackgroundColor Wheat

    $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '#,##0.00' -Range H:H

    [PSCustomObject]$Adv |
    ForEach-Object { $_ } |
    Select-Object 'ResourceGroup',
    'Affected Resource Type',
    'Name',
    'Category',
    'Impact',
    #'Score',
    'Problem',
    'Savings Currency',
    'Annual Savings',
    'Savings Region',
    'Current SKU',
    'Target SKU' |
    Export-Excel -Path $File -WorksheetName 'Advisor' -AutoSize -MaxAutoSizeRows 100 -TableName 'AzureAdvisory' -MoveToStart -TableStyle $tableStyle -Style $Style -ConditionalText $condtxtadv
}
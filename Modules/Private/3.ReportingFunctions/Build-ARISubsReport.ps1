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
    param($File, $Sub, $IncludeCosts, $TableStyle)
    $TableName = ('SubsTable_'+($Sub.Subscription | Select-Object -Unique).count)

    if ($IncludeCosts.IsPresent)
        {
            $Style = @() 
            $Style += New-ExcelStyle -AutoSize -HorizontalAlignment Center -NumberFormat '0'
            $Style += New-ExcelStyle -Width 55 -NumberFormat '$#,#########0.000000000' -Range J:J
            $Style += New-ExcelStyle -AutoSize -NumberFormat '$#,##0.00' -Range I:I
            [PSCustomObject]$Sub |
                ForEach-Object { $_ } |
                Select-Object 'Subscription',
                'Resource Group',
                'Location',
                'Resource Type',
                'Service Name',
                'Currency',
                'Month',
                'Year',
                'Cost',
                'Detailed Cost' | Export-Excel -Path $File -WorksheetName 'Subscriptions' -TableName $TableName -TableStyle $TableStyle -Style $Style

        }
    else
        {
            $Style = New-ExcelStyle -HorizontalAlignment Center -NumberFormat '0'
            [PSCustomObject]$Sub |
                ForEach-Object { $_ } |
                Select-Object 'Subscription',
                'Resource Group',
                'Location',
                'Resource Type',
                'Resources Count' | Export-Excel -Path $File -WorksheetName 'Subscriptions' -TableName $TableName -AutoSize -MaxAutoSizeRows 100 -TableStyle $TableStyle -Style $Style
        }

}
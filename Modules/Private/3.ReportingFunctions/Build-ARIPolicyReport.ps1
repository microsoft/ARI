<#
.Synopsis
Module for Policy Report

.DESCRIPTION
This script processes and creates the Policy sheet in the Excel report.

.Link
https://github.com/microsoft/ARI/Modules/Private/3.ReportingFunctions/Build-ARIPolicyReport.ps1

.COMPONENT
This PowerShell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.0
First Release Date: 15th Oct, 2024
Authors: Claudio Merola
#>

function Build-ARIPolicyReport {
    param($File ,$Pol, $TableStyle)
    if ($Pol)
        {
            $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

            $condtxt = @()
            $condtxt += New-ConditionalText -Range B2:B500 -ConditionalType GreaterThan 0
            $condtxt += New-ConditionalText -Range C2:C500 -ConditionalType GreaterThan 0
            $condtxt += New-ConditionalText -Range H2:H500 -ConditionalType GreaterThan 0

            [PSCustomObject]$Pol |
            ForEach-Object { $_ } |
            Select-Object 'Initiative',
            'Initiative Non Compliance Resources',
            'Initiative Non Compliance Policies',
            'Policy',
            'Policy Type',
            'Effect',
            'Compliance Resources',
            'Non Compliance Resources',
            'Unknown Resources',
            'Exempt Resources',
            'Policy Mode',
            'Policy Version',
            'Policy Deprecated',
            'Policy Category' | Export-Excel -Path $File -WorksheetName 'Policy' -AutoSize -MaxAutoSizeRows 100 -TableName 'AzurePolicy' -MoveToStart -ConditionalText $condtxt -TableStyle $tableStyle -Style $Style
        }
}
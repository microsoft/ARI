<#
.Synopsis
Module for Quota Report

.DESCRIPTION
This script processes and creates the Quota Usage sheet in the Excel report.

.Link
https://github.com/microsoft/ARI/Modules/Private/3.ReportingFunctions/Build-ARIQuotaReport.ps1

.COMPONENT
This PowerShell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.0
First Release Date: 15th Oct, 2024
Authors: Claudio Merola
#>

function Build-ARIQuotaReport {
    param($File, $AzQuota, $TableStyle)

    $Total = ($AzQuota.properties.Data).count
    $tmp = foreach($Quota in $AzQuota.properties)
    {
        foreach($Data in $Quota.Data)
            {
                $FreevCPU = ''
                if($Data.Name.LocalizedValue -like '*vCPUs'){$FreevCPU = $Data.limit - $Data.CurrentValue}
                $obj = @{
                    'Subscription' = $Quota.Subscription;
                    'Region' = $Quota.Location;
                    'Current Usage' = $Data.currentValue;
                    'Limit' = $Data.limit;
                    'Quota' = $Data.Name.LocalizedValue;
                    'vCPUs Available' = $FreevCPU;
                    'Total' = $Total
                }
                $obj
            }
    }

    $ExcelVar = $tmp

    $TableName = ('QuotaTable_'+$ExcelVar[0].Total)
    [PSCustomObject]$ExcelVar |
    ForEach-Object { $_ } |
    Select-Object -Unique 'Subscription',
    'Region',
    'Current Usage',
    'Limit',
    'Quota',
    'vCPUs Available' |
    Export-Excel -Path $File -WorksheetName 'Quota Usage' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $TableStyle -Numberformat '0' -MoveToEnd
}
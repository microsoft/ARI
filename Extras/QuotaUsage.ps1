<#
.Synopsis
vCPU Quotas Module

.DESCRIPTION
This script process and creates the Quota sheet based on Quotas Used. 

.Link
https://github.com/azureinventory/ARI/Extras/QuotaUsage.ps1

.COMPONENT
   This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 2.0.0
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>
param($File, $AzQuota, $TableStyle)

$tmp = @()
foreach($Quota in $AzQuota)
{
    foreach($Data in $Quota.Data)
        {
            $FreevCPU = ''
            if($Data.localName -like '*vCPUs'){$FreevCPU = $Data.limit - $Data.currentValue}
            $obj = @{
                'Subscription' = $Quota.Subscription;
                'Region' = $Quota.Location;
                'Current Usage' = $Data.currentValue;
                'Limit' = $Data.limit;
                'Quota' = $Data.localName;
                'vCPUs Available' = $FreevCPU;
            }
            $tmp += $obj
        }
}

        $ExcelVar = $tmp

            $ExcelVar | 
            ForEach-Object { [PSCustomObject]$_ } | 
            Select-Object -Unique 'Subscription',         
            'Region',
            'Current Usage',
            'Limit',
            'Quota',
            'vCPUs Available' | 
            Export-Excel -Path $File -WorksheetName 'Quota Usage' -AutoSize -MaxAutoSizeRows 100 -TableName 'Quota' -TableStyle $tableStyle -Numberformat '0' -MoveToEnd



                
<#
.Synopsis
Inventory for Azure SQLPOOL

.DESCRIPTION
This script consolidates information for all microsoft.sql/servers/elasticPools resource provider in $Resources variable. 
Excel Sheet Name: SQLPOOL

.Link
https://github.com/microsoft/ARI/Modules/Data/SQLPOOL.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 2.2.0
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Task , $File, $SmaResources, $TableStyle) 

if ($Task -eq 'Processing') {

    $SQLPOOL = $Resources | Where-Object { $_.TYPE -eq 'microsoft.sql/servers/elasticPools' }

    if($SQLPOOL)
        {
            $tmp = @()

            foreach ($1 in $SQLPOOL) {          
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                
                $metricStartTime = (Get-Date).AddDays(-30)
                $metricEndTime = (Get-Date)
 
                $allocateDataStorage = (Get-AzMetric -ResourceId $1.id -StartTime $metricStartTime -EndTime $metricEndTime -MetricName 'allocated_data_storage' -AggregationType Average -TimeGrain "01:00:00").Data.Average | Sort-Object -Descending
                $allocateDataStorageMax = ($allocateDataStorage | Measure-Object -Maximum).Maximum -as [double]
                
                $allocateDataStoragePercent = (Get-AzMetric -ResourceId $1.id -StartTime $metricStartTime -EndTime $metricEndTime -MetricName 'allocated_data_storage_percent' -AggregationType Maximum -TimeGrain "01:00:00").Data.Maximum | Sort-Object -Descending
                $allocateDataStoragePercentAvg = ($allocateDataStoragePercent | Measure-Object -Maximum).Maximum -as [double]
                
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) {
                        $obj = @{
                            'ID'                         = $1.id;
                            'Subscription'               = $sub1.Name;
                            'Resource Group'             = $1.RESOURCEGROUP;
                            'Name'                       = $1.NAME;
                            'Location'                   = $1.LOCATION;
                            'Capacity'                   = $1.sku.Capacity;
                            'Sku'                        = $1.sku.name;
                            'Size'                       = $1.sku.size;
                            'Tier'                       = $1.sku.tier;
                            'Replica Count'              = $data.highAvailabilityReplicaCount;
                            'License'                    = $data.licenseType;
                            'Min Capacity'               = $data.minCapacity;
                            'Max Capacity'               = (($data.maxSizeBytes / 1024) / 1024) / 1024;
                            'DB Max Capacity'            = $data.perDatabaseSettings.maxCapacity;
                            'DB Min Capacity'            = $data.perDatabaseSettings.minCapacity;
                            'Zone Redundant'             = $data.zoneRedundant;
                            'Allocated Storage'          = $allocateDataStorageMax;
                            'Allocated Storage Percent'  = $allocateDataStoragePercentAvg;
                            'Tag Name'                   = [string]$Tag.Name;
                            'Tag Value'                  = [string]$Tag.Value;
                        }
                        
                        $tmp += $obj
                        if ($ResUCount -eq 1) { $ResUCount = 0 } 
                    }               
            }
            $tmp
        }
}
else {
    if ($SmaResources.SQLPOOL) {

        $TableName = ('SqlPoolTable_'+($SmaResources.SQLPOOL.id | Select-Object -Unique).count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0
        
        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('Capacity')
        $Exc.Add('Sku')
        $Exc.Add('Size')
        $Exc.Add('Tier')
        $Exc.Add('Replica Count')
        $Exc.Add('License')
        $Exc.Add('Min Capacity')
        $Exc.Add('Max Capacity')
        $Exc.Add('DB Min Capacity')
        $Exc.Add('DB Max Capacity')
        $Exc.Add('Zone Redundant')        
        $Exc.Add('Allocated Storage')
        $Exc.Add('Allocated Storage Percent')
        
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.SQLPOOL 

        $ExcelVar | 
        ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        Export-Excel -Path $File -WorksheetName 'SQL Pools' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -Style $Style
    }
}

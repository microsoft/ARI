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
                
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) {
                        $obj = @{
                            'ID'                         = $1.id;
                            'Subscription'               = $sub1.Name;
                            'Resource Group'             = $1.RESOURCEGROUP;
                            'Name'                       = $1.NAME;
                            'Location'                   = $1.LOCATION;
                            'Capacity'                   = $1.sku.capacity;
                            'Sku Name'                   = $1.sku.name;
                            'Edition'                    = $1.sku.tier;
                            'State'                      = $data.state;
                            'License'                    = $data.licenseType;
                            'Max Size (GB)'              = (($data.maxSizeBytes / 1024) / 1024) / 1024;
                            'DB Max DTU'                 = $data.perDatabaseSettings.maxCapacity;
                            'DB Min DTU'                 = $data.perDatabaseSettings.minCapacity;
                            'Zone Redundant'             = $data.zoneRedundant;
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
        $Exc.Add('Sku Name')
        $Exc.Add('Edition')
        $Exc.Add('License')
        $Exc.Add('DB Min DTU')
        $Exc.Add('DB Max DTU')
        $Exc.Add('Max Size (GB)')
        $Exc.Add('Zone Redundant')        
        
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

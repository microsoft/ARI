<#
.Synopsis
Inventory for Azure SQLPOOL

.DESCRIPTION
This script consolidates information for all microsoft.sql/servers/elasticPools resource provider in $Resources variable. 
Excel Sheet Name: SQLPOOL

.Link
https://github.com/microsoft/ARI/Modules/Public/InventoryModules/Database/SQLPOOL.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.0
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Retirements, $Task ,$File, $SmaResources, $TableStyle, $Unsupported)

if ($Task -eq 'Processing') {

    $SQLPOOL = $Resources | Where-Object { $_.TYPE -eq 'microsoft.sql/servers/elasticPools' }

    if($SQLPOOL)
        {
            $tmp = foreach ($1 in $SQLPOOL) {          
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $Retired = $Retirements | Where-Object { $_.id -eq $1.id }
                if ($Retired) 
                    {
                        $RetiredFeature = foreach ($Retire in $Retired)
                            {
                                $RetiredServiceID = $Unsupported | Where-Object {$_.Id -eq $Retired.ServiceID}
                                $tmp0 = [pscustomobject]@{
                                        'RetiredFeature'            = $RetiredServiceID.RetiringFeature
                                        'RetiredDate'               = $RetiredServiceID.RetirementDate 
                                    }
                                $tmp0
                            }
                        $RetiringFeature = if ($RetiredFeature.RetiredFeature.count -gt 1) { $RetiredFeature.RetiredFeature | ForEach-Object { $_ + ' ,' } }else { $RetiredFeature.RetiredFeature}
                        $RetiringFeature = [string]$RetiringFeature
                        $RetiringFeature = if ($RetiringFeature -like '* ,*') { $RetiringFeature -replace ".$" }else { $RetiringFeature }

                        $RetiringDate = if ($RetiredFeature.RetiredDate.count -gt 1) { $RetiredFeature.RetiredDate | ForEach-Object { $_ + ' ,' } }else { $RetiredFeature.RetiredDate}
                        $RetiringDate = [string]$RetiringDate
                        $RetiringDate = if ($RetiringDate -like '* ,*') { $RetiringDate -replace ".$" }else { $RetiringDate }
                    }
                else 
                    {
                        $RetiringFeature = $null
                        $RetiringDate = $null
                    }
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) {
                        $obj = @{
                            'ID'                         = $1.id;
                            'Subscription'               = $sub1.Name;
                            'Resource Group'             = $1.RESOURCEGROUP;
                            'Name'                       = $1.NAME;
                            'Location'                   = $1.LOCATION;
                            'Retiring Feature'           = $RetiringFeature;
                            'Retiring Date'              = $RetiringDate;
                            'Capacity'                   = $1.sku.capacity;
                            'Sku Name'                   = $1.sku.name;
                            'Edition'                    = $1.sku.tier;
                            'State'                      = $data.state;
                            'License'                    = $data.licenseType;
                            'Max Size (GB)'              = (($data.maxSizeBytes / 1024) / 1024) / 1024;
                            'DB Max DTU'                 = $data.perDatabaseSettings.maxCapacity;
                            'DB Min DTU'                 = $data.perDatabaseSettings.minCapacity;
                            'Zone Redundant'             = $data.zoneRedundant;
                            'Resource U'                = $ResUCount;
                            'Tag Name'                   = [string]$Tag.Name;
                            'Tag Value'                  = [string]$Tag.Value;
                        }
                        $obj
                        if ($ResUCount -eq 1) { $ResUCount = 0 } 
                    }               
            }
            $tmp
        }
}
else {
    if ($SmaResources) {

        $TableName = ('SqlPoolTable_'+($SmaResources.'Resource U').count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

        $condtxt = @()
        #Retirement
        $condtxt += New-ConditionalText -Range E2:E100 -ConditionalType ContainsText
        
        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('Retiring Feature')
        $Exc.Add('Retiring Date')
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

        [PSCustomObject]$SmaResources | 
        ForEach-Object { $_ } | Select-Object $Exc | 
        Export-Excel -Path $File -WorksheetName 'SQL Pools' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -ConditionalText $condtxt -TableStyle $tableStyle -Style $Style
    }
}

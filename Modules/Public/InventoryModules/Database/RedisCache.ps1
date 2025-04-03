<#
.Synopsis
Inventory for Azure Cache for Redis

.DESCRIPTION
This script consolidates information for all microsoft.cache/redis resource provider in $Resources variable. 
Excel Sheet Name: RedisCache

.Link
https://github.com/microsoft/ARI/Modules/Public/InventoryModules/Database/RedisCache.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.0
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Retirements, $Task ,$File, $SmaResources, $TableStyle, $Unsupported)

If ($Task -eq 'Processing') {

    <######### Insert the resource extraction here ########>

    $RedisCache = @()
    $RedisCache += $Resources | Where-Object { $_.TYPE -eq 'microsoft.cache/redis' }
    $RedisCache += $Resources | Where-Object { $_.TYPE -eq 'microsoft.cache/redisenterprise' }

    if($RedisCache)
        {
            $tmp = foreach ($1 in $RedisCache) {
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
                $PvtEndP = if(![string]::IsNullOrEmpty($data.privateEndpointConnections.properties.privateEndpoint.id)){($data.privateEndpointConnections.properties.privateEndpoint.id.split('/')[8])}else{$null}
                if ($1.ZONES) { $Zones = $1.ZONES }else { $Zones = 'Not Configured' }
                if ([string]::IsNullOrEmpty($data.minimumTlsVersion)){$MinTLS = 'Default'}Else{$MinTLS = "TLS $($data.minimumTlsVersion)"}
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) {
                        $obj = @{
                            'ID'                    = $1.id;
                            'Subscription'          = $sub1.Name;
                            'ResourceGroup'         = $1.RESOURCEGROUP;
                            'Name'                  = $1.NAME;
                            'Location'              = $1.LOCATION;
                            'Zone'                  = $Zones;
                            'Retiring Feature'      = $RetiringFeature;
                            'Retiring Date'         = $RetiringDate;
                            'Version'               = $data.redisVersion;
                            'Public Network Access' = $data.publicNetworkAccess;
                            'FQDN'                  = $data.hostName;
                            'Port'                  = $data.port;
                            'Enable Non SSL Port'   = $data.enableNonSslPort;
                            'Minimum TLS Version'   = $MinTLS;
                            'SSL Port'              = $data.sslPort;
                            'Private Endpoint'      = $PvtEndP;
                            'Sku'                   = $data.sku.name;
                            'Capacity'              = $data.sku.capacity;
                            'Family'                = $data.sku.family;
                            'Max Frag Mem Reserved' = $data.redisConfiguration.'maxfragmentationmemory-reserved';
                            'Max Mem Reserved'      = $data.redisConfiguration.'maxmemory-reserved';
                            'Max Memory Delta'      = $data.redisConfiguration.'maxmemory-delta';
                            'Max Clients'           = $data.redisConfiguration.'maxclients';
                            'Resource U'            = $ResUCount;
                            'Tag Name'              = [string]$Tag.Name;
                            'Tag Value'             = [string]$Tag.Value
                        }
                        $obj
                        if ($ResUCount -eq 1) { $ResUCount = 0 } 
                    }               
            }
            $tmp
        }
}
<######## Resource Excel Reporting Begins Here ########>

Else {
    <######## $SmaResources.(RESOURCE FILE NAME) ##########>

    if ($SmaResources) {

        $SheetName = 'Redis Cache'

        $TableName = ('RedisCacheTable_'+($SmaResources.'Resource U').count)
        $condtxt = @()
        $condtxt += New-ConditionalText "Not Configured" -Range E:E
        $condtxt += New-ConditionalText Default -Range M:M
        $condtxt += New-ConditionalText 1.0 -Range M:M
        $condtxt += New-ConditionalText 1.1 -Range M:M
        $condtxt += New-ConditionalText TRUE -Range L:L
        #Retirement
        $condtxt += New-ConditionalText -Range F2:F100 -ConditionalType ContainsText

        $Style = @()        
        $Style += New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0.0 -Range M:M
        $Style += New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0 -Range A:L
        $Style += New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0 -Range N:Z
        
        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')                    
        $Exc.Add('Location')           
        $Exc.Add('Zone')
        $Exc.Add('Retiring Feature')
        $Exc.Add('Retiring Date')            
        $Exc.Add('Version')                 
        $Exc.Add('Public Network Access')
        $Exc.Add('FQDN')                    
        $Exc.Add('Port')                    
        $Exc.Add('Enable Non SSL Port')
        $Exc.Add('Minimum TLS Version')         
        $Exc.Add('SSL Port')   
        $Exc.Add('Private Endpoint')             
        $Exc.Add('Sku')                     
        $Exc.Add('Capacity')
        $Exc.Add('Family')                  
        $Exc.Add('Max Frag Mem Reserved')   
        $Exc.Add('Max Mem Reserved')        
        $Exc.Add('Max Memory Delta')        
        $Exc.Add('Max Clients')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        [PSCustomObject]$SmaResources | 
        ForEach-Object { $_ } | Select-Object $Exc | 
        Export-Excel -Path $File -WorksheetName $SheetName -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style

    }
}

<#
.Synopsis
Inventory for Azure Cache for Redis

.DESCRIPTION
This script consolidates information for all microsoft.cache/redis resource provider in $Resources variable. 
Excel Sheet Name: RedisCache

.Link
https://github.com/microsoft/ARI/Modules/Data/RedisCache.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.1.1
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Task , $File, $SmaResources, $TableStyle, $Unsupported)

If ($Task -eq 'Processing') {

    <######### Insert the resource extraction here ########>

    $RedisCache = @()
    $RedisCache += $Resources | Where-Object { $_.TYPE -eq 'microsoft.cache/redis' }
    $RedisCache += $Resources | Where-Object { $_.TYPE -eq 'microsoft.cache/redisenterprise' }

    if($RedisCache)
        {
            $tmp = @()

            foreach ($1 in $RedisCache) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $RetDate = ''
                $RetFeature = ''
                if($data.redisVersion -eq '4.0')
                    {
                        $RetDate = ($Unsupported | Where-Object {$_.Id -eq 6}).RetirementDate
                        $RetFeature = ($Unsupported | Where-Object {$_.Id -eq 6}).RetiringFeature
                    }
                $PvtEndP = $data.privateEndpointConnections.properties.privateEndpoint.id.split('/')[8]
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
                            'Retirement Date'       = [string]$RetDate;
                            'Retirement Feature'    = $RetFeature;
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
                        $tmp += $obj
                        if ($ResUCount -eq 1) { $ResUCount = 0 } 
                    }               
            }
            $tmp
        }
}
<######## Resource Excel Reporting Begins Here ########>

Else {
    <######## $SmaResources.(RESOURCE FILE NAME) ##########>

    if ($SmaResources.RedisCache) {

        $TableName = ('RedisCacheTable_'+($SmaResources.RedisCache.id | Select-Object -Unique).count)
        $condtxt = @()
        $condtxt += New-ConditionalText "Not Configured" -Range E:E
        $condtxt += New-ConditionalText Default -Range M:M
        $condtxt += New-ConditionalText 1.0 -Range M:M
        $condtxt += New-ConditionalText 1.1 -Range M:M
        $condtxt += New-ConditionalText TRUE -Range L:L
        $condtxt += New-ConditionalText VERDADEIRO -Range L:L
        $condtxt += New-ConditionalText - -Range F:F -ConditionalType ContainsText

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
        $Exc.Add('Retirement Date')
        $Exc.Add('Retirement Feature')              
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

        $ExcelVar = $SmaResources.RedisCache

        $ExcelVar | 
        ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        Export-Excel -Path $File -WorksheetName 'Redis Cache' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style

        $excel = Open-ExcelPackage -Path $File -KillExcel
    
        $null = $excel.'Redis Cache'.Cells["F1"].AddComment("It's important to be aware of upcoming Azure services and feature retirements to understand their impact on your workloads and plan migration.", "Azure Resource Inventory")
        $excel.'Redis Cache'.Cells["F1"].Hyperlink = 'https://learn.microsoft.com/en-us/azure/advisor/advisor-how-to-plan-migration-workloads-service-retirement'

        Close-ExcelPackage $excel

    }
    <######## Insert Column comments and documentations here following this model #########>
}

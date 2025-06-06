﻿<#
.Synopsis
Inventory for Azure Virtual WAN

.DESCRIPTION
This script consolidates information for all microsoft.network/virtualwans and  resource provider in $Resources variable. 
Excel Sheet Name: VirtualWAN

.Link
https://github.com/microsoft/ARI/Modules/Public/InventoryModules/Network_2/VirtualWAN.ps1

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

    $VirtualWAN = $Resources | Where-Object { $_.TYPE -eq 'microsoft.network/virtualwans' }
    $VirtualHub = $Resources | Where-Object { $_.TYPE -eq 'microsoft.network/virtualhubs' }
    $VPNSite = $Resources | Where-Object { $_.TYPE -eq 'microsoft.network/vpnsites' }
    #$ERSite = $Resources | Where-Object { $_.TYPE -eq 'microsoft.network/expressroutegateways'}

    if($VirtualWAN)
        {
            $tmp = foreach ($1 in $VirtualWAN) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.Id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $vhub = $VirtualHub | Where-Object { $_.ID -in $data.virtualHubs.id }
                $vpn = $VPNSite | Where-Object { $_.ID -in $data.vpnSites.id }
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
                if($vpn)
                    {
                        foreach ($2 in $vhub) {
                            foreach ($3 in $vpn) {                        
                                    foreach ($Tag in $Tags) {  
                                        $obj = @{
                                            'ID'                                 = $1.id;
                                            'Subscription'                       = $sub1.Name;
                                            'Resource Group'                     = $1.RESOURCEGROUP;
                                            'Name'                               = $1.NAME;
                                            'Location'                           = $1.LOCATION;
                                            'Retiring Feature'                   = $RetiringFeature;
                                            'Retiring Date'                      = $RetiringDate;
                                            'Allow BranchToBranch Traffic'       = $data.allowBranchToBranchTraffic;
                                            'Allow VnetToVnet Traffic'           = $data.allowVnetToVnetTraffic;
                                            'Disable Vpn Encryption'             = $data.disableVpnEncryption;
                                            'HUB Name'                           = [string]$2.name;
                                            'HUB Location'                       = [string]$2.location;
                                            'HUB Address Prefix'                 = [string]$2.properties.addressPrefix;
                                            'HUB Gateway Preference'             = [string]$2.properties.preferredRoutingGateway;
                                            'HUB Router ASN'                     = [string]$2.properties.virtualRouterAsn;
                                            'HUB Router IPs'                     = [string]($2.properties.virtualRouterIps | Select-Object -Unique);
                                            'Virtual Site Name'                  = [string]$3.name;
                                            'Device Vendor'                      = [string]$3.properties.deviceProperties.deviceVendor;
                                            'Device Vendor IpAddress'            = [string]$3.properties.vpnSiteLinks.properties.ipAddress;
                                            'Link Provider name'                 = [string]$3.properties.vpnSiteLinks.properties.linkProperties.linkProviderName;
                                            'Link Speed in Mbps'                 = [string]$3.properties.vpnSiteLinks.properties.linkProperties.linkSpeedInMbps;
                                            'Virtual Site Private Address Space' = [string]$3.properties.addressSpace.addressPrefixes;
                                            'Resource U'                         = $ResUCount;
                                            'Tag Name'                           = [string]$Tag.Name;
                                            'Tag Value'                          = [string]$Tag.Value
                                        }
                                        $obj
                                        if ($ResUCount -eq 1) { $ResUCount = 0 } 
                                    }                       
                            }
                        }
                    }
                else
                    {
                        foreach ($2 in $vhub) {                    
                                    foreach ($Tag in $Tags) {  
                                        $obj = @{
                                            'ID'                                 = $1.id;
                                            'Subscription'                       = $sub1.Name;
                                            'Resource Group'                     = $1.RESOURCEGROUP;
                                            'Name'                               = $1.NAME;
                                            'Location'                           = $1.LOCATION;
                                            'Retiring Feature'                   = $RetiringFeature;
                                            'Retiring Date'                      = $RetiringDate;
                                            'Allow BranchToBranch Traffic'       = $data.allowBranchToBranchTraffic;
                                            'Allow VnetToVnet Traffic'           = $data.allowVnetToVnetTraffic;
                                            'Disable Vpn Encryption'             = $data.disableVpnEncryption;
                                            'HUB Name'                           = [string]$2.name;
                                            'HUB Location'                       = [string]$2.location;
                                            'HUB Address Prefix'                 = [string]$2.properties.addressPrefix;
                                            'HUB Gateway Preference'             = [string]$2.properties.preferredRoutingGateway;
                                            'HUB Router ASN'                     = [string]$2.properties.virtualRouterAsn;
                                            'HUB Router IPs'                     = [string]($2.properties.virtualRouterIps | Select-Object -Unique);
                                            'Virtual Site Name'                  = $null;
                                            'Device Vendor'                      = $null;
                                            'Device Vendor IpAddress'            = $null;
                                            'Link Provider name'                 = $null;
                                            'Link Speed in Mbps'                 = $null;
                                            'Virtual Site Private Address Space' = $null;
                                            'Resource U'                         = $ResUCount;
                                            'Tag Name'                           = [string]$Tag.Name;
                                            'Tag Value'                          = [string]$Tag.Value
                                        }
                                        $obj
                                        if ($ResUCount -eq 1) { $ResUCount = 0 } 
                                    }                       
                            }
                    }
            }
            $tmp
        }
}
Else {
    if ($SmaResources) {

        $TableName = ('VWANTable_'+($SmaResources.'Resource U').count)
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
        $Exc.Add('Allow BranchToBranch Traffic')        
        $Exc.Add('Allow VnetToVnet Traffic')            
        $Exc.Add('Disable Vpn Encryption')              
        $Exc.Add('HUB Name')                          
        $Exc.Add('HUB Location')                      
        $Exc.Add('HUB Address Prefix')                
        $Exc.Add('HUB Gateway Preference')            
        $Exc.Add('HUB Router ASN')                   
        $Exc.Add('HUB Router IPs')                   
        $Exc.Add('Virtual Site Name')                 
        $Exc.Add('Device Vendor')                     
        $Exc.Add('Device Vendor IpAddress')           
        $Exc.Add('Link Provider name')                
        $Exc.Add('Link Speed in Mbps')                
        $Exc.Add('Virtual Site Private Address Space') 
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        [PSCustomObject]$SmaResources | 
        ForEach-Object { $_ } | Select-Object $Exc | 
        Export-Excel -Path $File -WorksheetName 'Virtual WAN' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -Style $Style -ConditionalText $condtxt

    }
}
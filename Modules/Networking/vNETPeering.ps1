<#
.Synopsis
Inventory for Azure Virtual Network Peering 

.DESCRIPTION
This script consolidates information for all microsoft.network/virtualnetworks and  resource provider in $Resources variable. 
Excel Sheet Name: vNETPeering

.Link
https://github.com/azureinventory/ARI/Modules/Networking/vNETPeering.ps1

.COMPONENT
   This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 2.0.0
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Task , $File, $SmaResources, $TableStyle) 
If ($Task -eq 'Processing') {

    $VNET = $Resources | Where-Object { $_.TYPE -eq 'microsoft.network/virtualnetworks' }        
    $VNETProperties = $VNET.PROPERTIES
    $VNETPeering = $Resources | Where-Object { $_.TYPE -eq 'microsoft.network/virtualnetworks' -and $null -ne $VNETProperties.Peering -and $VNETProperties.Peering -ne '' }

    if($VNETPeering)
        {
            $tmp = @()

            foreach ($1 in $VNETPeering) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                foreach ($2 in $data.addressSpace.addressPrefixes) {
                    foreach ($4 in $data.virtualNetworkPeerings) {
                        foreach ($5 in $4.properties.remoteAddressSpace.addressPrefixes) {
                                foreach ($Tag in $Tags) {  
                                    $obj = @{
                                        'Subscription'                          = $sub1.name;
                                        'Resource Group'                        = $1.RESOURCEGROUP;
                                        'VNET Name'                             = $1.NAME;
                                        'Location'                              = $1.LOCATION;
                                        'Zone'                                  = $1.ZONES;
                                        'Address Space'                         = $2;
                                        'Peering Name'                          = $4.name;
                                        'Peering VNet'                          = $4.properties.remoteVirtualNetwork.id.split('/')[8];
                                        'Peering State'                         = $4.properties.peeringState;
                                        'Peering Use Remote Gateways'           = $4.properties.useRemoteGateways;
                                        'Peering Allow Gateway Transit'         = $4.properties.allowGatewayTransit;
                                        'Peering Allow Forwarded Traffic'       = $4.properties.allowForwardedTraffic;
                                        'Peering Do Not Verify Remote Gateways' = $4.properties.doNotVerifyRemoteGateways;
                                        'Peering Allow Virtual Network Access'  = $4.properties.allowVirtualNetworkAccess;
                                        'Peering Address Space'                 = $5;
                                        'Resource U'                            = $ResUCount;
                                        'Tag Name'                              = [string]$Tag.Name;
                                        'Tag Value'                             = [string]$Tag.Value
                                    }
                                    $tmp += $obj
                                    if ($ResUCount -eq 1) { $ResUCount = 0 } 
                                }                           
                        }
                    }
                }                    
            }
            $tmp
        }
}
Else {
    if ($SmaResources.VNETPeering) {
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Location')
        $Exc.Add('Zone')
        $Exc.Add('Peering Name')
        $Exc.Add('VNET Name')
        $Exc.Add('Address Space')
        $Exc.Add('Peering VNet')
        $Exc.Add('Peering Address Space')
        $Exc.Add('Peering State')
        $Exc.Add('Peering Use Remote Gateways')
        $Exc.Add('Peering Allow Gateway Transit')
        $Exc.Add('Peering Allow Forwarded Traffic')
        $Exc.Add('Peering Do Not Verify Remote Gateways')
        $Exc.Add('Peering Allow Virtual NetworkAccess')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.VNETPeering 

        $ExcelVar | 
        ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        Export-Excel -Path $File -WorksheetName 'Peering' -AutoSize -MaxAutoSizeRows 100 -TableName 'AzureVNETPeerings' -TableStyle $tableStyle -Style $Style
    
    }
}
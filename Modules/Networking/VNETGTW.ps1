<#
.Synopsis
Inventory for Azure Virtual Network Gateway 

.DESCRIPTION
This script consolidates information for all microsoft.network/virtualnetworkgateways and  resource provider in $Resources variable. 
Excel Sheet Name: VNETGTW

.Link
https://github.com/azureinventory/ARI/Modules/Networking/VNETGTW.ps1

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

    $VNETGTW = $Resources | Where-Object { $_.TYPE -eq 'microsoft.network/virtualnetworkgateways' }

    if($VNETGTW)
        {
            $tmp = @()

            foreach ($1 in $VNETGTW) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) {  
                        $obj = @{
                            'Subscription'           = $sub1.name;
                            'Resource Group'         = $1.RESOURCEGROUP;
                            'Name'                   = $1.NAME;
                            'Location'               = $1.LOCATION;
                            'SKU'                    = $data.sku.tier;
                            'Active-active mode'     = $data.activeActive; 
                            'Gateway Type'           = $data.gatewayType;
                            'Gateway Generation'     = $data.vpnGatewayGeneration;
                            'VPN Type'               = $data.vpnType;
                            'Enable Private Address' = $data.enablePrivateIpAddress;
                            'Enable BGP'             = $data.enableBgp;
                            'BGP ASN'                = $data.bgpsettings.asn;
                            'BGP Peering Address'    = $data.bgpSettings.bgpPeeringAddress;
                            'BGP Peer Weight'        = $data.bgpSettings.peerWeight;
                            'Gateway Public IP'      = [string]$data.ipConfigurations.properties.publicIPAddress.id.split("/")[8];
                            'Gateway Subnet Name'    = [string]$data.ipConfigurations.properties.subnet.id.split("/")[8];
                            'Resource U'             = $ResUCount;
                            'Tag Name'               = [string]$Tag.Name;
                            'Tag Value'              = [string]$Tag.Value
                        }
                        $tmp += $obj
                        if ($ResUCount -eq 1) { $ResUCount = 0 } 
                    }               
            }
            $tmp
        }
}
Else {
    if ($SmaResources.VNETGTW) {
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('SKU')
        $Exc.Add('Active-active mode')
        $Exc.Add('Gateway Type')
        $Exc.Add('Gateway Generation')
        $Exc.Add('VPN Type')
        $Exc.Add('Enable Private Address')
        $Exc.Add('Enable BGP')
        $Exc.Add('BGP ASN')
        $Exc.Add('BGP Peering Address')
        $Exc.Add('BGP Peer Weight')
        $Exc.Add('Gateway Public IP')
        $Exc.Add('Gateway Subnet Name')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.VNETGTW 

        $ExcelVar | 
        ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        Export-Excel -Path $File -WorksheetName 'VNET Gateways' -AutoSize -MaxAutoSizeRows 100 -TableName 'AzureVNETGateways' -TableStyle $tableStyle -ConditionalText $txtvnet -Style $Style
    
    }
}
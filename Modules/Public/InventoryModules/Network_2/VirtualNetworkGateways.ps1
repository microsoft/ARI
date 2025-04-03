<#
.Synopsis
Inventory for Azure Virtual Network Gateway 

.DESCRIPTION
This script consolidates information for all microsoft.network/virtualnetworkgateways and  resource provider in $Resources variable. 
Excel Sheet Name: VNETGTW

.Link
https://github.com/microsoft/ARI/Modules/Public/InventoryModules/Network_2/VirtualNetworkGateways.ps1

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

    $VNETGTW = $Resources | Where-Object { $_.TYPE -eq 'microsoft.network/virtualnetworkgateways' }

    if($VNETGTW)
        {
            $tmp = foreach ($1 in $VNETGTW) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.Id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $generation = if($data.vpnGatewayGeneration -eq 'None'){ 'Generation1'}else{ 'Generation2'}
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
                            'ID'                     = $1.id;
                            'Subscription'           = $sub1.Name;
                            'Resource Group'         = $1.RESOURCEGROUP;
                            'Name'                   = $1.NAME;
                            'Location'               = $1.LOCATION;
                            'SKU'                    = $data.sku.tier;
                            'Retiring Feature'       = $RetiringFeature;
                            'Retiring Date'          = $RetiringDate;
                            'Gateway Generation'     = $generation;
                            'Migration Status'       = $data.virtualNetworkGatewayMigrationStatus.state;
                            'Active-active mode'     = $data.activeActive; 
                            'Gateway Type'           = $data.gatewayType;
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
                        $obj
                        if ($ResUCount -eq 1) { $ResUCount = 0 } 
                    }               
            }
            $tmp
        }
}
Else {
    if ($SmaResources) {

        $TableName = ('VNETGTWTable_'+($SmaResources.'Resource U').count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

        $condtxt = @()
        #Retirement
        $condtxt += New-ConditionalText -Range F2:F100 -ConditionalType ContainsText
        #SKU
        $condtxt += New-ConditionalText UltraPerformance -Range E:E
        $condtxt += New-ConditionalText Standard -Range E:E
        $condtxt += New-ConditionalText VpnGw1 -Range E:E
        $condtxt += New-ConditionalText VpnGw2 -Range E:E
        $condtxt += New-ConditionalText VpnGw3 -Range E:E
        $condtxt += New-ConditionalText VpnGw1AZ -Range E:E
        $condtxt += New-ConditionalText VpnGw2AZ -Range E:E
        $condtxt += New-ConditionalText VpnGw3AZ -Range E:E
        $condtxt += New-ConditionalText Basic -Range E:E
        #Generation
        $condtxt += New-ConditionalText Generation1 -Range H:H


        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('SKU')
        $Exc.Add('Retiring Feature')
        $Exc.Add('Retiring Date')
        $Exc.Add('Gateway Generation')
        $Exc.Add('Migration Status')
        $Exc.Add('Active-active mode')
        $Exc.Add('Gateway Type')
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

        [PSCustomObject]$SmaResources | 
        ForEach-Object { $_ } | Select-Object $Exc | 
        Export-Excel -Path $File -WorksheetName 'VNET Gateways' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style

    }
}
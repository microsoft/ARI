<#
.Synopsis
Inventory for Azure Virtual Network

.DESCRIPTION
This script consolidates information for all microsoft.network/virtualnetworks and  resource provider in $Resources variable. 
Excel Sheet Name: VirtualNetwork

.Link
https://github.com/microsoft/ARI/Modules/Networking/VirtualNetwork.ps1

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

    $VirtualNetwork = $Resources | Where-Object { $_.TYPE -eq 'microsoft.network/virtualnetworks' }

    if($VirtualNetwork)
        {
            $tmp = @()

            foreach ($1 in $VirtualNetwork) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.Id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $RetDate = ''
                $RetFeature = '' 
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                foreach ($2 in $data.addressSpace.addressPrefixes) {
                    foreach ($3 in $data.subnets) {
                            foreach ($Tag in $Tags) {
                                $obj = @{
                                    'ID'                                           = $1.id;
                                    'Subscription'                                 = $sub1.Name;
                                    'Resource Group'                               = $1.RESOURCEGROUP;
                                    'Name'                                         = $1.NAME;
                                    'Location'                                     = $1.LOCATION;
                                    'Zone'                                         = $1.ZONES;
                                    'Retirement Date'                              = [string]$RetDate;
                                    'Retirement Feature'                           = $RetFeature;
                                    'Address Space'                                = $2;
                                    'Enable DDOS Protection'                       = $data.enableDdosProtection;
                                    'DNS Servers'                                  = [string]$data.dhcpOptions.dnsServers;
                                    'Subnet Name'                                  = $3.name;
                                    'Subnet Prefix'                                = $3.properties.addressPrefix;
                                    'Used IPs'                                     = [string]$3.properties.ipConfigurations.id.count;
                                    'Subnet Private Link Service Network Policies' = $3.properties.privateLinkServiceNetworkPolicies;
                                    'Subnet Private Endpoint Network Policies'     = $3.properties.privateEndpointNetworkPolicies;
                                    'Subnet Route Table'                           = if ($3.properties.routeTable.id) { $3.properties.routeTable.id.split("/")[8] };
                                    'Subnet Network Security Group'                = if ($3.properties.networkSecurityGroup.id) { $3.properties.networkSecurityGroup.id.split("/")[8] };
                                    'Resource U'                                   = $ResUCount;
                                    'Tag Name'                                     = [string]$Tag.Name;
                                    'Tag Value'                                    = [string]$Tag.Value
                                }
                                $tmp += $obj
                                if ($ResUCount -eq 1) { $ResUCount = 0 } 
                            }                       
                    }
                }
            }
            $tmp
        }
}

Else {
    if ($SmaResources.VirtualNetwork) {

        $TableName = ('VNETTable_'+($SmaResources.VirtualNetwork.id | Select-Object -Unique).count)

        $condtxt = @()
        $condtxt += New-ConditionalText FALSE -Range G:G
        $condtxt += New-ConditionalText FALSO -Range G:G
        $condtxt += New-ConditionalText - -Range H:H -ConditionalType ContainsText
        

        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'
                

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('Zone')
        $Exc.Add('Address Space')
        $Exc.Add('Enable DDOS Protection')
        $Exc.Add('Retirement Date')
        $Exc.Add('Retirement Feature')  
        $Exc.Add('DNS Servers')
        $Exc.Add('Subnet Name')
        $Exc.Add('Used IPs')
        $Exc.Add('Subnet Prefix')
        $Exc.Add('Subnet Private Link Service Network Policies')
        $Exc.Add('Subnet Private Endpoint Network Policies')
        $Exc.Add('Subnet Route Table')
        $Exc.Add('Subnet Network Security Group')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.VirtualNetwork 

        
        $ExcelVar | 
            ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        Export-Excel -Path $File -WorksheetName 'Virtual Networks' -AutoSize -TableName $TableName -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style
        

        $excel = Open-ExcelPackage -Path $File -KillExcel

        $null = $excel.VirtualNetwork.Cells["G1"].AddComment("Azure DDoS Protection Standard, combined with application design best practices, provides enhanced DDoS mitigation features to defend against DDoS attacks.", "Azure Resource Inventory")
        $excel.VirtualNetwork.Cells["G1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/ddos-protection/ddos-protection-overview'

        Close-ExcelPackage $excel 

    }
}
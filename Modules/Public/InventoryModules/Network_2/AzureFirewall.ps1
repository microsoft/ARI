<#
.Synopsis
Inventory for Azure Firewall

.DESCRIPTION
This script consolidates information for all microsoft.network/azurefirewalls and  resource provider in $Resources variable. 
Excel Sheet Name: AzureFirewall

.Link
https://github.com/microsoft/ARI/Modules/Public/InventoryModules/Network_2/AzureFirewall.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.0
First Release Date: 19th November, 2020
Authors: Claudio Merola 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Retirements, $Task ,$File, $SmaResources, $TableStyle, $Unsupported)

If ($Task -eq 'Processing') {

    <######### Insert the resource extraction here ########>
    $AzureFirewall = $Resources | Where-Object { $_.TYPE -eq 'microsoft.network/azurefirewalls' }
    $AzureFWPolicies = $Resources | Where-Object { $_.TYPE -eq 'microsoft.network/firewallpolicies' }
    $AzureFWPoliciesRules = $Resources | Where-Object { $_.TYPE -eq 'microsoft.network/firewallpolicies/rulecollectiongroups' }
    $AzureIPGroups = $Resources | Where-Object { $_.TYPE -eq 'microsoft.network/ipgroups' }

    if($AzureFirewall)
        {
            $tmp = foreach ($1 in $AzureFirewall) 
                { 
                    $sub1 = $SUB | Where-Object { $_.Id -eq $1.subscriptionId }
                    $data = $1.PROPERTIES
                    if ($1.zones) { $Zones = $1.zones } Else { $Zones = "Not Configured" }
                    $Retired = Foreach ($Retirement in $Retirements)
                    {
                        if ($Retirement.id -eq $1.id) { $Retirement }
                    }
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
                    $Threat = if($data.threatintelmode -eq 'deny'){'Alert and deny'}elseif($data.threatintelmode -eq 'alert'){'Alert only'}else{'Off'}
                    $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    
                    $VNETs = @()
                    $PIPs = @()
                    $PrivIPs = @()
                    Foreach($2 in $data.ipConfigurations)
                        {
                            $PIPs += $2.name
                            $VNETs += if(![string]::IsNullOrEmpty($2.properties.subnet.id)){$2.properties.subnet.id.split('/')[8]}else{$null}
                            $PrivIPs += $2.properties.privateIPAddress
                        }
                    
                    $Policy = $AzureFWPolicies | Where-Object {$_.id -eq $data.firewallpolicy.id}
                    $Policy = if(![string]::IsNullOrEmpty($Policy)){$Policy}else{'0'}
                    $Rules = $AzureFWPoliciesRules | Where-Object {$_.id -eq $Policy.properties.rulecollectiongroups.id}
                    $Rules = if(![string]::IsNullOrEmpty($Rules)){$Rules}else{'0'}
                    $FinalPIP = if ($PIPs.count -gt 1) { $PIPs | ForEach-Object { $_ + ' ,' } }else { $PIPs }
                    $FinalPIP = [string]$FinalPIP
                    $FinalPIP = if ($FinalPIP -like '* ,*') { $FinalPIP -replace ".$" }else { $FinalPIP }
                    $FinalVNET = if ($VNETs.count -gt 1) { $VNETs | ForEach-Object { $_ + ' ,' } }else { $VNETs }
                    $FinalVNET = [string]$FinalVNET
                    $FinalVNET = if ($FinalVNET -like '* ,*') { $FinalVNET -replace ".$" }else { $FinalVNET }
                    $FinalPrivIP = if ($PrivIPs.count -gt 1) { $PrivIPs | ForEach-Object { $_ + ' ,' } }else { $PrivIPs }
                    $FinalPrivIP = [string]$FinalPrivIP
                    $FinalPrivIP = if ($FinalPrivIP -like '* ,*') { $FinalPrivIP -replace ".$" }else { $FinalPrivIP }
                    $FinalDNSServers = if ($Policy.properties.dnssettings.servers.count -gt 1) { $Policy.properties.dnssettings.servers | ForEach-Object { $_ + ' ,' } }else { $Policy.properties.dnssettings.servers }
                    $FinalDNSServers = [string]$FinalDNSServers
                    $FinalDNSServers = if ($FinalDNSServers -like '* ,*') { $FinalDNSServers -replace ".$" }else { $FinalDNSServers }

                    foreach ($CoreRule in $Rules)
                        {
                            $CoreCollections = $CoreRule.properties.rulecollections
                            $CoreCollections = if(![string]::IsNullOrEmpty($CoreCollections)){$CoreCollections}else{'0'}
                            foreach ($RuleCollection in $CoreCollections)
                                {
                                    $RuleCoreCollections = $RuleCollection.rules
                                    $RuleCoreCollections = if(![string]::IsNullOrEmpty($RuleCoreCollections)){$RuleCoreCollections}else{'0'}
                                    foreach ($Rule in $RuleCoreCollections)
                                        {
                                            $FinalProtocol = if ($Rule.ipprotocols.count -gt 1) { $Rule.ipprotocols | ForEach-Object { $_ + ' ,' } }else { $Rule.ipprotocols}
                                            $FinalProtocol = [string]$FinalProtocol
                                            $FinalProtocol = if ($FinalProtocol -like '* ,*') { $FinalProtocol -replace ".$" }else { $FinalProtocol }

                                            $FinalPort = if ($Rule.destinationports.count -gt 1) { $Rule.destinationports | ForEach-Object { $_ + ' ,' } }else { $Rule.destinationports}
                                            $FinalPort = [string]$FinalPort
                                            $FinalPort = if ($FinalPort -like '* ,*') { $FinalPort -replace ".$" }else { $FinalPort }

                                            if(![string]::IsNullOrEmpty($Rule.sourceipgroups))
                                                {
                                                    $SourceIpGroup = ($AzureIPGroups | Where-Object {$_.id -eq $Rule.sourceipgroups}).properties.ipaddresses
                                                    $SourceIP = if ($SourceIpGroup.count -gt 1) { $SourceIpGroup | ForEach-Object { $_ + ' ,' } }else { $SourceIpGroup }
                                                    $SourceIP = [string]$SourceIP
                                                    $SourceIP = if ($SourceIP -like '* ,*') { $SourceIP -replace ".$" }else { $SourceIP }
                                                    $SourceType = 'IP Group'
                                                }
                                            else
                                                {
                                                    $SourceIP = [string]$Rule.sourceaddresses
                                                    $SourceType = 'IP Address'
                                                }

                                            if(![string]::IsNullOrEmpty($Rule.destinationipgroups))
                                                {
                                                    $DestinationIpGroup = ($AzureIPGroups | Where-Object {$_.id -eq $Rule.destinationipgroups}).properties.ipaddresses
                                                    $DestinationIP = if ($DestinationIpGroup.count -gt 1) { $DestinationIpGroup | ForEach-Object { $_ + ' ,' } }else { $DestinationIpGroup }
                                                    $DestinationIP = [string]$DestinationIP
                                                    $DestinationIP = if ($DestinationIP -like '* ,*') { $DestinationIP -replace ".$" }else { $DestinationIP }
                                                    $DestionationType = 'IP Group'
                                                }
                                            elseif(![string]::IsNullOrEmpty($Rule.destinationfqdns))
                                                {
                                                    $DestinationIP = [string]$Rule.destinationfqdns
                                                    $DestionationType = 'FQDN'
                                                }
                                            else
                                                {
                                                    $DestinationIP = [string]$Rule.destinationaddresses
                                                    $DestionationType = 'IP Address'
                                                }

                                            foreach ($Tag in $Tags) {
                                                    $obj = @{
                                                        'ID'                                = $1.id;
                                                        'Subscription'                      = $sub1.Name;
                                                        'Resource Group'                    = $1.RESOURCEGROUP;
                                                        'Name'                              = $1.NAME;
                                                        'Location'                          = $1.LOCATION;
                                                        'SKU'                               = $data.sku.tier;
                                                        'Retiring Feature'                  = $RetiringFeature;
                                                        'Retiring Date'                     = $RetiringDate;
                                                        'Threat Intel Mode'                 = $Threat;
                                                        'Zone'                              = [string]$Zones;
                                                        'Public IP Name'                    = $FinalPIP;
                                                        'Firewall VNET'                     = $FinalVNET;
                                                        'Firewall Private IP'               = $FinalPrivIP;
                                                        'Policy Name'                       = $Policy.name;
                                                        'DNS Proxy'                         = $Policy.properties.dnssettings.enableproxy;
                                                        'DNS Servers'                       = $FinalDNSServers;
                                                        'Rule Collection Group'             = $CoreRule.name;
                                                        'Rule Collection Group Priority'    = $CoreRule.properties.priority;
                                                        'Rule Collection'                   = $RuleCollection.name;
                                                        'Rule Action'                       = $RuleCollection.action.type;
                                                        'Rule Priority'                     = $RuleCollection.priority;
                                                        'Rule Type'                         = $Rule.ruletype;
                                                        'Rule Name'                         = $Rule.name;
                                                        'Source Type'                       = $SourceType;
                                                        'Source'                            = $SourceIP;
                                                        'Protocol'                          = $FinalProtocol;
                                                        'Destination Port'                  = $FinalPort;
                                                        'Destination Type'                  = $DestionationType;
                                                        'Destination'                       = $DestinationIP;
                                                        'Resource U'                        = $ResUCount;
                                                        'Tag Name'                          = [string]$Tag.Name;
                                                        'Tag Value'                         = [string]$Tag.Value
                                                    }
                                                    $obj
                                                    if ($ResUCount -eq 1) { $ResUCount = 0 } 
                                                }
                                        }
                                }
                        }
                }
            $tmp
        }
}
<######## Resource Excel Reporting Begins Here ########>

Else {
    <######## $SmaResources.(RESOURCE FILE NAME) ##########>

    if ($SmaResources) {

        $TableName = ('AzFirewallTable_'+($SmaResources.'Resource U').count)

        $condtxt = @()
        #Retirement
        $condtxt += New-ConditionalText -Range F2:F100 -ConditionalType ContainsText

        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('SKU')
        $Exc.Add('Retiring Feature')
        $Exc.Add('Retiring Date')
        $Exc.Add('Threat Intel Mode')
        $Exc.Add('Zone')
        $Exc.Add('Public IP Name')
        $Exc.Add('Firewall VNET')
        $Exc.Add('Firewall Private IP')
        $Exc.Add('Policy Name')
        $Exc.Add('DNS Proxy')
        $Exc.Add('DNS Servers')
        $Exc.Add('Rule Collection Group')
        $Exc.Add('Rule Collection Group Priority')
        $Exc.Add('Rule Collection')
        $Exc.Add('Rule Action')
        $Exc.Add('Rule Priority')
        $Exc.Add('Rule Type')
        $Exc.Add('Rule Name')
        $Exc.Add('Source Type')
        $Exc.Add('Source')
        $Exc.Add('Protocol')
        $Exc.Add('Destination Port')
        $Exc.Add('Destination Type')
        $Exc.Add('Destination')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        [PSCustomObject]$SmaResources | 
        ForEach-Object { $_ } | Select-Object $Exc | 
        Export-Excel -Path $File -WorksheetName 'Azure Firewall' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style

    }
}
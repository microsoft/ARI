<#
.Synopsis
Inventory for Azure Network Interfaces

.DESCRIPTION
This script consolidates information for all microsoft.network/natgateways and  resource provider in $Resources variable. 
Excel Sheet Name: Network Interface

.Link
https://github.com/microsoft/ARI/Modules/Public/InventoryModules/Network_2/NetworkInterface.ps1

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

    $nic = $Resources | Where-Object {$_.TYPE -eq 'microsoft.network/networkinterfaces'}
    $PublicIP = $Resources | Where-Object { $_.TYPE -eq 'microsoft.network/publicipaddresses' }

    if($nic)
        {
            $tmp = foreach ($1 in $nic) 
                {
                    $ResUCount = 1
                    $sub1 = $SUB | Where-Object { $_.Id -eq $1.subscriptionId }
                    $data = $1.PROPERTIES
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

                    if(![string]::IsNullOrEmpty($data.virtualmachine.id))
                        {
                            $ResourceType = 'Virtual Machine'
                            $Resource = $data.virtualmachine.id.split('/')[8]
                        }
                    elseif(![string]::IsNullOrEmpty($data.privateendpoint.id))
                        {
                            $ResourceType = 'Private Endpoint'
                            $Resource = $data.privateendpoint.id.split('/')[8]
                        }
                    else
                        {
                            $ResourceType = 'Underutilized'
                            $Resource = 'None'
                        }
                    
                    $NSG = if(![string]::IsNullOrEmpty($data.networksecuritygroup.id)){$data.networksecuritygroup.id.split('/')[8]}else{$null}

                    $DNS = if ($data.dnssettings.dnsservers.count -gt 1) { $data.dnssettings.dnsservers | ForEach-Object { $_ + ' ,' } }else { $data.dnssettings.dnsservers }
                    $DNS = [string]$DNS
                    $DNS = if ($DNS -like '* ,*') { $DNS -replace ".$" }else { $DNS }

                    $AcceleratedNetworking = if($data.enableacceleratednetworking -eq $true){'On'}else{'Off'}

                    $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($2 in $data.ipconfigurations)
                        {
                            $VNET = if(![string]::IsNullOrEmpty($2.properties.subnet.id)){$2.properties.subnet.id.split('/')[8]}else{$null}
                            $Subnet = if(![string]::IsNullOrEmpty($2.properties.subnet.id)){$2.properties.subnet.id.split('/')[10]}else{$null}
                            $PIP = $PublicIP | Where-Object {$_.id -eq $2.properties.publicipaddress.id}
                            $PIPName = $PIP.Name
                            $PIPAddress = if(![string]::IsNullOrEmpty($PIP.properties.ipaddress)){$PIP.properties.ipaddress}else{'Unassigned'}
                            foreach ($Tag in $Tags) 
                                {
                                    $obj = @{
                                        'ID'                    = $1.id;
                                        'Subscription'          = $sub1.Name;
                                        'Resource Group'        = $1.RESOURCEGROUP;
                                        'Name'                  = $1.NAME;
                                        'Location'              = $1.LOCATION;
                                        'Retiring Feature'      = $RetiringFeature;
                                        'Retiring Date'         = $RetiringDate;
                                        'Attached Resource Type'= $ResourceType;
                                        'Attached Resource'     = $Resource;
                                        'Network Security Group'= $NSG;
                                        'DNS Servers'           = $DNS;
                                        'Internal Domain Suffix'= $data.dnssettings.internaldomainnamesuffix;
                                        'Accelerated Networking'= $AcceleratedNetworking;
                                        'IP Forwarding'         = $data.enableipforwarding;
                                        'MAC Address'           = $data.macaddress;
                                        'IP Configurations'     = $2.name;
                                        'Virtual Network'       = $VNET;
                                        'Subnet'                = $Subnet;
                                        'Primary'               = $2.properties.primary;
                                        'Private IP Version'    = $2.properties.privateipaddressversion;
                                        'Private IP'            = $2.properties.privateipaddress;
                                        'Private IP Method'     = $2.properties.privateipallocationmethod;
                                        'Public IP Name'        = $PIPName;
                                        'Public IP'             = $PIPAddress;
                                        'Resource U'            = $ResUCount;
                                        'Tag Name'              = [string]$Tag.Name;
                                        'Tag Value'             = [string]$Tag.Value
                                    }
                                    $obj
                                    if ($ResUCount -eq 1) { $ResUCount = 0 } 
                                }
                        }
                }
            $tmp
        }
}
Else {
    if ($SmaResources) {

        $TableName = ('NICTable_'+($SmaResources.'Resource U').count)
        $Style = @()
        $Style += New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

        $condtxt = @()
        $condtxt += New-ConditionalText Off -Range L:L
        $condtxt += New-ConditionalText Underutilized -Range G:G
        #Retirement
        $condtxt += New-ConditionalText -Range E2:E100 -ConditionalType ContainsText

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('Retiring Feature')
        $Exc.Add('Retiring Date')
        $Exc.Add('Attached Resource Type')
        $Exc.Add('Attached Resource')
        $Exc.Add('Network Security Group')
        $Exc.Add('DNS Servers')
        $Exc.Add('Internal Domain Suffix')
        $Exc.Add('Accelerated Networking')
        $Exc.Add('IP Forwarding')
        $Exc.Add('MAC Address')
        $Exc.Add('IP Configurations')
        $Exc.Add('Virtual Network')
        $Exc.Add('Subnet')
        $Exc.Add('Primary')
        $Exc.Add('Private IP Version')
        $Exc.Add('Private IP')
        $Exc.Add('Private IP Method')
        $Exc.Add('Public IP Name')
        $Exc.Add('Public IP')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $noNumberConversion = @()
        $noNumberConversion += 'DNS Servers'
        $noNumberConversion += 'Private IP'
        $noNumberConversion += 'Public IP'

        [PSCustomObject]$SmaResources | 
        ForEach-Object { $_ } | Select-Object $Exc | 
        Export-Excel -Path $File -WorksheetName 'Network Interface' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style -NoNumberConversion $noNumberConversion

    }
}
<#
.Synopsis
Inventory for Azure Virtual Machine

.DESCRIPTION
This script consolidates information for all microsoft.compute/virtualmachines resource provider in $Resources variable. 
Excel Sheet Name: Virtual Machines

.Link
https://github.com/microsoft/ARI/Modules/Public/InventoryModules/Compute/VirtualMachine.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.0
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Retirements, $Task, $File, $SmaResources, $TableStyle, $Unsupported)

If ($Task -eq 'Processing')
{

        $vm =  $Resources | Where-Object {$_.TYPE -eq 'microsoft.compute/virtualmachines'}
        $nic = $Resources | Where-Object {$_.TYPE -eq 'microsoft.network/networkinterfaces'}
        $vmexp = $Resources | Where-Object {$_.TYPE -eq 'microsoft.compute/virtualmachines/extensions'}
        $disk = $Resources | Where-Object {$_.TYPE -eq 'microsoft.compute/disks'}
        $VirtualNetwork = $Resources | Where-Object { $_.TYPE -eq 'microsoft.network/virtualnetworks' }
        $VMExtraDetails = $Resources | Where-Object { $_.TYPE -eq 'ARI/VM/SKU' }
        $VMQuotas = $Resources | Where-Object { $_.TYPE -eq 'ARI/VM/Quotas' }

    if($vm)
        {    

            $tmp = foreach ($1 in $vm) 
                {
                    $ResUCount = 1
                    $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                    $data = $1.PROPERTIES
                    $timecreated = $data.timeCreated
                    $timecreated = [datetime]$timecreated
                    $timecreated = $timecreated.ToString("yyyy-MM-dd HH:mm")
                    $dataSize = ''
                    $StorAcc = ''
                    $OSName = if(![string]::IsNullOrEmpty($data.extended.instanceView.osname)){$data.extended.instanceView.osname}else{$data.storageprofile.imagereference.offer}
                    $OSVersion = if(![string]::IsNullOrEmpty($data.extended.instanceView.osversion)){$data.extended.instanceView.osversion}else{$data.storageprofile.imagereference.sku}

                    # Extra VM Details

                    $VMExtraDetail = $VMExtraDetails.properties | Where-Object {$_.Location -eq $1.location}
                    $VMExtraDetail = $VMExtraDetail.SKUs | Where-Object {$_.Name -eq $data.hardwareProfile.vmSize}

                    foreach ($Capability in $VMExtraDetail.Capabilities) {
                        if ($Capability.Name -eq 'vCPUs') {$vCPUs = $Capability.Value}
                        if ($Capability.Name -eq 'vCPUsPerCore') {$vCPUsPerCore = $Capability.Value}
                        if ($Capability.Name -eq 'MemoryGB') {$RAM = $Capability.Value}
                        if ($Capability.Name -eq 'MaxDataDiskCount') {$MaxDataDiskCount = $Capability.Value}
                        if ($Capability.Name -eq 'UncachedDiskIOPS') {$UncachedDiskIOPS = $Capability.Value}
                        if ($Capability.Name -eq 'UncachedDiskBytesPerSecond') {$UncachedDiskBytesPerSecond = ([math]::Round($Capability.Value / 1024) / 1024)}
                        if ($Capability.Name -eq 'MaxNetworkInterfaces') {$MaxNetworkInterfaces = $Capability.Value}
                    }

                    # Quotas
                    $Size = $VMExtraDetail.Family
                    $Quota = $VMQuotas.properties | Where-Object {$_.SubId -eq $1.subscriptionId}
                    $Quota = $Quota | Where-Object {$_.Location -eq $1.location}
                    $RemainingQuota = (($Quota.Data | Where-Object {$_.Name.Value -eq $Size}).Limit - ($Quota.Data | Where-Object {$_.Name.Value -eq $Size}).CurrentValue)

                    $Retired = Foreach ($Retirement in $Retirements)
                        {
                            if ($Retirement.id -eq $1.id) { $Retirement }
                        }
                    if ($Retired) 
                        {
                            $RetiredFeature = foreach ($Retire in $Retired)
                                {
                                    $RetiredServiceID = $Unsupported | Where-Object {$_.Id -eq $Retired.ServiceID}
                                    $tmp0 = [PSCustomObject]@{
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

                    #Extensions 
                    $ext = @()
                    $AzDiag = ''
                    $Azinsights = ''
                    $Lic = switch ($data.licenseType) {
                        'Windows_Server' { 'Azure Hybrid Benefit for Windows' }
                        'Windows_Client' { 'Windows client with multi-tenant hosting' }
                        'RHEL_BYOS' { 'Azure Hybrid Benefit for Redhat' }
                        'SLES_BYOS' { 'Azure Hybrid Benefit for SUSE' }
                        default { $data.licenseType }
                    }
                    $Lic = if($Lic){$Lic}else{'None'}
                    $ext = foreach ($vmextension in $vmexp)
                        {
                            if (($vmextension.id -split "/")[8] -eq $1.name) { $vmextension.properties.Publisher }
                        }
                    if ($null -ne $ext) 
                        {
                            $ext = foreach ($ex in $ext) 
                                {
                                    if ($ex | Where-Object { $_ -eq 'Microsoft.Azure.Performance.Diagnostics' }) { $AzDiag = $true }
                                    if ($ex | Where-Object { $_ -eq 'Microsoft.EnterpriseCloud.Monitoring' }) { $Azinsights = $true }
                                    $ex + ', '
                                }
                            $ext = [string]$ext
                            $ext = $ext.Substring(0, $ext.Length - 2)
                        }

                    if(![string]::IsNullOrEmpty($data.osprofile.windowsconfiguration.enableautomaticupdates))
                        {
                            if($data.osprofile.windowsconfiguration.enableautomaticupdates -eq 'True')
                                {
                                    $Autoupdate = $true
                                }
                            else
                                {
                                    $Autoupdate = $false
                                }
                        }
                    elseif(![string]::IsNullOrEmpty($data.osprofile.linuxconfiguration.patchsettings.patchmode))
                        {
                            if($data.osprofile.linuxconfiguration.patchsettings.patchmode -eq 'automaticbyos')
                                {
                                    $Autoupdate = $true
                                }
                            else
                                {
                                    $Autoupdate = $false
                                }
                        }

                    if (![string]::IsNullOrEmpty($data.availabilitySet)) { $AVSET = $true }else { $AVSET = $false }
                    if ($data.diagnosticsProfile.bootDiagnostics.enabled -eq $true) { $bootdg = $true }else { $bootdg = $false }

                    #Storage
                    if($data.storageProfile.osDisk.vhd.uri)
                        {
                            $OSDisk = 'Custom VHD'
                            $OSDiskSize = $data.storageProfile.osDisk.diskSizeGB
                        }
                    else
                        {
                            foreach ($VMDisk in $disk)
                                {
                                    if ($VMDisk.id -eq $data.storageProfile.osDisk.managedDisk.id)
                                        {
                                            $OSDisk = $VMDisk.sku.name
                                        }
                                    if ($VMDisk.id -eq $data.storageProfile.dataDisks.managedDisk.id)
                                        {
                                            $OSDiskSize = $VMDisk.properties.diskSizeGB
                                        }
                                }
                        }

                    if ($data.storageProfile.dataDisks.managedDisk.id)
                        {
                            if ($data.storageProfile.dataDisks.managedDisk.id.count -ge 2) 
                            { 
                                $StorAcc = ($data.storageProfile.dataDisks.managedDisk.id.count.ToString() + ' Disks found.')
                                foreach ($VMDisk in $disk)
                                    {
                                        if ($VMDisk.id -in $data.storageProfile.dataDisks.managedDisk.id)
                                            {
                                                $dataSize = ($VMDisk.properties.diskSizeGB | Measure-Object -Sum).Sum
                                            }
                                    }
                            }
                            else 
                            {
                                foreach ($VMDisk in $disk)
                                    {
                                        if ($VMDisk.id -eq $data.storageProfile.dataDisks.managedDisk.id)
                                            {
                                                $StorAcc = $VMDisk.sku.name
                                                $dataSize = $VMDisk.properties.diskSizeGB
                                            }
                                    }
                            }
                        }
                    else
                        {
                            $StorAcc = 'None'
                            $dataSize = '0'
                        }

                    $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    $VMNICS = if(![string]::IsNullOrEmpty($data.networkProfile.networkInterfaces.id)){$data.networkProfile.networkInterfaces.id}else{'0'}
                    foreach ($2 in $VMNICS) {

                        $vmnic = foreach ($netinterface in $nic) 
                            {
                                if ($netinterface.id -eq $2) { $netinterface }
                            }
                        $vmnic = $vmnic | Select-Object -Unique
                        $PIP = if(![string]::IsNullOrEmpty($vmnic.properties.ipConfigurations.properties.publicIPAddress.id)){$vmnic.properties.ipConfigurations.properties.publicIPAddress.id.split('/')[8]}else{''}
                        $VNET = if(![string]::IsNullOrEmpty($vmnic.properties.ipConfigurations.properties.subnet.id)){$vmnic.properties.ipConfigurations.properties.subnet.id.split('/')[8]}else{''}
                        $Subnet = if(![string]::IsNullOrEmpty($vmnic.properties.ipConfigurations.properties.subnet.id)){$vmnic.properties.ipConfigurations.properties.subnet.id.split('/')[10]} else {''}
                        $vmnet = foreach ($VMVnet in $VirtualNetwork)
                            {
                                if ($VMVnet.subnets.id -eq $vmnic.properties.ipConfigurations.properties.subnet.id) { $VMVnet }
                            }
                        $vmnetsubnet = $vmnet.properties.subnets | Where-Object {$_.id -eq $vmnic.properties.ipConfigurations.properties.subnet.id}

                        if(![string]::IsNullOrEmpty($vmnic.properties.dnsSettings.dnsServers))
                            {
                                $DNSServer = $vmnic.properties.dnsSettings.dnsServers
                            }
                        else
                            {
                                $DNSServer = $vmnet.properties.dhcpoptions.dnsservers
                            }

                        if(![string]::IsNullOrEmpty($DNSServer))
                            {
                                $FinalDNS = if ($DNSServer.count -gt 1) { $DNSServer | ForEach-Object { $_ + ' ,' } }else { $DNSServer }
                                $FinalDNS = [string]$FinalDNS
                                $FinalDNS = if ($FinalDNS -like '* ,*') { $FinalDNS -replace ".$" }else { $FinalDNS }
                                $FinalDNS = ('VNET: ( ' + $FinalDNS + ')')
                            }
                        else
                            {
                                $FinalDNS = 'Default (Azure-provided)'
                            }

                        if(![string]::IsNullOrEmpty($vmnic.properties.networkSecurityGroup.id))
                            {
                                $vmnsg = $vmnic.properties.networkSecurityGroup.id.split('/')[8]
                            }
                        elseif(![string]::IsNullOrEmpty($vmnetsubnet.properties.networksecuritygroup.id))
                            {
                                $vmnsg = ('Subnet: ('+$vmnetsubnet.properties.networksecuritygroup.id.split('/')[8]+')')
                            }
                        else
                            {
                                $vmnsg = 'None'
                            }
                        if(![string]::IsNullOrEmpty($vmnic.properties.enableAcceleratedNetworking))
                            {
                                $AcceleratedNetwork = $true
                            }
                        else
                            {
                                $AcceleratedNetwork = $false
                            }

                        foreach ($Tag in $Tags) 
                            {
                                $obj = @{
                                'ID'                                    = $1.id;
                                'Subscription'                          = $sub1.Name;
                                'Resource Group'                        = $1.RESOURCEGROUP;
                                'VM Name'                               = $1.NAME;
                                'Location'                              = $1.LOCATION;
                                'Retiring Feature'                      = $RetiringFeature;
                                'Retiring Date'                         = $RetiringDate;
                                'Availability Zone'                     = [string]$1.ZONES;
                                'Zones Available in the Region'         = [string]$VMExtraDetail.LocationInfo.ZoneDetails.Name;
                                'Availability Set'                      = $AVSET;
                                'VM Size'                               = $data.hardwareProfile.vmSize;
                                'Remaining Quota (vCPUs)'               = [string]$RemainingQuota;
                                'vCPUs'                                 = $vCPUs;
                                'vCPUs Per Core'                        = $vCPUsPerCore;
                                'RAM (GiB)'                             = $RAM;
                                'Max Remote Storage Disks'              = $MaxDataDiskCount;
                                'Uncached Disk IOPS Limit'              = $UncachedDiskIOPS;
                                'Uncached Disk Throughput Limit (MB/s)' = $UncachedDiskBytesPerSecond;
                                'Max Network Interfaces'                = $MaxNetworkInterfaces;
                                'Image Reference'                       = $data.storageProfile.imageReference.publisher;
                                'Image Version'                         = $data.storageProfile.imageReference.exactVersion;
                                'Capabilities'                          = [string]$VMExtraDetail.LocationInfo.ZoneDetails.Capabilities.Name;
                                'Hybrid Benefit'                        = $Lic;
                                'Admin Username'                        = $data.osProfile.adminUsername;
                                'OS Type'                               = $data.storageProfile.osDisk.osType;
                                'OS Name'                               = $OSName;
                                'OS Version'                            = $OSVersion;
                                'Automatic Update'                      = $Autoupdate;
                                'Boot Diagnostics'                      = $bootdg;
                                'Performance Agent'                     = if ($azDiag -ne '') { $true }else { $false };
                                'Azure Monitor'                         = if ($Azinsights -ne '') { $true }else { $false };
                                'OS Disk Storage Type'                  = $OSDisk;
                                'OS Disk Size (GB)'                     = $OSDiskSize;
                                'Data Disk Storage Type'                = $StorAcc;
                                'Data Disk Size (GB)'                   = $dataSize;
                                'VM generation'                         = $data.extended.instanceview.hypervgeneration;
                                'Power State'                           = $data.extended.instanceView.powerState.displayStatus;
                                'NIC Name'                              = [string]$vmnic.name;
                                'NIC Type'                              = [string]$vmnic.properties.nicType;
                                'DNS Servers'                           = $FinalDNS;
                                'Public IP'                             = $PIP;
                                'Virtual Network'                       = $VNET;
                                'Subnet'                                = $Subnet;
                                'NSG'                                   = $vmnsg;
                                'Accelerated Networking'                = $AcceleratedNetwork;
                                'IP Forwarding'                         = [string]$vmnic.properties.enableIPForwarding;
                                'Private IP Address'                    = [string]$vmnic.properties.ipConfigurations.properties.privateIPAddress;
                                'Private IP Allocation'                 = [string]$vmnic.properties.ipConfigurations.properties.privateIPAllocationMethod;
                                'Creation Time'                         = $timecreated;
                                'VM Extensions'                         = $ext;
                                'Resource U'                            = $ResUCount;
                                'Tag Name'                              = [string]$Tag.Name;
                                'Tag Value'                             = [string]$Tag.Value
                                }
                                if ($ResUCount -eq 1) { $ResUCount = 0 }
                                $obj
                            }
                        }
                    }
                $tmp
        }
}
else
{
    If($SmaResources)
        {

            $TableName = ('VMTable_'+($SmaResources.'Resource U').count)
            $Style = @()
            $Style += New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0' -VerticalAlignment Center
            $Style += New-ExcelStyle -HorizontalAlignment Left -Range AW:AW -Width 60 -WrapText

            $SheetName = 'Virtual Machines'

            $condtxt = @()
            #Automatic Updates
            $condtxt += New-ConditionalText false -Range V:V
            #Hybrid Benefit
            $condtxt += New-ConditionalText None -Range Y:Y
            #Boot Diagnostics
            $condtxt += New-ConditionalText false -Range AA:AA
            #Performance Agent
            $condtxt += New-ConditionalText false -Range AB:AB
            #Azure Monitor
            $condtxt += New-ConditionalText false -Range AC:AC
            #NSG
            $condtxt += New-ConditionalText None -Range AN:AN
            #Acelerated Network
            $condtxt += New-ConditionalText false -Range AQ:AQ
            #Retirement
            $condtxt += New-ConditionalText -Range M2:M100 -ConditionalType ContainsText

            $Exc = New-Object System.Collections.Generic.List[System.Object]
            $Exc.Add('Subscription')
            $Exc.Add('Resource Group')
            $Exc.Add('VM Name')
            $Exc.Add('VM Size')
            $Exc.Add('Remaining Quota (vCPUs)')
            $Exc.Add('vCPUs')
            $Exc.Add('vCPUs Per Core')
            $Exc.Add('RAM (GiB)')
            $Exc.Add('Max Remote Storage Disks')
            $Exc.Add('Uncached Disk IOPS Limit')
            $Exc.Add('Uncached Disk Throughput Limit (MB/s)')
            $Exc.Add('Max Network Interfaces')
            $Exc.Add('Retiring Feature')
            $Exc.Add('Retiring Date')
            $Exc.Add('Availability Zone')
            $Exc.Add('Zones Available in the Region')
            $Exc.Add('Capabilities')
            $Exc.Add('Location')
            $Exc.Add('OS Type')
            $Exc.Add('OS Name')
            $Exc.Add('OS Version')
            $Exc.Add('Automatic Update')
            $Exc.Add('Image Reference')
            $Exc.Add('Image Version')
            $Exc.Add('Hybrid Benefit')
            $Exc.Add('Admin Username')
            $Exc.Add('Boot Diagnostics')
            $Exc.Add('Performance Agent')
            $Exc.Add('Azure Monitor')
            $Exc.Add('OS Disk Storage Type')
            $Exc.Add('OS Disk Size (GB)')
            $Exc.Add('Data Disk Storage Type')
            $Exc.Add('Data Disk Size (GB)')
            $Exc.Add('VM generation')
            $Exc.Add('Power State')
            $Exc.Add('Availability Set')
            $Exc.Add('Virtual Network')
            $Exc.Add('Subnet')
            $Exc.Add('DNS Servers')
            $Exc.Add('NSG')
            $Exc.Add('NIC Name')
            $Exc.Add('NIC Type')
            $Exc.Add('Accelerated Networking')
            $Exc.Add('IP Forwarding')
            $Exc.Add('Private IP Address')
            $Exc.Add('Private IP Allocation')
            $Exc.Add('Public IP')
            $Exc.Add('Creation Time')                
            $Exc.Add('VM Extensions')
            $Exc.Add('Resource U')
            if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

            $noNumberConversion = @()
            $noNumberConversion += 'OS Version'
            $noNumberConversion += 'Image Version'
            $noNumberConversion += 'Private IP Address'
            $noNumberConversion += 'DNS Servers'

            [PSCustomObject]$SmaResources | 
            ForEach-Object { $_ } | Select-Object $Exc | 
            Export-Excel -Path $File -WorksheetName $SheetName -TableName $TableName -TableStyle $tableStyle -MaxAutoSizeRows 100 -ConditionalText $condtxt -Style $Style -NoNumberConversion $noNumberConversion

        }
}
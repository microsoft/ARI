<#
.Synopsis
Inventory for Azure Virtual Machine

.DESCRIPTION
This script consolidates information for all microsoft.compute/virtualmachines resource provider in $Resources variable. 
Excel Sheet Name: VM

.Link
https://github.com/microsoft/ARI/Modules/Compute/VM.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.1.6
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Task ,$File, $SmaResources, $TableStyle, $Unsupported)

If ($Task -eq 'Processing')
{

        $vm =  $Resources | Where-Object {$_.TYPE -eq 'microsoft.compute/virtualmachines'}
        $nic = $Resources | Where-Object {$_.TYPE -eq 'microsoft.network/networkinterfaces'}
        $vmexp = $Resources | Where-Object {$_.TYPE -eq 'microsoft.compute/virtualmachines/extensions'}
        $disk = $Resources | Where-Object {$_.TYPE -eq 'microsoft.compute/disks'}
        $VirtualNetwork = $Resources | Where-Object { $_.TYPE -eq 'microsoft.network/virtualnetworks' }
        $vmsizemap = @{}
        foreach($location in ($vm | Select-Object -ExpandProperty location -Unique))
            {
                foreach ($vmsize in ( az vm list-sizes -l $location | ConvertFrom-Json))
                    {
                        $vmsizemap[$vmsize.name] = @{
                            CPU = $vmSize.numberOfCores
                            RAM = [math]::Round($vmSize.memoryInMB / 1024, 0) 
                        }
                    }
            }

    if($vm)
        {    
            $tmp = @()

            foreach ($1 in $vm) 
                {
                    $ResUCount = 1
                    $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                    $data = $1.PROPERTIES
                    $timecreated = $data.timeCreated
                    $timecreated = [datetime]$timecreated
                    $timecreated = $timecreated.ToString("yyyy-MM-dd HH:mm")
                    $dataSize = ''
                    $StorAcc = ''

                    #Retirements Validation
                    $RetDate = ''
                    $RetFeature = '' 
                    if($data.hardwareProfile.vmSize -in ('basic_a0','basic_a1','basic_a2','basic_a3','basic_a4','standard_a0','standard_a1','standard_a2','standard_a3','standard_a4','standard_a5','standard_a6','standard_a7','standard_a9') -or $1.sku.name -in ('basic_a0','basic_a1','basic_a2','basic_a3','basic_a4','standard_a0','standard_a1','standard_a2','standard_a3','standard_a4','standard_a5','standard_a6','standard_a7','standard_a9'))
                        {
                            $RetDate = ($Unsupported | Where-Object {$_.Id -eq 1}).RetirementDate
                            $RetFeature = ($Unsupported | Where-Object {$_.Id -eq 1}).RetiringFeature
                        }
                    if($data.hardwareProfile.vmSize -in ('Standard_NV12','Standard_NV12_Promo','Standard_NV24','Standard_NV24_Promo','Standard_NV6','Standard_NV6_Promo') -or $1.sku.name -in ('Standard_NV12','Standard_NV12_Promo','Standard_NV24','Standard_NV24_Promo','Standard_NV6','Standard_NV6_Promo'))
                        {
                            $RetDate = ($Unsupported | Where-Object {$_.Id -eq 18}).RetirementDate
                            $RetFeature = ($Unsupported | Where-Object {$_.Id -eq 18}).RetiringFeature
                        }
                    if($data.hardwareProfile.vmSize -in ('Standard_NC6','Standard_NC6_Promo','Standard_NC12','Standard_NC12_Promo','Standard_NC24','Standard_NC24_Promo','Standard_NC24r','Standard_NC24r_Promo') -or $1.sku.name -in ('Standard_NC6','Standard_NC6_Promo','Standard_NC12','Standard_NC12_Promo','Standard_NC24','Standard_NC24_Promo','Standard_NC24r','Standard_NC24r_Promo'))
                        {
                            $RetDate = ($Unsupported | Where-Object {$_.Id -eq 37}).RetirementDate
                            $RetFeature = ($Unsupported | Where-Object {$_.Id -eq 37}).RetiringFeature
                        }
                    if($data.hardwareProfile.vmSize -in ('Standard_NC6s_v2','Standard_NC12s_v2','Standard_NC24s_v2','Standard_NC24rs_v2') -or $1.sku.name -in ('Standard_NC6s_v2','Standard_NC12s_v2','Standard_NC24s_v2','Standard_NC24rs_v2'))
                        {
                            $RetDate = ($Unsupported | Where-Object {$_.Id -eq 38}).RetirementDate
                            $RetFeature = ($Unsupported | Where-Object {$_.Id -eq 38}).RetiringFeature
                        }
                    if($data.hardwareProfile.vmSize -in ('Standard_ND6','Standard_ND12','Standard_ND24','Standard_ND24r') -or $1.sku.name -in ('Standard_ND6','Standard_ND12','Standard_ND24','Standard_ND24r'))
                        {
                            $RetDate = ($Unsupported | Where-Object {$_.Id -eq 39}).RetirementDate
                            $RetFeature = ($Unsupported | Where-Object {$_.Id -eq 39}).RetiringFeature
                        }
                    if($data.hardwareProfile.vmSize -in ('Standard_HB60rs','Standard_HB60-45rs','Standard_HB60-30rs','Standard_HB60-15rs') -or $1.sku.name -in ('Standard_HB60rs','Standard_HB60-45rs','Standard_HB60-30rs','Standard_HB60-15rs'))
                        {
                            $RetDate = ($Unsupported | Where-Object {$_.Id -eq 40}).RetirementDate
                            $RetFeature = ($Unsupported | Where-Object {$_.Id -eq 40}).RetiringFeature
                        }
                    if(!$data.storageProfile.osDisk.managedDisk.id)
                        {
                            $RetDate = ($Unsupported | Where-Object {$_.Id -eq 4}).RetirementDate
                            $RetFeature = ($Unsupported | Where-Object {$_.Id -eq 4}).RetiringFeature
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
                    $ext = ($vmexp | Where-Object { ($_.id -split "/")[8] -eq $1.name }).properties.Publisher
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
                    if($data.storageProfile.osDisk.managedDisk.id) 
                        {
                            $OSDisk = ($disk | Where-Object {$_.id -eq $data.storageProfile.osDisk.managedDisk.id} | Select-Object -Unique).sku.name
                            $OSDiskSize = ($disk | Where-Object {$_.id -eq $data.storageProfile.osDisk.managedDisk.id} | Select-Object -Unique).Properties.diskSizeGB
                        }
                    else
                        {
                            $OSDisk = if($data.storageProfile.osDisk.vhd.uri){'Custom VHD'}else{''}
                            $OSDiskSize = $data.storageProfile.osDisk.diskSizeGB
                        }
                    $StorAcc = if ($data.storageProfile.dataDisks.managedDisk.id.count -ge 2) 
                                { 
                                    ($data.storageProfile.dataDisks.managedDisk.id.count.ToString() + ' Disks found.') 
                                }
                                else 
                                { 
                                    ($disk | Where-Object {$_.id -eq $data.storageProfile.dataDisks.managedDisk.id} | Select-Object -Unique).sku.name
                                }
                    $dataSize = if ($data.storageProfile.dataDisks.managedDisk.storageAccountType.count -ge 2) 
                                { 
                                    (($disk | Where-Object {$_.id -in $data.storageProfile.dataDisks.managedDisk.id}).properties.diskSizeGB | Measure-Object -Sum).Sum
                                }
                                else 
                                { 
                                    ($disk | Where-Object {$_.id -eq $data.storageProfile.dataDisks.managedDisk.id}).properties.diskSizeGB
                                }

                    $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    $VMNICS = if(![string]::IsNullOrEmpty($data.networkProfile.networkInterfaces.id)){$data.networkProfile.networkInterfaces.id}else{'0'}
                    foreach ($2 in $VMNICS) {

                        $vmnic = $nic | Where-Object { $_.ID -eq $2 } | Select-Object -Unique
                        $PIP = if(![string]::IsNullOrEmpty($vmnic.properties.ipConfigurations.properties.publicIPAddress.id)){$vmnic.properties.ipConfigurations.properties.publicIPAddress.id.split('/')[8]}else{''}
                        $VNET = if(![string]::IsNullOrEmpty($vmnic.properties.ipConfigurations.properties.subnet.id)){$vmnic.properties.ipConfigurations.properties.subnet.id.split('/')[8]}else{''}
                        $Subnet = if(![string]::IsNullOrEmpty($vmnic.properties.ipConfigurations.properties.subnet.id)){$vmnic.properties.ipConfigurations.properties.subnet.id.split('/')[10]} else {''}
                        $vmnet = $VirtualNetwork | Where-Object {$_.properties.subnets.id -eq $vmnic.properties.ipConfigurations.properties.subnet.id}
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

                        foreach ($Tag in $Tags) 
                            {
                                $obj = @{
                                'ID'                            = $1.id;
                                'Subscription'                  = $sub1.Name;
                                'Resource Group'                = $1.RESOURCEGROUP;
                                'VM Name'                       = $1.NAME;
                                'Location'                      = $1.LOCATION;
                                'Zone'                          = [string]$1.ZONES;
                                'Availability Set'              = $AVSET;
                                'VM Size'                       = $data.hardwareProfile.vmSize;
                                'vCPUs'                         = $vmsizemap[$data.hardwareProfile.vmSize].CPU;
                                'RAM (GiB)'                     = $vmsizemap[$data.hardwareProfile.vmSize].RAM;
                                'Image Reference'               = $data.storageProfile.imageReference.publisher;
                                'Image Version'                 = $data.storageProfile.imageReference.exactVersion;
                                'Hybrid Benefit'                = $Lic;
                                'Admin Username'                = $data.osProfile.adminUsername;
                                'OS Type'                       = $data.storageProfile.osDisk.osType;
                                'OS Name'                       = $data.extended.instanceView.osname;
                                'OS Version'                    = $data.extended.instanceView.osversion;
                                'Automatic Update'              = $Autoupdate;
                                'Retirement Date'               = [string]$RetDate;
                                'Retirement Feature'            = $RetFeature;
                                'Boot Diagnostics'              = $bootdg;
                                'Performance Agent'             = if ($azDiag -ne '') { $true }else { $false };
                                'Azure Monitor'                 = if ($Azinsights -ne '') { $true }else { $false };
                                'OS Disk Storage Type'          = $OSDisk;
                                'OS Disk Size (GB)'             = $OSDiskSize;
                                'Data Disk Storage Type'        = $StorAcc;
                                'Data Disk Size (GB)'           = $dataSize;
                                'VM generation'                 = $data.extended.instanceview.hypervgeneration;
                                'Power State'                   = $data.extended.instanceView.powerState.displayStatus;
                                'NIC Name'                      = [string]$vmnic.name;
                                'NIC Type'                      = [string]$vmnic.properties.nicType;
                                'DNS Servers'                   = $FinalDNS;
                                'Public IP'                     = $PIP;
                                'Virtual Network'               = $VNET;
                                'Subnet'                        = $Subnet;
                                'NSG'                           = $vmnsg;
                                'Accelerated Networking'        = [string]$vmnic.properties.enableAcceleratedNetworking;
                                'IP Forwarding'                 = [string]$vmnic.properties.enableIPForwarding;
                                'Private IP Address'            = [string]$vmnic.properties.ipConfigurations.properties.privateIPAddress;
                                'Private IP Allocation'         = [string]$vmnic.properties.ipConfigurations.properties.privateIPAllocationMethod;
                                'Created Time'                  = $timecreated;
                                'VM Extensions'                 = $ext;
                                'Resource U'                    = $ResUCount;
                                'Tag Name'                      = [string]$Tag.Name;
                                'Tag Value'                     = [string]$Tag.Value
                                }
                                $tmp += $obj
                                if ($ResUCount -eq 1) { $ResUCount = 0 } 
                            }
                        }
                    }
                    $tmp
        }
}
else
{
    If($SmaResources.VM)
        {
            $TableName = ('VMTable_'+($SmaResources.VM.id | Select-Object -Unique).count)
            $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0' -VerticalAlignment Center
            $StyleExt = New-ExcelStyle -HorizontalAlignment Left -Range AO:AO -Width 60 -WrapText 

                $cond = @()
                #Automatic Updates
                $cond += New-ConditionalText false -Range K:K
                #Hybrid Benefit
                $cond += New-ConditionalText None -Range P:P
                #Boot Diagnostics
                $cond += New-ConditionalText false -Range R:R
                #Performance Agent
                $cond += New-ConditionalText false -Range S:S
                #Azure Monitor
                $cond += New-ConditionalText false -Range T:T
                #NSG
                $cond += New-ConditionalText None -Range AF:AF
                #Acelerated Network
                $cond += New-ConditionalText false -Range AI:AI
                #Retirement
                $cond += New-ConditionalText - -Range N:N -ConditionalType ContainsText

                $Exc = New-Object System.Collections.Generic.List[System.Object]
                $Exc.Add('Subscription')
                $Exc.Add('Resource Group')
                $Exc.Add('VM Name')
                $Exc.Add('VM Size')
                $Exc.Add('vCPUs')
                $Exc.Add('RAM (GiB)')
                $Exc.Add('Location')
                $Exc.Add('OS Type')
                $Exc.Add('OS Name')
                $Exc.Add('OS Version')
                $Exc.Add('Automatic Update')
                $Exc.Add('Image Reference')
                $Exc.Add('Image Version')
                $Exc.Add('Retirement Date')
                $Exc.Add('Retirement Feature')
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
                $Exc.Add('Zone')    
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
                $Exc.Add('Created Time')                
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

                $ExcelVar = $SmaResources.VM
                            
                $ExcelVar | 
                ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
                Export-Excel -Path $File -WorksheetName 'Virtual Machines' -TableName $TableName -MaxAutoSizeRows 100 -TableStyle $tableStyle -ConditionalText $cond -Style $Style, $StyleExt -NoNumberConversion $noNumberConversion

                $excel = Open-ExcelPackage -Path $File -KillExcel
    
                $null = $excel.'Virtual Machines'.Cells["N1"].AddComment("It's important to be aware of upcoming Azure services and feature retirements to understand their impact on your workloads and plan migration.", "Azure Resource Inventory")
                $excel.'Virtual Machines'.Cells["N1"].Hyperlink = 'https://learn.microsoft.com/en-us/azure/advisor/advisor-how-to-plan-migration-workloads-service-retirement'
                $null = $excel.'Virtual Machines'.Cells["R1"].AddComment("Boot diagnostics is a debugging feature for Azure virtual machines (VM) that allows diagnosis of VM boot failures.", "Azure Resource Inventory")
                $excel.'Virtual Machines'.Cells["R1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/virtual-machines/boot-diagnostics'
                $null = $excel.'Virtual Machines'.Cells["S1"].AddComment("Is recommended to install Performance Diagnostics Agent in every Azure Virtual Machine upfront. The agent is only used when triggered by the console and may save time in an event of performance struggling.", "Azure Resource Inventory")
                $excel.'Virtual Machines'.Cells["S1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/virtual-machines/troubleshooting/performance-diagnostics'
                $null = $excel.'Virtual Machines'.Cells["T1"].AddComment("We recommend that you use Azure Monitor to gain visibility into your resource's health.", "Azure Resource Inventory")
                $excel.'Virtual Machines'.Cells["T1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/security/fundamentals/iaas#monitor-vm-performance'
                $null = $excel.'Virtual Machines'.Cells["AF1"].AddComment("Use a network security group to protect against unsolicited traffic into Azure subnets. Network security groups are simple, stateful packet inspection devices that use the 5-tuple approach (source IP, source port, destination IP, destination port, and layer 4 protocol) to create allow/deny rules for network traffic.", "Azure Resource Inventory")
                $excel.'Virtual Machines'.Cells["AF1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/security/fundamentals/network-best-practices#logically-segment-subnets'
                $null = $excel.'Virtual Machines'.Cells["AI1"].AddComment("Accelerated networking enables single root I/O virtualization (SR-IOV) to a VM, greatly improving its networking performance. This high-performance path bypasses the host from the datapath, reducing latency, jitter, and CPU utilization.", "Azure Resource Inventory")
                $excel.'Virtual Machines'.Cells["AI1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/virtual-network/create-vm-accelerated-networking-cli'

            Close-ExcelPackage $excel
        }             

}
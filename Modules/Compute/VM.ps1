<#
.Synopsis
Inventory for Azure Virtual Machine

.DESCRIPTION
This script consolidates information for all microsoft.compute/virtualmachines resource provider in $Resources variable. 
Excel Sheet Name: VM

.Link
https://github.com/azureinventory/ARI/Modules/Compute/VM.ps1

.COMPONENT
   This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 2.0.0
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Task ,$File, $SmaResources, $TableStyle,$Unsupported) 
If ($Task -eq 'Processing')
{

        $vm =  $Resources | Where-Object {$_.TYPE -eq 'microsoft.compute/virtualmachines'}
        $nic = $Resources | Where-Object {$_.TYPE -eq 'microsoft.network/networkinterfaces'}
        $vmexp = $Resources | Where-Object {$_.TYPE -eq 'microsoft.compute/virtualmachines/extensions'}
        $disk = $Resources | Where-Object {$_.TYPE -eq 'microsoft.compute/disks'}    


    if($vm)
        {    
            $tmp = @()

            foreach ($1 in $vm) 
                {

                    $ResUCount = 1
                    $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                    $data = $1.PROPERTIES 
                    $AVSET = ''
                    $dataSize = ''
                    $StorAcc = ''
                    $UpdateMgmt = if ($null -eq $data.osProfile.LinuxConfiguration.patchSettings.patchMode) { $data.osProfile.WindowsConfiguration.patchSettings.patchMode } else { $data.osProfile.LinuxConfiguration.patchSettings.patchMode }

                    $ext = @()
                    $AzDiag = ''
                    $Azinsights = ''
                    $Lic = if($data.licensetype){$data.licensetype}else{'None'}
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
                                        
                    if ($null -ne $data.availabilitySet) { $AVSET = 'True' }else { $AVSET = 'False' }
                    if ($data.diagnosticsProfile.bootDiagnostics.enabled -eq $true) { $bootdg = $true }else { $bootdg = $false }
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
                        $vmnsg = if($vmnic.properties.networkSecurityGroup.id){$vmnic.properties.networkSecurityGroup.id.split('/')[8]}else{'None'}
                        $PIP = $vmnic.properties.ipConfigurations.properties.publicIPAddress.id.split('/')[8]
                        $VNET = $vmnic.properties.ipConfigurations.properties.subnet.id.split('/')[8]
                        $Subnet = $vmnic.properties.ipConfigurations.properties.subnet.id.split('/')[10]

                        foreach ($Tag in $Tags) 
                            {
                                $obj = @{
                                'Subscription'                  = $sub1.name;
                                'Resource Group'                = $1.RESOURCEGROUP;
                                'VM Name'                       = $1.NAME;
                                'Location'                      = $1.LOCATION;
                                'Zone'                          = [string]$1.ZONES;
                                'Availability Set'              = $AVSET;
                                'VM Size'                       = $data.hardwareProfile.vmSize;
                                'Image Reference'               = $data.storageProfile.imageReference.publisher;
                                'Image Version'                 = $data.storageProfile.imageReference.exactVersion;
                                'Hybrid Benefit'                = $Lic;
                                'Admin Username'                = $data.osProfile.adminUsername;
                                'OS Type'                       = $data.storageProfile.osDisk.osType;
                                'Update Management'             = $UpdateMgmt;
                                'Boot Diagnostics'              = $bootdg;
                                'Performance Agent'             = if ($azDiag -ne '') { $true }else { $false };
                                'Azure Monitor'                 = if ($Azinsights -ne '') { $true }else { $false };
                                'OS Disk Storage Type'          = $OSDisk;
                                'OS Disk Size (GB)'             = $OSDiskSize;
                                'Data Disk Storage Type'        = $StorAcc;
                                'Data Disk Size (GB)'           = $dataSize;
                                'Power State'                   = $data.extended.instanceView.powerState.displayStatus;
                                'NIC Name'                      = [string]$vmnic.name;
                                'NIC Type'                      = [string]$vmnic.properties.nicType;
                                'DNS Servers'                   = [string]$vmnic.properties.dnsSettings.dnsServers;
                                'Public IP'                     = $PIP;
                                'Virtual Network'               = $VNET;
                                'Subnet'                        = $Subnet;
                                'NSG'                           = $vmnsg;
                                'Accelerated Networking'        = [string]$vmnic.properties.enableAcceleratedNetworking;
                                'IP Forwarding'                 = [string]$vmnic.properties.enableIPForwarding;
                                'Private IP Address'            = $vmnic.properties.ipConfigurations.properties.privateIPAddress;
                                'Private IP Allocation'         = $vmnic.properties.ipConfigurations.properties.privateIPAllocationMethod;
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
            $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0' -VerticalAlignment Center
            $StyleExt = New-ExcelStyle -HorizontalAlignment Left -Range AF:AF -Width 60 -WrapText 

            $cond = @()
            Foreach ($UnSupOS in $Unsupported.Linux)
                {
                    #ImageVersion
                    $cond += New-ConditionalText $UnSupOS -Range H:H
                }

            #Hybrid Benefit
            $cond += New-ConditionalText None -Range I:I
            #NSG
            $cond += New-ConditionalText None -Range Y:Y
            #Boot Diagnostics
            $cond += New-ConditionalText falso -Range L:L
            $cond += New-ConditionalText false -Range L:L
            #Performance Agent
            $cond += New-ConditionalText falso -Range M:M
            $cond += New-ConditionalText false -Range M:M
            #Azure Monitor
            $cond += New-ConditionalText falso -Range N:N
            $cond += New-ConditionalText false -Range N:N
            #Acelerated Network
            $cond += New-ConditionalText false -Range AA:AA
            $cond += New-ConditionalText falso -Range AA:AA


            $Exc = New-Object System.Collections.Generic.List[System.Object]
            $Exc.Add('Subscription')
            $Exc.Add('Resource Group')
            $Exc.Add('VM Name')
            $Exc.Add('VM Size')
            $Exc.Add('OS Type')
            $Exc.Add('Location')
            $Exc.Add('Image Reference')
            $Exc.Add('Image Version')
            $Exc.Add('Hybrid Benefit')
            $Exc.Add('Admin Username')
            $Exc.Add('Update Management')
            $Exc.Add('Boot Diagnostics')
            $Exc.Add('Performance Agent')
            $Exc.Add('Azure Monitor')
            $Exc.Add('OS Disk Storage Type')
            $Exc.Add('OS Disk Size (GB)')
            $Exc.Add('Data Disk Storage Type')
            $Exc.Add('Data Disk Size (GB)')
            $Exc.Add('Power State')
            $Exc.Add('Availability Set')
            $Exc.Add('Zone')    
            $Exc.Add('Virtual Network')
            $Exc.Add('Subnet')
            $Exc.Add('DNS Servers')
            $Exc.Add('NSG')
            $Exc.Add('NIC Name')
            $Exc.Add('Accelerated Networking')
            $Exc.Add('IP Forwarding')
            $Exc.Add('Private IP Address')
            $Exc.Add('Private IP Allocation')
            $Exc.Add('Public IP')
            $Exc.Add('VM Extensions')
            $Exc.Add('Resource U')
            if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

            $ExcelVar = $SmaResources.VM
                        
            $ExcelVar | 
            ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
            Export-Excel -Path $File -WorksheetName 'Virtual Machines' -TableName 'AzureVMs' -MaxAutoSizeRows 100 -TableStyle $tableStyle -ConditionalText $cond -Style $Style, $StyleExt
         
            $excel = Open-ExcelPackage -Path $File -KillExcel

            $null = $excel.'Virtual Machines'.Cells["L1"].AddComment("Boot diagnostics is a debugging feature for Azure virtual machines (VM) that allows diagnosis of VM boot failures.", "Azure Resource Inventory")
            $excel.'Virtual Machines'.Cells["L1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/virtual-machines/boot-diagnostics'
            $null = $excel.'Virtual Machines'.Cells["M1"].AddComment("Is recommended to install Performance Diagnostics Agent in every Azure Virtual Machine upfront. The agent is only used when triggered by the console and may save time in an event of performance struggling.", "Azure Resource Inventory")
            $excel.'Virtual Machines'.Cells["M1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/virtual-machines/troubleshooting/performance-diagnostics'
            $null = $excel.'Virtual Machines'.Cells["N1"].AddComment("We recommend that you use Azure Monitor to gain visibility into your resource’s health.", "Azure Resource Inventory")
            $excel.'Virtual Machines'.Cells["N1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/security/fundamentals/iaas#monitor-vm-performance'
            $null = $excel.'Virtual Machines'.Cells["Y1"].AddComment("Use a network security group to protect against unsolicited traffic into Azure subnets. Network security groups are simple, stateful packet inspection devices that use the 5-tuple approach (source IP, source port, destination IP, destination port, and layer 4 protocol) to create allow/deny rules for network traffic.", "Azure Resource Inventory")
            $excel.'Virtual Machines'.Cells["Y1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/security/fundamentals/network-best-practices#logically-segment-subnets'
            $null = $excel.'Virtual Machines'.Cells["AA1"].AddComment("Accelerated networking enables single root I/O virtualization (SR-IOV) to a VM, greatly improving its networking performance. This high-performance path bypasses the host from the datapath, reducing latency, jitter, and CPU utilization.", "Azure Resource Inventory")
            $excel.'Virtual Machines'.Cells["AA1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/virtual-network/create-vm-accelerated-networking-cli'

            Close-ExcelPackage $excel
        }             

}
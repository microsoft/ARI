<#
.Synopsis
Inventory for Azure Virtual Machine Scale Set

.DESCRIPTION
This script consolidates information for all microsoft.compute/virtualmachinescalesets resource provider in $Resources variable. 
Excel Sheet Name: VMSS

.Link
https://github.com/azureinventory/ARI/Modules/Compute/VMSS.ps1

.COMPONENT
   This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 2.0.0
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Task ,$File, $SmaResources, $TableStyle)
 
If ($Task -eq 'Processing')
{
 
    <######### Insert the resource extraction here ########>

        $vmss = $Resources | Where-Object {$_.TYPE -eq 'microsoft.compute/virtualmachinescalesets'}
        $AutoScale = $Resources | Where-Object {$_.TYPE -eq "microsoft.insights/autoscalesettings" -and $_.Properties.enabled -eq 'true'} 

    <######### Insert the resource Process here ########>

    if($vmss)
        {
            $tmp = @()

            foreach ($1 in $vmss) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $OS = $data.virtualMachineProfile.storageProfile.osDisk.osType
                $Scaling = ($AutoScale | Where-Object {$_.Properties.targetResourceUri -eq $1.id})
                if([string]::IsNullOrEmpty($Scaling)){$AutoSc = $false}else{$AutoSc = $true}
                $Diag = if($data.virtualMachineProfile.diagnosticsProfile){'Enabled'}else{'Disabled'}
                if($OS -eq 'Linux'){$PWD = $data.virtualMachineProfile.osProfile.linuxConfiguration.disablePasswordAuthentication}Else{$PWD = 'N/A'}
                $Subnet = $data.virtualMachineProfile.networkProfile.networkInterfaceConfigurations.properties.ipConfigurations.properties.subnet.id | Select-Object -Unique
                $VNET = $subnet.split('/')[8]
                $Subnet = $Subnet.split('/')[10]
                $ext = @()
                $ext = foreach ($ex in $1.Properties.virtualMachineProfile.extensionProfile.extensions.name) 
                                {
                                    $ex + ', '
                                }
                $NSG = $data.virtualMachineProfile.networkProfile.networkInterfaceConfigurations.properties.networkSecurityGroup.id.split('/')[8] 
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                foreach ($Tag in $Tags) {
                    $obj = @{
                        'Subscription'                  = $sub1.name;
                        'Resource Group'                = $1.RESOURCEGROUP;
                        'Name'                          = $1.NAME;
                        'Location'                      = $1.LOCATION;
                        'SKU Tier'                      = $1.sku.tier;
                        'Fault Domain'                  = $data.platformFaultDomainCount;
                        'Upgrade Policy'                = $data.upgradePolicy.mode;                                    
                        'Diagnostics'                   = $Diag;
                        'VM Size'                       = $1.sku.name;
                        'Instances'                     = $1.sku.capacity;
                        'Autoscale Enabled'             = $AutoSc;
                        'VM OS'                         = $OS;
                        'OS Image'                      = $data.virtualMachineProfile.storageProfile.imageReference.offer;
                        'Image Version'                 = $data.virtualMachineProfile.storageProfile.imageReference.sku;                            
                        'VM OS Disk Size (GB)'          = $data.virtualMachineProfile.storageProfile.osDisk.diskSizeGB;
                        'Disk Storage Account Type'     = $data.virtualMachineProfile.storageProfile.osDisk.managedDisk.storageAccountType;
                        'Disable Password Authentication'= $PWD;
                        'Custom DNS Servers'            = [string]$data.virtualMachineProfile.networkProfile.networkInterfaceConfigurations.properties.dnsSettings.dnsServers;
                        'Virtual Network'               = $VNET;
                        'Subnet'                        = $Subnet;
                        'Accelerated Networking Enabled'= $data.virtualMachineProfile.networkProfile.networkInterfaceConfigurations.properties.enableAcceleratedNetworking; 
                        'Network Security Group'        = $NSG;
                        'Extensions'                    = [string]$ext;
                        'Admin Username'                = $data.virtualMachineProfile.osProfile.adminUsername;
                        'VM Name Prefix'                = $data.virtualMachineProfile.osProfile.computerNamePrefix;
                        'Resource U'                    = $ResUCount;
                        'Tag Name'                      = [string]$Tag.Name;
                        'Tag Value'                     = [string]$Tag.Value
                    }
                    $tmp += $obj
                    if ($ResUCount -eq 1) { $ResUCount = 0 } 
                }
            }
            $tmp
        }
}

<######## Resource Excel Reporting Begins Here ########>

Else
{
    <######## $SmaResources.(RESOURCE FILE NAME) ##########>

    if($SmaResources.VMSS)
    {

        $Style = @()
        $Style += New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0' -Range A:V
        $Style += New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0.0' -Range X:Z
        $Style += New-ExcelStyle -HorizontalAlignment Left -Range W:W -Width 60 -WrapText 
                   
        $condtxt = @()       
        $condtxt += New-ConditionalText FALSE -Range K:K
        $condtxt += New-ConditionalText FALSO -Range K:K
        $condtxt += New-ConditionalText Disabled -Range H:H
        $condtxt += New-ConditionalText FALSE -Range U:U
        $condtxt += New-ConditionalText FALSO -Range U:U

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('SKU Tier')
        $Exc.Add('Fault Domain')
        $Exc.Add('Upgrade Policy')                                   
        $Exc.Add('Diagnostics')
        $Exc.Add('VM Size')
        $Exc.Add('Instances')
        $Exc.Add('Autoscale Enabled')
        $Exc.Add('VM OS')
        $Exc.Add('OS Image')
        $Exc.Add('Image Version')                        
        $Exc.Add('VM OS Disk Size (GB)')
        $Exc.Add('Disk Storage Account Type')
        $Exc.Add('Disable Password Authentication')
        $Exc.Add('Custom DNS Servers')
        $Exc.Add('Virtual Network')
        $Exc.Add('Subnet')
        $Exc.Add('Accelerated Networking Enabled')
        $Exc.Add('Network Security Group')
        $Exc.Add('Extensions')
        $Exc.Add('Admin Username')
        $Exc.Add('VM Name Prefix')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.VMSS 

        $ExcelVar | 
        ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        Export-Excel -Path $File -WorksheetName 'VM Scale Sets' -AutoSize -MaxAutoSizeRows 50 -TableName 'AzureVMSS' -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style

    }
}
<#
.Synopsis
Inventory for Azure VMWare Solution

.DESCRIPTION
This script consolidates information for all Microsoft.AVS/privateClouds resource provider in $Resources variable. 
Excel Sheet Name: VMWare

.Link
https://github.com/microsoft/ARI/Modules/Compute/VMWare.ps1

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

    <######### Insert the resource extraction here ########>

    $VMWare = $Resources | Where-Object { $_.TYPE -eq 'Microsoft.AVS/privateClouds' }

    if($VMWare)
        {
            $tmp = @()
            foreach ($1 in $VMWare) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $ER = $data.circuit.expressRouteID.split('/')[8]
                $externalCloud = $data.externalCloudLinks.count
                $identitySources = $data.identitySources.count
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) {
                        $obj = @{
                            'ID'                                = $1.id;
                            'Subscription'                      = $sub1.Name;
                            'Resource Group'                    = $1.RESOURCEGROUP;
                            'Name'                              = $1.NAME;
                            'Location'                          = $1.LOCATION;
                            'SKU'                               = $data.sku.name;
                            'Availability Strategy'             = $data.availability.strategy;
                            'Zone'                              = $data.availability.zone;
                            'Express Route Circuit'             = $ER;
                            'Encryption'                        = $data.encryption.status;
                            'External Cloud Links'              = [string]$externalCloud;
                            'Identity Sources'                  = [string]$identitySources;
                            'Internet'                          = $data.internet;
                            'Cluster Size'                      = $data.managementCluster.clusterSize;
                            'Management Network'                = $data.managementNetwork;
                            'Network Block'                     = $data.networkBlock;
                            'Provisioning Network'              = $data.provisioningNetwork;
                            'vMotion Network'                   = $data.vmotionNetwork;
                            'HCX Cloud Manager'                 = $data.endpoints.hcxCloudManager;
                            'NSXT Manager'                      = $data.endpoints.nsxtManager;
                            'VCSA'                              = $data.endpoints.vcsa;
                            'Tag Name'                          = [string]$Tag.Name;
                            'Tag Value'                         = [string]$Tag.Value
                        }
                        $tmp += $obj
                        if ($ResUCount -eq 1) { $ResUCount = 0 } 
                    }                
            }
            $tmp
        }
}
<######## Resource Excel Reporting Begins Here ########>

Else {
    <######## $SmaResources.VMWare ##########>

    if ($SmaResources.VMWare) {

        $TableName = ('VMWareTable_'+($SmaResources.VMWare.id | Select-Object -Unique).count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0
        
        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('SKU')
        $Exc.Add('Availability Strategy')
        $Exc.Add('Zone')
        $Exc.Add('Express Route Circuit')
        $Exc.Add('Encryption')
        $Exc.Add('External Cloud Links')
        $Exc.Add('Identity Sources')
        $Exc.Add('Internet')
        $Exc.Add('Cluster Size')
        $Exc.Add('Management Network')
        $Exc.Add('Network Block')
        $Exc.Add('Provisioning Network')
        $Exc.Add('vMotion Network')
        $Exc.Add('HCX Cloud Manager')
        $Exc.Add('NSXT Manager')
        $Exc.Add('VCSA')        
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.VMWare 

        $ExcelVar | 
        ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        Export-Excel -Path $File -WorksheetName 'VMWare' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -Style $Style

    }
    <######## Insert Column comments and documentations here following this model #########>
}
<#
.Synopsis
Inventory for Azure VMWare Solution

.DESCRIPTION
This script consolidates information for all Microsoft.AVS/privateClouds resource provider in $Resources variable. 
Excel Sheet Name: VMWare

.Link
https://github.com/microsoft/ARI/Modules/Public/InventoryModules/Compute/VMWare.ps1

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

    <######### Insert the resource extraction here ########>

    $VMWare = $Resources | Where-Object { $_.TYPE -eq 'Microsoft.AVS/privateClouds' }

    if($VMWare)
        {
            $tmp = foreach ($1 in $VMWare) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
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
                            'Retiring Feature'                  = $RetiringFeature;
                            'Retiring Date'                     = $RetiringDate;
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
                            'Resource U'                        = $ResUCount;
                            'Tag Name'                          = [string]$Tag.Name;
                            'Tag Value'                         = [string]$Tag.Value
                        }
                        $obj
                        if ($ResUCount -eq 1) { $ResUCount = 0 } 
                    }                
            }
            $tmp
        }
}
<######## Resource Excel Reporting Begins Here ########>

Else {
    <######## $SmaResources.VMWare ##########>

    if ($SmaResources) {

        $TableName = ('VMWareTable_'+($SmaResources.'Resource U').count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

        $condtxt = @()
        #Retirement
        $condtxt += New-ConditionalText -Range F2:F100 -ConditionalType ContainsText
        
        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('SKU')
        $Exc.Add('Retiring Feature')
        $Exc.Add('Retiring Date')
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

        [PSCustomObject]$SmaResources | 
        ForEach-Object { $_ } | Select-Object $Exc | 
        Export-Excel -Path $File -WorksheetName 'VMWare' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -ConditionalText $condtxt -TableStyle $tableStyle -Style $Style

    }
}
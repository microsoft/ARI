<#
.Synopsis
Inventory for Azure RedHat OpenShift

.DESCRIPTION
This script consolidates information for all microsoft.redhatopenshift/openshiftclusters resource provider in $Resources variable. 
Excel Sheet Name: ARO

.Link
https://github.com/microsoft/ARI/Modules/Public/InventoryModules/Container/ARO.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.0
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Retirements, $Task, $File, $SmaResources, $TableStyle, $Unsupported)

If ($Task -eq 'Processing') {

    <######### Insert the resource extraction here ########>

    $ARO = $Resources | Where-Object { $_.TYPE -eq 'microsoft.redhatopenshift/openshiftclusters' }

    <######### Insert the resource Process here ########>

    if($ARO)
        {
            $tmp = foreach ($1 in $ARO) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
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
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) {
                        $obj = @{
                            'ID'                   = $1.id;
                            'Subscription'         = $sub1.Name;
                            'Resource Group'       = $1.RESOURCEGROUP;
                            'Clusters'             = $1.NAME;
                            'Location'             = $1.LOCATION;
                            'Retiring Feature'     = $RetiringFeature;
                            'Retiring Date'        = $RetiringDate;
                            'ARO Version'          = $data.clusterProfile.version;
                            'ARO Domain'           = $data.clusterProfile.domain;
                            'Outbound Type'        = $data.networkProfile.outboundType;
                            'Ingress Profile Name' = $data.ingressProfiles.name;
                            'Ingress Profile type' = $data.ingressProfiles.visibility;
                            'Ingress Profile IP'   = $data.ingressProfiles.ip;
                            'API Server type'      = $data.apiserverProfile.visibility;
                            'API Server URL'       = $data.apiserverProfile.url;
                            'API Server IP'        = $data.apiserverProfile.ip;
                            'Docker Pod Cidr'      = $data.networkProfile.podCidr;
                            'Service Cidr'         = $data.networkProfile.serviceCidr;
                            'Console URL'          = $data.consoleProfile.url;                   
                            'Master SKU'           = $data.masterProfile.vmSize;
                            'Master vNET'          = if($data.masterProfile.subnetId){$data.masterProfile.subnetId.split("/")[8]};
                            'Master Subnet'        = if($data.masterProfile.subnetId){$data.masterProfile.subnetId.split("/")[10]};                    
                            'Worker SKU'           = $data.workerProfiles.vmSize | Select-Object -Unique;        
                            'Worker DiskSize'      = $data.workerProfiles.diskSizeGB | Select-Object -Unique;        
                            'Total Worker Nodes'   = $data.workerProfiles.count;        
                            'Worker vNET'          = $data.workerProfiles.subnetId | ForEach-Object { $_.split("/")[8] } | Select-Object -Unique; 
                            'Worker Subnet'        = $data.workerProfiles.subnetId | ForEach-Object { $_.split("/")[10] } | Select-Object -Unique;       
                            'Resource U'           = $ResUCount;
                            'Tag Name'             = [string]$Tag.Name;
                            'Tag Value'            = [string]$Tag.Value
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
    <######## $SmaResources.(RESOURCE FILE NAME) ##########>

    if ($SmaResources) {

        $TableName = ('AROTable_'+($SmaResources.'Resource U').count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

        $condtxt = @()
        #Retirement
        $condtxt += New-ConditionalText -Range E2:E100 -ConditionalType ContainsText

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Clusters')         
        $Exc.Add('Location')
        $Exc.Add('Retiring Feature')
        $Exc.Add('Retiring Date')        
        $Exc.Add('ARO Version')          
        $Exc.Add('ARO Domain')           
        $Exc.Add('Outbound Type')        
        $Exc.Add('Ingress Profile Name')
        $Exc.Add('Ingress Profile type') 
        $Exc.Add('Ingress Profile IP')   
        $Exc.Add('API Server type')      
        $Exc.Add('API Server URL')       
        $Exc.Add('API Server IP')        
        $Exc.Add('Docker Pod Cidr')      
        $Exc.Add('Service Cidr')         
        $Exc.Add('Console URL')                
        $Exc.Add('Master SKU')           
        $Exc.Add('Master vNET')          
        $Exc.Add('Master Subnet')                     
        $Exc.Add('Worker SKU')           
        $Exc.Add('Worker DiskSize')        
        $Exc.Add('Total Worker Nodes')   
        $Exc.Add('Worker vNET')          
        $Exc.Add('Worker Subnet')
        if($InTag)
        {
            $Exc.Add('Tag Name')
            $Exc.Add('Tag Value') 
        }

        [PSCustomObject]$SmaResources | 
        ForEach-Object { $_ } | Select-Object $Exc | 
        Export-Excel -Path $File -WorksheetName 'ARO' -AutoSize -TableName $TableName -MaxAutoSizeRows 100 -TableStyle $tableStyle -ConditionalText $condtxt -Numberformat '0' -Style $Style
    }
}
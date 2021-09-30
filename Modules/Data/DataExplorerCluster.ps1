<#
.Synopsis
Inventory for Azure Data Explorer

.DESCRIPTION
This script consolidates information for all microsoft.kusto/clusters resource provider in $Resources variable. 
Excel Sheet Name: DataExplorerCluster

.Link
https://github.com/azureinventory/ARI/Modules/Data/DataExplorerCluster.ps1

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

    $DataExplorer = $Resources | Where-Object { $_.TYPE -eq 'microsoft.kusto/clusters' }

    if($DataExplorer)
        {
            $tmp = @()

            foreach ($1 in $DataExplorer) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $sku = $1.SKU
                $VNET = $data.virtualNetworkConfiguration.subnetid.split('/')[8]
                $Subnet = $data.virtualNetworkConfiguration.subnetid.split('/')[10]
                $DataPIP = $data.virtualNetworkConfiguration.dataManagementPublicIpId.split('/')[8]
                $EnginePIP = $data.virtualNetworkConfiguration.enginePublicIpId.split('/')[8]
                $TenantPerm = if($data.trustedExternalTenants.value -eq '*'){'All Tenants'}else{$data.trustedExternalTenants.value}
                $AutoScale = if($data.optimizedAutoscale.isEnabled -eq 'true'){'Enabled'}else{'Disabled'}
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) {
                        $obj = @{
                            'Subscription'              = $sub1.name;
                            'Resource Group'            = $1.RESOURCEGROUP;
                            'Name'                      = $1.NAME;
                            'Location'                  = $1.LOCATION;
                            'Compute specifications'    = $sku.name;
                            'Instance count'            = $sku.capacity;
                            'State'                     = $data.state;
                            'State Reason'              = $data.stateReason;
                            'Virtual Network'           = $VNET;
                            'Subnet'                    = $Subnet;
                            'Data Management Public IP' = $DataPIP;
                            'Engine Public IP'          = $EnginePIP;
                            'Tenants Permissions'       = $TenantPerm;
                            'Disk Encryption'           = $data.enableDiskEncryption;
                            'Streaming Ingestion'       = $data.enableStreamingIngest;
                            'Optimized Autoscale'       = $AutoScale;
                            'Optimized Autoscale Min'   = $data.optimizedAutoscale.minimum;
                            'Optimized Autoscale Max'   = $data.optimizedAutoscale.maximum;
                            'URI'                       = $data.uri;
                            'Data Ingestion Uri'        = $data.dataIngestionUri;
                            'Resource U'                = $ResUCount;
                            'Tag Name'                  = [string]$Tag.Name;
                            'Tag Value'                 = [string]$Tag.Value
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
    <######## $SmaResources.(RESOURCE FILE NAME) ##########>

    if ($SmaResources.DataExplorerCluster) {
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0
        
        $condtxt = @()
        
        $condtxt += New-ConditionalText 'All Tenants' -Range M:M
        $condtxt += New-ConditionalText FALSO -Range N:N
        $condtxt += New-ConditionalText FALSE -Range N:N
        $condtxt += New-ConditionalText Disabled -Range P:P


        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('Compute specifications')
        $Exc.Add('Instance count')
        $Exc.Add('State')
        $Exc.Add('State Reason')
        $Exc.Add('Virtual Network')
        $Exc.Add('Subnet')
        $Exc.Add('Data Management Public IP')
        $Exc.Add('Engine Public IP')
        $Exc.Add('Tenants Permissions')
        $Exc.Add('Disk Encryption')
        $Exc.Add('Streaming Ingestion')
        $Exc.Add('Optimized Autoscale')
        $Exc.Add('Optimized Autoscale Min')
        $Exc.Add('Optimized Autoscale Max')
        $Exc.Add('URI')
        $Exc.Add('Data Ingestion Uri')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.DataExplorerCluster 

        $ExcelVar | 
        ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        Export-Excel -Path $File -WorksheetName 'Data Explorer Clusters' -AutoSize -MaxAutoSizeRows 100 -TableName 'AzureKusto' -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style

    }
    <######## Insert Column comments and documentations here following this model #########>
}
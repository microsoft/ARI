<#
.Synopsis
Inventory for Azure IOT

.DESCRIPTION
This script consolidates information for all microsoft.devices/iothubs resource provider in $Resources variable. 
Excel Sheet Name: CONTAINER

.Link
https://github.com/azureinventory/ARI/Modules/Compute/IoT.ps1

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
        
        $IoT = $Resources | Where-Object {$_.TYPE -eq 'microsoft.devices/iothubs'}

    <######### Insert the resource Process here ########>

    if($IoT)
        {
            $tmp = @()
            
            foreach ($1 in $IoT) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) {
                        $obj = @{
                            'Subscription'                     = $sub1.name;
                            'Resource Group'                   = $1.RESOURCEGROUP;
                            'Name'                             = $1.NAME;
                            'HostName'                         = $data.hostname;
                            'State'                            = $data.state;
                            'SKU'                              = $1.sku.name;
                            'SKU Tier'                         = $1.sku.tier;
                            'SKU Capacity'                     = $1.sku.capacity;
                            'Features'                         = $data.features;
                            'Enable File Upload Notifications' = $data.enableFileUploadNotifications;
                            'Default TTL As ISO8601'           = $data.cloudToDevice.defaultTtlAsIso8601;
                            'Max Delivery Count'               = $data.cloudToDevice.maxDeliveryCount;
                            'EventHubs Endpoint'               = $data.eventHubEndpoints.events.endpoint;
                            'EventHubs Partition Count'        = $data.eventHubEndpoints.events.partitionCount;
                            'EventHubs Path'                   = $data.eventHubEndpoints.events.path;
                            'EventHubs Retention Days'         = $data.eventHubEndpoints.events.retentionTimeInDays;
                            'Locations'                        = [string]$data.locations.location;
                            'Resource U'                       = $ResUCount;
                            'Tag Name'                         = [string]$Tag.Name;
                            'Tag Value'                        = [string]$Tag.Value
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

    if($SmaResources.IoT)
    {
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('HostName')
        $Exc.Add('State')
        $Exc.Add('SKU')
        $Exc.Add('SKU Tier')
        $Exc.Add('SKU Capacity')
        $Exc.Add('Features')
        $Exc.Add('Enable File Upload Notifications')
        $Exc.Add('Default TTL As ISO8601')
        $Exc.Add('Max Delivery Count')
        $Exc.Add('EventHubs Endpoint')
        $Exc.Add('EventHubs Partition Count')
        $Exc.Add('EventHubs Path')
        $Exc.Add('EventHubs Retention Days')
        $Exc.Add('Locations')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.IoT

        $ExcelVar | 
        ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        Export-Excel -Path $File -WorksheetName 'IoT Hubs' -AutoSize -MaxAutoSizeRows 100 -TableName 'AzureIOT' -TableStyle $tableStyle -Style $Style
    
    }
}
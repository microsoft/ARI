<#
.Synopsis
Inventory for Azure IOT Hubs

.DESCRIPTION
This script consolidates information for all  resource provider in $Resources variable. 
Excel Sheet Name: IOTHubs

.Link
https://github.com/microsoft/ARI/Modules/Integration/IOTHubs.ps1

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

    $IOTHubs = $Resources | Where-Object { $_.TYPE -eq 'microsoft.devices/iothubs' }

    if($IOTHubs)
        {
            $tmp = @()
            foreach ($1 in $IOTHubs) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $IpFilter = $data.ipFilterRules.count
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach($loc in $data.locations)
                        {
                            foreach ($Tag in $Tags) {
                                $obj = @{
                                    'ID'                                = $1.id;
                                    'Subscription'                      = $sub1.Name;
                                    'Resource Group'                    = $1.RESOURCEGROUP;
                                    'Name'                              = $1.NAME;                                    
                                    'SKU'                               = $data.sku.name;
                                    'SKU Tier'                          = $data.sku.tier;
                                    'Location'                          = $loc.location;
                                    'Role'                              = $loc.role;
                                    'State'                             = $data.state;
                                    'IP Filter Rules'                   = [string]$IpFilter;
                                    'Event Retention Time In Days'      = [string]$data.eventHubEndpoints.events.retentionTimeInDays;
                                    'Event Partition Count'             = [string]$data.eventHubEndpoints.events.partitionCount;
                                    'Events Path'                       = [string]$data.eventHubEndpoints.events.path;
                                    'Max Delivery Count'                = [string]$data.cloudToDevice.maxDeliveryCount;
                                    'Host Name'                         = $data.hostName;
                                    'Tag Name'                          = [string]$Tag.Name;
                                    'Tag Value'                         = [string]$Tag.Value
                                }
                                $tmp += $obj
                                if ($ResUCount -eq 1) { $ResUCount = 0 } 
                            }   
                        }             
            }
            $tmp
        }
}
<######## Resource Excel Reporting Begins Here ########>

Else {
    <######## $SmaResources.IOTHubs ##########>

    if ($SmaResources.IOTHubs) {

        $TableName = ('IOTHubsTable_'+($SmaResources.IOTHubs.id | Select-Object -Unique).count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0
        
        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('SKU')
        $Exc.Add('SKU Tier')
        $Exc.Add('Location')
        $Exc.Add('Role')
        $Exc.Add('State')
        $Exc.Add('IP Filter Rules')
        $Exc.Add('Event Retention Time In Days')
        $Exc.Add('Event Partition Count')
        $Exc.Add('Events Path')
        $Exc.Add('Max Delivery Count')
        $Exc.Add('Host Name')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.IOTHubs 

        $ExcelVar | 
        ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        Export-Excel -Path $File -WorksheetName 'IOTHubs' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -Style $Style

    }
    <######## Insert Column comments and documentations here following this model #########>
}
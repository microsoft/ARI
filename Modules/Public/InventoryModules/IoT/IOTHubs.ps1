<#
.Synopsis
Inventory for Azure IOT Hubs

.DESCRIPTION
This script consolidates information for all  resource provider in $Resources variable. 
Excel Sheet Name: IOTHubs

.Link
https://github.com/microsoft/ARI/Modules/Public/InventoryModules/IoT/IOTHubs.ps1

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

    $IOTHubs = $Resources | Where-Object { $_.TYPE -eq 'microsoft.devices/iothubs' }

    if($IOTHubs)
        {
            $tmp = foreach ($1 in $IOTHubs) {
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
                                    'Retiring Feature'                  = $RetiringFeature;
                                    'Retiring Date'                     = $RetiringDate;                                
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
                                    'Resource U'                       = $ResUCount;
                                    'Tag Name'                          = [string]$Tag.Name;
                                    'Tag Value'                         = [string]$Tag.Value
                                }
                                $obj
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

    if ($SmaResources) {

        $TableName = ('IOTHubsTable_'+($SmaResources.'Resource U').count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

        $condtxt = @()
        #Retirement
        $condtxt += New-ConditionalText -Range E2:E100 -ConditionalType ContainsText
        
        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('Retiring Feature')
        $Exc.Add('Retiring Date')
        $Exc.Add('SKU')
        $Exc.Add('SKU Tier')
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

        [PSCustomObject]$SmaResources | 
        ForEach-Object { $_ } | Select-Object $Exc | 
        Export-Excel -Path $File -WorksheetName 'IOTHubs' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -Style $Style -ConditionalText $condtxt

    }
}
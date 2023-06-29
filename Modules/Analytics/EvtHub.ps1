<#
.Synopsis
Inventory for Azure EventHubs

.DESCRIPTION
This script consolidates information for all microsoft.eventhub/namespaces and  resource provider in $Resources variable. 
Excel Sheet Name: EvHub

.Link
https://github.com/microsoft/ARI/Modules/Infrastructure/EvHub.ps1

.COMPONENT
    This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.0.1
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Task ,$File, $SmaResources, $TableStyle, $Unsupported)

If ($Task -eq 'Processing')
{

    <######### Insert the resource extraction here ########>

        $evthub = $Resources | Where-Object {$_.TYPE -eq 'microsoft.eventhub/namespaces'}

    <######### Insert the resource Process here ########>

    if($evthub)
        {
            $tmp = @()
            foreach ($1 in $evthub) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $timecreated = $data.createdAt
                $timecreated = [datetime]$timecreated
                $timecreated = $timecreated.ToString("yyyy-MM-dd HH:mm")
                $sku = $1.SKU
                $RetDate = ''
                $RetFeature = '' 
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) { 
                        $obj = @{
                            'ID'                   = $1.id;
                            'Subscription'         = $sub1.Name;
                            'Resource Group'       = $1.RESOURCEGROUP;
                            'Name'                 = $1.NAME;
                            'Location'             = $1.LOCATION;
                            'SKU'                  = $sku.name;
                            'Status'               = $data.status;
                            'Geo-Replication'      = $data.zoneRedundant;
                            'Retirement Date'      = [string]$RetDate;
                            'Retirement Feature'   = $RetFeature;
                            'Throughput Units'     = $1.sku.capacity;
                            'Auto-Inflate'         = $data.isAutoInflateEnabled;
                            'Max Throughput Units' = $data.maximumThroughputUnits;
                            'Kafka Enabled'        = $data.kafkaEnabled;
                            'Endpoint'             = $data.serviceBusEndpoint;
                            'Created Time'         = $timecreated;
                            'Resource U'           = $ResUCount;
                            'Tag Name'             = [string]$Tag.Name;
                            'Tag Value'            = [string]$Tag.Value
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

    if($SmaResources.EvtHub)
    {
        $TableName = ('EvtHubTable_'+($SmaResources.EvtHub.id | Select-Object -Unique).count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

        $condtxt = @()
        $condtxt += New-ConditionalText false -Range J:J
        $condtxt += New-ConditionalText falso -Range J:J
        $condtxt += New-ConditionalText - -Range H:H -ConditionalType ContainsText

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('SKU')
        $Exc.Add('Status')
        $Exc.Add('Geo-Rep')
        $Exc.Add('Retirement Date')
        $Exc.Add('Retirement Feature')
        $Exc.Add('Throughput Units')
        $Exc.Add('Auto-Inflate')
        $Exc.Add('Max Throughput Units')
        $Exc.Add('Kafka Enabled')
        $Exc.Add('Endpoint')
        $Exc.Add('Created Time')  
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.EvtHub  

        $ExcelVar | 
        ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        Export-Excel -Path $File -WorksheetName 'Event Hubs' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style, $StyleCost

        <######## Insert Column comments and documentations here following this model #########>


        $excel = Open-ExcelPackage -Path $File -KillExcel

        $null = $excel.'Event Hubs'.Cells["J1"].AddComment("The Auto-inflate feature of Event Hubs automatically scales up by increasing the number of throughput units, to meet usage needs. Increasing throughput units prevents throttling scenarios.", "Azure Resource Inventory")
        $excel.'Event Hubs'.Cells["J1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-auto-inflate'

        Close-ExcelPackage $excel 
    }
}
<#
.Synopsis
Short Module Description

.DESCRIPTION
For this template we used the Event HUB Module as example. 
Long Module Description referring Resource Provider
Excel Sheet Name: Sheet Generated in Excel

.Link
https://github.com/azureinventory/ARI/<full_URI>.ps1

.COMPONENT
   This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 2.0.0
First Release Date: 19th November, 2020
Authors:  

#>

<######## Default Parameters. Don't modify this ########>
<# This param and if allways need to be on your module #>>
param($SCPath, $Sub, $Intag, $Resources, $Task ,$File, $SmaResources, $TableStyle,$Unsupported)
 
If ($Task -eq 'Processing')
{
 
    <######### Create a Variable and insert the resource provider that you want to extract here. E.g.: ########>

        $evthub = $Resources | Where-Object {$_.TYPE -eq 'microsoft.eventhub/namespaces'}

    <######### Insert the resource Process here ########>
    <######### Now you need to create an "IF" Looping with this Variable and use Foreach to Proccess the resource and extract the vaules for expected fields. ########>
    <#
    Variables:
    $evthub: The same variable of your Resource Provider  extraction
    $ResUCount: It's just to help in the looping for count the resources
    $sub1: used to associate your resource to thei subscription
    $data: Just a way to read PROPERTIES in graph results for the resource
    $Tags: If you use -IncludeTags during the script execution this variable will be filled.    
    #>
    if($evthub)
        {
            $tmp = @()

            foreach ($1 in $evthub) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $sku = $1.SKU
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) { 
                        $obj = @{
                            'Subscription'         = $sub1.name;
                            'Resource Group'       = $1.RESOURCEGROUP;
                            'Name'                 = $1.NAME;
                            'Location'             = $1.LOCATION;
                            'SKU'                  = $sku.name;
                            'Status'               = $data.status;
                            'Geo-Replication'      = $data.zoneRedundant;
                            'Throughput Units'     = $1.sku.capacity;
                            'Auto-Inflate'         = $data.isAutoInflateEnabled;
                            'Max Throughput Units' = $data.maximumThroughputUnits;
                            'Kafka Enabled'        = $data.kafkaEnabled;
                            'Endpoint'             = $data.serviceBusEndpoint;
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
    <######## Now you need to create the fields that your sheet will have ##########>
    <#
    Variables:
    $SmaResources.EvtHub
        $SmaResources : The same for all extraction. This Variuable was created by Main script and already have the values.
        EvtHub : name of Module File
    
    $txtEvt: Conditional for some cell/Column that you want to check a specific value and "highlight" with a different collor

    $Exc.Add : Use this var to add any field that will be present on your sheet. The value used in this variable need to be exactly equal created in your foreach created above. 

    $ExcelVar : adapt this for your module name. E.g.: "$ExcelVar = $SmaResources.EvtHub" >> "$ExcelVar = $SmaResources.YorModule"

    #>

    if($SmaResources.EvtHub)
    {
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

        $txtEvt = $(New-ConditionalText false -Range I:I
            New-ConditionalText falso -Range I:I)

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('SKU')
        $Exc.Add('Status')
        $Exc.Add('Geo-Rep')
        $Exc.Add('Throughput Units')
        $Exc.Add('Auto-Inflate')
        $Exc.Add('Max Throughput Units')
        $Exc.Add('Kafka Enabled')
        $Exc.Add('Endpoint')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.EvtHub  

        $ExcelVar | 
        ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        Export-Excel -Path $File -WorksheetName 'Event Hubs' -AutoSize -MaxAutoSizeRows 100 -TableName 'AzureEventHubs' -TableStyle $tableStyle -ConditionalText $txtEvt -Style $Style

        <######## Insert Column comments and documentations here following this model #########>
        
        <######## If you want to add comments for your Column, like a documentation, Just use .AddComment like bellow and the link for the url for Hyperlink  #########>

        $excel = Open-ExcelPackage -Path $File -KillExcel

        $null = $excel.'Event Hubs'.Cells["I1"].AddComment("The Auto-inflate feature of Event Hubs automatically scales up by increasing the number of throughput units, to meet usage needs. Increasing throughput units prevents throttling scenarios.", "Azure Resource Inventory")
        $excel.'Event Hubs'.Cells["I1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-auto-inflate'

        Close-ExcelPackage $excel 
    }
}
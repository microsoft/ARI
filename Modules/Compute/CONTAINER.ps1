<#
.Synopsis
Inventory for Azure Container instance

.DESCRIPTION
This script consolidates information for all microsoft.containerinstance/containergroups resource provider in $Resources variable. 
Excel Sheet Name: CONTAINER

.Link
https://github.com/azureinventory/ARI/Modules/Compute/CONTAINER.ps1

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

        $CONTAINER = $Resources | Where-Object {$_.TYPE -eq 'microsoft.containerinstance/containergroups'}

    <######### Insert the resource Process here ########>

    if($CONTAINER)
        {
            $tmp = @()

            foreach ($1 in $CONTAINER) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                foreach ($2 in $data.containers) {
                        foreach ($Tag in $Tags) {
                            $obj = @{
                                'Subscription'        = $sub1.name;
                                'Resource Group'      = $1.RESOURCEGROUP;
                                'Instance Name'       = $1.NAME;
                                'Location'            = $1.LOCATION;
                                'Instance OS Type'    = $data.osType;
                                'Container Name'      = $2.name;
                                'Container State'     = $2.properties.instanceView.currentState.state;
                                'Container Image'     = [string]$2.properties.image;
                                'Restart Count'       = $2.properties.instanceView.restartCount;
                                'Start Time'          = $2.properties.instanceView.currentState.startTime;
                                'Command'             = [string]$2.properties.command;
                                'Request CPU'         = $2.properties.resources.requests.cpu;
                                'Request Memory (GB)' = $2.properties.resources.requests.memoryInGB;
                                'IP'                  = $data.ipAddress.ip;
                                'Protocol'            = [string]$2.properties.ports.protocol;
                                'Port'                = [string]$2.properties.ports.port;
                                'Resource U'          = $ResUCount;
                                'Tag Name'            = [string]$Tag.Name;
                                'Tag Value'           = [string]$Tag.Value
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

Else
{
    <######## $SmaResources.(RESOURCE FILE NAME) ##########>

    if($SmaResources.CONTAINER)
    {

        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Instance Name')
        $Exc.Add('Location')
        $Exc.Add('Instance OS Type')
        $Exc.Add('Container Name')
        $Exc.Add('Container State')
        $Exc.Add('Container Image')
        $Exc.Add('Restart Count')
        $Exc.Add('Start Time')
        $Exc.Add('Command')
        $Exc.Add('Request CPU')
        $Exc.Add('Request Memory (GB)')
        $Exc.Add('IP')
        $Exc.Add('Protocol')
        $Exc.Add('Port')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.CONTAINER 
            
        $ExcelVar | 
        ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        Export-Excel -Path $File -WorksheetName 'Containers' -AutoSize -MaxAutoSizeRows 100 -TableName 'AzureContainers' -TableStyle $tableStyle -Style $Style

    }
}
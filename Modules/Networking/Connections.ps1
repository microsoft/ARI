<#
.Synopsis
Inventory for Azure Network Connections

.DESCRIPTION
This script consolidates information for all microsoft.network/connections and  resource provider in $Resources variable. 
Excel Sheet Name: Connections

.Link
https://github.com/microsoft/ARI/Modules/Networking/Connections.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 2.2.0
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Task ,$File, $SmaResources, $TableStyle)

If ($Task -eq 'Processing')
{
    <######### Insert the resource extraction here ########>

        $connections = $Resources | Where-Object {$_.TYPE -eq 'microsoft.network/connections'}

    <######### Insert the resource Process here ########>

    if($connections)
        {
            $tmp = @()

            foreach ($1 in $connections) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) { 
                        $obj = @{
                            'ID'                   = $1.id;
                            'Subscription'         = $sub1.name;
                            'Resource Group'       = $1.RESOURCEGROUP;
                            'Name'                 = $1.NAME;
                            'Location'             = $1.LOCATION;
                            'Type'                 = $data.connectionType;
                            'Status'               = $data.connectionStatus;
                            'Connection Protocol'  = $data.connectionProtocol;
                            'Routing Weight'       = $data.routingWeight;
                            'connectionMode'       = $data.connectionMode;
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

    if($SmaResources.Connections)
    {
        $TableName = ('Connections_'+($SmaResources.Connections.id | Select-Object -Unique).count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('Type')
        $Exc.Add('Status')
        $Exc.Add('Connection Protocol')
        $Exc.Add('Routing Weight')
        $Exc.Add('connectionMode')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.Connections  

        $ExcelVar | 
        ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        Export-Excel -Path $File -WorksheetName 'Connections' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -Style $Style

        <######## Insert Column comments and documentations here following this model #########>

        Close-ExcelPackage $excel 
    }
}
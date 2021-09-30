<#
.Synopsis
Inventory for Azure Public DNS

.DESCRIPTION
This script consolidates information for all microsoft.network/dnszones and  resource provider in $Resources variable. 
Excel Sheet Name: PublicDNS

.Link
https://github.com/azureinventory/ARI/Modules/Networking/PublicDNS.ps1

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

    $PublicDNS = $Resources | Where-Object { $_.TYPE -eq 'microsoft.network/dnszones' }

    if($PublicDNS)
        {
            $tmp = @()

            foreach ($1 in $PublicDNS) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) {     
                        $obj = @{
                            'Subscription'              = $sub1.name;
                            'Resource Group'            = $1.RESOURCEGROUP;
                            'Name'                      = $1.NAME;
                            'Location'                  = $1.LOCATION;
                            'Zone Type'                 = $data.zoneType;
                            'Number of Record Sets'     = $data.numberOfRecordSets;
                            'Max Number of Record Sets' = $data.maxNumberofRecordSets;
                            'Name Servers'              = [string]$data.nameServers;
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
Else {
    if ($SmaResources.PublicDNS) {
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('Zone Type')
        $Exc.Add('Number of Record Sets')
        $Exc.Add('Max Number of Record Sets')
        $Exc.Add('Name Servers')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.PublicDNS 

        $ExcelVar | 
        ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        Export-Excel -Path $File -WorksheetName 'Public DNS' -AutoSize -MaxAutoSizeRows 100 -TableName 'AzurePubDNSZones' -TableStyle $tableStyle -Style $Style

    }
}
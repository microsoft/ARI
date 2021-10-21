<#
.Synopsis
Inventory for Azure Private DNS

.DESCRIPTION
This script consolidates information for all microsoft.network/privatednszones and  resource provider in $Resources variable. 
Excel Sheet Name: PrivateDNS

.Link
https://github.com/azureinventory/ARI/Modules/Networking/PrivateDNS.ps1

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

    $PrivateDNS = $Resources | Where-Object { $_.TYPE -eq 'microsoft.network/privatednszones' }  

    if($PrivateDNS)
        {
            $tmp = @()

            foreach ($1 in $PrivateDNS) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) {     
                        $obj = @{
                            'Subscription'                    = $sub1.name;
                            'Resource Group'                  = $1.RESOURCEGROUP;
                            'Name'                            = $1.NAME;
                            'Location'                        = $1.LOCATION;
                            'Number of Records'               = $data.numberOfRecordSets;
                            'Virtual Network Links'           = $data.numberOfVirtualNetworkLinks;
                            'Network Links with Registration' = $data.numberOfVirtualNetworkLinksWithRegistration;
                            'Tag Name'                        = [string]$Tag.Name;
                            'Tag Value'                       = [string]$Tag.Value
                        }
                        $tmp += $obj
                        if ($ResUCount -eq 1) { $ResUCount = 0 } 
                    }               
            }
            $tmp
        }
}
Else {
    if ($SmaResources.PrivateDNS) {
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('Number of Records')
        $Exc.Add('Virtual Network Links')
        $Exc.Add('Network Links with Registration')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.PrivateDNS

        $ExcelVar | 
        ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        Export-Excel -Path $File -WorksheetName 'Private DNS' -AutoSize -MaxAutoSizeRows 100 -TableName 'AzurePrivDNSZones' -TableStyle $tableStyle -Style $Style
    
    }   
}
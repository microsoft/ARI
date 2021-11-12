<#
.Synopsis
Inventory for Azure Public IP

.DESCRIPTION
This script consolidates information for all microsoft.network/publicipaddresses and  resource provider in $Resources variable. 
Excel Sheet Name: PublicIP

.Link
https://github.com/azureinventory/ARI/Modules/Networking/PublicIP.ps1

.COMPONENT
   This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 2.0.1
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Task , $File, $SmaResources, $TableStyle) 
If ($Task -eq 'Processing') {

    $PublicIP = $Resources | Where-Object { $_.TYPE -eq 'microsoft.network/publicipaddresses' }

    if($PublicIP)
        {
            $tmp = @()

            foreach ($1 in $PublicIP) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                if (!($data.ipConfiguration.id)) { $Use = 'Underutilized' } else { $Use = 'Utilized' }
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                if ($null -ne $data.ipConfiguration.id) {
                    foreach ($Tag in $Tags) { 
                        $obj = @{
                            'Subscription'             = $sub1.name;
                            'Resource Group'           = $1.RESOURCEGROUP;
                            'Name'                     = $1.NAME;
                            'SKU'                      = $1.SKU.Name;
                            'Location'                 = $1.LOCATION;
                            'Zones'                    = [string]$1.Zones;
                            'Type'                     = $data.publicIPAllocationMethod;
                            'Version'                  = $data.publicIPAddressVersion;
                            'IP Address'               = $data.ipAddress;
                            'Use'                      = $Use;
                            'Associated Resource'      = $data.ipConfiguration.id.split('/')[8];
                            'Associated Resource Type' = $data.ipConfiguration.id.split('/')[7];
                            'Resource U'               = $ResUCount;
                            'Tag Name'                 = [string]$Tag.Name;
                            'Tag Value'                = [string]$Tag.Else
                        }
                        $tmp += $obj
                        if ($ResUCount -eq 1) { $ResUCount = 0 } 
                    }
                }               
                else {
                    foreach ($Tag in $Tags) {  
                        $obj = @{
                            'Subscription'             = $sub1.name;
                            'Resource Group'           = $1.RESOURCEGROUP;
                            'Name'                     = $1.NAME;
                            'SKU'                      = $1.SKU.Name;
                            'Location'                 = $1.LOCATION;
                            'Zones'                    = $1.Zones;
                            'Type'                     = $data.publicIPAllocationMethod;
                            'Version'                  = $data.publicIPAddressVersion;
                            'IP Address'               = $data.ipAddress;
                            'Use'                      = $Use;
                            'Associated Resource'      = $null;
                            'Associated Resource Type' = $null;
                            'Resource U'               = $ResUCount;
                            'Tag Name'                 = [string]$Tag.Name;
                            'Tag Value'                = [string]$Tag.Value
                        }
                        $tmp += $obj
                        if ($ResUCount -eq 1) { $ResUCount = 0 } 
                    }               
                }            
        }
        $tmp
    }
}
Else {
    if ($SmaResources.PublicIP) {
        $condtxtpip = New-ConditionalText Underutilized -Range J:J
        Write-Debug ('Generating Public IP sheet for: ' + $pubip.count + ' Public IPs.')

        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('SKU')
        $Exc.Add('Location')
        $Exc.Add('Zones')
        $Exc.Add('Type')
        $Exc.Add('Version')
        $Exc.Add('IP Address')
        $Exc.Add('Use')
        $Exc.Add('Associated Resource')
        $Exc.Add('Associated Resource Type')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.PublicIP

        $ExcelVar | 
        ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        Export-Excel -Path $File -WorksheetName 'Public IPs' -AutoSize -MaxAutoSizeRows 100 -TableName 'AzurePubIPs' -TableStyle $tableStyle -Style $Style -ConditionalText $condtxtpip
    
    }
}

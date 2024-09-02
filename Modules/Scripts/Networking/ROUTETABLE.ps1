<#
.Synopsis
Inventory for Azure Route Table

.DESCRIPTION
This script consolidates information for all microsoft.network/routetables and  resource provider in $Resources variable. 
Excel Sheet Name: ROUTETABLE

.Link
https://github.com/microsoft/ARI/Modules/Networking/ROUTETABLE.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.0.1
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Task , $File, $SmaResources, $TableStyle, $Unsupported) 
If ($Task -eq 'Processing') {

    $ROUTETABLE = $Resources | Where-Object { $_.TYPE -eq 'microsoft.network/routetables' }

    if($ROUTETABLE)
        {
            $tmp = @()

            foreach ($1 in $ROUTETABLE) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.Id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $Orphaned = if([string]::IsNullOrEmpty($data.subnets.id)){$true}else{$false}
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach($2 in $data.routes)
                        {
                            foreach ($TagKey in $Tags) { 
                                $obj = @{
                                    'ID'                            = $1.id;
                                    'Subscription'                  = $sub1.Name;
                                    'Resource Group'                = $1.RESOURCEGROUP;
                                    'Name'                          = $1.NAME;
                                    'Location'                      = $1.LOCATION;
                                    'Orphaned'                      = $Orphaned;
                                    'Disable BGP Route Propagation' = $data.disableBgpRoutePropagation;
                                    'Routes'                        = [string]$2.name;
                                    'Routes Prefixes'               = [string]$2.properties.addressPrefix;
                                    'Routes BGP Override'           = [string]$2.properties.hasBgpOverride;
                                    'Routes Next Hop IP'            = [string]$2.properties.nextHopIpAddress;
                                    'Routes Next Hop Type'          = [string]$2.properties.nextHopType;
                                    'Resource U'                    = $ResUCount;
                                    'Tag Name'                      = [string]$Tag.Name;
                                    'Tag Value'                     = [string]$Tag.Value
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
    if ($SmaResources.ROUTETABLE) {

        $TableName = ('RouteTbTable_'+($SmaResources.ROUTETABLE.id | Select-Object -Unique).count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

        $condtxt = @()
        $condtxt += New-ConditionalText TRUE -Range E:E

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('Orphaned')
        $Exc.Add('Disable BGP Route Propagation')
        $Exc.Add('Routes')
        $Exc.Add('Routes Prefixes')
        $Exc.Add('Routes BGP Override')
        $Exc.Add('Routes Next Hop IP')
        $Exc.Add('Routes Next Hop Type')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.ROUTETABLE 

        $ExcelVar | 
        ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        Export-Excel -Path $File -WorksheetName 'Route Tables' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style
    
    }
}
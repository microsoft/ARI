<#
.Synopsis
Inventory for Azure Private DNS

.DESCRIPTION
This script consolidates information for all microsoft.network/privatednszones and  resource provider in $Resources variable. 
Excel Sheet Name: PrivateDNS

.Link
https://github.com/microsoft/ARI/Modules/Public/InventoryModules/Network_2/PrivateDNS.ps1

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

    $PrivateDNS = $Resources | Where-Object { $_.TYPE -eq 'microsoft.network/privatednszones' }
    $VNETLinks =  $Resources | Where-Object { $_.TYPE -eq 'microsoft.network/privatednszones/virtualnetworklinks' }

    if($PrivateDNS)
        {
            $tmp = foreach ($1 in $PrivateDNS) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.Id -eq $1.subscriptionId }
                $data = $1.PROPERTIES

                $vnlks = ($VNETLinks | Where-Object {$_.id -like ($1.id + '*')})
                $vnlks = if (!$vnlks) {[pscustomobject]@{id = 'none'}} else {$vnlks | Select-Object @{Name="id";Expression={$_.properties.virtualNetwork.id.split("/")[8]}}}
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

                foreach ($2 in $vnlks) {

                    $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    
                    foreach ($Tag in $Tags) {     
                        $obj = @{
                            'ID'                              = $1.id;
                            'Subscription'                    = $sub1.Name;
                            'Resource Group'                  = $1.RESOURCEGROUP;
                            'Name'                            = $1.NAME;
                            'Location'                        = $1.LOCATION;
                            'Retiring Feature'                = $RetiringFeature;
                            'Retiring Date'                   = $RetiringDate;
                            'Number of Records'               = $data.numberOfRecordSets;
                            'Virtual Network Links'           = $data.numberOfVirtualNetworkLinks;
                            'Network Links with Registration' = $data.numberOfVirtualNetworkLinksWithRegistration;
                            'Tag Name'                        = [string]$Tag.Name;
                            'Tag Value'                       = [string]$Tag.Value;
                            'Resource U'                        = $ResUCount;
                            'Virtual Network'                 = $2.id
                        }
                        $obj
                        if ($ResUCount -eq 1) { $ResUCount = 0 } 
                    }
                }               
            }
            $tmp
        }
}
Else {
    if ($SmaResources) {

        $TableName = ('PrivDNSTable_'+($SmaResources.'Resource U').count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

        $condtxt = @()
        $condtxt += New-ConditionalText 0 -Range H:H
        #Retirement
        $condtxt += New-ConditionalText -Range E2:E100 -ConditionalType ContainsText

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('Retiring Feature')
        $Exc.Add('Retiring Date')
        $Exc.Add('Number of Records')
        $Exc.Add('Virtual Network Links')
        $Exc.Add('Virtual Network')
        $Exc.Add('Network Links with Registration')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        [PSCustomObject]$SmaResources | 
        ForEach-Object { $_ } | Select-Object $Exc | 
        Export-Excel -Path $File -WorksheetName 'Private DNS' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -ConditionalText $condtxt -TableStyle $tableStyle -Style $Style
    }
}
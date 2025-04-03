<#
.Synopsis
Inventory for Azure Public IP

.DESCRIPTION
This script consolidates information for all microsoft.network/publicipaddresses and  resource provider in $Resources variable. 
Excel Sheet Name: PublicIP

.Link
https://github.com/microsoft/ARI/Modules/Public/InventoryModules/Network_2/PublicIP.ps1

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

    $PublicIP = $Resources | Where-Object { $_.TYPE -eq 'microsoft.network/publicipaddresses' }

    if($PublicIP)
        {
            $tmp = foreach ($1 in $PublicIP) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.Id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $Retired = Foreach ($Retirement in $Retirements)
                    {
                        if ($Retirement.id -eq $1.id) { $Retirement }
                    }
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
                if (!($data.ipConfiguration.id)) { $Use = 'Underutilized' } else { $Use = 'Utilized' }
                if (!($data.natGateway.id) -and $Use -eq 'Underutilized') { $Use = 'Underutilized' } else { $Use = 'Utilized' }
                
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                if ($null -ne $data.ipConfiguration.id) {
                    foreach ($Tag in $Tags) { 
                        $obj = @{
                            'ID'                       = $1.id;
                            'Subscription'             = $sub1.Name;
                            'Resource Group'           = $1.RESOURCEGROUP;
                            'Name'                     = $1.NAME;
                            'SKU'                      = $1.SKU.Name;
                            'Location'                 = $1.LOCATION;
                            'Zones'                    = [string]$1.Zones;
                            'Retiring Feature'         = $RetiringFeature;
                            'Retiring Date'            = $RetiringDate;
                            'Type'                     = $data.publicIPAllocationMethod;
                            'Version'                  = $data.publicIPAddressVersion;
                            'IP Address'               = [string]$data.ipAddress;
                            'Use'                      = $Use;
                            'Associated Resource'      = $data.ipConfiguration.id.split('/')[8];
                            'Associated Resource Type' = $data.ipConfiguration.id.split('/')[7];
                            'Resource U'               = $ResUCount;
                            'Tag Name'                 = [string]$Tag.Name;
                            'Tag Value'                = [string]$Tag.Value
                        }
                        $obj
                        if ($ResUCount -eq 1) { $ResUCount = 0 } 
                    }
                }               
                else {
                    foreach ($Tag in $Tags) {  
                        $obj = @{
                            'ID'                       = $1.id;
                            'Subscription'             = $sub1.name;
                            'Resource Group'           = $1.RESOURCEGROUP;
                            'Name'                     = $1.NAME;
                            'SKU'                      = $1.SKU.Name;
                            'Location'                 = $1.LOCATION;
                            'Zones'                    = [string]$1.Zones;
                            'Retiring Feature'         = $RetiringFeature;
                            'Retiring Date'            = $RetiringDate;
                            'Type'                     = $data.publicIPAllocationMethod;
                            'Version'                  = $data.publicIPAddressVersion;
                            'IP Address'               = [string]$data.ipAddress;
                            'Use'                      = $Use;
                            'Associated Resource'      = $null;
                            'Associated Resource Type' = $null;
                            'Resource U'               = $ResUCount;
                            'Tag Name'                 = [string]$Tag.Name;
                            'Tag Value'                = [string]$Tag.Value
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

        $SheetName = 'Public IPs'

        $TableName = ('PIPTable_'+($SmaResources.'Resource U').count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

        $condtxt = @()
        $condtxt += New-ConditionalText Underutilized -Range L:L
        #Retirement
        $condtxt += New-ConditionalText -Range G2:G100 -ConditionalType ContainsText

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('SKU')
        $Exc.Add('Location')
        $Exc.Add('Zones')
        $Exc.Add('Retiring Feature')
        $Exc.Add('Retiring Date')
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

        $noNumberConversion = @()
        $noNumberConversion += 'IP Address'

        [PSCustomObject]$SmaResources | 
        ForEach-Object { $_ } | Select-Object $Exc | 
        Export-Excel -Path $File -WorksheetName $SheetName -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -Style $Style -ConditionalText $condtxt -NoNumberConversion $noNumberConversion

    }
}

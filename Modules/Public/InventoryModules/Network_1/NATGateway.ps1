<#
.Synopsis
Inventory for Azure NAT Gateway

.DESCRIPTION
This script consolidates information for all microsoft.network/natgateways and  resource provider in $Resources variable. 
Excel Sheet Name: NAT Gateway

.Link
https://github.com/microsoft/ARI/Modules/Public/InventoryModules/Network_1/NATGateway.ps1

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

    $NATGAT = $Resources | Where-Object { $_.TYPE -eq 'microsoft.network/natgateways' }

    if($NATGAT)
        {
            $tmp = foreach ($1 in $NATGAT) 
                {
                    $ResUCount = 1
                    $sub1 = $SUB | Where-Object { $_.Id -eq $1.subscriptionId }
                    $data = $1.PROPERTIES
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
                    $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                        foreach ($2 in $data.subnets)
                            {
                                foreach ($Tag in $Tags) 
                                    {  
                                        $t_pip_addresses = ''
                                        $t_pip_prefixes = ''

                                        if ($data.publicipaddresses) {
                                            $t_pip_addresses = [string]$data.publicipaddresses.id.split("/")[8]
                                        }

                                        
                                        if ($data.publicipprefixes) {
                                            $t_pip_prefixes = [string]$data.publicipprefixes.id.split("/")[8]
                                        }

                                        $obj = @{
                                            'ID'                    = $1.id;
                                            'Subscription'          = $sub1.Name;
                                            'Resource Group'        = $1.RESOURCEGROUP;
                                            'Name'                  = $1.NAME;
                                            'Location'              = $1.LOCATION;
                                            'SKU'                   = $1.sku.name;
                                            'Retiring Feature'      = $RetiringFeature;
                                            'Retiring Date'         = $RetiringDate;
                                            'Idle Timeout (Min)'    = $data.idleTimeoutInMinutes;
                                            'Public IP'             = $t_pip_addresses;
                                            'Public Prefixes'       = $t_pip_prefixes;
                                            'VNET'                  = [string]$2.id.split("/")[8];
                                            'Subnet'                = [string]$2.id.split("/")[10];
                                            'Resource U'            = $ResUCount;
                                            'Tag Name'              = [string]$Tag.Name;
                                            'Tag Value'             = [string]$Tag.Value
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

        $TableName = ('NATGtwTable_'+($SmaResources.'Resource U').count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

        $condtxt = @()
        #Retirement
        $condtxt += New-ConditionalText -Range F2:F100 -ConditionalType ContainsText

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('SKU')
        $Exc.Add('Retiring Feature')
        $Exc.Add('Retiring Date')
        $Exc.Add('Idle Timeout (Min)')
        $Exc.Add('Public IP')
        $Exc.Add('Public Prefixes')
        $Exc.Add('VNET')
        $Exc.Add('Subnet')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        [PSCustomObject]$SmaResources | 
        ForEach-Object { $_ } | Select-Object $Exc | 
        Export-Excel -Path $File -WorksheetName 'NAT Gateway' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style

    }
}
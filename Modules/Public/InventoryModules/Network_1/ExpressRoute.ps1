<#
.Synopsis
Inventory for Azure Express Route Circuits

.DESCRIPTION
This script consolidates information for all microsoft.network/expressroutecircuits and  resource provider in $Resources variable. 
Excel Sheet Name: EvHub

.Link
https://github.com/microsoft/ARI/Modules/Public/InventoryModules/Network_1/ExpressRoute.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.0
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Retirements, $Task ,$File, $SmaResources, $TableStyle, $Unsupported)

If ($Task -eq 'Processing')
{
    <######### Insert the resource extraction here ########>

        $expressroute = $Resources | Where-Object {$_.TYPE -eq 'microsoft.network/expressroutecircuits'}

    <######### Insert the resource Process here ########>

    if($expressroute)
        {
            $tmp = foreach ($1 in $expressroute) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $sku = $1.SKU
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
                $Auths = if(![string]::IsNullOrEmpty($data.authorizations)){$data.authorizations}else{'0'}
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach($Auth in $Auths)
                        {
                            foreach ($Tag in $Tags) { 
                                $obj = @{
                                    'ID'                   = $1.id;
                                    'Subscription'         = $sub1.name;
                                    'Resource Group'       = $1.RESOURCEGROUP;
                                    'Name'                 = $1.NAME;
                                    'Location'             = $1.LOCATION;
                                    'Retiring Feature'     = $RetiringFeature;
                                    'Retiring Date'        = $RetiringDate;
                                    'SKU'                  = $sku.tier;
                                    'Billing Model'        = $sku.family;
                                    'Authorization'        = $Auth.Name;
                                    'Circuit Status'       = $data.circuitProvisioningState;
                                    'Provider Status'      = $data.serviceProviderProvisioningState;
                                    'Provider'             = $data.serviceProviderProperties.serviceProviderName;
                                    'Bandwidth'            = $data.serviceProviderProperties.bandwidthInMbps;
                                    'Peering Location'     = $data.serviceProviderProperties.peeringLocation;
                                    'GlobalReach Enabled'  = $data.globalReachEnabled;
                                    'Resource U'           = $ResUCount;
                                    'Tag Name'             = [string]$Tag.Name;
                                    'Tag Value'            = [string]$Tag.Value
                                }
                                $obj
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

    if($SmaResources)
    {
        $TableName = ('ERs_'+($SmaResources.'Resource U').count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

        $condtxt = @()
        #Retirement
        $condtxt += New-ConditionalText -Range E2:E100 -ConditionalType ContainsText

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('Retiring Feature')
        $Exc.Add('Retiring Date')
        $Exc.Add('Provider Status')
        $Exc.Add('Provider')
        $Exc.Add('Peering Location')
        $Exc.Add('Bandwidth')
        $Exc.Add('SKU')
        $Exc.Add('Billing Model')
        $Exc.Add('Authorization')
        $Exc.Add('Circuit Status')
        $Exc.Add('GlobalReach Enabled')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        [PSCustomObject]$SmaResources | 
        ForEach-Object { $_ } | Select-Object $Exc | 
        Export-Excel -Path $File -WorksheetName 'Express Route' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -Style $Style -ConditionalText $condtxt
    }
}
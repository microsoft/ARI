<#
.Synopsis
Inventory for Azure LoadBalancer

.DESCRIPTION
This script consolidates information for all microsoft.network/loadbalancers and  resource provider in $Resources variable. 
Excel Sheet Name: LoadBalancer

.Link
https://github.com/microsoft/ARI/Modules/Public/InventoryModules/Network_1/LoadBalancer.ps1

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

    $LoadBalancer = $Resources | Where-Object { $_.TYPE -eq 'microsoft.network/loadbalancers' }

    if($LoadBalancer)
        {
            $tmp = foreach ($1 in $LoadBalancer ) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.Id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $Orphaned = if([string]::IsNullOrEmpty($data.backendAddressPools.id)){$true}else{$false}
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
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                $FrontEnds = foreach ($2 in $data.frontendIPConfigurations) 
                    {
                        if (![string]::IsNullOrEmpty($2.properties.subnet.id)) 
                            {
                                $tmps = [pscustomobject]@{
                                    Name             = $2.name
                                    Fronttarget      = $2.properties.subnet.id.split('/')[8]
                                    FrontType        = 'VNET'
                                    frontsub         = $2.properties.subnet.id.split('/')[10]
                                }
                                $tmps
                            }
                        elseif (![string]::IsNullOrEmpty($2.properties.publicIPAddress.id)) 
                            {
                                $tmps = [pscustomobject]@{
                                    Name              = $2.name
                                    Fronttarget       = $2.properties.publicIPAddress.id.split('/')[8]
                                    FrontType         = 'Public IP'
                                    frontsub          = $null
                                }
                                $tmps
                            }
                    }
                $Backends = $data.backendAddressPools.count

                $BackendState = if(![string]::IsNullOrEmpty($data.backendAddressPools.properties.loadBalancerBackendAddresses)){'In Use'}else{'Not In Use'}

                $Probes = $data.probes.count

                $FrontEnds = if(![string]::IsNullOrEmpty($FrontEnds)){$FrontEnds}else{'0'}

                foreach ($FrontEnd in $FrontEnds)
                    {
                        foreach ($Tag in $Tags) {
                            $obj = @{
                                'ID'                        = $1.id;
                                'Subscription'              = $sub1.Name;
                                'Resource Group'            = $1.RESOURCEGROUP;
                                'Name'                      = $1.NAME;
                                'Location'                  = $1.LOCATION;
                                'SKU'                       = $1.sku.name;
                                'Retiring Feature'          = $RetiringFeature;
                                'Retiring Date'             = $RetiringDate;
                                'Orphaned'                  = $Orphaned;
                                'Usage'                     = $BackendState;
                                'Frontend Name'             = $FrontEnd.Name;
                                'Frontend Target'           = $FrontEnd.Fronttarget;
                                'Frontend Type'             = $FrontEnd.FrontType;
                                'Frontend Subnet'           = $FrontEnd.frontsub;
                                'Backend Count'             = $BackEnds;
                                'Probe Count'               = $Probes;
                                'Resource U'                = $ResUCount;
                                'Tag Name'                  = [string]$Tag.Name;
                                'Tag Value'                 = [string]$Tag.Value
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

        $SheetName = 'Load Balancers'

        $TableName = ('LBTable_'+($SmaResources.'Resource U').count)

        $condtxt = @()
        #Retirement
        $condtxt += New-ConditionalText -Range F2:F100 -ConditionalType ContainsText
        $condtxt += New-ConditionalText Basic -Range E:E
        $condtxt += New-ConditionalText TRUE -Range H:H
        $condtxt += New-ConditionalText 'Not In Use' -Range I:I

        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('SKU')
        $Exc.Add('Retiring Feature')
        $Exc.Add('Retiring Date')
        $Exc.Add('Orphaned')
        $Exc.Add('Usage')
        $Exc.Add('Frontend Name')
        $Exc.Add('Frontend Target')
        $Exc.Add('Frontend Type')
        $Exc.Add('Frontend Subnet')
        $Exc.Add('Backend Count')
        $Exc.Add('Probe Count')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        [PSCustomObject]$SmaResources | 
        ForEach-Object { $_ } | Select-Object $Exc | 
        Export-Excel -Path $File -WorksheetName $SheetName -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style

    }
}
<#
.Synopsis
Inventory for Azure Application Gateway

.DESCRIPTION
This script consolidates information for all microsoft.network/applicationgateways and  resource provider in $Resources variable. 
Excel Sheet Name: AppGW

.Link
https://github.com/microsoft/ARI/Modules/Public/InventoryModules/Network_2/ApplicationGateways.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.0
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>

param($SCPath, $Sub, $Intag, $Resources, $Retirements, $Task ,$File, $SmaResources, $TableStyle, $Unsupported)
If ($Task -eq 'Processing') {

    $APPGTW = $Resources | Where-Object { $_.TYPE -eq 'microsoft.network/applicationgateways' }
    $APPGTWPOL = $Resources | Where-Object { $_.TYPE -eq 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies' }

    if($APPGTW)
        {
            $tmp = foreach ($1 in $APPGTW) {
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
                if([string]::IsNullOrEmpty($data.autoscaleConfiguration.maxCapacity)){$MaxCap = 'Autoscale Disabled'}else{$MaxCap = $data.autoscaleConfiguration.maxCapacity}
                if([string]::IsNullOrEmpty($data.autoscaleConfiguration.minCapacity)){$MinCap = 'Autoscale Disabled'}else{$MinCap = $data.autoscaleConfiguration.minCapacity}
                if([string]::IsNullOrEmpty($data.sslPolicy.minProtocolVersion)){$PROT = 'Default'}else{$PROT = $data.sslPolicy.minProtocolVersion}
                if([string]::IsNullOrEmpty($data.webApplicationFirewallConfiguration.enabled)){$WAF = 'false'}else{$WAF = $data.webApplicationFirewallConfiguration.enabled}
                if($WAF -eq 'false' -and $1.id -in $APPGTWPOL.properties.applicationGateways.id){$WAF = 'true'}
                $BackendState = if(![string]::IsNullOrEmpty($data.backendAddressPools.properties.backendAddresses)){'In Use'}else{'Empty'}
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) {
                        $obj = @{
                            'ID'                    = $1.id;
                            'Subscription'          = $sub1.Name;
                            'Resource Group'        = $1.RESOURCEGROUP;
                            'Name'                  = $1.NAME;
                            'Location'              = $1.LOCATION;
                            'Retiring Feature'      = $RetiringFeature;
                            'Retiring Date'         = $RetiringDate;
                            'State'                 = $data.OperationalState;
                            'WAF Enabled'           = $WAF;
                            'Minimum TLS Version'   = $PROT;
                            'Autoscale Min Capacity'= $MinCap;
                            'Autoscale Max Capacity'= $MaxCap;
                            'SKU Name'              = $data.sku.tier;
                            'Current Instances'     = $data.sku.capacity;
                            'Backend Pool State'    = $BackendState;
                            'Backend'               = [string]$data.backendAddressPools.name;
                            'Frontend'              = [string]$data.frontendIPConfigurations.name;
                            'Frontend Ports'        = [string]$data.frontendports.properties.port;
                            'Gateways'              = [string]$data.gatewayIPConfigurations.name;
                            'HTTP Listeners'        = [string]$data.httpListeners.name;
                            'Request Routing Rules' = [string]$data.RequestRoutingRules.Name;
                            'Resource U'            = $ResUCount;
                            'Tag Name'              = [string]$Tag.Name;
                            'Tag Value'             = [string]$Tag.Value
                        }
                        $obj
                        if ($ResUCount -eq 1) { $ResUCount = 0 } 
                    }
            }
            $tmp
        }
}
Else {
    if ($SmaResources) {

        $SheetName = 'App Gateway'

        $TableName = ('APPGWTb_'+($SmaResources.'Resource U').count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

        $condtxt = @()
        #WAF Enabled
        $condtxt += New-ConditionalText FALSE -Range I:I
        #TLS Version
        $condtxt += New-ConditionalText 'Default' -Range J:J
        $condtxt += New-ConditionalText '1.0' -Range J:J
        $condtxt += New-ConditionalText '1.1' -Range J:J
        #Autoscale Min
        $condtxt += New-ConditionalText 'Autoscale Disabled' -Range K:K
        #Autoscale Max
        $condtxt += New-ConditionalText 'Autoscale Disabled' -Range L:L
        #Backend Pool
        $condtxt += New-ConditionalText 'Empty' -Range N:N
        #Retirement
        $condtxt += New-ConditionalText -Range F2:F100 -ConditionalType ContainsText

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('SKU Name')
        $Exc.Add('Retiring Feature')
        $Exc.Add('Retiring Date')
        $Exc.Add('State')
        $Exc.Add('WAF Enabled')
        $Exc.Add('Minimum TLS Version')
        $Exc.Add('Autoscale Min Capacity')
        $Exc.Add('Autoscale Max Capacity')
        $Exc.Add('Current Instances')
        $Exc.Add('Backend Pool State')
        $Exc.Add('Backend')
        $Exc.Add('Frontend')
        $Exc.Add('Frontend Ports')
        $Exc.Add('Gateways')
        $Exc.Add('HTTP Listeners')
        $Exc.Add('Request Routing Rules')
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

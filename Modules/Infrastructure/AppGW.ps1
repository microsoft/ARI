<#
.Synopsis
Inventory for Azure Application Gateway

.DESCRIPTION
This script consolidates information for all microsoft.network/applicationgateways and  resource provider in $Resources variable. 
Excel Sheet Name: AppGW

.Link
https://github.com/microsoft/ARI/Modules/Networking/AppGW.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.0.3
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>

param($SCPath, $Sub, $Intag, $Resources, $Task , $File, $SmaResources, $TableStyle, $Unsupported) 
If ($Task -eq 'Processing') {

    $APPGTW = $Resources | Where-Object { $_.TYPE -eq 'microsoft.network/applicationgateways' }
    $APPGTWPOL = $Resources | Where-Object { $_.TYPE -eq 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies' }

    if($APPGTW)
        {
            $tmp = @()

            foreach ($1 in $APPGTW) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.Id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $RetDate = ''
                $RetFeature = ''
                if($data.sku.tier -in ('Standard','WAF'))
                    {
                        $RetDate = ($Unsupported | Where-Object {$_.Id -eq 17}).RetirementDate
                        $RetFeature = ($Unsupported | Where-Object {$_.Id -eq 17}).RetiringFeature
                    }
                if([string]::IsNullOrEmpty($data.autoscaleConfiguration.maxCapacity)){$MaxCap = 'Autoscale Disabled'}else{$MaxCap = $data.autoscaleConfiguration.maxCapacity}
                if([string]::IsNullOrEmpty($data.autoscaleConfiguration.minCapacity)){$MinCap = 'Autoscale Disabled'}else{$MinCap = $data.autoscaleConfiguration.minCapacity}
                if([string]::IsNullOrEmpty($data.sslPolicy.minProtocolVersion)){$PROT = 'Default'}else{$PROT = $data.sslPolicy.minProtocolVersion}
                if([string]::IsNullOrEmpty($data.webApplicationFirewallConfiguration.enabled)){$WAF = 'false'}else{$WAF = $data.webApplicationFirewallConfiguration.enabled}
                if($WAF -eq 'false' -and $1.id -in $APPGTWPOL.properties.applicationGateways.id){$WAF = 'true'}
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) {        
                        $obj = @{
                            'ID'                    = $1.id;
                            'Subscription'          = $sub1.Name;
                            'Resource Group'        = $1.RESOURCEGROUP;
                            'Name'                  = $1.NAME;
                            'Location'              = $1.LOCATION;
                            'Retirement Date'       = [string]$RetDate;
                            'Retirement Feature'    = $RetFeature;
                            'State'                 = $data.OperationalState;
                            'WAF Enabled'           = $WAF;
                            'Minimum TLS Version'   = "$($PROT -Replace '_', '.' -Replace 'v', ' ' -Replace 'tls', 'TLS')";
                            'Autoscale Min Capacity'= $MinCap;
                            'Autoscale Max Capacity'= $MaxCap;
                            'SKU Name'              = $data.sku.tier;
                            'Current Instances'     = $data.sku.capacity;
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
                        $tmp += $obj
                        if ($ResUCount -eq 1) { $ResUCount = 0 } 
                    }               
            }
            $tmp
        }
}
Else {
    if ($SmaResources.APPGW) {

        $TableName = ('APPGWTable_'+($SmaResources.APPGW.id | Select-Object -Unique).count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

        $condtxt = @()
        $condtxt += New-ConditionalText FALSE -Range F:F
        $condtxt += New-ConditionalText FALSO -Range F:F
        $condtxt += New-ConditionalText Default -Range G:G
        $condtxt += New-ConditionalText 'Autoscale Disabled' -Range H:H
        $condtxt += New-ConditionalText 'Autoscale Disabled' -Range I:I
        $condtxt += New-ConditionalText - -Range K:K -ConditionalType ContainsText

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('State')
        $Exc.Add('WAF Enabled')
        $Exc.Add('Minimum TLS Version')
        $Exc.Add('Autoscale Min Capacity')
        $Exc.Add('Autoscale Max Capacity')
        $Exc.Add('SKU Name')
        $Exc.Add('Retirement Date')
        $Exc.Add('Retirement Feature')  
        $Exc.Add('Current Instances')
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

        $ExcelVar = $SmaResources.APPGW 

        $ExcelVar | 
        ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        Export-Excel -Path $File -WorksheetName 'App Gateway' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style

        $excel = Open-ExcelPackage -Path $File -KillExcel
    
        $null = $excel.'App Gateway'.Cells["K1"].AddComment("It's important to be aware of upcoming Azure services and feature retirements to understand their impact on your workloads and plan migration.", "Azure Resource Inventory")
        $excel.'App Gateway'.Cells["K1"].Hyperlink = 'https://learn.microsoft.com/en-us/azure/advisor/advisor-how-to-plan-migration-workloads-service-retirement'

        Close-ExcelPackage $excel

    }
}

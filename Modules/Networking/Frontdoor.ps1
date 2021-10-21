<#
.Synopsis
Inventory for Azure Frontdoor

.DESCRIPTION
This script consolidates information for all microsoft.network/frontdoors and  resource provider in $Resources variable. 
Excel Sheet Name: Frontdoor

.Link
https://github.com/azureinventory/ARI/Modules/Networking/Frontdoor.ps1

.COMPONENT
   This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 2.0.0
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $InTag, $Resources, $Task , $File, $SmaResources, $TableStyle, $Unsupported) 
If ($Task -eq 'Processing') {

    $FRONTDOOR = $Resources | Where-Object { $_.TYPE -eq 'microsoft.network/frontdoors' }

    if($FRONTDOOR)
        {
            $tmp = @()

            foreach ($1 in $FRONTDOOR) 
                {
                    $ResUCount = 1
                    $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                    $data = $1.PROPERTIES
                    if([string]::IsNullOrEmpty($data.frontendendpoints.properties.webApplicationFirewallPolicyLink.id)){$WAF = $false} else {$WAF = $data.frontendendpoints.properties.webApplicationFirewallPolicyLink.id.split('/')[8]}
                    $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                        foreach ($Tag in $Tags) 
                            {  
                                $obj = @{
                                    'Subscription'   = $sub1.name;
                                    'Resource Group' = $1.RESOURCEGROUP;
                                    'Name'           = $1.NAME;
                                    'Location'       = $1.LOCATION;
                                    'Friendly Name'  = $data.friendlyName;
                                    'cName'          = $data.cName;
                                    'State'          = $data.enabledState;
                                    'Web Application Firewall' = [string]$WAF;
                                    'Frontend'       = [string]$data.frontendEndpoints.name;
                                    'Backend'        = [string]$data.backendPools.name;
                                    'Health Probe'   = [string]$data.healthProbeSettings.name;
                                    'Load Balancing' = [string]$data.loadBalancingSettings.name;
                                    'Routing Rules'  = [string]$data.routingRules.name;
                                    'Resource U'     = $ResUCount;
                                    'Tag Name'       = [string]$Tag.Name;
                                    'Tag Value'      = [string]$Tag.Value
                                }
                                $tmp += $obj
                                if ($ResUCount -eq 1) { $ResUCount = 0 } 
                            }               
                }
            $tmp
        }
}
Else {
    if ($SmaResources.FRONTDOOR) {
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

        $condtxt = @()        
        $condtxt += New-ConditionalText FALSE -Range H:H
        $condtxt += New-ConditionalText FALSO -Range H:H

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('Friendly Name')
        $Exc.Add('cName')
        $Exc.Add('State')
        $Exc.Add('Web Application Firewall')
        $Exc.Add('Frontend')
        $Exc.Add('Backend')
        $Exc.Add('Health Probe')
        $Exc.Add('Load Balancing')
        $Exc.Add('Routing Rules')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.FrontDoor 

        $ExcelVar | 
        ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        Export-Excel -Path $File -WorksheetName 'FrontDoor' -AutoSize -MaxAutoSizeRows 100 -TableName 'AzureFrontDoor' -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style
    
    }
}
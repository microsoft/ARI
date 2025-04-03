<#
.Synopsis
Inventory for Azure Frontdoor

.DESCRIPTION
This script consolidates information for all microsoft.network/frontdoors and  resource provider in $Resources variable. 
Excel Sheet Name: Frontdoor

.Link
https://github.com/microsoft/ARI/Modules/Public/InventoryModules/Network_2/Frontdoor.ps1

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

    $FRONTDOOR = $Resources | Where-Object { $_.TYPE -eq 'microsoft.network/frontdoors' }

    if($FRONTDOOR)
        {
            $tmp = foreach ($1 in $FRONTDOOR) 
                {
                    $ResUCount = 1
                    $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
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
                    if([string]::IsNullOrEmpty($data.frontendendpoints.properties.webApplicationFirewallPolicyLink.id)){$WAF = $false} else {$WAF = $data.frontendendpoints.properties.webApplicationFirewallPolicyLink.id.split('/')[8]}
                    $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                        foreach ($Tag in $Tags) 
                            {  
                                $obj = @{
                                    'ID'                        = $1.id;
                                    'Subscription'              = $sub1.Name;
                                    'Resource Group'            = $1.RESOURCEGROUP;
                                    'Name'                      = $1.NAME;
                                    'Location'                  = $1.LOCATION;
                                    'Retiring Feature'          = $RetiringFeature;
                                    'Retiring Date'             = $RetiringDate;
                                    'Friendly Name'             = $data.friendlyName;
                                    'cName'                     = $data.cName;
                                    'State'                     = $data.enabledState;
                                    'Web Application Firewall'  = [string]$WAF;
                                    'Frontend'                  = [string]$data.frontendEndpoints.name;
                                    'Backend'                   = [string]$data.backendPools.name;
                                    'Health Probe'              = [string]$data.healthProbeSettings.name;
                                    'Load Balancing'            = [string]$data.loadBalancingSettings.name;
                                    'Routing Rules'             = [string]$data.routingRules.name;
                                    'Resource U'                = $ResUCount;
                                    'Total'                     = $Total;
                                    'Tag Name'                  = [string]$Tag.Name;
                                    'Tag Value'                 = [string]$Tag.Value
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

        $TableName = ('FRONTDOORTable_'+($SmaResources.'Resource U').count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

        $condtxt = @()
        $condtxt += New-ConditionalText FALSE -Range J:J
        #Retirement
        $condtxt += New-ConditionalText -Range E2:E100 -ConditionalType ContainsText

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('Retiring Feature')
        $Exc.Add('Retiring Date')
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

        [PSCustomObject]$SmaResources | 
        ForEach-Object { $_ } | Select-Object $Exc | 
        Export-Excel -Path $File -WorksheetName 'FrontDoor' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style

    }
}
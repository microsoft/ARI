<#
.Synopsis
Inventory for Azure Function and App Services

.DESCRIPTION
This script consolidates information for all microsoft.web/sites resource provider in $Resources variable. 
Excel Sheet Name: APPServices

.Link
https://github.com/microsoft/ARI/Modules/Public/InventoryModules/Web/APPServices.ps1

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

        $AppSvc = $Resources | Where-Object {$_.TYPE -eq 'microsoft.web/sites'}

    <######### Insert the resource Process here ########>

    if($AppSvc)
        {
            $tmp = foreach ($1 in $AppSvc) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
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
                if([string]::IsNullOrEmpty($data.siteConfig.ftpsState)){$FTPS = $false}else{$FTPS = $data.siteConfig.ftpsState}
                if([string]::IsNullOrEmpty($data.Properties.SiteConfig.acrUseManagedIdentityCreds)){$MGMID = $false}else{$MGMID = $true}
                $VNET = if(![string]::IsNullOrEmpty($data.virtualNetworkSubnetId)){$data.virtualNetworkSubnetId.split("/")[8]}else{$null}
                $SUBNET = if(![string]::IsNullOrEmpty($data.virtualNetworkSubnetId)){$data.virtualNetworkSubnetId.split("/")[10]}else{$null}
                $Stack = if(![string]::IsNullOrEmpty($data.SiteConfig.linuxFxVersion)){$data.SiteConfig.linuxFxVersion}else{$data.SiteConfig.windowsFxVersion}
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                foreach ($2 in $data.hostNameSslStates) {
                        foreach ($Tag in $Tags) {
                            $obj = @{
                                'ID'                            = $1.id;
                                'Subscription'                  = $sub1.Name;
                                'Resource Group'                = $1.RESOURCEGROUP;
                                'Name'                          = $1.NAME;
                                'SKU'                           = $data.sku;
                                'Retiring Feature'              = $RetiringFeature;
                                'Retiring Date'                 = $RetiringDate;
                                'App Type'                      = $1.KIND;
                                'Location'                      = $1.LOCATION;
                                'Enabled'                       = $data.enabled;
                                'State'                         = $data.state;
                                'Client Cert Enabled'           = $data.clientCertEnabled;
                                'Client Cert Mode'              = $data.clientCertMode;
                                'Content Availability State'    = $data.contentAvailabilityState;
                                'Runtime Availability State'    = $data.runtimeAvailabilityState;
                                'HTTPS Only'                    = $data.httpsOnly;
                                'FTPS Only'                     = $FTPS;
                                'Possible Inbound IP Addresses' = $data.possibleInboundIpAddresses;
                                'Repository Site Name'          = $data.repositorySiteName;
                                'Managed Identity'              = $MGMID;
                                'Availability State'            = $data.availabilityState;
                                'HostNames'                     = $2.Name;
                                'HostName Type'                 = $2.hostType;
                                'Stack'                         = $Stack;
                                'Virtual Network'               = $VNET;
                                'Subnet'                        = $SUBNET;
                                'SSL State'                     = $2.sslState;
                                'Default Hostname'              = $data.defaultHostName;                        
                                'Container Size'                = $data.containerSize;
                                'Admin Enabled'                 = $data.adminEnabled;                        
                                'FTPs Host Name'                = $data.ftpsHostName;                        
                                'Resource U'                    = $ResUCount;
                                'Tag Name'                      = [string]$Tag.Name;
                                'Tag Value'                     = [string]$Tag.Value
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
        $TableName = ('AppSvcsTable_'+($SmaResources.'Resource U').count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

        $condtxt = @()        
        $condtxt += New-ConditionalText FALSE -Range Q:Q
        $condtxt += New-ConditionalText FALSE -Range R:R
        $condtxt += New-ConditionalText FALSE -Range M:M
        $condtxt += New-ConditionalText FALSE -Range U:U
        $condtxt += New-ConditionalText - -Range L:L -ConditionalType ContainsText
        #Retirement
        $condtxt += New-ConditionalText -Range E2:E100 -ConditionalType ContainsText

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('SKU')
        $Exc.Add('Retiring Feature')
        $Exc.Add('Retiring Date')
        $Exc.Add('App Type')
        $Exc.Add('Location')
        $Exc.Add('Enabled')
        $Exc.Add('State')
        $Exc.Add('Client Cert Enabled')
        $Exc.Add('Client Cert Mode')
        $Exc.Add('Content Availability State')
        $Exc.Add('Runtime Availability State')
        $Exc.Add('HTTPS Only')
        $Exc.Add('FTPS Only')
        $Exc.Add('Possible Inbound IP Addresses')
        $Exc.Add('Repository Site Name')
        $Exc.Add('Managed Identity')
        $Exc.Add('Availability State')
        $Exc.Add('HostNames')
        $Exc.Add('HostName Type')
        $Exc.Add('Stack')
        $Exc.Add('Virtual Network')
        $Exc.Add('Subnet')
        $Exc.Add('SSL State')
        $Exc.Add('Default Hostname')                      
        $Exc.Add('Container Size')
        $Exc.Add('Admin Enabled')                       
        $Exc.Add('FTPs Host Name')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value')
            }

        [PSCustomObject]$SmaResources | 
        ForEach-Object { $_ } | Select-Object $Exc | 
        Export-Excel -Path $File -WorksheetName 'App Services' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style

    }
}
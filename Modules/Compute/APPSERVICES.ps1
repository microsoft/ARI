<#
.Synopsis
Inventory for Azure Function and App Services

.DESCRIPTION
This script consolidates information for all microsoft.web/sites resource provider in $Resources variable. 
Excel Sheet Name: APPServices

.Link
https://github.com/azureinventory/ARI/Modules/Compute/APPServices.ps1

.COMPONENT
   This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 2.0.0
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Task ,$File, $SmaResources, $TableStyle, $Unsupported)
 
If ($Task -eq 'Processing')
{
 
    <######### Insert the resource extraction here ########>

        $AppSvc = $Resources | Where-Object {$_.TYPE -eq 'microsoft.web/sites'}

    <######### Insert the resource Process here ########>

    if($AppSvc)
        {
            $tmp = @()

            foreach ($1 in $AppSvc) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                if([string]::IsNullOrEmpty($data.siteConfig.ftpsState)){$FTPS = $false}else{$FTPS = $data.siteConfig.ftpsState}
                if([string]::IsNullOrEmpty($data.Properties.SiteConfig.acrUseManagedIdentityCreds)){$MGMID = $false}else{$MGMID = $true}
                $VNET = $data.virtualNetworkSubnetId.split("/")[8]
                $SUBNET = $data.virtualNetworkSubnetId.split("/")[10]
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                foreach ($2 in $data.hostNameSslStates) {
                        foreach ($Tag in $Tags) {
                            $obj = @{
                                'Subscription'                  = $sub1.name;
                                'Resource Group'                = $1.RESOURCEGROUP;
                                'Name'                          = $1.NAME;
                                'App Type'                      = $1.KIND;
                                'Location'                      = $1.LOCATION;
                                'Enabled'                       = $data.enabled;
                                'State'                         = $data.state;
                                'SKU'                           = $data.sku;
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
                                'Stack'                         = $data.SiteConfig.linuxFxVersion;
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
                            $tmp += $obj
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

    if($SmaResources.APPSERVICES)
    {

        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

        $condtxt = @()
        Foreach ($UnSupOS in $Unsupported.WebSite)
            {
                $condtxt += New-ConditionalText $UnSupOS -Range U:U
            }
        
        $condtxt += New-ConditionalText FALSE -Range M:M
        $condtxt += New-ConditionalText FALSO -Range M:M
        $condtxt += New-ConditionalText FALSE -Range N:N
        $condtxt += New-ConditionalText FALSO -Range N:N
        $condtxt += New-ConditionalText FALSE -Range I:I
        $condtxt += New-ConditionalText FALSO -Range I:I
        $condtxt += New-ConditionalText FALSE -Range Q:Q
        $condtxt += New-ConditionalText FALSO -Range Q:Q

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('App Type')
        $Exc.Add('Location')
        $Exc.Add('Enabled')
        $Exc.Add('State')
        $Exc.Add('SKU')
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

        $ExcelVar = $SmaResources.APPSERVICES 

        $ExcelVar | 
        ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        Export-Excel -Path $File -WorksheetName 'App Services' -AutoSize -MaxAutoSizeRows 100 -TableName 'AppSvcs' -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style

    }
}
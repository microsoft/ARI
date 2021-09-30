<#
.Synopsis
Inventory for Azure API Management

.DESCRIPTION
This script consolidates information for all microsoft.apimanagement/service resource provider in $Resources variable. 
Excel Sheet Name: APIM

.Link
https://github.com/azureinventory/ARI/Modules/Infrastructure/APIM.ps1

.COMPONENT
   This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 2.0.0
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Task ,$File, $SmaResources, $TableStyle)
 
If ($Task -eq 'Processing')
{
 
    <######### Insert the resource extraction here ########>

        $APIM = $Resources | Where-Object {$_.TYPE -eq 'microsoft.apimanagement/service'}

    <######### Insert the resource Process here ########>

    if($APIM)
        {
            $tmp = @()

            foreach ($1 in $APIM) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                if ($data.virtualNetworkType -eq 'None') { $NetType = '' } else { $NetType = [string]$data.virtualNetworkConfiguration.subnetResourceId.split("/")[8] }
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) {
                        $obj = @{
                            'Subscription'         = $sub1.name;
                            'Resource Group'       = $1.RESOURCEGROUP;
                            'Name'                 = $1.NAME;
                            'Location'             = $1.LOCATION;
                            'SKU'                  = $1.sku.name;
                            'Gateway URL'          = $data.gatewayUrl;
                            'Virtual Network Type' = $data.virtualNetworkType;
                            'Virtual Network'      = $NetType;
                            'Http2'                = $data.customProperties."Microsoft.WindowsAzure.ApiManagement.Gateway.Protocols.Server.Http2";
                            'Backend SSL 3.0'      = $data.customProperties."Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Ssl30";
                            'Backend TLS 1.0'      = $data.customProperties."Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls10";
                            'Backend TLS 1.1'      = $data.customProperties."Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls11";
                            'Triple DES'           = $data.customProperties."Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TripleDes168";
                            'Client SSL 3.0'       = $data.customProperties."Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Ssl30";
                            'Client TLS 1.0'       = $data.customProperties."Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls10";
                            'Client TLS 1.1'       = $data.customProperties."Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls11";
                            'Public IP'            = [string]$data.publicIPAddresses;
                            'Tag Name'             = [string]$Tag.Name;
                            'Tag Value'            = [string]$Tag.Value
                        }
                        $tmp += $obj
                        if ($ResUCount -eq 1) { $ResUCount = 0 } 
                    }               
            }
            $tmp
        }
}

<######## Resource Excel Reporting Begins Here ########>

Else
{
    <######## $SmaResources.(RESOURCE FILE NAME) ##########>

    if($SmaResources.APIM)
    {

        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('SKU')
        $Exc.Add('Gateway URL')
        $Exc.Add('Virtual Network Type')
        $Exc.Add('Virtual Network')
        $Exc.Add('Http2')
        $Exc.Add('Backend SSL 3.0')
        $Exc.Add('Backend TLS 1.0')
        $Exc.Add('Backend TLS 1.1')
        $Exc.Add('Triple DES')
        $Exc.Add('Client SSL 3.0')
        $Exc.Add('Client TLS 1.0')
        $Exc.Add('Client TLS 1.1')
        $Exc.Add('Public IP')
        if($InTag)
        {
            $Exc.Add('Tag Name')
            $Exc.Add('Tag Value') 
        }

        $ExcelVar = $SmaResources.APIM 

        $ExcelVar | 
        ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        Export-Excel -Path $File -WorksheetName 'APIM' -AutoSize -MaxAutoSizeRows 100 -TableName 'AzureAPIM' -TableStyle $tableStyle -Style $Style

        <######## Insert Column comments and documentations here following this model #########>


        #$excel = Open-ExcelPackage -Path $File -KillExcel


        #Close-ExcelPackage $excel 

    }
}
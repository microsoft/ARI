<#
.Synopsis
Inventory for Azure API Management

.DESCRIPTION
This script consolidates information for all microsoft.apimanagement/service resource provider in $Resources variable. 
Excel Sheet Name: APIM

.Link
https://github.com/microsoft/ARI/Modules/Public/InventoryModules/Integration/APIM.ps1

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

        $APIM = $Resources | Where-Object {$_.TYPE -eq 'microsoft.apimanagement/service'}

    <######### Insert the resource Process here ########>

    if($APIM)
        {
            $tmp = foreach ($1 in $APIM) {
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
                if ($data.virtualNetworkType -eq 'None') { $NetType = '' } else { $NetType = [string]$data.virtualNetworkConfiguration.subnetResourceId.split("/")[8] }
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) {
                        $obj = @{
                            'ID'                   = $1.id;
                            'Subscription'         = $sub1.Name;
                            'Resource Group'       = $1.RESOURCEGROUP;
                            'Name'                 = $1.NAME;
                            'Location'             = $1.LOCATION;
                            'SKU'                  = $1.sku.name;
                            'Retiring Feature'     = $RetiringFeature;
                            'Retiring Date'        = $RetiringDate;
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
                            'Resource U'         = $ResUCount;
                            'Tag Name'             = [string]$Tag.Name;
                            'Tag Value'            = [string]$Tag.Value
                        }
                        $obj
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

    if($SmaResources)
    {

        $TableName = ('APIMTable_'+($SmaResources.'Resource U').count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

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

        [PSCustomObject]$SmaResources | 
        ForEach-Object { $_ } | Select-Object $Exc | 
        Export-Excel -Path $File -WorksheetName 'APIM' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style

    }
}
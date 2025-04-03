<#
.Synopsis
Inventory for Azure Bastion Hosts

.DESCRIPTION
This script consolidates information for all microsoft.network/bastionhosts and  resource provider in $Resources variable. 
Excel Sheet Name: BASTION

.Link
https://github.com/microsoft/ARI/Modules/Public/InventoryModules/Network_1/BastionHosts.ps1

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

        $BASTION = $Resources | Where-Object {$_.TYPE -eq 'microsoft.network/bastionhosts'}

    <######### Insert the resource Process here ########>

    if($BASTION)
        {
            $tmp = foreach ($1 in $BASTION) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.Id -eq $1.subscriptionId }
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
                $BastVNET = if(![string]::IsNullOrEmpty($data.ipConfigurations.properties.subnet.id)){$data.ipConfigurations.properties.subnet.id.split("/")[8]}else{$null}
                $BastPIP = if(![string]::IsNullOrEmpty($data.ipConfigurations.properties.publicIPAddress.id)){$data.ipConfigurations.properties.publicIPAddress.id.split("/")[8]}else{$null}
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) {
                        $obj = @{
                            'ID'              = $1.id;
                            'Subscription'    = $sub1.Name;
                            'Resource Group'  = $1.RESOURCEGROUP;
                            'Name'            = $1.NAME;
                            'Location'        = $1.LOCATION;
                            'SKU'             = $1.sku.name;
                            'Retiring Feature'= $RetiringFeature;
                            'Retiring Date'   = $RetiringDate;
                            'DNS Name'        = $data.dnsName;
                            'Virtual Network' = $BastVNET;
                            'Public IP'       = $BastPIP;
                            'Scale Units'     = $data.scaleUnits;
                            'Resource U'       = $ResUCount;
                            'Tag Name'        = [string]$Tag.Name;
                            'Tag Value'       = [string]$Tag.Value
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

        $TableName = ('BASTIONTable_'+($SmaResources.'Resource U').count)
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
        $Exc.Add('DNS Name')
        $Exc.Add('Virtual Network')
        $Exc.Add('Public IP')
        $Exc.Add('Scale Units')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        [PSCustomObject]$SmaResources | 
        ForEach-Object { $_ } | Select-Object $Exc | 
        Export-Excel -Path $File -WorksheetName 'Bastion Hosts' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -ConditionalText $condtxt -TableStyle $tableStyle -Style $Style

    }
}
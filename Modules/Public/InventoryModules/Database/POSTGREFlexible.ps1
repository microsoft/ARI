<#
.Synopsis
Inventory for Azure Database for Postgre SQL Flexible Server

.DESCRIPTION
This script consolidates information for all Microsoft.DBforPostgreSQL/flexibleServers resource provider in $Resources variable. 
Excel Sheet Name: POSTGRE Flexible

.Link
https://github.com/microsoft/ARI/Modules/Public/InventoryModules/Database/POSTGREFlexible.ps1

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

    $POSTGRE = $Resources | Where-Object { $_.TYPE -eq 'Microsoft.DBforPostgreSQL/flexibleServers' }

    if($POSTGRE)
        {
            $tmp = foreach ($1 in $POSTGRE) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $sku = $1.SKU
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
                $DelegatedVNET = if(![string]::IsNullOrEmpty($data.network.delegatedsubnetresourceid)){$data.network.delegatedsubnetresourceid.split('/')[8]}else{$null}
                $DelegatedSubnet = if(![string]::IsNullOrEmpty($data.network.delegatedsubnetresourceid)){$data.network.delegatedsubnetresourceid.split('/')[10]}else{$null}
                $PrivateDNSZone = if(![string]::IsNullOrEmpty($data.network.privatednszonearmresourceid)){$data.network.privatednszonearmresourceid.split('/')[8]}else{$null}
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) {
                        $obj = @{
                            'ID'                        = $1.id;
                            'Subscription'              = $sub1.Name;
                            'Resource Group'            = $1.RESOURCEGROUP;
                            'Name'                      = $1.NAME;
                            'Location'                  = $1.LOCATION;
                            'Retiring Feature'          = $RetiringFeature;
                            'Retiring Date'             = $RetiringDate;
                            'FQDN'                      = $data.fullyqualifieddomainname;
                            'ADMIN Login'               = $data.administratorLogin;
                            'Version'                   = [string]($data.version+'.'+$data.minorversion);
                            'AD Authentication'         = $data.authconfig.activedirectoryauth;
                            'Password Authentication'   = $data.authconfig.passwordauth;
                            'Computer Tier'             = $sku.tier;
                            'Computer Size'             = $sku.name;
                            'Storage Size (GB)'         = $data.storage.storagesizegb;
                            'Availability Zone'         = $data.availabilityzone;
                            'High Availability'         = $data.highavailability.state;
                            'Data Encryption'           = $data.dataencryption.type;
                            'Backup Retention (Days)'   = $data.backup.backupretentiondays;
                            'Geo-Redundant Backup'      = $data.backup.geoRedundantBackup;
                            'Replication Role'          = $data.replicationRole;
                            'Replication Capacity'      = $data.replicaCapacity;
                            'Public Network Access'     = $data.network.publicnetworkaccess;
                            'Delegated VNET'            = $DelegatedVNET;
                            'Delegated Subnet'          = $DelegatedSubnet;
                            'Private DNS Zone'          = $PrivateDNSZone;
                            'Resource U'                = $ResUCount;
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
<######## Resource Excel Reporting Begins Here ########>

Else {
    <######## $SmaResources.(RESOURCE FILE NAME) ##########>

    if ($SmaResources) {

        $TableName = ('POSTGFlex_'+($SmaResources.'Resource U').count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

        $condtxt = @()
        $condtxt += New-ConditionalText enabled -Range V:V
        $condtxt += New-ConditionalText notenabled -Range P:P
        #Retirement
        $condtxt += New-ConditionalText -Range E2:E100 -ConditionalType ContainsText

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription') #A
        $Exc.Add('Resource Group') #B
        $Exc.Add('Name') #C
        $Exc.Add('Location') #D
        $Exc.Add('Retiring Feature')
        $Exc.Add('Retiring Date')
        $Exc.Add('FQDN') #G
        $Exc.Add('ADMIN Login') #H
        $Exc.Add('Version') #I
        $Exc.Add('AD Authentication') #J
        $Exc.Add('Password Authentication') #K
        $Exc.Add('Computer Tier') #L
        $Exc.Add('Computer Size') #M
        $Exc.Add('Storage Size (GB)') #N
        $Exc.Add('Availability Zone') #O
        $Exc.Add('High Availability') #P
        $Exc.Add('Data Encryption') #Q 
        $Exc.Add('Backup Retention (Days)') #R
        $Exc.Add('Geo-Redundant Backup') #S
        $Exc.Add('Replication Role') #T
        $Exc.Add('Replication Capacity') #U
        $Exc.Add('Public Network Access') #V
        $Exc.Add('Delegated VNET') #W
        $Exc.Add('Delegated Subnet') #X
        $Exc.Add('Private DNS Zone') #Y
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        [PSCustomObject]$SmaResources | 
        ForEach-Object { $_ } | Select-Object $Exc | 
        Export-Excel -Path $File -WorksheetName 'PostgreSQL Flexible' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style

    }
}

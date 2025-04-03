<#
.Synopsis
Inventory for Azure Database for Postgre

.DESCRIPTION
This script consolidates information for all microsoft.dbforpostgresql/servers resource provider in $Resources variable. 
Excel Sheet Name: POSTGRE

.Link
https://github.com/microsoft/ARI/Modules/Public/InventoryModules/Database/POSTGRE.ps1

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

    $POSTGRE = $Resources | Where-Object { $_.TYPE -eq 'microsoft.dbforpostgresql/servers' }

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
                if(!$data.privateEndpointConnections){$PVTENDP = $false}else{$PVTENDP = $data.privateEndpointConnections.Id.split("/")[8]}
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) {
                        $obj = @{
                            'ID'                        = $1.id;
                            'Subscription'              = $sub1.Name;
                            'Resource Group'            = $1.RESOURCEGROUP;
                            'Name'                      = $1.NAME;
                            'Location'                  = $1.LOCATION;
                            'SKU'                       = $sku.name;
                            'SKU Family'                = $sku.family;
                            'Tier'                      = $sku.tier;
                            'Retiring Feature'          = $RetiringFeature;
                            'Retiring Date'             = $RetiringDate;
                            'Capacity'                  = $sku.capacity;
                            'Postgre Version'           = $data.version;
                            'Private Endpoint'          = $PVTENDP;
                            'Backup Retention Days'     = $data.storageProfile.backupRetentionDays;
                            'Geo-Redundant Backup'      = $data.storageProfile.geoRedundantBackup;
                            'Auto Grow'                 = $data.storageProfile.storageAutogrow;
                            'Storage MB'                = $data.storageProfile.storageMB;
                            'Public Network Access'     = $data.publicNetworkAccess;
                            'Admin Login'               = $data.administratorLogin;
                            'Infrastructure Encryption' = $data.InfrastructureEncryption;
                            'Minimum TLS Version'       = "$($data.minimalTlsVersion -Replace '_', '.' -Replace 'tls', 'TLS')";
                            'State'                     = $data.userVisibleState;
                            'Replica Capacity'          = $data.replicaCapacity;
                            'Replication Role'          = $data.replicationRole;
                            'BYOK Enforcement'          = $data.byokEnforcement;
                            'SSL Enforcement'           = $data.sslEnforcement;
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

        $TableName = ('POSTGRETable_'+($SmaResources.'Resource U').count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

        $SheetName = 'PostgreSQL'

        $condtxt = @()
        $condtxt += New-ConditionalText FALSE -Range L:L
        $condtxt += New-ConditionalText Disabled -Range M:M
        $condtxt += New-ConditionalText Enabled -Range Q:Q
        $condtxt += New-ConditionalText TLSEnforcementDisabled -Range T:T
        $condtxt += New-ConditionalText Disabled -Range Y:Y
        #Retirement
        $condtxt += New-ConditionalText -Range J2:J100 -ConditionalType ContainsText


        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('SKU')
        $Exc.Add('SKU Family')
        $Exc.Add('Tier')
        $Exc.Add('Capacity')
        $Exc.Add('Postgre Version')
        $Exc.Add('Retiring Feature')
        $Exc.Add('Retiring Date')
        $Exc.Add('Private Endpoint')
        $Exc.Add('Backup Retention Days')
        $Exc.Add('Geo-Redundant Backup')
        $Exc.Add('Auto Grow')
        $Exc.Add('Storage MB')
        $Exc.Add('Public Network Access')
        $Exc.Add('Admin Login')
        $Exc.Add('Infrastructure Encryption')
        $Exc.Add('Minimum TLS Version')
        $Exc.Add('State')
        $Exc.Add('Replica Capacity')
        $Exc.Add('Replication Role')
        $Exc.Add('BYOK Enforcement')
        $Exc.Add('SSL Enforcement')
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

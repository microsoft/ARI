<#
.Synopsis
Inventory for Azure Storage Account

.DESCRIPTION
This script consolidates information for all microsoft.storage/storageaccounts and  resource provider in $Resources variable.
Excel Sheet Name: StorageAcc

.Link
https://github.com/microsoft/ARI/Modules/Public/InventoryModules/Storage/StorageAccounts.ps1

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
    <######### Insert the resource extraction here ########>

    $storageacc = $Resources | Where-Object { $_.TYPE -eq 'microsoft.storage/storageaccounts' }

    <######### Insert the resource Process here ########>

    if($storageacc)
        {
            $tmp = foreach ($1 in $storageacc) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.Id -eq $1.subscriptionId }
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
                $timecreated = $data.creationTime
                $timecreated = [datetime]$timecreated
                $timecreated = $timecreated.ToString("yyyy-MM-dd HH:mm")
                $TLSv = if ($data.minimumTlsVersion -eq 'TLS1_2') { "TLS 1.2" }elseif ($data.minimumTlsVersion -eq 'TLS1_1') { "TLS 1.1" }else { "TLS 1.0" }
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                $VNETRules = if(![string]::IsNullOrEmpty($data.networkacls.virtualnetworkrules)){$data.networkacls.virtualnetworkrules}else{' '}
                $BlobAccess = if ($data.allowBlobPublicAccess -eq $false){$false}else{$true}
                $KeyAccess = if($data.allowsharedkeyaccess -eq $true){$true}else{$false}
                $SFTPEnabled = if($data.isSftpEnabled -eq $true){$true}else{$false}
                $HNSEnabled = if($data.ishnsenabled -eq $true){$true}else{$false}
                $NFSv3 = if($data.isnfsv3enabled -eq $true){$true}else{$false}
                $LargeFileShare = if($data.largeFileSharesState -eq $true){$true}else{$false}
                $CrossTNT = if($data.allowCrossTenantReplication -eq $true){$true}else{$false}
                $InfrastructureEncryption = if($data.encryption.requireInfrastructureEncryption -eq "True"){$true}else{$false}

                if ($data.azureFilesIdentityBasedAuthentication.directoryServiceOptions -eq 'None')
                    {
                        $EntraID = $false
                    }
                elseif ([string]::IsNullOrEmpty($data.azureFilesIdentityBasedAuthentication.directoryServiceOptions))
                    {
                        $EntraID = $false
                    }
                else
                    {
                        $EntraID = $true
                    }

                if ($data.networkacls.defaultaction -eq 'allow')
                    {
                        $PubNetAccess = 'Enabled from all networks'
                    }
                elseif ($data.networkacls.defaultaction -eq 'Deny' -and $data.publicNetworkAccess -eq 'Enabled')
                    {
                        $PubNetAccess = 'Enabled from selected virtual networks and IP addresses'
                    }
                elseif ($data.publicNetworkAccess -eq 'Disabled')
                    {
                        $PubNetAccess = 'Disabled'
                    }

                $PVTEndpoints = @()
                foreach ($pvt in $data.privateEndpointConnections.properties.privateendpoint)
                    {
                        $PVTEndpoints += if(![string]::IsNullOrEmpty($pvt.id)){$pvt.id.split('/')[8]}else{$null}
                    }
                $DirectResources = @()
                foreach ($DiRes in $data.networkacls.resourceaccessrules)
                    {
                        $DirectResources += if(![string]::IsNullOrEmpty($DiRes.resourceid)){$DiRes.resourceid.split('/')[8]}else{$null}
                    }

                $FinalDirectResources = if ($DirectResources.count -gt 1) { $DirectResources | ForEach-Object { $_ + ' ,' } }else { $DirectResources }
                $FinalDirectResources = [string]$FinalDirectResources
                $FinalDirectResources = if ($FinalDirectResources -like '* ,*') { $FinalDirectResources -replace ".$" }else { $FinalDirectResources }

                $FinalPVTEndpoint = if ($PVTEndpoints.count -gt 1) { $PVTEndpoints | ForEach-Object { $_ + ' ,' } }else { $PVTEndpoints }
                $FinalPVTEndpoint = [string]$FinalPVTEndpoint
                $FinalPVTEndpoint = if ($FinalPVTEndpoint -like '* ,*') { $FinalPVTEndpoint -replace ".$" }else { $FinalPVTEndpoint }

                $FinalACLIPs = if ($data.networkacls.iprules.value.count -gt 1) { $data.networkacls.iprules.value | ForEach-Object { $_ + ' ,' } }else { $data.networkacls.iprules.value }
                $FinalACLIPs = [string]$FinalACLIPs
                $FinalACLIPs = if ($FinalACLIPs -like '* ,*') { $FinalACLIPs -replace ".$" }else { $FinalACLIPs }

                foreach ($2 in $VNETRules)
                    {
                        $VNET = if(![string]::IsNullOrEmpty($2.id)){$2.id.split('/')[8]}else{''}
                        $Subnet = if(![string]::IsNullOrEmpty($2.id)){$2.id.split('/')[10]}else{''}
                        foreach ($Tag in $Tags) {
                            $obj = @{
                                'ID'                                    = $1.id;
                                'Subscription'                          = $sub1.Name;
                                'Resource Group'                        = $1.RESOURCEGROUP;
                                'Name'                                  = $1.NAME;
                                'Location'                              = $1.LOCATION;
                                'Retiring Feature'                      = $RetiringFeature;
                                'Retiring Date'                         = $RetiringDate;
                                'Zone'                                  = $1.ZONES;
                                'SKU'                                   = $1.sku.name;
                                'Tier'                                  = $1.sku.tier;
                                'Storage Account Kind'                  = $1.kind;
                                'Secure Transfer Required'              = $data.supportsHttpsTrafficOnly;
                                'Allow Blob Anonymous Access'           = $BlobAccess;
                                'Minimum TLS Version'                   = $TLSv;
                                'Microsoft Entra Authorization'         = $EntraID;
                                'Allow Storage Account Key Access'      = $KeyAccess;
                                'SFTP Enabled'                          = $SFTPEnabled;
                                'Hierarchical Namespace'                = $HNSEnabled;
                                'NFSv3 Enabled'                         = $NFSv3;
                                'Large File Shares'                     = $LargeFileShare;
                                'Access Tier'                           = $data.accessTier;
                                'Allow Cross Tenant Replication'        = $CrossTNT;
                                'Infrastructure Encryption Enabled'     = $InfrastructureEncryption;
                                'Public Network Access'                 = $PubNetAccess;
                                'Private Endpoints'                     = $FinalPVTEndpoint;
                                'Direct Access Resources'               = $FinalDirectResources;
                                'Virtual Networks'                      = $VNET;
                                'Subnet'                                = $Subnet;
                                'Direct Access IPs'                     = $FinalACLIPs;
                                'Firewall Exceptions'                   = [string]$data.networkacls.bypass;
                                'Primary Location'                      = $data.primaryLocation;
                                'Status Of Primary Location'            = $data.statusOfPrimary;
                                'Secondary Location'                    = $data.secondaryLocation;
                                'Status Of Secondary Location'          = $data.statusofsecondary;
                                'Created Time'                          = $timecreated;
                                'Resource U'                            = $ResUCount;
                                'Tag Name'                              = [string]$Tag.Name;
                                'Tag Value'                             = [string]$Tag.Value
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

Else {
    <######## $SmaResources.(RESOURCE FILE NAME) ##########>

    if ($SmaResources) {

        $SheetName = 'Storage Accounts'

        $TableName = ('StorAccTable_'+($SmaResources.'Resource U').count)
        $Style = @(
        New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'
        New-ExcelStyle -HorizontalAlignment Center -Width 80 -WrapText -NumberFormat '0' -Range "X:X"
        New-ExcelStyle -HorizontalAlignment Center -Width 140 -WrapText -NumberFormat '0' -Range "AA:AA"
        )

        $condtxt = @()
        $condtxt += New-ConditionalText false -Range K:K
        $condtxt += New-ConditionalText true -Range L:L
        $condtxt += New-ConditionalText 1.0 -Range M:M
        $condtxt += New-ConditionalText 1.1 -Range M:M
        $condtxt += New-ConditionalText all -Range W:W
        $condtxt += New-ConditionalText . -Range AB:AB -ConditionalType ContainsText
        $condtxt += New-ConditionalText unavailable -Range AE:AE
        $condtxt += New-ConditionalText unavailable -Range AG:AG
        #Retirement
        $condtxt += New-ConditionalText -Range I2:I100 -ConditionalType ContainsText

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('Zone')
        $Exc.Add('SKU')
        $Exc.Add('Tier')
        $Exc.Add('Storage Account Kind')
        $Exc.Add('Retiring Feature')
        $Exc.Add('Retiring Date')
        $Exc.Add('Secure Transfer Required')
        $Exc.Add('Allow Blob Anonymous Access')
        $Exc.Add('Minimum TLS Version')
        $Exc.Add('Microsoft Entra Authorization')
        $Exc.Add('Allow Storage Account Key Access')
        $Exc.Add('SFTP Enabled')
        $Exc.Add('Hierarchical Namespace')
        $Exc.Add('NFSv3 Enabled')
        $Exc.Add('Large File Shares')
        $Exc.Add('Access Tier')
        $Exc.Add('Allow Cross Tenant Replication')
        $Exc.Add('Infrastructure Encryption Enabled')
        $Exc.Add('Public Network Access')
        $Exc.Add('Private Endpoints')
        $Exc.Add('Direct Access Resources')
        $Exc.Add('Virtual Networks')
        $Exc.Add('Subnet')
        $Exc.Add('Direct Access IPs')
        $Exc.Add('Firewall Exceptions')
        $Exc.Add('Primary Location')
        $Exc.Add('Status Of Primary Location')
        $Exc.Add('Secondary Location')
        $Exc.Add('Status Of Secondary Location')
        $Exc.Add('Created Time')
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

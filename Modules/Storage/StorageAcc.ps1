<#
.Synopsis
Inventory for Azure Storage Account

.DESCRIPTION
This script consolidates information for all microsoft.storage/storageaccounts and  resource provider in $Resources variable.
Excel Sheet Name: StorageAcc

.Link
https://github.com/microsoft/ARI/Modules/Infrastructure/StorageAcc.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.1.2
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Task , $File, $SmaResources, $TableStyle, $Unsupported)

If ($Task -eq 'Processing') {
    <######### Insert the resource extraction here ########>

    $storageacc = $Resources | Where-Object { $_.TYPE -eq 'microsoft.storage/storageaccounts' }

    <######### Insert the resource Process here ########>

    if($storageacc)
        {
            $tmp = @()

            foreach ($1 in $storageacc) { 
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.Id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $RetDate = ''
                $RetFeature = '' 
                $timecreated = $data.creationTime
                $timecreated = [datetime]$timecreated
                $timecreated = $timecreated.ToString("yyyy-MM-dd HH:mm")
                $TLSv = if ($data.minimumTlsVersion -eq 'TLS1_2') { "TLS 1.2" }elseif ($data.minimumTlsVersion -eq 'TLS1_1') { "TLS 1.1" }else { "TLS 1.0" }
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                $VNETRules = if(![string]::IsNullOrEmpty($data.networkacls.virtualnetworkrules)){$data.networkacls.virtualnetworkrules}else{' '}
                $BlobAccess = if ($data.allowBlobPublicAccess -eq $false) { $false }else { $true }
                $KeyAccess = if($data.allowsharedkeyaccess -eq $true){$true}else{$false}
                $SFTPEnabled = if($data.isSftpEnabled -eq $true){$true}else{$false}
                $HNSEnabled = if($data.ishnsenabled -eq $true){$true}else{$false}
                $NFSv3 = if($data.isnfsv3enabled -eq $true){$true}else{$false}
                $LargeFileShare = if($data.largeFileSharesState -eq $true){$true}else{$false}
                $CrossTNT = if($data.allowCrossTenantReplication -eq $true){$true}else{$false}

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
                        $PVTEndpoints += $pvt.id.split('/')[8]
                    }
                $DirectResources = @()
                foreach ($DiRes in $data.networkacls.resourceaccessrules)
                    {
                        $DirectResources += $DiRes.resourceid.split('/')[8]
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
                                'Zone'                                  = $1.ZONES;
                                'SKU'                                   = $1.sku.name;
                                'Tier'                                  = $1.sku.tier;
                                'Storage Account Kind'                  = $1.kind;
                                'Retirement Date'                       = [string]$RetDate;
                                'Retirement Feature'                    = $RetFeature;
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
                            $tmp += $obj
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

    if ($SmaResources.StorageAcc) {

        $TableName = ('StorAccTable_'+($SmaResources.StorageAcc.id | Select-Object -Unique).count)
        $Style = @(
        New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'
        New-ExcelStyle -HorizontalAlignment Center -Width 80 -WrapText -NumberFormat '0' -Range "X:X"
        New-ExcelStyle -HorizontalAlignment Center -Width 140 -WrapText -NumberFormat '0' -Range "AA:AA"
        )

        $condtxt = @()
        $condtxt += New-ConditionalText false -Range K:K
        $condtxt += New-ConditionalText true -Range L:L
        $condtxt += New-ConditionalText 1.0 -Range M:M
        $condtxt += New-ConditionalText all -Range V:V
        $condtxt += New-ConditionalText . -Range AA:AA -ConditionalType ContainsText
        $condtxt += New-ConditionalText unavailable -Range AD:AD
        $condtxt += New-ConditionalText unavailable -Range AF:AF

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('Zone')
        $Exc.Add('SKU')
        $Exc.Add('Tier')
        $Exc.Add('Storage Account Kind')
        $Exc.Add('Retirement Date')
        $Exc.Add('Retirement Feature')
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

        $ExcelVar = $SmaResources.StorageAcc

        $ExcelVar |
        ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc |
        Export-Excel -Path $File -WorksheetName 'Storage Acc' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style

        <######## Insert Column comments and documentations here following this model #########>


        $excel = Open-ExcelPackage -Path $File -KillExcel

        $null = $excel.'Storage Acc'.Cells["K1"].AddComment("Is recommended that you configure your storage account to accept requests from secure connections only by setting the Secure transfer required property for the storage account.", "Azure Resource Inventory")
        $excel.'Storage Acc'.Cells["K1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/storage/common/storage-require-secure-transfer'
        $null = $excel.'Storage Acc'.Cells["L1"].AddComment("When a container is configured for anonymous access, any client can read data in that container. Anonymous access presents a potential security risk, so if your scenario does not require it, we recommend that you remediate anonymous access for the storage account.", "Azure Resource Inventory")
        $excel.'Storage Acc'.Cells["L1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/storage/blobs/anonymous-read-access-configure?tabs=portal'
        $null = $excel.'Storage Acc'.Cells["M1"].AddComment("By default, Azure Storage accounts permit clients to send and receive data with the oldest version of TLS, TLS 1.0, and above. To enforce stricter security measures, you can configure your storage account to require that clients send and receive data with a newer version of TLS", "Azure Resource Inventory")
        $excel.'Storage Acc'.Cells["M1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/storage/common/transport-layer-security-configure-minimum-version?tabs=portal'
        $null = $excel.'Storage Acc'.Cells["I1"].AddComment("It's important to be aware of upcoming Azure services and feature retirements to understand their impact on your workloads and plan migration.", "Azure Resource Inventory")
        $excel.'Storage Acc'.Cells["I1"].Hyperlink = 'https://learn.microsoft.com/en-us/azure/advisor/advisor-how-to-plan-migration-workloads-service-retirement'

        Close-ExcelPackage $excel

    }
}

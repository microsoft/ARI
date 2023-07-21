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
Version: 3.1.1
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
                $PvtEnd = [string]$data.privateEndpointConnections.count
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
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
                            'Retirement Date'                       = [string]$RetDate;
                            'Retirement Feature'                    = $RetFeature;
                            'Supports HTTPs Traffic Only'           = $data.supportsHttpsTrafficOnly;
                            'Allow Blob Public Access'              = if ($data.allowBlobPublicAccess -eq $false) { $false }else { $true };
                            'Minimum TLS Version'                   = $TLSv;
                            'Identity-based access for file shares' = if ($data.azureFilesIdentityBasedAuthentication.directoryServiceOptions -eq 'None') { $false }elseif ($null -eq $data.azureFilesIdentityBasedAuthentication.directoryServiceOptions) { $false }else { $true };
                            'Private Endpoints'                     = $PvtEnd;
                            'Access Tier'                           = $data.accessTier;
                            'Primary Location'                      = $data.primaryLocation;
                            'Status Of Primary'                     = $data.statusOfPrimary;
                            'Secondary Location'                    = $data.secondaryLocation;
                            'Blob Address'                          = [string]$data.primaryEndpoints.blob;
                            'File Address'                          = [string]$data.primaryEndpoints.file;
                            'Table Address'                         = [string]$data.primaryEndpoints.table;
                            'Queue Address'                         = [string]$data.primaryEndpoints.queue;
                            'Network Acls'                          = $data.networkAcls.defaultAction;
                            'Hierarchical namespace'                = $data.isHnsEnabled;
                            'Created Time'                          = $timecreated;   
                            'Resource U'                            = $ResUCount;
                            'Tag Name'                              = [string]$Tag.Name;
                            'Tag Value'                             = [string]$Tag.Value
                        }
                        $tmp += $obj
                        if ($ResUCount -eq 1) { $ResUCount = 0 }
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
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

        $condtxt = @()
        $condtxt += New-ConditionalText false -Range J:J
        $condtxt += New-ConditionalText falso -Range J:J
        $condtxt += New-ConditionalText true -Range K:K
        $condtxt += New-ConditionalText verdadeiro -Range K:K
        $condtxt += New-ConditionalText 1.0 -Range L:L
        $condtxt += New-ConditionalText - -Range H:H -ConditionalType ContainsText

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('Zone')
        $Exc.Add('SKU')
        $Exc.Add('Tier')
        $Exc.Add('Retirement Date')
        $Exc.Add('Retirement Feature')  
        $Exc.Add('Supports HTTPS Traffic Only')
        $Exc.Add('Allow Blob Public Access')
        $Exc.Add('Minimum TLS Version')
        $Exc.Add('Identity-based access for file shares')
        $Exc.Add('Private Endpoints')
        $Exc.Add('Access Tier')
        $Exc.Add('Primary Location')
        $Exc.Add('Status Of Primary')
        $Exc.Add('Secondary Location')
        $Exc.Add('Hierarchical namespace')
        $Exc.Add('Blob Address')
        $Exc.Add('File Address')
        $Exc.Add('Table Address')
        $Exc.Add('Queue Address')
        $Exc.Add('Network Acls')
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

        $null = $excel.'Storage Acc'.Cells["J1"].AddComment("Is recommended that you configure your storage account to accept requests from secure connections only by setting the Secure transfer required property for the storage account.", "Azure Resource Inventory")
        $excel.'Storage Acc'.Cells["J1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/storage/common/storage-require-secure-transfer'
        $null = $excel.'Storage Acc'.Cells["K1"].AddComment("When a container is configured for public access, any client can read data in that container. Public access presents a potential security risk, so if your scenario does not require it, Microsoft recommends that you disallow it for the storage account.", "Azure Resource Inventory")
        $excel.'Storage Acc'.Cells["K1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/storage/blobs/anonymous-read-access-configure?tabs=portal'
        $null = $excel.'Storage Acc'.Cells["L1"].AddComment("By default, Azure Storage accounts permit clients to send and receive data with the oldest version of TLS, TLS 1.0, and above. To enforce stricter security measures, you can configure your storage account to require that clients send and receive data with a newer version of TLS", "Azure Resource Inventory")
        $excel.'Storage Acc'.Cells["L1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/storage/common/transport-layer-security-configure-minimum-version?tabs=portal'
        $null = $excel.'Storage Acc'.Cells["H1"].AddComment("It's important to be aware of upcoming Azure services and feature retirements to understand their impact on your workloads and plan migration.", "Azure Resource Inventory")
        $excel.'Storage Acc'.Cells["H1"].Hyperlink = 'https://learn.microsoft.com/en-us/azure/advisor/advisor-how-to-plan-migration-workloads-service-retirement'

        Close-ExcelPackage $excel

    }
}

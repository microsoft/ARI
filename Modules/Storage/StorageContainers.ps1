<#
.Synopsis
Inventory for Azure Storage Account Containers

.DESCRIPTION
This script consolidates information for all microsoft.storage/storageaccounts and  resource provider in $Resources variable.
Excel Sheet Name: StorageContainer

.Link
https://github.com/microsoft/ARI/Modules/Storage/StorageContainers.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.0.2
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

            foreach ($1 in $storageacc) 
            {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.Id -eq $1.subscriptionId }

                $blobSvcs = (az storage container-rm list --resource-group $1.ResourceGroup --include-deleted --storage-account $1.name) | ConvertFrom-Json

                if($blobSvcs)
                {
                    foreach($blobContainer in $blobSvcs)
                    {
                        $modifiedTime = $blobContainer.lastModifiedTime
                        $modifiedTime = [datetime]$modifiedTime
                        $modifiedTime = $modifiedTime.ToString("yyyy-MM-dd HH:mm")

                          $obj = @{
                              'ID'                       = $blobContainer.id;
                              'Subscription'             = $sub1.name;
                              'Resource Group'           = $1.RESOURCEGROUP;
                              'Name'                     = $blobContainer.name;
                              'Location'                 = $1.LOCATION;
                              'Storage Account'          = $1.name;
                              'Deleted'                  = $blobContainer.deleted;
                              'Remaining Retention Days' = $blobContainer.remainingRetentionDays;
                              'Legal Hold'               = $blobContainer.hasLegalHold;
                              'Lease State'              = $blobContainer.leaseState;
                              'Lease Status'             = $blobContainer.leaseStatus;
                              'Public Access'            = $blobContainer.publicAccess;
                              'Immutable Policy'         = $blobContainer.hasImmutabilityPolicy;
                              'Immutable Versioning'     = $blobContainer.immutableStorageWithVersioning.enabled;
                              'Modified Time'            = $modifiedTime;
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

    if ($SmaResources.StorageContainers) {

        $TableName = ('StorageContainerTable_'+($SmaResources.StorageContainers.id | Select-Object -Unique).count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

        $condtxt = @()

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('Storage Account')
        $Exc.Add('Deleted')
        $Exc.Add('Remaining Retention Days')
        $Exc.Add('Legal Hold')
        $Exc.Add('Lease State')
        $Exc.Add('Lease Status')
        $Exc.Add('Public Access')
        $Exc.Add('Immutable Policy')
        $Exc.Add('Immutable Versioning')
        $Exc.Add('Modified Time')

        $ExcelVar = $SmaResources.StorageContainers

        $ExcelVar |
        ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc |
        Export-Excel -Path $File -WorksheetName 'Storage Containers' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style

        <######## Insert Column comments and documentations here following this model #########>

        $excel = Open-ExcelPackage -Path $File -KillExcel

        Close-ExcelPackage $excel
    }
}

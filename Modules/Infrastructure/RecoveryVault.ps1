<#
.Synopsis
Inventory for Azure Recovery Services Vault

.DESCRIPTION
This script consolidates information for all microsoft.recoveryservices/vaults and  resource provider in $Resources variable. 
Excel Sheet Name: RecoveryVault

.Link
https://github.com/azureinventory/ARI/Modules/Infrastructure/RecoveryVault.ps1

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

        $RECOVAULT = $Resources | Where-Object {$_.TYPE -eq 'microsoft.recoveryservices/vaults'}

    <######### Insert the resource Process here ########>

    if($RECOVAULT)
        {
            $tmp = @()

            foreach ($1 in $RECOVAULT) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) {
                        $obj = @{
                            'Subscription'                             = $sub1.name;
                            'Resource Group'                           = $1.RESOURCEGROUP;
                            'Name'                                     = $1.NAME;
                            'Location'                                 = $1.LOCATION;
                            'SKU Name'                                 = $1.sku.name;
                            'SKU Tier'                                 = $1.sku.tier;
                            'Private Endpoint State for Backup'        = $data.privateEndpointStateForBackup;
                            'Private Endpoint State for Site Recovery' = $data.privateEndpointStateForSiteRecovery;
                            'Resource U'                               = $ResUCount;
                            'Tag Name'                                 = [string]$Tag.Name;
                            'Tag Value'                                = [string]$Tag.Value
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

    if($SmaResources.RecoveryVault)
    {

        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('SKU Name')
        $Exc.Add('SKU Tier')
        $Exc.Add('Private Endpoint State for Backup')
        $Exc.Add('Private Endpoint State for Site Recovery')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.RecoveryVault

        $ExcelVar | 
        ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        Export-Excel -Path $File -WorksheetName 'Recovery Vaults' -AutoSize -MaxAutoSizeRows 100 -TableName 'AzureRecVault' -TableStyle $tableStyle -Style $Style

        <######## Insert Column comments and documentations here following this model #########>


        #$excel = Open-ExcelPackage -Path $File -KillExcel


        #Close-ExcelPackage $excel 

    }
}
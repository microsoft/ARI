<#
.Synopsis
Inventory for Azure Recovery Services Vault

.DESCRIPTION
This script consolidates information for all microsoft.recoveryservices/vaults and  resource provider in $Resources variable. 
Excel Sheet Name: RecoveryVault

.Link
https://github.com/microsoft/ARI/Modules/Public/InventoryModules/Management/RecoveryVault.ps1

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

        $RECOVAULT = $Resources | Where-Object {$_.TYPE -eq 'microsoft.recoveryservices/vaults'}

    <######### Insert the resource Process here ########>

    if($RECOVAULT)
        {
            $tmp = foreach ($1 in $RECOVAULT) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
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
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) {
                        $obj = @{
                            'ID'                                       = $1.id;
                            'Subscription'                             = $sub1.Name;
                            'Resource Group'                           = $1.RESOURCEGROUP;
                            'Name'                                     = $1.NAME;
                            'Location'                                 = $1.LOCATION;
                            'Retiring Feature'                         = $RetiringFeature;
                            'Retiring Date'                            = $RetiringDate;
                            'SKU Name'                                 = $1.sku.name;
                            'SKU Tier'                                 = $1.sku.tier;
                            'Private Endpoint State for Backup'        = $data.privateEndpointStateForBackup;
                            'Private Endpoint State for Site Recovery' = $data.privateEndpointStateForSiteRecovery;
                            'Resource U'                               = $ResUCount;
                            'Tag Name'                                 = [string]$Tag.Name;
                            'Tag Value'                                = [string]$Tag.Value
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

        $TableName = ('RecoveryVaultTable_'+($SmaResources.'Resource U').count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

        $condtxt = @()
        #Retirement
        $condtxt += New-ConditionalText -Range E2:E100 -ConditionalType ContainsText

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('Retiring Feature')
        $Exc.Add('Retiring Date')
        $Exc.Add('SKU Name')
        $Exc.Add('SKU Tier')
        $Exc.Add('Private Endpoint State for Backup')
        $Exc.Add('Private Endpoint State for Site Recovery')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        [PSCustomObject]$SmaResources | 
        ForEach-Object { $_ } | Select-Object $Exc | 
        Export-Excel -Path $File -WorksheetName 'Recovery Vaults' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -ConditionalText $condtxt -TableStyle $tableStyle -Style $Style

    }
}
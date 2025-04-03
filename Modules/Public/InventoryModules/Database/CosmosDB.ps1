<#
.Synopsis
Inventory for Azure Cosmos DB

.DESCRIPTION
This script consolidates information for all microsoft.documentdb/databaseaccounts resource provider in $Resources variable. 
Excel Sheet Name: CosmosDB

.Link
https://github.com/microsoft/ARI/Modules/Public/InventoryModules/Database/CosmosDB.ps1

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

    $COSMOS = $Resources | Where-Object { $_.TYPE -eq 'microsoft.documentdb/databaseaccounts' }

    if($COSMOS)
        {
            $tmp = foreach ($1 in $COSMOS) {                
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
                $VNETs = @()
                foreach ($VNET in $data.virtualNetworkRules.id)
                    {
                        $VNETs += $VNET.split('/')[8]
                    }
                $VNETs = $VNETs | Select-Object -Unique
                if(!$data.privateEndpointConnections){$PVTENDP = $false}else{$PVTENDP = $data.privateEndpointConnections.Id.split("/")[8]}
                $GeoReplicate = if($data.failoverPolicies.count -gt 1){'Enabled'}else{'Disabled'}
                $Mongo = if([string]::IsNullOrEmpty($data.mongoEndpoint)){$data.documentEndpoint}else{$data.mongoEndpoint}
                $FreeTier = if($data.enableFreeTier -eq $true){'Opted In'}else{'Opted Out'}
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
                            'Enabled API Types'         = $data.EnabledApiTypes;
                            'Backup Policy'             = $data.backupPolicy.type;
                            'Backup Storage Redundancy' = $data.backupPolicy.periodicModeProperties.backupStorageRedundancy;
                            'Account Offer Type'        = $data.databaseAccountOfferType;
                            'Replicate Data Globally'   = $GeoReplicate;
                            'VNET Filtering'            = $data.isVirtualNetworkFilterEnabled;
                            'Virtual Networks'          = [string]$VNETs;
                            'Free Tier Discount'        = $FreeTier;
                            'Public Access'             = $data.publicNetworkAccess;
                            'Default Consistency'       = $data.consistencyPolicy.defaultConsistencyLevel;
                            'Private Endpoint'          = $PVTENDP;
                            'Read Locations'            = [string]$data.readLocations.locationName;
                            'Write Locations'           = [string]$data.writeLocations.locationName;
                            'CORS'                      = [string]$data.cors;
                            'URI'                       = $Mongo;
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

        $TableName = ('CosmosTable_'+($SmaResources.'Resource U').count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

        $condtxt = @()
        $condtxt += New-ConditionalText FALSE -Range L:L
        $condtxt += New-ConditionalText Enabled -Range O:O
        $condtxt += New-ConditionalText Disabled -Range K:K
        $condtxt += New-ConditionalText Local -Range I:I
        #Retirement
        $condtxt += New-ConditionalText -Range E2:E100 -ConditionalType ContainsText

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('Retiring Feature')
        $Exc.Add('Retiring Date')
        $Exc.Add('Enabled API Types')
        $Exc.Add('Backup Policy')
        $Exc.Add('Backup Storage Redundancy')
        $Exc.Add('Account Offer Type')
        $Exc.Add('Replicate Data Globally')
        $Exc.Add('VNET Filtering')
        $Exc.Add('Virtual Networks')
        $Exc.Add('Free Tier Discount')
        $Exc.Add('Public Access')
        $Exc.Add('Default Consistency')
        $Exc.Add('Private Endpoint')
        $Exc.Add('Read Locations')
        $Exc.Add('Write Locations')
        $Exc.Add('CORS')
        $Exc.Add('URI')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        [PSCustomObject]$SmaResources | 
        ForEach-Object { $_ } | Select-Object $Exc | 
        Export-Excel -Path $File -WorksheetName 'Cosmos DB' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style

    }
}
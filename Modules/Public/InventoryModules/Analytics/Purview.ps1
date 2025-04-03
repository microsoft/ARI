<#
.Synopsis
Inventory for Azure Purview

.DESCRIPTION
This script consolidates information for all resource provider in $Resources variable. 
Excel Sheet Name: Purview

.Link
https://github.com/microsoft/ARI/Modules/Public/InventoryModules/Analytics/Purview.ps1

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

    $Purview = $Resources | Where-Object { $_.TYPE -eq 'microsoft.purview/accounts' }

    if($Purview)
        {
            $tmp = foreach ($1 in $Purview) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $CloudConnectors = $data.cloudConnectors.count
                $pvted = $data.privateEndpointConnections.count
                $timecreated = $data.createdAt
                $timecreated = [datetime]$timecreated
                $timecreated = $timecreated.ToString("yyyy-MM-dd HH:mm")
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
                $StorageAcc = if(![string]::IsNullOrEmpty($data.managedResources.storageAccount)){$data.managedResources.storageAccount.split('/')[8]}else{$null}
                $eventHubNamespace = if(![string]::IsNullOrEmpty($data.managedResources.eventHubNamespace)){($data.managedResources.eventHubNamespace.split('/')[8])}else{$null}
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) {
                        $obj = @{
                            'ID'                                = $1.id;
                            'Subscription'                      = $sub1.Name;
                            'Resource Group'                    = $1.RESOURCEGROUP;
                            'Name'                              = $1.NAME;
                            'Location'                          = $1.LOCATION;
                            'SKU'                               = $data.sku.name;
                            'Capacity'                          = $data.sku.capacity;
                            'Retiring Feature'                  = $RetiringFeature;
                            'Retiring Date'                     = $RetiringDate;
                            'Friendly Name'                     = $data.friendlyName;
                            'Cloud Connectors'                  = [string]$CloudConnectors;
                            'Private Endpoints'                 = [string]$pvted;
                            'Managed Resource Group'            = [string]$data.managedResourceGroupName;
                            'Managed Storage Account'           = [string]$StorageAcc;
                            'Managed Event Hub'                 = [string]$eventHubNamespace;
                            'Public Network Access'             = $data.publicNetworkAccess;
                            'Created By'                        = $data.createdBy;      
                            'Created Time'                      = $timecreated;
                            'Resource U'                       = $ResUCount;
                            'Tag Name'                          = [string]$Tag.Name;
                            'Tag Value'                         = [string]$Tag.Value
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

        $TableName = ('PurviewATable_'+($SmaResources.'Resource U').count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

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
        $Exc.Add('Capacity')
        $Exc.Add('Friendly Name')
        $Exc.Add('Cloud Connectors')
        $Exc.Add('Private Endpoints')
        $Exc.Add('Managed Resource Group')
        $Exc.Add('Managed Storage Account')
        $Exc.Add('Managed Event Hub')
        $Exc.Add('Public Network Access')
        $Exc.Add('Created By')
        $Exc.Add('Created Time')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value')
            }

        [PSCustomObject]$SmaResources | 
        ForEach-Object { $_ } | Select-Object $Exc | 
        Export-Excel -Path $File -WorksheetName 'Purview' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -ConditionalText $condtxt -TableStyle $tableStyle -Style $Style

    }
}
<#
.Synopsis
Inventory for Azure Databricks

.DESCRIPTION
This script consolidates information for all microsoft.databricks/workspaces resource provider in $Resources variable. 
Excel Sheet Name: Databricks

.Link
https://github.com/microsoft/ARI/Modules/Public/InventoryModules/Analytics/Databricks.ps1

.COMPONENT
    This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.0
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Retirements, $Task, $File, $SmaResources, $TableStyle, $Unsupported)

If ($Task -eq 'Processing') {

    $DataBricks = $Resources | Where-Object { $_.TYPE -eq 'microsoft.databricks/workspaces' }

    if($DataBricks)
        {
            $tmp = foreach ($1 in $DataBricks) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $sku = $1.SKU
                $RetDate = ''
                $RetFeature = '' 
                $timecreated = $data.createdDateTime
                $timecreated = [datetime]$timecreated
                $timecreated = $timecreated.ToString("yyyy-MM-dd HH:mm")
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
                $PIP = if($data.parameters.enableNoPublicIp.value -eq 'False'){$true}else{$false}
                $VNET = $data.parameters.customVirtualNetworkId.value.split('/')[8]
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) {
                        $obj = @{
                            'ID'                        = $1.id;
                            'Subscription'              = $sub1.Name;
                            'Resource Group'            = $1.RESOURCEGROUP;
                            'Name'                      = $1.NAME;
                            'Location'                  = $1.LOCATION;
                            'Pricing Tier'              = $sku.name;
                            'Retiring Feature'          = $RetiringFeature;
                            'Retiring Date'             = $RetiringDate;
                            'Managed Resource Group'    = $data.managedResourceGroupId.split('/')[4];
                            'Storage Account'           = $data.parameters.storageAccountName.value;
                            'Storage Account SKU'       = $data.parameters.storageAccountSkuName.value;
                            'Infrastructure Encryption' = $data.parameters.requireInfrastructureEncryption.value;
                            'Prepare Encryption'        = $data.parameters.prepareEncryption.value;
                            'Enable Public IP'          = $PIP;
                            'Custom Virtual Network'    = $VNET;
                            'Custom Private Subnet'     = $data.parameters.customPrivateSubnetName.value;
                            'Custom Public Subnet'      = $data.parameters.customPublicSubnetName.value;
                            'URL'                       = $data.workspaceUrl;
                            'Created Time'              = $timecreated;
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

        $TableName = ('DBricksTable_'+($SmaResources.'Resource U').count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

        $condtxt = @()
        #Retirement
        $condtxt += New-ConditionalText -Range E2:E100 -ConditionalType ContainsText
        $condtxt += New-ConditionalText FALSE -Range K:K
        $condtxt += New-ConditionalText FALSE -Range L:L



        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('Retiring Feature')
        $Exc.Add('Retiring Date')
        $Exc.Add('Pricing Tier')
        $Exc.Add('Managed Resource Group')
        $Exc.Add('Storage Account')
        $Exc.Add('Storage Account SKU')
        $Exc.Add('Infrastructure Encryption')
        $Exc.Add('Prepare Encryption')
        $Exc.Add('Enable Public IP')
        $Exc.Add('Custom Virtual Network')
        $Exc.Add('Custom Private Subnet')
        $Exc.Add('Custom Public Subnet')
        $Exc.Add('URL')
        $Exc.Add('Created Time')  
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        [PSCustomObject]$SmaResources | 
        ForEach-Object { $_ } | Select-Object $Exc | 
        Export-Excel -Path $File -WorksheetName 'Databricks' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style

    }
}
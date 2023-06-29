<#
.Synopsis
Inventory for Azure Machine Learning

.DESCRIPTION
This script consolidates information for all 'microsoft.machinelearningservices/workspaces' resource provider in $Resources variable. 
Excel Sheet Name: Machine Learning

.Link
https://github.com/microsoft/ARI/Modules/Analytics/MachineLearning.ps1

.COMPONENT
    This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.0.1
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Task , $File, $SmaResources, $TableStyle, $Unsupported)

If ($Task -eq 'Processing') {

    $AzureML = $Resources | Where-Object { $_.TYPE -eq 'microsoft.machinelearningservices/workspaces' }

    if($AzureML)
        {
            $tmp = @()

            foreach ($1 in $AzureML) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $sku = $1.SKU
                $RetDate = ''
                $RetFeature = '' 
                $timecreated = $data.creationTime
                $timecreated = [datetime]$timecreated
                $timecreated = $timecreated.ToString("yyyy-MM-dd HH:mm")
                $StorageAcc = $data.storageAccount.split('/')[8]
                $KeyVault = $data.keyVault.split('/')[8]
                $Insight = $data.applicationInsights.split('/')[8]
                $containerRegistry = $data.containerRegistry.split('/')[8]
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) {
                        $obj = @{
                            'ID'                        = $1.id;
                            'Subscription'              = $sub1.Name;
                            'Resource Group'            = $1.RESOURCEGROUP;
                            'Name'                      = $1.NAME;
                            'Location'                  = $1.LOCATION;
                            'SKU'                       = $sku.name;
                            'Friendly Name'             = $data.friendlyName;
                            'Description'               = $data.description;
                            'HBI Workspace'             = $data.hbiWorkspace;
                            'Container Registry'        = $containerRegistry;
                            'Retirement Date'           = [string]$RetDate;
                            'Retirement Feature'        = $RetFeature;
                            'Storage HNS Enabled'       = $data.storageHnsEnabled;
                            'Private Link Count'        = $data.privateLinkCount;
                            'Public Access Behind Vnet' = $data.allowPublicAccessWhenBehindVnet;
                            'Discovery Url'             = $data.discoveryUrl;
                            'ML Flow Tracking Uri'      = $data.mlFlowTrackingUri;
                            'Storage Account'           = $StorageAcc;
                            'Key Vault'                 = $KeyVault;
                            'Created Time'              = $timecreated;
                            'Application Insight'       = $Insight;
                            'Resource U'                = $ResUCount;
                            'Tag Name'                  = [string]$Tag.Name;
                            'Tag Value'                 = [string]$Tag.Value
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

    if ($SmaResources.AzureML) {

        $TableName = ('AzureMLTable_'+($SmaResources.AzureML.id | Select-Object -Unique).count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

        $condtxt = @()
        $condtxt += New-ConditionalText - -Range J:J -ConditionalType ContainsText


        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('SKU')
        $Exc.Add('Friendly Name')
        $Exc.Add('Description')
        $Exc.Add('HBI Workspace')
        $Exc.Add('Container Registry')
        $Exc.Add('Retirement Date')
        $Exc.Add('Retirement Feature')
        $Exc.Add('Storage HNS Enabled')
        $Exc.Add('Private Link Count')
        $Exc.Add('Public Access Behind Vnet')
        $Exc.Add('Discovery Url')
        $Exc.Add('ML Flow Tracking Uri')
        $Exc.Add('Storage Account')
        $Exc.Add('Key Vault')
        $Exc.Add('Application Insight')
        $Exc.Add('Created Time')  
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.AzureML

        $ExcelVar | 
        ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        Export-Excel -Path $File -WorksheetName 'Machine Learning' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style

    }
    <######## Insert Column comments and documentations here following this model #########>
}
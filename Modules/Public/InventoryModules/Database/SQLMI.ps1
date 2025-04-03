<#
.Synopsis
Inventory for Azure SQL Server

.DESCRIPTION
This script consolidates information for all microsoft.sql/servers resource provider in $Resources variable. 
Excel Sheet Name: SQL MI

.Link
https://github.com/microsoft/ARI/Modules/Public/InventoryModules/Database/SQLMI.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.0
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 
#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Retirements, $Task ,$File, $SmaResources, $TableStyle, $Unsupported)

if ($Task -eq 'Processing') {

    $SQLSERVERMI = $Resources | Where-Object { $_.TYPE -eq 'microsoft.sql/managedInstances' }

    if($SQLSERVERMI)
        {
            $tmp = foreach ($1 in $SQLSERVERMI) {
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
                $Tags = if(!!($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}

                $pvteps = if(!($1.privateEndpointConnections)) {[pscustomobject]@{id = 'NONE'}} else {$1.privateEndpointConnections | Select-Object @{Name="id";Expression={$_.id.split("/")[8]}}}

                foreach ($pvtep in $pvteps) {
                    foreach ($Tag in $Tags) {
                        $obj = @{
                            'ID'                    = $1.id;
                            'Subscription'          = $sub1.Name;
                            'Resource Group'        = $1.RESOURCEGROUP;
                            'Name'                  = $1.NAME;
                            'Location'              = $1.LOCATION;
                            'Retiring Feature'      = $RetiringFeature;
                            'Retiring Date'         = $RetiringDate;
                            'SkuName'               = $1.sku.Name;
                            'SkuCapacity'           = $1.sku.capacity;
                            'SkuTier'               = $1.sku.tier;
                            'Admin Login'           = $data.adminitrators.login;
                            'AzureADOnlyAuthentication'           = $data.adminitrators.azureADOnlyAuthentication;
                            'Private Endpoint'      = $pvtep.id;
                            'FQDN'                  = $data.fullyQualifiedDomainName;
                            'Public Network Access' = $data.publicDataEndpointEnabled;
                            'licenseType'           = $data.licenseType;
                            'managedInstanceCreateMode'               = $data.managedInstanceCreateMode;
                            'Resource U'            = $ResUCount;
                            'Zone Redundant'        = $data.zoneRedundant;
                            'Tag Name'              = [string]$Tag.Name;
                            'Tag Value'             = [string]$Tag.Value
                        }
                        $obj
                        if ($ResUCount -eq 1) { $ResUCount = 0 } 
                    }     
                }          
            }
            $tmp
        }
}
else {
    if ($SmaResources) {

        $TableName = ('SQLMITable_'+($SmaResources.'Resource U').count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

        $condtxt = @()
        $condtxt += New-ConditionalText FALSE -Range L:L
        $condtxt += New-ConditionalText FAUX -Range L:L
        $condtxt += New-ConditionalText NONE -Range L:L
        $condtxt += New-ConditionalText Enabled -Range N:N
        $condtxt += New-ConditionalText VRAI -Range N:N
        #Retirement
        $condtxt += New-ConditionalText -Range E2:E100 -ConditionalType ContainsText

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('Retiring Feature')
        $Exc.Add('Retiring Date')
        $Exc.Add('SkuName')
        $Exc.Add('SkuCapacity')
        $Exc.Add('SkuTier')
        $Exc.Add('Admin Login')
        $Exc.Add('ActiveDirectoryOnlyAuthentication')
        $Exc.Add('Private Endpoint')
        $Exc.Add('FQDN')
        $Exc.Add('Public Network Access')
        $Exc.Add('licenseType')
        $Exc.Add('managedInstanceCreateMode')
        $Exc.Add('Zone Redundant')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        [PSCustomObject]$SmaResources | 
        ForEach-Object { $_ } | Select-Object $Exc | 
        Export-Excel -Path $File -WorksheetName 'SQL MI' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style

    }
}
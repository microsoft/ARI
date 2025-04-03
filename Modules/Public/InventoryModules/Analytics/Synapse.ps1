<#
.Synopsis
Inventory for Azure Synapse

.DESCRIPTION
This script consolidates information for all 'microsoft.synapse/workspaces' resource provider in $Resources variable. 
Excel Sheet Name: Synapse

.Link
https://github.com/microsoft/ARI/Modules/Public/InventoryModules/Analytics/Synapse.ps1

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

    <######### Insert the resource extraction here ########>

    $Synapse = $Resources | Where-Object { $_.TYPE -eq 'microsoft.synapse/workspaces' }

    if($Synapse)
        {
            $tmp = foreach ($1 in $Synapse) {
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
                $pvt = $data.privateEndpointConnections.count
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) {
                        $obj = @{
                            'ID'                                = $1.id;
                            'Subscription'                      = $sub1.Name;
                            'Resource Group'                    = $1.RESOURCEGROUP;
                            'Name'                              = $1.NAME;
                            'Location'                          = $1.LOCATION;
                            'Retiring Feature'                  = $RetiringFeature;
                            'Retiring Date'                     = $RetiringDate;
                            'Public Network Access'             = $data.publicNetworkAccess;
                            'Private Endpoints'                 = [string]$pvt;
                            'Double Encryption Enabled'         = [string]$data.encryption.doubleEncryptionEnabled;
                            'Trusted Service Bypass Enabled'    = $data.trustedServiceBypassEnabled;
                            'SQL Administrator Login'           = $data.sqlAdministratorLogin;
                            'Scope Enabled'                     = [string]$data.extraProperties.IsScopeEnabled;
                            'Workspace Type'                    = [string]$data.extraProperties.WorkspaceType;
                            'Prevent Data Exfiltration'         = [string]$data.managedVirtualNetworkSettings.preventDataExfiltration;
                            'Managed Virtual Network'           = $data.managedVirtualNetwork;                            
                            'Managed ResourceGroup'             = $data.managedResourceGroupName;
                            'Resource U'                             = $ResUCount
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
    <######## $SmaResources.Synapse ##########>

    if ($SmaResources) {

        $TableName = ('SynapseTable_'+($SmaResources.'Resource U').count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0
        
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
        $Exc.Add('Public Network Access')
        $Exc.Add('Private Endpoints')
        $Exc.Add('Double Encryption Enabled')
        $Exc.Add('Trusted Service Bypass Enabled')
        $Exc.Add('SQL Administrator Login')
        $Exc.Add('Scope Enabled')
        $Exc.Add('Workspace Type')
        $Exc.Add('Prevent Data Exfiltration')
        $Exc.Add('Managed Virtual Network')
        $Exc.Add('Managed ResourceGroup')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        [PSCustomObject]$SmaResources | 
        ForEach-Object { $_ } | Select-Object $Exc | 
        Export-Excel -Path $File -WorksheetName 'Synapse' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -Style $Style

    }
}
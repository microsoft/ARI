<#
.Synopsis
Inventory for Azure Backup Items

.DESCRIPTION
This script consolidates information for all microsoft.recoveryservices/vaults/backuppolicies resource provider in $Resources variable. 
Excel Sheet Name: Backup

.Link
https://github.com/microsoft/ARI/Modules/Public/InventoryModules/Management/Backup.ps1

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

        $ProtectedItems = $Resources | Where-Object {$_.TYPE -eq 'microsoft.recoveryservices/vaults/backupfabrics/protectioncontainers/protecteditems'}
        $BackupPolicies = $Resources | Where-Object {$_.TYPE -eq 'microsoft.recoveryservices/vaults/backuppolicies'}

    <######### Insert the resource Process here ########>

    if($BackupPolicies)
        {
            $tmp = foreach ($1 in $BackupPolicies) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                $ProtectedObjs = $ProtectedItems | Where-Object {$_.properties.policyid -eq $1.id}
                $ProtectedObjs = if(![string]::IsNullOrEmpty($ProtectedObjs)){$ProtectedObjs}else{'0'}

                $Compression = if(![string]::IsNullOrEmpty($data.settings.iscompression)){$data.settings.iscompression}else{$false}
                $SQLCompression = if(![string]::IsNullOrEmpty($data.settings.issqlcompression)){$data.settings.issqlcompression}else{$false}

                $PolicyType = if ($data.subprotectionpolicy.policytype.count -gt 1) { $data.subprotectionpolicy.policytype | ForEach-Object { $_ + ' ,' } }else { $data.subprotectionpolicy.policytype }
                $PolicyType = [string]$PolicyType
                $PolicyType = if ($PolicyType -like '* ,*') { $PolicyType -replace ".$" }else { $PolicyType }

                foreach ($ProtectedItem in $ProtectedObjs)
                    {
                        $VaultResource = if(![string]::IsNullOrEmpty($ProtectedItem.properties.vaultid)){$ProtectedItem.properties.vaultid.split('/')[8]}else{''}
                        if(![string]::IsNullOrEmpty($ProtectedItem.properties.lastbackuptime))
                            {
                                $LastBackup = [string](get-date($ProtectedItem.properties.lastbackuptime))
                                $Currenttime = get-date
                                $OldTime = get-date($ProtectedItem.properties.lastbackuptime)
                                $DaysSinceBKP = New-TimeSpan -Start $OldTime -End $Currenttime
                            }
                        else
                            {
                                $LastBackup = ''
                                $DaysSinceBKP = ''
                            }
                        $LastRecovery = if(![string]::IsNullOrEmpty($ProtectedItem.properties.lastrecoverypoint)){[string](get-date($ProtectedItem.properties.lastrecoverypoint))}else{''}
                        $LastRecoverySecondary = if(![string]::IsNullOrEmpty($ProtectedItem.properties.latestrecoverypointinsecondaryregion)){[string](get-date($ProtectedItem.properties.latestrecoverypointinsecondaryregion))}

                        foreach ($Tag in $Tags) {
                            $obj = @{
                                'ID'                                        = $1.id;
                                'Subscription'                              = $sub1.Name;
                                'Resource Group'                            = $1.RESOURCEGROUP;
                                'Backup Policy Name'                        = $1.NAME;
                                'Location'                                  = $1.LOCATION;
                                'Datasource Type'                           = $data.workloadtype;
                                'Protected Items Count'                     = $data.protecteditemscount;
                                'Backup Compression'                        = $Compression;
                                'SQL Compression'                           = $SQLCompression;
                                'Policy Type'                               = $PolicyType;
                                'Protected Item Type'                       = $ProtectedItem.properties.backupmanagementtype;
                                'Protected Item'                            = $ProtectedItem.properties.friendlyname;
                                'Vault'                                     = $VaultResource;
                                'Retention Period'                          = [string]$ProtectedItem.properties.configuredmaximumretention;
                                'Backup Frequency'                          = [string]$ProtectedItem.properties.configuredrpgenerationfrequency;
                                'Health Status'                             = $ProtectedItem.properties.healthstatus;
                                'Protection Status'                         = $ProtectedItem.properties.protectionstatus;
                                'Archive Enabled'                           = $ProtectedItem.properties.isarchiveenabled;
                                'Last Backup Status'                        = $ProtectedItem.properties.lastbackupstatus;
                                'Last Backup Time'                          = $LastBackup;
                                'Days Since Last Backup'                    = $DaysSinceBKP.Days;
                                'Last Recovery Point'                       = $LastRecovery;
                                'Latest Recovery Point (Secondary Region)'  = $LastRecoverySecondary;
                                'Protection State'                          = $ProtectedItem.properties.protectionstate;
                                'Protection State (Secondary Region)'       = $ProtectedItem.properties.protectionstateinsecondaryregion;
                                'Soft Delete Retention Period'              = $ProtectedItem.properties.softdeleteretentionperiod;
                                'Resource U'                               = $ResUCount;
                                'Tag Name'                                  = [string]$Tag.Name;
                                'Tag Value'                                 = [string]$Tag.Value
                            }
                            $obj
                            if ($ResUCount -eq 1) { $ResUCount = 0 }
                        }
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

        $TableName = ('BackupTable_'+($SmaResources.'Resource U').count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

        $condtxt = @()
        $condtxt += New-ConditionalText 0 -Range F:F
        $condtxt += New-ConditionalText failed -Range O:O
        $condtxt += New-ConditionalText incomplete -Range R:R
        $condtxt += New-ConditionalText Unhealthy -Range P:P
        $condtxt += New-ConditionalText notprotected -Range W:W
        $condtxt += New-ConditionalText 0 -Range Y:Y
        $condtxt += New-ConditionalText -ConditionalType GreaterThan 7 -Range T:T

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Backup Policy Name')
        $Exc.Add('Location')
        $Exc.Add('Datasource Type')
        $Exc.Add('Protected Items Count')
        $Exc.Add('Backup Compression')
        $Exc.Add('SQL Compression')
        $Exc.Add('Policy Type')
        $Exc.Add('Protected Item Type')
        $Exc.Add('Protected Item')
        $Exc.Add('Vault')
        $Exc.Add('Retention Period')
        $Exc.Add('Backup Frequency')
        $Exc.Add('Health Status')
        $Exc.Add('Protection Status')
        $Exc.Add('Archive Enabled')
        $Exc.Add('Last Backup Status')
        $Exc.Add('Last Backup Time')
        $Exc.Add('Days Since Last Backup')
        $Exc.Add('Last Recovery Point')
        $Exc.Add('Latest Recovery Point (Secondary Region)')
        $Exc.Add('Protection State')
        $Exc.Add('Protection State (Secondary Region)')
        $Exc.Add('Soft Delete Retention Period')
        if($InTag)
        {
            $Exc.Add('Tag Name')
            $Exc.Add('Tag Value') 
        }

        [PSCustomObject]$SmaResources | 
        ForEach-Object { $_ } | Select-Object $Exc | 
        Export-Excel -Path $File -WorksheetName 'Backup' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style

    }
}
<#
.Synopsis
Inventory for Azure Database for MySQL

.DESCRIPTION
This script consolidates information for all microsoft.dbformysql/servers resource provider in $Resources variable. 
Excel Sheet Name: MySQL

.Link
https://github.com/microsoft/ARI/Modules/Data/MySQL.ps1

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

    $MySQL = $Resources | Where-Object { $_.TYPE -eq 'microsoft.dbformysql/servers' }

    if($MySQL)
        {
            $tmp = @()

            foreach ($1 in $MySQL) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $RetDate = ($Unsupported | Where-Object {$_.Id -eq 7}).RetirementDate
                $RetFeature = ($Unsupported | Where-Object {$_.Id -eq 7}).RetiringFeature
                if(!$data.privateEndpointConnections){$PVTENDP = $false}else{$PVTENDP = $data.privateEndpointConnections.Id.split("/")[8]}
                $sku = $1.SKU
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) {
                        $obj = @{
                            'ID'                        = $1.id;
                            'Subscription'              = $sub1.Name;
                            'Resource Group'            = $1.RESOURCEGROUP;
                            'Name'                      = $1.NAME;
                            'Location'                  = $1.LOCATION;
                            'Retirement Date'           = [string]$RetDate;
                            'Retirement Feature'        = $RetFeature;
                            'SKU'                       = $sku.name;
                            'SKU Family'                = $sku.family;
                            'Tier'                      = $sku.tier;
                            'Capacity'                  = $sku.capacity;
                            'MySQL Version'             = "=$($data.version)";
                            'Private Endpoint'          = $PVTENDP;
                            'Backup Retention Days'     = $data.storageProfile.backupRetentionDays;
                            'Geo-Redundant Backup'      = $data.storageProfile.geoRedundantBackup;
                            'Auto Grow'                 = $data.storageProfile.storageAutogrow;
                            'Storage MB'                = $data.storageProfile.storageMB;
                            'Public Network Access'     = $data.publicNetworkAccess;
                            'Admin Login'               = $data.administratorLogin;
                            'Infrastructure Encryption' = $data.InfrastructureEncryption;
                            'Minimum TLS Version'       = "$($data.minimalTlsVersion -Replace '_', '.' -Replace 'tls', 'TLS ')";
                            'State'                     = $data.userVisibleState;
                            'Replica Capacity'          = $data.replicaCapacity;
                            'Replication Role'          = $data.replicationRole;
                            'BYOK Enforcement'          = $data.byokEnforcement;
                            'SSL Enforcement'           = $data.sslEnforcement;
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

    if ($SmaResources.MySQL) {

        $TableName = ('MySQLTable_'+($SmaResources.MySQL.id | Select-Object -Unique).count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0.0

        $condtxt = @()
        $condtxt += New-ConditionalText FALSE -Range L:L
        $condtxt += New-ConditionalText FALSO -Range L:L
        $condtxt += New-ConditionalText Disabled -Range N:N
        $condtxt += New-ConditionalText Enabled -Range Q:Q
        $condtxt += New-ConditionalText TLSEnforcementDisabled -Range T:T
        $condtxt += New-ConditionalText Disabled -Range Y:Y
        $condtxt += New-ConditionalText - -Range H:H -ConditionalType ContainsText

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('SKU')
        $Exc.Add('SKU Family')
        $Exc.Add('Tier')
        $Exc.Add('Retirement Date')
        $Exc.Add('Retirement Feature')  
        $Exc.Add('Capacity')
        $Exc.Add('MySQL Version')
        $Exc.Add('Private Endpoint')
        $Exc.Add('Backup Retention Days')
        $Exc.Add('Geo-Redundant Backup')
        $Exc.Add('Auto Grow')
        $Exc.Add('Storage MB')
        $Exc.Add('Public Network Access')
        $Exc.Add('Admin Login')
        $Exc.Add('Infrastructure Encryption')
        $Exc.Add('Minimum TLS Version')
        $Exc.Add('State')
        $Exc.Add('Replica Capacity')
        $Exc.Add('Replication Role')
        $Exc.Add('BYOK Enforcement')
        $Exc.Add('SSL Enforcement')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.MySQL

        $ExcelVar | 
        ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        Export-Excel -Path $File -WorksheetName 'MySQL' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style

        $excel = Open-ExcelPackage -Path $File -KillExcel
    
        $null = $excel.'MySQL'.Cells["H1"].AddComment("It's important to be aware of upcoming Azure services and feature retirements to understand their impact on your workloads and plan migration.", "Azure Resource Inventory")
        $excel.'MySQL'.Cells["H1"].Hyperlink = 'https://learn.microsoft.com/en-us/azure/advisor/advisor-how-to-plan-migration-workloads-service-retirement'

        Close-ExcelPackage $excel

    }
    <######## Insert Column comments and documentations here following this model #########>
}

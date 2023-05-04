<#
.Synopsis
Inventory for Azure NetApp

.DESCRIPTION
This script consolidates information for all  resource provider in $Resources variable. 
Excel Sheet Name: NetApp

.Link
https://github.com/microsoft/ARI/Modules/Storage/NetApp.ps1

.COMPONENT
    This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 2.0.0
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Task , $File, $SmaResources, $TableStyle)

If ($Task -eq 'Processing') {

    <######### Insert the resource extraction here ########>

    $NetApp = $Resources | Where-Object { $_.TYPE -eq 'Microsoft.NetApp/netAppAccounts/capacityPools/volumes' }

    if($NetApp)
        {
            $tmp = @()
            foreach ($1 in $NetApp) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $VNET = $data.subnetId.split('/')[8]
                $Subnet = $data.subnetId.split('/')[10]
                $ExportPolicy = $data.exportPolicy.rules.count
                $NetApp = $1.Name.split('/')[0]
                $CapacityPool = $1.Name.split('/')[1]
                $Volume = $1.Name.split('/')[2]
                $Quota = ((($data.usageThreshold/1024)/1024)/1024)/1024
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) {
                        $obj = @{
                            'ID'                                = $1.id;
                            'Subscription'                      = $sub1.Name;
                            'Resource Group'                    = $1.RESOURCEGROUP;
                            'Location'                          = $1.LOCATION;
                            'NetApp Account'                    = $NetApp;
                            'Capacity Pool'                     = $CapacityPool;
                            'Volume'                            = $Volume;
                            'Service Level'                     = $data.serviceLevel;
                            'Quota (TB)'                        = [string]$Quota;
                            'Protocol'                          = [string]$data.protocolTypes;
                            'Max Throughput MiB/s'              = [string]$data.throughputMibps;
                            'Export Policy Count'               = [string]$ExportPolicy;
                            'Network Features'                  = $data.networkFeatures;
                            'Security Style'                    = $data.securityStyle;
                            'SMB Encryption'                    = $data.smbEncryption;
                            'UNIX Permissions'                  = $data.unixPermissions;
                            'Cool Access'                       = $data.coolAccess;
                            'VMWare Solution'                   = $data.avsDataStore;
                            'LDAP'                              = $data.ldapEnabled;
                            'VNET Name'                         = [string]$VNET;
                            'Subnet Name'                       = [string]$Subnet;                            
                            'Tag Name'                          = [string]$Tag.Name;
                            'Tag Value'                         = [string]$Tag.Value
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
    <######## $SmaResources.NetApp ##########>

    if ($SmaResources.NetApp) {

        $TableName = ('NetAppATable_'+($SmaResources.NetApp.id | Select-Object -Unique).count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0
        
        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Location')
        $Exc.Add('NetApp Account')
        $Exc.Add('Capacity Pool')
        $Exc.Add('Volume')
        $Exc.Add('Service Level')
        $Exc.Add('Quota (TB)')
        $Exc.Add('Protocol')
        $Exc.Add('Max Throughput MiB/s')
        $Exc.Add('Export Policy Count')
        $Exc.Add('Network Features')
        $Exc.Add('Security Style')
        $Exc.Add('SMB Encryption')
        $Exc.Add('UNIX Permissions')
        $Exc.Add('Cool Access')
        $Exc.Add('VMWare Solution')
        $Exc.Add('LDAP')
        $Exc.Add('VNET Name')
        $Exc.Add('Subnet Name')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.NetApp 

        $ExcelVar | 
        ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        Export-Excel -Path $File -WorksheetName 'NetApp' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -Style $Style

    }
    <######## Insert Column comments and documentations here following this model #########>
}
<#
.Synopsis
Inventory for Azure ARC Servers

.DESCRIPTION
This script consolidates information for all microsoft.eventhub/namespaces and  resource provider in $Resources variable. 
Excel Sheet Name: EvHub

.Link
https://github.com/microsoft/ARI/Modules/Compute/ARCServers.ps1

.COMPONENT
    This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 4.0.1
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Task ,$File, $SmaResources, $TableStyle, $Unsupported)

If ($Task -eq 'Processing')
{

    <######### Insert the resource extraction here ########>

        $arcservers = $Resources | Where-Object {$_.TYPE -eq 'microsoft.hybridcompute/machines'}

    <######### Insert the resource Process here ########>

    if($arcservers)
        {
            $tmp = @()
            foreach ($1 in $arcservers) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}

                if($data.networkprofile.networkinterfaces.ipaddresses.count -gt 1)
                    {
                        $IPTemp = @()
                        $SubnetTemp = @()
                        foreach ($IPaddresses in $data.networkprofile.networkinterfaces.ipaddresses)
                            {
                                $IPTemp += $IPaddresses.address
                                $SubnetTemp += $IPaddresses.subnet.addressprefix
                            }
                        $IP = if ($IPTemp.count -gt 1) { $IPTemp | ForEach-Object { $_ + ' ,' } }else { $IPTemp }
                        $IP = [string]$IP
                        $IP = if ($IP -like '* ,*') { $IP -replace ".$" }else { $IP }

                        $Subnet = if ($SubnetTemp.count -gt 1) { $SubnetTemp | ForEach-Object { $_ + ' ,' } }else { $SubnetTemp }
                        $Subnet = [string]$Subnet
                        $Subnet = if ($Subnet -like '* ,*') { $Subnet -replace ".$" }else { $Subnet }
                    }
                else
                    {
                        $IP = $data.networkprofile.networkinterfaces.ipaddresses.address
                        $Subnet = $data.networkprofile.networkinterfaces.ipaddresses.subnet.addressprefix
                    }

                    $LastStatus = $data.laststatuschange
                    $LastStatus = [datetime]$LastStatus
                    $LastStatus = $LastStatus.ToString("yyyy-MM-dd HH:mm")

                    $InstallDate = $data.osinstalldate
                    $InstallDate = [datetime]$InstallDate
                    $InstallDate = $InstallDate.ToString("yyyy-MM-dd HH:mm")

                    foreach ($Tag in $Tags) { 
                        $obj = @{
                            'ID'                   = $1.id;
                            'Subscription'         = $sub1.name;
                            'Resource Group'       = $1.RESOURCEGROUP;
                            'Location'             = $1.LOCATION;
                            'Name'                 = $1.NAME;
                            'Display Name'         = $data.displayname;
                            'Domain'               = $data.domainname;
                            'AD FQDN'              = $data.adfqdn;
                            'DNS FQDN'             = $data.dnsfqdn;
                            'Cloud Provider'       = $data.cloudmetadata.provider;
                            'Manufacturer'         = $data.detectedproperties.manufacturer;
                            'Model'                = $data.detectedProperties.model;
                            'Processor'            = $data.detectedproperties.processornames;
                            'Processor Count'      = $data.detectedproperties.processorcount;
                            'Logical Core Count'   = $data.detectedproperties.logicalcorecount;
                            'Memory (GB)'          = $data.detectedproperties.totalphysicalmemoryingigabytes;
                            'Serial Number'        = $data.detectedproperties.serialnumber;
                            'Asset Tag'            = $data.detectedproperties.smbiosassettag;
                            'MS SQL Server'        = $data.mssqldiscovered;
                            'Agent Version'        = $data.agentversion;
                            'Status'               = $data.status;
                            'Last Status Change'   = $LastStatus;
                            'IP Address'           = $IP;
                            'Subnet'               = $Subnet;
                            'OS Name'              = $data.osName;
                            'OS Version'           = $data.osVersion;
                            'OS Install Date'      = $InstallDate;
                            'Operating System'     = $data.osSku;
                            'License Status'       = $data.licenseprofile.licensestatus;
                            'License Channel'      = $data.licenseprofile.licensechannel;
                            'License Type'         = $data.licenseprofile.esuprofile.servertype;
                            'Resource U'           = $ResUCount;
                            'Tag Name'             = [string]$Tag.Name;
                            'Tag Value'            = [string]$Tag.Value
                        }
                        $tmp += $obj
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

    if($SmaResources.ARCServers)
    {
        $TableName = ('ARCServer_'+($SmaResources.ARCServers.id | Select-Object -Unique).count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Location')
        $Exc.Add('Name')
        $Exc.Add('Display Name')
        $Exc.Add('Domain')
        $Exc.Add('AD FQDN')
        $Exc.Add('DNS FQDN')
        $Exc.Add('Cloud Provider')
        $Exc.Add('Manufacturer')
        $Exc.Add('Model')
        $Exc.Add('Processor')
        $Exc.Add('Processor Count')
        $Exc.Add('Logical Core Count')
        $Exc.Add('Memory (GB)')
        $Exc.Add('Serial Number')
        $Exc.Add('Asset Tag')
        $Exc.Add('MS SQL Server')
        $Exc.Add('Agent Version')
        $Exc.Add('Status')
        $Exc.Add('Last Status Change')
        $Exc.Add('IP Address')
        $Exc.Add('Subnet')
        $Exc.Add('OS Name')
        $Exc.Add('OS Version')
        $Exc.Add('OS Install Date')
        $Exc.Add('License Status')
        $Exc.Add('License Channel')
        $Exc.Add('License Type')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.ARCServers  

        $ExcelVar | 
        ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        Export-Excel -Path $File -WorksheetName 'ARC Servers' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -Style $Style

    }
}
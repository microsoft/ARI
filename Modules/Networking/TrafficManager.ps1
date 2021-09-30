<#
.Synopsis
Inventory for Azure Traffic Manager

.DESCRIPTION
This script consolidates information for all microsoft.network/trafficmanagerprofiles and  resource provider in $Resources variable. 
Excel Sheet Name: TrafficManager

.Link
https://github.com/azureinventory/ARI/Modules/Networking/TrafficManager.ps1

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
    $TrafficManager = $Resources | Where-Object { $_.TYPE -eq 'microsoft.network/trafficmanagerprofiles' }

    if($TrafficManager)
        {
            $tmp = @()

            foreach ($1 in $TrafficManager) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) {
                        $obj = @{
                            'Subscription'                      = $sub1.name;
                            'Resource Group'                    = $1.RESOURCEGROUP;
                            'Name'                              = $1.NAME;
                            'Status'                            = $data.profilestatus;
                            'DNS name'                          = $data.dnsconfig.fqdn;
                            'Routing method'                    = $data.trafficroutingmethod;
                            'Monitor status'                    = $data.monitorconfig.profilemonitorstatus;                            
                            'Resource U'                        = $ResUCount;
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
    <######## $SmaResources.(RESOURCE FILE NAME) ##########>

    if ($SmaResources.AzureFirewall) {

        $condtxt = New-ConditionalText inactive -Range G:G

        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0
        
        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Status')
        $Exc.Add('DNS name')
        $Exc.Add('Routing method')
        $Exc.Add('Monitor status')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.AzureFirewall 

        $ExcelVar | 
        ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        Export-Excel -Path $File -WorksheetName 'Traffic Manager' -AutoSize -MaxAutoSizeRows 100 -TableName 'TrafficManager' -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style

    }
    <######## Insert Column comments and documentations here following this model #########>
}
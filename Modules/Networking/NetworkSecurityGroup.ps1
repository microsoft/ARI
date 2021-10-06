<#
.Synopsis
Inventory for Azure Network Security Group

.DESCRIPTION
This script consolidates information for all microsoft.network/NetowrkeecuritytoupowrkeecuritytoupowrkeecuritytoupowrkeecuritytoupowrkeecuritytoupowrkeecuritytoupowrkeecuritytoupowrkeecuritytoupowrkeecuritytoupowrkeecuritytoupowrkeecuritytoupowrkeecuritytoupowrkeecuritytoupowrkeecuritytoupowrkeecuritytoupowrkeecuritytoupowrkeecuritytoupowrkSecurityGoup and resource provider in $Resources variable.
Excel Sheet Name: NetworkeecuritytroupworkeecuritytroupworkeecuritytroupworkeecuritytroupworkeecuritytroupworkeecuritytroupworkeecuritytroupworkeecuritytroupworkeecuritytroupworkeecuritytroupworkeecuritytroupworkeecuritytroupworkeecuritytroupworkeecuritytroupworkeecuritytroupworkeecuritytroupworkeecuritytroupworkSecurityGroup

.Link
https://github.com/azureinventory/ARI/Modules/Networking/NetworkeecuritytroupworkeecuritytroupworkeecuritytroupworkeecuritytroupworkeecuritytroupworkeecuritytroupworkeecuritytroupworkeecuritytroupworkeecuritytroupworkeecuritytroupworkeecuritytroupworkeecuritytroupworkeecuritytroupworkeecuritytroupworkeecuritytroupworkeecuritytroupworkeecuritytroupworkSecurityGroup.ps1

.COMPONENT
   This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 2.0.0
First Release Date: 2021.10.05
Authors: Christopher Lewis

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Task , $File, $SmaResources, $TableStyle)
If ($Task -eq 'Processing') {

    $NSGs = $Resources | Where-Object { $_.TYPE -eq 'microsoft.network/networksecuritygroups' }

    if ($NSGs) {
        $tmp = @()

        foreach ($1 in $NSGs) {
            $ResUCount = 1
            $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
            $data = $1.PROPERTIES
            $Tags = if (![string]::IsNullOrEmpty($1.tags.psobject.properties)) { $1.tags.psobject.properties }else { '0' }
            foreach ($TagKey in $Tags) {
                if ($data.networkInterfaces.count -EQ 0 -and
                    $data.subnets.count -EQ 0) {
                    $Orphaned = $True;
                } else {
                    $Orphaned = $false;
                }

                $obj = @{
                    'Subscription'                 = $sub1.name;
                    'Resource Group'               = $1.RESOURCEGROUP;
                    'Name'                         = $1.NAME;
                    'Location'                     = $1.LOCATION;

                    'Security Rules'               = [string]$data.securityRules.name;
                    'Direction'                    = [string]$data.securityRules.properties.direction;
                    'Access'                       = [string]$data.securityRules.properties.Access;
                    'Priority'                     = [string]$data.securityRules.properties.priority;
                    'Protocol'                     = [string]$data.securityRules.properties.protocol;
                    'Source Address Prefixes'      = [string]$data.securityRules.properties.sourceAddressPrefixes;
                    'Source Address Prefix'        = [string]$data.securityRules.properties.sourceAddressPrefix;
                    'Source Port Ranges'           = [string]$data.securityRules.properties.sourcePortRanges;
                    'Source Port Range'            = [string]$data.securityRules.properties.sourcePortRange;
                    'Destination Address Prefixes' = [string]$data.securityRules.properties.destinationAddressPrefixes;
                    'Destination Address Prefix'   = [string]$data.securityRules.properties.destinationAddressPrefix;
                    'Destination Port Ranges'      = [string]$data.securityRules.properties.destinationPortRanges;
                    'Destination Port Range'       = [string]$data.securityRules.properties.destinationPortRange;
                    'NICs'                         = [string]$data.networkInterfaces.id -Join ",";
                    'Subnets'                      = [string]$data.Subnets.id;
                    'Orphaned'                     = $Orphaned

                    'Tag Name'                     = [string]$Tag.Name;
                    'Tag Value'                    = [string]$Tag.Value
                }
                $tmp += $obj
                if ($ResUCount -eq 1) { $ResUCount = 0 }
            }
        }
        $tmp
    }
} Else {
    # --------------------------------------------------------------------------------
    # the $SmaResources object for a module should be the same as the name of the file.
    #  In this case the file name is "NetworkSecurityGroup.ps1" so the SMA object
    #  is $SmaResources.NetworkSecurityGroup
    # --------------------------------------------------------------------------------
    $ExcelVar = $SmaResources.NetworkSecurityGroup
    if ($ExcelVar) {
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

        #Conditional formats.  Note that this can be $() for none
        $condtxt = $(
            New-ConditionalText true -Range T:T
        )

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('Security Rules')
        $Exc.Add('Direction')
        $Exc.Add('Access')
        $Exc.Add('Priority')
        $Exc.Add('Protocol')
        $Exc.Add('Source Address Prefixes')
        $Exc.Add('Source Address Prefix')
        $Exc.Add('Source Port Ranges')
        $Exc.Add('Source Port Range')
        $Exc.Add('Destination Address Prefixes')
        $Exc.Add('Destination Address Prefix')
        $Exc.Add('Destination Port Ranges')
        $Exc.Add('Destination Port Range')
        $Exc.Add('NICs')
        $Exc.Add('Subnets')
        $Exc.Add('Orphaned')

        if ($InTag) {
            $Exc.Add('Tag Name')
            $Exc.Add('Tag Value')
        }

        $ExcelVar |
        ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc |
        Export-Excel -Path $File -WorksheetName 'Network Security Groups' -AutoSize -MaxAutoSizeRows 100 -TableName 'AzureNetworkSecurityGroups' -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style


        <######## Insert Column comments and documentations here following this model.  See StoraceAcc.ps1 for samples #########>


    }
}

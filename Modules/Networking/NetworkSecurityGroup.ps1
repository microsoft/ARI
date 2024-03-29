<#
.Synopsis
Inventory for Azure Network Security Group

.DESCRIPTION
This script consolidates information for all microsoft.network/Netowrksecuritygroup and resource provider in $Resources variable.
Excel Sheet Name: NetworkSecuritytGroup

.Link
https://github.com/microsoft/ARI/Modules/Networking/NetworkSecurityGroup.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.0.1
First Release Date: 2021.10.05
Authors: Christopher Lewis

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Task , $File, $SmaResources, $TableStyle, $Unsupported)
If ($Task -eq 'Processing') {

    $NSGs = $Resources | Where-Object { $_.TYPE -eq 'microsoft.network/networksecuritygroups' }

    if ($NSGs) {
        $tmp = @()

        foreach ($1 in $NSGs) {
            $ResUCount = 1
            $sub1 = $SUB | Where-Object { $_.Id -eq $1.subscriptionId }
            $data = $1.PROPERTIES
            $RetDate = ''
            $RetFeature = '' 
            $Tags = if (![string]::IsNullOrEmpty($1.tags.psobject.properties)) { $1.tags.psobject.properties }else { '0' }
            foreach ($2 in $data.securityRules)
            {
                foreach ($Tag in $Tags) {
                    if ($data.networkInterfaces.count -eq 0 -and $data.subnets.count -eq 0) 
                    {
                        $Orphaned = $true;
                    } else {
                        $Orphaned = $false;
                    }

                    $obj = @{
                        'ID'                           = $1.id;
                        'Subscription'                 = $sub1.Name;
                        'Resource Group'               = $1.RESOURCEGROUP;
                        'Name'                         = $1.NAME;
                        'Location'                     = $1.LOCATION;
                        'Retirement Date'              = [string]$RetDate;
                        'Retirement Feature'           = $RetFeature;
                        'Security Rules'               = [string]$2.name;
                        'Direction'                    = [string]$2.properties.direction;
                        'Access'                       = [string]$2.properties.Access;
                        'Priority'                     = [string]$2.properties.priority;
                        'Protocol'                     = [string]$2.properties.protocol;
                        'Source Address Prefixes'      = [string]$2.properties.sourceAddressPrefixes;
                        'Source Address Prefix'        = [string]$2.properties.sourceAddressPrefix;
                        'Source Port Ranges'           = [string]$2.properties.sourcePortRanges;
                        'Source Port Range'            = [string]$2.properties.sourcePortRange;
                        'Destination Address Prefixes' = [string]$2.properties.destinationAddressPrefixes;
                        'Destination Address Prefix'   = [string]$2.properties.destinationAddressPrefix;
                        'Destination Port Ranges'      = [string]$2.properties.destinationPortRanges;
                        'Destination Port Range'       = [string]$2.properties.destinationPortRange;
                        'NICs'                         = [string]$data.networkInterfaces.id -Join ",";
                        'Subnets'                      = [string]$data.Subnets.id;
                        'Orphaned'                     = $Orphaned;
                        'Tag Name'                     = [string]$Tag.Name;
                        'Tag Value'                    = [string]$Tag.Value
                    }
                    $tmp += $obj
                    if ($ResUCount -eq 1) { $ResUCount = 0 }
                }
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

        $TableName = ('NSGTable_'+($SmaResources.NetworkSecurityGroup.id | Select-Object -Unique).count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

        #Conditional formats.  Note that this can be $() for none
        $condtxt = @()
        $condtxt += New-ConditionalText TRUE -Range V:V
        $condtxt += New-ConditionalText - -Range E:E -ConditionalType ContainsText

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('Retirement Date')
        $Exc.Add('Retirement Feature')  
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

        $noNumberConversion = @()
        $noNumberConversion += 'Source Address Prefixes'
        $noNumberConversion += 'Source Address Prefix'
        $noNumberConversion += 'Destination Address Prefixes'
        $noNumberConversion += 'Destination Address Prefix'

        $ExcelVar |
        ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc |
        Export-Excel -Path $File -WorksheetName 'Network Security Groups' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style -NoNumberConversion $noNumberConversion


        <######## Insert Column comments and documentations here following this model.  See StoraceAcc.ps1 for samples #########>


    }
}

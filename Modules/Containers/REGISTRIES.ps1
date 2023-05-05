<#
.Synopsis
Inventory for Azure Container Registries instance

.DESCRIPTION
This script consolidates information for all microsoft.containerinstance/containergroups resource provider in $Resources variable. 
Excel Sheet Name: REGISTRIES

.Link
https://github.com/microsoft/ARI/Modules/Compute/CONTAINERREGISTRIES.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 2.3.0
First Release Date: 19th November, 2022
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Task ,$File, $SmaResources, $TableStyle)

If ($Task -eq 'Processing')
{

    <######### Insert the resource extraction here ########>

        $REGISTRIES = $Resources | Where-Object {$_.TYPE -eq 'microsoft.containerregistry/registries'}

    <######### Insert the resource Process here ########>

    if($REGISTRIES)
        {
            $tmp = @()

            foreach ($1 in $REGISTRIES) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $timecreated = $data.creationDate
                $timecreated = [datetime]$timecreated
                $timecreated = $timecreated.ToString("yyyy-MM-dd HH:mm")
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                foreach ($Tag in $Tags) {
                    $obj = @{
                        'ID'                        = $1.id;
                        'Subscription'              = $sub1.Name;
                        'Resource Group'            = $1.RESOURCEGROUP;
                        'Name'                      = $1.NAME;
                        'Location'                  = $1.LOCATION;
                        'SKU'                       = $1.sku.name;
                        'Anonymous Pull Enabled'    = $data.anonymouspullenabled;
                        'Encryption'                = $data.encryption.status;
                        'Public Network Access'     = $data.publicnetworkaccess;
                        'Zone Redundancy'           = $data.zoneredundancy;
                        'Private Link'              = if($data.privateendpointconnections){'True'}else{'False'};
                        'Soft Delete Policy'        = $data.policies.softdeletepolicy.status;
                        'Trust Policy'              = $data.policies.trustpolicy.status;
                        'Created Time'              = $timecreated;
                        'Resource U'                = $ResUCount;
                        'Total'                     = $Total;
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

Else
{
    <######## $SmaResources.(RESOURCE FILE NAME) ##########>

    if($SmaResources.REGISTRIES)
    {
        $TableName = ('ContsTable_'+($SmaResources.REGISTRIES.id | Select-Object -Unique).count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

        $cond = @()

        #Anonymous Pull Enabled
        $cond += New-ConditionalText True -Range F:F

        #Encryption
        $cond += New-ConditionalText disabled -Range G:G

        #Public Network Access
        $cond += New-ConditionalText enabled -Range H:H

        #Zone Redundancy
        $cond += New-ConditionalText disabled -Range I:I

        #Private Link
        $cond += New-ConditionalText False -Range J:J

        #Soft Delete Policy
        $cond += New-ConditionalText disabled -Range K:K

        #Trust Policy
        $cond += New-ConditionalText disabled -Range L:L

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('SKU')
        $Exc.Add('Anonymous Pull Enabled')
        $Exc.Add('Encryption')
        $Exc.Add('Public Network Access')
        $Exc.Add('Zone Redundancy')
        $Exc.Add('Private Link')
        $Exc.Add('Soft Delete Policy')
        $Exc.Add('Trust Policy')
        $Exc.Add('Created Time')  
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.REGISTRIES 
            
        $ExcelVar | 
        ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        Export-Excel -Path $File -WorksheetName 'Registries' -AutoSize -ConditionalText $cond -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -Style $Style

    }
}
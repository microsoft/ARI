<#
.Synopsis
Inventory for Azure Container Registries instance

.DESCRIPTION
This script consolidates information for all microsoft.containerinstance/containergroups resource provider in $Resources variable. 
Excel Sheet Name: REGISTRIES

.Link
https://github.com/microsoft/ARI/Modules/Public/InventoryModules/Container/ContainerRegistries.ps1

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

        $REGISTRIES = $Resources | Where-Object {$_.TYPE -eq 'microsoft.containerregistry/registries'}

    <######### Insert the resource Process here ########>

    if($REGISTRIES)
        {
            $tmp = foreach ($1 in $REGISTRIES) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $timecreated = $data.creationDate
                $timecreated = [datetime]$timecreated
                $timecreated = $timecreated.ToString("yyyy-MM-dd HH:mm")
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
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                foreach ($Tag in $Tags) {
                    $obj = @{
                        'ID'                        = $1.id;
                        'Subscription'              = $sub1.Name;
                        'Resource Group'            = $1.RESOURCEGROUP;
                        'Name'                      = $1.NAME;
                        'Location'                  = $1.LOCATION;
                        'SKU'                       = $1.sku.name;
                        'Retiring Feature'          = $RetiringFeature;
                        'Retiring Date'             = $RetiringDate;
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
                    $obj
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

    if($SmaResources)
    {
        $TableName = ('ContsTable_'+($SmaResources.'Resource U').count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

        $condtxt = @()
        #Anonymous Pull Enabled
        $condtxt += New-ConditionalText True -Range H:H
        #Encryption
        $condtxt += New-ConditionalText disabled -Range I:I
        #Public Network Access
        $condtxt += New-ConditionalText enabled -Range J:J
        #Zone Redundancy
        $condtxt += New-ConditionalText disabled -Range K:K
        #Private Link
        $condtxt += New-ConditionalText False -Range L:L
        #Soft Delete Policy
        $condtxt += New-ConditionalText disabled -Range M:M
        #Trust Policy
        $condtxt += New-ConditionalText disabled -Range N:N
        #Retirement
        $condtxt += New-ConditionalText -Range F2:F100 -ConditionalType ContainsText

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('SKU')
        $Exc.Add('Retiring Feature')
        $Exc.Add('Retiring Date')
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

        [PSCustomObject]$SmaResources | 
        ForEach-Object { $_ } | Select-Object $Exc | 
        Export-Excel -Path $File -WorksheetName 'Registries' -AutoSize -ConditionalText $condtxt -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -Style $Style

    }
}
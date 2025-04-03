<#
.Synopsis
Inventory for Azure Content Moderator

.DESCRIPTION
This script consolidates information for all microsoft.cognitiveservices/accounts and resource provider in $Resources variable. 
Excel Sheet Name: Content Moderator

.Link
https://github.com/microsoft/ARI/Modules/Public/InventoryModules/AI/ContentModerator.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.0
First Release Date: 19th November, 2020
Authors: Claudio Merola
#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Retirements, $Task ,$File, $SmaResources, $TableStyle, $Unsupported)

If ($Task -eq 'Processing')
{

    <######### Insert the resource extraction here ########>

    $ContentModerator = $Resources | Where-Object {$_.TYPE -eq 'microsoft.cognitiveservices/accounts' -and $_.Kind -eq 'ContentModerator'}

    <######### Insert the resource Process here ########>

    if($ContentModerator)
        {
            $tmp = @()

            foreach ($1 in $ContentModerator) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $timecreated = $data.datecreated
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
                $pvt = if(![string]::IsNullOrEmpty($data.privateendpointconnections)){$data.privateendpointconnections}else{'0'}
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($pv in $pvt)
                        {
                            $priv = $pv.split('/')[8]
                            foreach ($Tag in $Tags) {
                                $obj = @{
                                    'ID'                                        = $1.id;
                                    'Subscription'                              = $sub1.Name;
                                    'Resource Group'                            = $1.RESOURCEGROUP;
                                    'Name'                                      = $1.NAME;
                                    'SKU'                                       = $1.sku.name;
                                    'Retiring Feature'                          = $RetiringFeature;
                                    'Retiring Date'                             = $RetiringDate;
                                    'Public Network Access'                     = $data.publicnetworkaccess;
                                    'Creation Time'                             = $timecreated;
                                    'Is Migrated'                               = $data.ismigrated;
                                    'Custom Domain Name'                        = $data.customsubdomainname;
                                    'Endpoint'                                  = $data.endpoint;
                                    'Network Default Action'                    = $data.networkacls.defaultaction;
                                    'IP Rules'                                  = $data.networkacls.iprules.count;
                                    'Virtual Network Rules'                     = $data.networkacls.virtualnetworkrules.count;
                                    'Private Endpoint'                          = $priv;
                                    'Resource U'                                = $ResUCount;
                                    'Tag Name'                                  = [string]$Tag.Name;
                                    'Tag Value'                                 = [string]$Tag.Value
                                }
                                $tmp += $obj
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

        $TableName = ('ContentModTb_'+($SmaResources.'Resource U').count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

        $condtxt = @()
        $condtxt += New-ConditionalText F0 -Range D:D
        #Retirement
        $condtxt += New-ConditionalText -Range E2:E100 -ConditionalType ContainsText
        $condtxt += New-ConditionalText enabled -Range G:G

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('SKU')
        $Exc.Add('Retiring Feature')
        $Exc.Add('Retiring Date')
        $Exc.Add('Public Network Access')
        $Exc.Add('Creation Time')
        $Exc.Add('Is Migrated')
        $Exc.Add('Custom Domain Name')
        $Exc.Add('Endpoint')
        $Exc.Add('Network Default Action')
        $Exc.Add('IP Rules')
        $Exc.Add('Virtual Network Rules')
        $Exc.Add('Private Endpoint')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

            [PSCustomObject]$SmaResources | 
        ForEach-Object { $_ } | Select-Object $Exc | 
        Export-Excel -Path $File -WorksheetName 'Content Moderator' -AutoSize -MaxAutoSizeRows 100 -ConditionalText $condtxt -TableName $TableName -TableStyle $tableStyle -Style $Style

    }
}
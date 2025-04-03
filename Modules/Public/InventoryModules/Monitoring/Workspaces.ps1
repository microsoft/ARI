<#
.Synopsis
Inventory for Azure Log Analytics Workspace

.DESCRIPTION
This script consolidates information for all microsoft.operationalinsights/workspaces and  resource provider in $Resources variable. 
Excel Sheet Name: WrkSpace

.Link
https://github.com/microsoft/ARI/Modules/Public/InventoryModules/Monitoring/Workspaces.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.0
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Retirements, $Task, $File, $SmaResources, $TableStyle, $Unsupported)

If ($Task -eq 'Processing')
{

    <######### Insert the resource extraction here ########>

    $wrkspace = $Resources | Where-Object {$_.TYPE -eq 'microsoft.operationalinsights/workspaces'}

    <######### Insert the resource Process here ########>

    if($wrkspace)
        {
            $tmp = foreach ($1 in $wrkspace) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $timecreated = [string](get-date($data.createdDate))
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
                $Quota = if($data.workspaceCapping.dailyQuotaGb -eq -1){'Off'}else{[string]$data.workspaceCapping.dailyQuotaGb}
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) {
                        $obj = @{
                            'ID'                                        = $1.id;
                            'Subscription'                              = $sub1.Name;
                            'Resource Group'                            = $1.RESOURCEGROUP;
                            'Name'                                      = $1.NAME;
                            'Location'                                  = $1.LOCATION;
                            'SKU'                                       = $data.sku.name;
                            'Retiring Feature'                          = $RetiringFeature;
                            'Retiring Date'                             = $RetiringDate;
                            'Retention Days'                            = $data.retentionInDays;
                            'Daily Cap (GB)'                            = $Quota;
                            'Data Ingestion From Public Networks'       = $data.publicNetworkAccessForIngestion;
                            'Queries From Public Networks'              = $data.publicNetworkAccessForQuery;
                            'Created Time'                              = $timecreated;
                            'Resource U'                                = $ResUCount;
                            'Tag Name'                                  = [string]$Tag.Name;
                            'Tag Value'                                 = [string]$Tag.Value
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

        $TableName = ('WorkSpaceTable_'+($SmaResources.'Resource U').count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0.0'

        $condtxt = @()
        #Retirement
        $condtxt += New-ConditionalText -Range F2:F100 -ConditionalType ContainsText
        $condtxt += New-ConditionalText enabled -Range J:J
        $condtxt += New-ConditionalText enabled -Range K:K
        $condtxt += New-ConditionalText '0.' -Range I:I

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('SKU')
        $Exc.Add('Retiring Feature')
        $Exc.Add('Retiring Date')
        $Exc.Add('Retention Days')
        $Exc.Add('Daily Cap (GB)')
        $Exc.Add('Data Ingestion From Public Networks')
        $Exc.Add('Queries From Public Networks')
        $Exc.Add('Created Time')  
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $noNumberConversion = @()
        $noNumberConversion += 'Daily Cap (GB)'

        [PSCustomObject]$SmaResources | 
        ForEach-Object { $_ } | Select-Object $Exc | 
        Export-Excel -Path $File -WorksheetName 'Workspaces' -AutoSize -MaxAutoSizeRows 100 -ConditionalText $condtxt -TableName $TableName -TableStyle $tableStyle -Style $Style -NoNumberConversion $noNumberConversion

    }
}
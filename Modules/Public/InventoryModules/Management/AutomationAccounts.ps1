<#
.Synopsis
Inventory for Azure Automation Account

.DESCRIPTION
This script consolidates information for all microsoft.automation/automationaccounts and  resource provider in $Resources variable. 

.Link
https://github.com/microsoft/ARI/Modules/Public/InventoryModules/Management/AutomationAccounts.ps1

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

        $runbook = $Resources | Where-Object {$_.TYPE -eq 'microsoft.automation/automationaccounts/runbooks'}
        $autacc = $Resources | Where-Object {$_.TYPE -eq 'microsoft.automation/automationaccounts'}

    <######### Insert the resource Process here ########>

    if($autacc)
        {
            $tmp = foreach ($0 in $autacc) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.Id -eq $0.subscriptionId }
                $rbs = $runbook | Where-Object { $_.id.split('/')[8] -eq $0.name }
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                $data0 = $0.properties
                $timecreated = $data0.creationTime
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
                if ($null -ne $rbs) {
                    foreach ($1 in $rbs) {
                            foreach ($Tag in $Tags) {    
                                $data = $1.PROPERTIES
                                $obj = @{
                                    'ID'                                = $1.id;
                                    'Subscription'                      = $sub1.Name;
                                    'Resource Group'                    = $0.RESOURCEGROUP;
                                    'Automation Account Name'           = $0.NAME;
                                    'Retiring Feature'                  = $RetiringFeature;
                                    'Retiring Date'                     = $RetiringDate;
                                    'Automation Account State'          = $0.properties.State;
                                    'Automation Account SKU'            = $0.properties.sku.name;
                                    'Automation Account Created Time'   = $timecreated;   
                                    'Location'                          = $0.LOCATION;
                                    'Runbook Name'                      = $1.Name;
                                    'Last Modified Time'                = ([datetime]$data.lastModifiedTime).tostring('MM/dd/yyyy hh:mm') ;
                                    'Runbook State'                     = $data.state;
                                    'Runbook Type'                      = $data.runbookType;
                                    'Runbook Description'               = $data.description;
                                    'Resource U'                        = $ResUCount;
                                    'Tag Name'                          = [string]$Tag.Name;
                                    'Tag Value'                         = [string]$Tag.Value
                                }
                                $obj
                                if ($ResUCount -eq 1) { $ResUCount = 0 } 
                            }                        
                    }
                }
                else {
                        foreach ($Tag in $Tags) {  
                            $obj = @{
                                'ID'                                = $1.id;
                                'Subscription'                      = $sub1.name;
                                'Resource Group'                    = $0.RESOURCEGROUP;
                                'Automation Account Name'           = $0.NAME;
                                'Retiring Feature'                  = $RetiringFeature;
                                'Retiring Date'                     = $RetiringDate;
                                'Automation Account State'          = $0.properties.State;
                                'Automation Account SKU'            = $0.properties.sku.name;
                                'Automation Account Created Time'   = $timecreated;   
                                'Location'                          = $0.LOCATION;
                                'Runbook Name'                      = $null;
                                'Last Modified Time'                = $null;
                                'Runbook State'                     = $null;
                                'Runbook Type'                      = $null;
                                'Runbook Description'               = $null;
                                'Resource U'                        = $ResUCount;
                                'Tag Name'                          = [string]$Tag.Name;
                                'Tag Value'                         = [string]$Tag.Value
                            }
                            $obj
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

        $TableName = ('AutAccTable_'+($SmaResources.'Resource U').count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'
        $StyleExt = New-ExcelStyle -HorizontalAlignment Left -Range K:K -Width 80 -WrapText 

        $condtxt = @()
        #Retirement
        $condtxt += New-ConditionalText -Range D2:D100 -ConditionalType ContainsText

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Automation Account Name')
        $Exc.Add('Retiring Feature')
        $Exc.Add('Retiring Date')
        $Exc.Add('Automation Account State')
        $Exc.Add('Automation Account SKU')
        $Exc.Add('Automation Account Created Time')
        $Exc.Add('Location')
        $Exc.Add('Runbook Name')
        $Exc.Add('Last Modified Time')
        $Exc.Add('Runbook State')
        $Exc.Add('Runbook Type')
        $Exc.Add('Runbook Description')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        [PSCustomObject]$SmaResources | 
        ForEach-Object { $_ } | Select-Object $Exc | 
        Export-Excel -Path $File -WorksheetName 'Runbooks' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style, $StyleExt

    }
}